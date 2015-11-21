'use strict'

EventDetailCtrl = ($scope, $rootScope, $q, $timeout, $state, $stateParams
  $location, $ionicScrollDelegate, $ionicModal
  $log, toastr, exportDebug
  EventsResource, UsersResource, MenuItemsResource
  EventActionHelpers, AAAHelpers
  ParticipationsResource, ContributionsResource, TokensResource
  appModalSvc, geocodeSvc
  utils, devConfig
  ionicMaterialMotion, ionicMaterialInk
  ) ->
    vm = this
    vm.me = null
    vm.title = "Event Detail"
    vm.event = { ready: false }
    vm.lookup = {}
    exportDebug.set( 'lookup', vm['lookup'] )
    vm.imgAsBg = utils.imgAsBg
    vm.isDev = utils.isDev

    ###
    # @description set address & location labels by ACL, mask values for visitors
    # @param event object
    # @param user object
    # @return event.object with the following fields
    #         event.visibleAddress
    #         event.visibleLocation
    # # TODO: hide event.address, event.location from JS introspection,
    #         reload values on `event:participant-changed`
    ###
    setVisibleLocation = (event, user) ->
      userid = (user || vm.me || {}).id
      event.visibleAddress = event.neighborhood
      participantIds = _.pluck vm.lookup['Participations'], 'participantId'
      showExactLocation = userid && ~participantIds?.indexOf(userid)
      showExactLocation = true if event.setting?['allowPublicAddress']
      if showExactLocation
        # add complete address
        event['visibleAddress'] = event.address
        # event['visibleLocation'] = event.location
        event['visibleMarker'] = event.location
      else
        # mask event.location
        event['visibleLocation'] = utils.maskLatLon(event.location, event.title)
      return event

    vm.getLabel_MenuItemCategory = MenuItemsResource.getCategoryLabel

    vm.isInvitation = ()->
      return !!$state.params.invitation

    isInvitationRequired = (event)->
      return $q.when()
      .then ()->
        return true if $state.is('app.event-detail.invitation')
        if event.setting['isExclusive'] || $state.params.invitation
          return TokensResource.isValid($state.params.invitation, 'Event', event.id)
      .catch (result)->
        $log.info "Token check, value="+result
        toastr.info "Sorry, this event is by invitation only." if result=='INVALID'
        if result=='EXPIRED'
          toastr.warning "Sorry, this invitation has expired. Please contact the host for another."
        return $q.reject(result)


    ###
    # @description get Participation in event from current user, vm.me == $rootScope.user
    # @param user object, either user instanceOf UsersResource object, or
    #         user.participation instanceOf ParticipationsResource
    ###
    vm.getParticipationByUser = (user)->
      # TODO: memo result in vm.lookup
      return null if !user
      participation = _.find vm.lookup['Participations'], {participantId: user.id}
      participation = user.participation if !participation  # the case of anonymous participation
      return null if !participation
      # TODO: link contribution to participation.id, not user.id
      participation.contributionIds = []
      if participation.response == 'Yes'
        contributions = _.filter vm.lookup['Contributions'], {contributorId: user.id}
        participation.contributionIds = _.pluck contributions, 'id'
      return participation

    vm.getContributionsByMenuItem = (event, menuItem)->
      return [] if !menuItem
      # filter only 'Yes' participation.responses
      yesParticipantIds = _.chain vm.getParticipationsByEvent(event, 'Yes')
        .pluck 'participantId'
        .value()
      contributions = _.filter vm.lookup['Contributions'], (o)->
        return false if !~yesParticipantIds.indexOf o.contributorId
        return true if o.menuItemId == menuItem.id
      return contributions

    vm.getParticipationsByEvent = (event, response, sort)->
      return [] if !event || !event['ready']
      if event.setting['denyParticipantList'] && vm.acl.isOwner()==false
        return []
      if event.setting['denyMaybeNoResponseList'] && vm.acl.isOwner()==false
        return [] if response != "Yes"


      participations = _.chain(event.participationIds)
      .map (id)-> return vm.lookup['Participations'][id]
      .compact()
      participations = participations.filter({'response':response}) if /Yes|Maybe|No/.test response
      if sort
        sortOrder = {'Yes':0, 'Maybe':1, 'No':2}
        participations = participations.sortBy (o)->
          return sortOrder[o.response]
      return participations.value()

    vm.lookupByClass = (event, className, idOrArray)->
      if !(event?.id?) || !idOrArray
        return if _.isArray idOrArray then [] else false
      if _.isArray idOrArray
        check = _.chain( idOrArray )
          .map( (id)-> return vm.lookup[ className ][id] )
          .value()
        return check
      else
        return vm.lookup[ className ][idOrArray]

      

    vm.acl = {
      debounced:
        isParticipant_ALL: _.debounce( ()->
          return vm.acl.isParticipant()
        , 300 , {
          leading: true
          maxWait: 300
          trailing: false
        })
        isParticipant_YES: _.debounce( ()->
          return vm.acl.isParticipant('Yes')
        , 300 , {
          leading: true
          maxWait: 300
          trailing: false
        })

      isAnonymous: AAAHelpers.isAnonymous

      isVisitor: ()-> ## has not responded to or joined event
        return true if AAAHelpers.isAnonymous()
        return vm.acl.isParticipant() == false
    
      isParticipant: (responseType)->
        return false if _.isEmpty $rootScope['user']
        participations = _.chain(vm.lookup['Participations'])
        participations = participations.filter({response:responseType}) if responseType
        participantIds = participations.pluck('participantId').compact().value()
        return true if ~participantIds.indexOf($rootScope['user'].id)
        return true if vm.acl.isOwner()
        # handle anonymous response participation
        anonResp = $rootScope['user'].participation?.response
        return false if !anonResp
        return true if !responseType || anonResp == responseType
        return false

      isContributor: ()->
        return false if _.isEmpty $rootScope.user
        $log.warn "isContributor() fix to consider if participation.response=='Yes'"
        return true if _.pluck(vm.lookup['Contributions'],'contributorId')
        .indexOf($rootScope.user.id) > -1
        # return vm.event?.contributorIds?.indexOf($rootScope.user.id) > -1
        return false

      isOwner: ()->
        return false if _.isEmpty $rootScope.user
        return false if vm.event.ready == false
        return vm.event.ownerId == $rootScope.user.id
    }

    vm.settings = {
      view:
        menu: 'less'   # [less|more|contribute]
        response: 'Yes'  # [Yes|Maybe|No]
    }

    vm.on = {
      testGeocode: (address)->
        return geocodeSvc.getLatLon(address)
        .then (result)->
          toastr.info result
          return

      refresh: ()->
        event = vm.event
        getDerivedValues_Event(event)
        getDerivedValues_MenuItems(event)
        $timeout ()->
          $scope.$broadcast('scroll.refreshComplete')
        , 1000

      scrollTo: (anchor)->
        $location.hash(anchor)
        $ionicScrollDelegate.anchorScroll(true)
        return

      notReady: (value)->
        toastr.info "Sorry, " + value + " is not available yet"
        return false

      menuView: (value, peek=false)->
        values = ['less','more','contribute','less']
      
        switch value
          when 'next'
            i = _.indexOf values, vm.settings.view.menu
          when 'contribute'
            i = 1
          else
            i = value

        next = i + 1
        if values[next] == 'contribute'
          if !vm.event.summary # not ready
            return vm.on.menuView(next, peek) # skip
          if vm.acl.debounced.isParticipant_YES() == false
            return vm.on.menuView(next, peek) # skip
          if vm.event.summary.myParticipation.isFullyParticipating
            if value == 'next'
              return vm.on.menuView(next, peek) # skip unless forced
        return values[next] if peek

        if value == 'contribute'
          toastr.info "Contribute a suggested Menu Item or add a new one."
        vm.settings.view.menu = values[next]
        utils.ga_Send(
          'send', 'event', 'engagement', 'menu', 'menu-view:' + vm.settings.view.menu, 2)
        $timeout ()->  vm.on.scrollTo('menu')
        return

      participantView: (value, peek)->
        values = ['Yes','Maybe','No','Yes']
        switch value
          when 'next'
            i = _.indexOf values, vm.settings.view.response
          else
            i = value
        next = i+1
        return values[next] if peek
        return vm.settings.view.response = values[next]



      gotoState : (state, field, obj)->
        return if !obj
        params = {}
        params[field] = obj[field]
        switch state
          when 'app.menu-item'
            params['menu'] = vm.event.menuItemIds.join(',')
            params['id'] = params['menu'][0] if obj=='first'
            utils.ga_Send('send', 'event'
              , 'engagement', 'menu-item', 'event:' + vm.event.id, 2)
        $state.transitionTo state, params
        return

      'getShareLink': ()->EventActionHelpers.getShareLink.apply(vm, arguments)
      'showShareLink': ()->EventActionHelpers.showShareLink.apply(vm, arguments)

      'showSignIn': (initialSlide)->
        $log.warn "deprecate EventDetailCtrl.showSignIn(), moved to EventActionHelpers"
        return EventActionHelpers.showSignIn.apply(vm, arguments)


      'beginResponse': ()->
        return EventActionHelpers.beginResponse.apply(vm, arguments)
     
      # called by button.JoinEvent
      # or do is this action for joinEvent w/o invitation?
      'beginBooking': (person, event)->
        return EventActionHelpers.beginBooking.apply(vm, arguments)


      'beginContribute': (mitem, category)->
        return EventActionHelpers.beginContribute.apply(vm, arguments)

      updateSettings: (setting, isPublic)->
        fields = []
        fields.push 'setting' if setting?
        fields.push 'isPublic' if isPublic?
        data = _.pick vm.event, fields
        EventsResource.put(vm.event.id, data).then (result)->
          $log.info "Event updated, result=" + JSON.stringify _.pick result, fields

      ###
      # @description show edit event modal and handle response
      # called by button.ion-plus in app.events
      ###
      editEvent: (copyEvent)->
        # vm = this
        owner = vm.me
        EVENT_TYPE = 'Potluck'
        return $q.reject('MISSING EVENT') if !copyEvent
        return $q.when()
        .then ()->
          # must be user
          if _.isEmpty owner
            return AAAHelpers.showSignInRegister.call(vm, 'signin')
            .then (result)-> # closeModal(result)
              return $q.reject('CANCELED') if `result==null` || result == 'CANCELED'
              return $q.reject(result) if result?['isError']
              return result
            .then (result)->
              _.extend owner, result

        .then ()->
          return $q.reject('NO PRIVILEGE') if owner.id != copyEvent.ownerId

          utils.ga_PageView($location.path() + '/edit' , 'app.event.edit')
          # get a fresh copy of event
          return EventsResource.get(copyEvent.id)

        .then (blankEvent)->
          return $q.reject('NO EVENT IN DB') if _.isEmpty blankEvent

          blankEvent.latlon = blankEvent.location?.join(',')
          if blankEvent.startTime
            blankEvent.startTime = new Date(blankEvent.startTime)
          # coffeelint: disable=max_line_length

          # lookups for form select options
          vm.lookup['select'] = {
            'MenuItemCategories' : MenuItemsResource.categoryLookup
          }
          _.extend vm.lookup['select'], EventsResource.selectOptions

          menuCategoryOptions = []
          _.each MenuItemsResource.categoryLookup, (value, key)->
            menuCategoryOptions.push {
              id: key
              value: value
              selected:
                if blankEvent.menu?.allowCategoryKeys?
                then blankEvent.menu.allowCategoryKeys.indexOf(key) > -1
                else true
            }
            return

          menuCategorySelected = _.chain(menuCategoryOptions)
          .filter({selected:true}).pluck('value').value().join(', ')

          modalModel = {
            action: "Edit"
            event: blankEvent
            eventType: EVENT_TYPE
            owner: owner
            select: vm.lookup['select']
            menuCategoryOptions: menuCategoryOptions
            menuCategoryParseSelected: (options)->
              options = modalModel.menuCategoryOptions if !options
              selected = _.reduce options, (result, o)->
                result[o.id] = o.value if o.selected
                return result
              , {}
              # $log.info selected
              modalModel.menuCategorySelected = _.values( selected ).join(', ')
              return selected
            menuCategorySelected: menuCategorySelected

            # for setting startTime, duration
            when: # initialize values
              startDate: blankEvent.startTime
              startTime: blankEvent.startTime
              endTime: moment(blankEvent.startTime).add(blankEvent.duration,'millisecond').toDate()
              asString: moment(blankEvent.startTime).format('ddd, MMM Do YYYY, h:mm a')

            updateWhen: ()->
              newV = modalModel.when
              event = modalModel.event
              dateTimeString = [
                moment(newV.startDate).format('YYYY-MM-DD')
                moment(newV.startTime).format('HH:mm')
              ].join(' ')
              event.startTime = new Date(dateTimeString)
              newV.startDate = newV.startTime = event.startTime
              nextDay = moment(event.startTime).add(1,'day').startOf('day')
              if newV.startDate <= newV.endTime && newV.endTime < nextDay
                'skip'
              else if newV.endTime.getHours() < 6 # assume it is the next morning
                nextDay.hour(newV.endTime.getHours()).minute(newV.endTime.getMinutes())
                newV.endTime = nextDay.toDate()
              else
                newV.endTime = moment(newV.startDate).toDate()
              event.duration = newV.endTime - newV.startTime
              return

            geocodeAddress: (event)->
              return geocodeSvc.getLatLon( event.address )
              .then (result)->
                return event if result == 'CANCELED'
                if result == 'NOT FOUND'
                  # show message
                  toastr.info "No locations were found for that address. Please try again."
                  return event
                event.address = result.address
                event.location = result.location
                event.latlon = event.location.join(',')
                event.locateAddress = false
                return event


            submitEvent: (event, onSuccess)->
              # sanity checks

              # data cleanup
              return $q.when(event)
              .then (event)->
                return modalModel.geocodeAddress(event) if event.locateAddress == true
                return modalModel.geocodeAddress(event) if _.isEmpty event.location
                return event
              .then (event)->
                event.setting['rsvpFriendsLimit'] = parseInt event.setting['rsvpFriendsLimit']
                event.menu ?= {}
                event.menu['allowCategoryKeys'] = _.keys modalModel.menuCategoryParseSelected()

                updateEvent.call(vm, event).then (result)->
                  utils.ga_Send('send', 'event', 'participation', 'edit', 'event', 10)
                  onSuccess?(result)
                  return result
                return
          }

          return appModalSvc.show('events/event-new.modal.html', vm, {
            mm: modalModel
            test: ()->
              console.log "I am here"
          })

    }

    initialize = ()->
      # dev
      DEV_USER_ID = null # '0'
      devConfig.loginUser( DEV_USER_ID , false).then (user)->
        vm.me = $rootScope.user
        vm.settings.view.menu = 'more' if vm.acl.isParticipant('Yes')
      return

    getEvent = (id) ->
      return EventsResource.get(id).then (result)->
        # toastr.info JSON.stringify( result)[0...50]
        return result

    getEventUsers = (event)->
      UsersResource.get( event.ownerId )
      .then (result)->
        # ownerId => host
        vm.lookup['Users'] = {}
        vm.lookup['host'] = vm.lookup['Users'][event.ownerId] = result
        # toastr.info JSON.stringify( result )[0...50]
        return event

    getContributions = (event)->
      # using contributors join table
      ContributionsResource.query({ 'eventId' : event.id })
      .then (result)->
        event.contributionIds = _.pluck result, 'id'
        vm.lookup['Contributions'] = _.indexBy result, 'id'
        return event
      .then (event)->
        event.contributorIds = _.chain vm.lookup['Contributions']
          .pluck 'contributorId'
          .compact().uniq().value()

        # sanity check
        participantIds = _.pluck vm.lookup['Participations'], 'participantId'
        error = _.difference(event.contributorIds, participantIds)
        toastr.warning "WARNING: found a contributor who is not a participant" if error.length
      #   UsersResource.get( event.contributorIds )
      # .then (result)->
      #   _.extend vm.lookup['Users'], _.indexBy result, 'id' # redundant, see getParticipations()
        return event

    getMenuItems = (event)->
      event.menuItemIds = _.chain( vm.lookup['Contributions'] )
        .pluck( 'menuItemId' ).compact().uniq().value()
      MenuItemsResource.get( event.menuItemIds )
      .then (result)->
        # ownerId => host
        sortedMenuItems = MenuItemsResource.sortByCategory(result)
        event.menuItemIds = _.pluck sortedMenuItems, 'id'
        vm.lookup['MenuItems'] = _.indexBy result, 'id'
        # toastr.info JSON.stringify( result )[0...50]
        return event

    getParticipations = (event)->
      # Yes|Maybe|No participants
      ParticipationsResource.query({ 'eventId' : event.id })
      .then (result)->
        event.participationIds = _.pluck result, 'id'
        vm.lookup['Participations'] = _.indexBy result, 'id'
        return event
      .then (event)->
        participantIds = _.chain(vm.lookup['Participations']).pluck('participantId').compact().value()
        UsersResource.get( participantIds )
      .then (result)->
        _.extend vm.lookup['Users'], _.indexBy result, 'id'
        return event



    ###
    @description: summarize event statistics based on vm.lookup cached values
      NOTE: remember to update vm.lookup cached values on Resty.put()/post()
    ###
    getDerivedValues_Event = (event)->
      summary = {
        countdown: ''
        booking:
          seats: 0
          seatsPct: 0
          parties: 0         # count of indivivdual parties aka participants        contributors: 0
        views:
          count: 0
        response:
          Yes: 0
          Maybe: 0
          No: 0
        participation:
          contributors: 0
          contributorsPct: 0
          menuItems: 0
          menuItemContributions: 0
          menuItemContributionsPct: 0
          portions: 0
          portionsPct: 0
        myParticipation:
          isFullyParticipating: false
          portions: 0
          portionsPct: 0
      }

      # filter for Yes participants
      yesParticipantIds = []

      # public stats
      summary['countdown'] = moment(event.startTime).fromNow()

      _.each vm.lookup['Participations'], (o)->
        return if o.eventId != event.id
        summary.response[o.response] += parseInt(o.seats || 1)
        if o.response == 'Yes'
          summary.booking['seats'] += parseInt o.seats
          yesParticipantIds.push o.participantId
        return
      summary.booking['parties'] = yesParticipantIds.length
      summary.booking['seatsPct'] = Math.round( summary.booking['seats']/event.seatsTotal * 100 )
      event.seatsOpen = Math.max(0, event.seatsTotal - summary.booking['seats'])

      # myParticipation, any response
      vm.lookup['MyParticipation'] = vm.getParticipationByUser(vm.me)
      if vm.lookup['MyParticipation']
        myParticipation = summary['myParticipation']
        myParticipation['isFullyParticipating'] = false

      if vm.lookup['MyParticipation']?.contributionIds.length
        # myParticipation = summary['myParticipation']
        _.each vm.lookup['MyParticipation'].contributionIds, (id)->
          myParticipation['portions'] += parseInt vm.lookup['Contributions'][id].portions
          return
        myParticipation['portionsPct'] =
          Math.round( myParticipation['portions'] /
            (vm.lookup['MyParticipation']['seats'] * event.seatsTotal) * 100
          )
        if myParticipation['portionsPct'] > 85
          myParticipation['isFullyParticipating'] = true

      if vm.lookup['MyParticipation']  # stats are visible to any Participant
        yesContributions = _.reduce vm.lookup['Contributions'], (result, o)->
          # filter out participation.response != 'Yes'
          result.push o if ~yesParticipantIds.indexOf o.contributorId
          return result
        ,[]

        participation = summary['participation']
        participation['menuItems'] = _.chain(vm.lookup['Contributions'])
          .pluck( 'menuItemId').uniq().value().length
       
       
        _.each yesContributions, (o)->
          # return if !o.contributorId?   # mitem with no contributor
          # ignore if contributor changed response, not coming
          participation['menuItemContributions'] += 1
          participation['portions'] += parseInt o.portions
          return
        participation['contributors'] = _.chain(yesContributions)
          .pluck('contributorId').uniq().value().length
        participation['contributorsPct'] =
          Math.round( participation['contributors'] / summary.booking['parties'] * 100 )
        participation['menuItemContributionsPct'] =
          Math.round( participation['menuItemContributions'] /
            participation['menuItems'] * 100 )
        participation['portionsPct'] =
          Math.round( participation['portions'] /
            (participation['menuItems'] * event.seatsTotal) * 100
          )

      event.summary = {} if !event.summary
      _.extend event.summary, summary
      return event

    ###
    @description summarize portions & contribution status for each MenuItem
    @return distribution of portions by MenuItem.category
    ###
    getDerivedValues_MenuItems = (event)->
      # TODO: move to a better location
      yesParticipantIds = _.chain vm.getParticipationsByEvent(event, 'Yes')
        .pluck 'participantId'
        .value()
      # Contributions indexBy MenuItemId

      vm.lookup['MenuItemContributions'] = _.reduce vm.lookup['Contributions'], (result, contrib)->
        return result if contrib.eventId != event.id
        result[contrib.menuItemId] = result[contrib.menuItemId] || []
        return result if !contrib.contributorId   # mitem with no contributor
        return result if !~yesParticipantIds.indexOf contrib.contributorId
        result[contrib.menuItemId].push contrib
        return result
      , {}

      # portionsByMenuItemId = _.reduce vm.lookup['MenuItemContributions'], (result, contrib)->
      #   return result if contrib.eventId != event.id
      #   return result if !contrib.contributorId
      #   result[contrib.menuItemId] = result[contrib.menuItemId] || 0
      #   result[contrib.menuItemId] += parseInt contrib.portions
      #   return result
      # , {}

      distribution = {
        total: 0
        count: {}
        pct: {}
      }
      # initialize Categories, as necessary
      if event.menu?.allowCategoryKeys
        _.each event.menu.allowCategoryKeys, (key)-> distribution.count[key] = 0

      _.each event.menuItemIds, (id)->
        required = _.reduce vm.lookup['Contributions'], (result, o)->
          return result if o.menuItemId != id || !o.portionsRequired
          return result = Math.max(result||0, o.portionsRequired)
        , null
        mi = vm.lookup['MenuItems'][id]
        mi.summary = {
          portions: 0
          portionsPct: 0
          # TODO: need to be able to set portionsRemaining to something less than seatsTotal
          portionsRequired: required || event.seatsTotal
          portionsRemaining: null  # derived below
          isContributed: false
        }

        mi.summary['portions'] = _.reduce vm.lookup['MenuItemContributions'][mi.id]
        , (result, contrib)->
          return result += parseInt contrib.portions
        , 0

        # summary portions by menuItem.category, i.e. Starter, Main, etc.
        if mi.summary['portions']
          distribution.count[mi['category']] = 0 if `distribution.count[mi['category']]==null`
          distribution.count[mi['category']] += mi.summary['portions']
          distribution.total += mi.summary['portions']

        mi.summary['portionsRemaining'] =
          Math.max(mi.summary['portionsRequired'] - mi.summary['portions'], 0)
        mi.summary['portionsPct'] =
          Math.round( mi.summary['portions'] /
            (mi.summary['portionsRequired']) * 100
          )
        if mi.summary['portionsPct'] > 85
          mi.summary['isContributed'] = true
        return

      _.each distribution.count, (v,k)->
        distribution.pct[k] = Math.round( v / distribution.total * 100 )
        return

      return distribution

    vm.createBooking = (options)->
      $log.warn "deprecate EventDetailCtrl.createBooking(), moved to EventActionHelpers"
      return EventActionHelpers.createBooking.apply(vm, arguments)

    createContribution = (options)->
      $log.warn "deprecate EventDetailCtrl.createContribution(), moved to EventActionHelpers"
      return EventActionHelpers.createContribution.apply(vm, arguments)

    createMenuItem = (menuItem)->
      $log.warn "deprecate EventDetailCtrl.createMenuItem(), moved to EventActionHelpers"
      return EventActionHelpers.createMenuItem.apply(vm, arguments)

    updateEvent = (event)->
      return $q.reject "NO PRIVILIGE" if !vm.acl.isOwner()
      return $q.reject "EVENT DATA ERROR" if event.id != vm.event.id
      return $q.when()
      .then ()->
        EventsResource.put(event.id, event)
      .then (result)->
        $log.info "Event Updated, result="+JSON.stringify result
        return result
      .then ()->
        activate()

     
    activate = ()->
      getData()
      # // Set Ink
      ionicMaterialInk.displayEffect()
      setMaterialEffects()

    getMap = (event)->
      if useStaticMap=true
        mapSrc = "https://maps.googleapis.com/maps/api/staticmap?"
        params = {}
        params['size'] = "400x400"
        params['markers'] = event.visibleMarker.join(',') if event.visibleMarker?
        qs = _.map (v, k)-> [k,v].join("=")
        mapSrc += encodeURIComponent(qs.join('&'))
        $log.info("Static Map=" + mapSrc)

      location = event.visibleMarker || event.visibleLocation
      mapConfig = geocodeSvc.getMapConfig {
        id: event.id
        location: location
        type: if event.visibleMarker then 'marker' else 'circle'
        draggableMap: false
        draggableMarker: vm.acl.isOwner()
        dragendMarker: (marker, eventName, args)->
          location = [marker.getPosition().lat(), marker.getPosition().lng()]
          $log location
          return
      }

      if location?
        $timeout ()->
          event.map = mapConfig
          return
         , 3000
      return event

    getData = () ->
      return $q.when()
      .then ()->
        if !$state.params.id
          eventId = null
          # BUG: $stateParams.invitation != $state.params.invitation
          return $q.reject('MISSING_ID') if !$state.params.invitation
          return TokensResource.get($state.params.invitation)
          .then (token)->
            # return $q.reject('INVALID') if !token
            [className, eventId] = token?.target.split(':')
            return TokensResource.isValid(token, 'Event', eventId)
          .then ()->
            return eventId
          .catch (err)->
            if err=='EXPIRED'
              toastr.warning "Sorry, this invitation has expired. " +
              "Please contact the host for another."
            if err=='INVALID'
              toastr.warning "Sorry, this event is by invitation only"
            return $q.reject(err)
        return eventId = $state.params.id
      .catch (err)->
        $rootScope.goBack('app.events')
        return $q.reject()
      .then (eventId)->
        vm.event['ready'] = false
        vm.lookup['Participations']
        vm.lookup['Contributions']
        return getEvent(eventId)
      .then (event)->
        vm.event = event
        exportDebug.set( 'event', vm['event'] )
        return event
      .then (event)->
        getEventUsers(event)
      .then (event)->
        getParticipations(event)
      .then (event)->
        getContributions(event)
      .then (event)->
        allowCategoryKeys = event.menu?.allowCategoryKeys
        vm.lookup['MenuItemCategories'] =
          if allowCategoryKeys
          then _.pick MenuItemsResource.categoryLookup, allowCategoryKeys
          else MenuItemsResource.categoryLookup
        getMenuItems(event)
      .then (event)->
        getDerivedValues_Event(event)
        vm.event['ready'] = true
        event.summary['distribution'] = getDerivedValues_MenuItems(event)
        return event
      .then (event)->
        # TODO: reset on 'event:participant-changed'
        setVisibleLocation(event)
        getMap(event)
        return event


    setMaterialEffects = () ->
      # Set Motion
      $timeout ()->
        ionicMaterialMotion.slideUp({
          selector: '.animate-slide-up'
        })
        return
      , 300

      # $timeout () ->
      #   ionicMaterialMotion.fadeSlideInRight({
      #     startVelocity: 3000
      #   })
      #   return
      # , 700
    
      # $timeout () ->
      #   ionicMaterialMotion.blinds({
      #     startVelocity: 3000
      #   })
      #   return
      # , 700
      return


    # toastr.info "Creating EventDetailCtrl"

    $scope.$on 'event:participant-changed', (ev, participant)->
      if participant && participant.eventId == vm.event.id
        participation = vm.lookup['Participations'][participant.id]
        isNewParticipant = !participation
        # update lookups
        if isNewParticipant
          if !~vm.event['participationIds'].indexOf(participant.id)
            vm.event['participationIds'].push participant.id
          vm.lookup['Participations'][participant.id] = participant
          if !vm.lookup['Users'][participant.participantId]
            # load user data
            skip = UsersResource.get(participant.participantId)
            .then (user)->
              vm.lookup['Users'][user.id] = user
              return
        else
          isResponseChanged =  participant.response != participation.response
          _.extend participation, participant  # update lookup
          if isResponseChanged
            if participation.response != 'Yes'
              delete vm.lookup['MyParticipation']
            $scope.$broadcast 'event:contribution-changed'
            return

      event = vm.event
      getDerivedValues_Event(event)
      # getDerivedValues_MenuItems(event)
      # push notification to host + participants
      return

    $scope.$on 'event:contribution-changed', (ev, options)->
      event = vm.event
      getDerivedValues_Event(event)
      event.summary['distribution'] = getDerivedValues_MenuItems(event)
      # push notification to host + participants
      return
   

    $scope.$on '$ionicView.loaded', (e) ->
      $log.info "viewLoaded for EventDetailCtrl"
      initialize()

    $scope.$on '$ionicView.enter', (e) ->
      $log.info "viewEnter for EventDetailCtrl"
      activate()

    $scope.$on '$ionicView.leave', (e) ->
      $log.info "viewLeave for EventDetailCtrl"



    $rootScope.$on 'user:sign-in', (ev, user)->
      return if vm.event.ready == false
      activate() # reload data

    $rootScope.$on 'user:sign-out', ()->
      vm.me = $rootScope.user
      return

      #ready
      vm.me = $rootScope.user

      # TODO: fire 'event:participant-changed'
      vm.lookup['Users'][vm.me.id] = vm.me

      $q.when(vm.event)
      .then (event)->
        getDerivedValues_Event(event)
        return event
      .then (event)->
        # TODO: reset on 'event:participant-changed'
        setVisibleLocation(event)
        getMap(event)
        return event



    $scope.dev = {
      settings:
        show: 'less'
      on:
        selectUser: ()->
          UsersResource.query()
          .then (result)->
            vm.people = _.indexBy result, 'id'
            $scope.dev.settings.show = 'admin'
            $timeout ()-> vm.on.scrollTo('admin-change-user')
            return
        loginUser: (person)->
          devConfig.loginUser( person.id )
          .then (user)->   # sets $rootScope.user
            vm.me = $rootScope.user
            toastr.info "You are now " + person.displayName
            $scope.dev.settings.show = 'less'
            return user
          .then ()->
            # getDerivedValues_Event(event)
            # getDerivedValues_MenuItems(event)
            activate()
            $timeout ()-> vm.on.scrollTo()
            return
        getRoleLabel: (person)->
          return 'Host' if person.id == vm.event.ownerId
          return 'Contributor' if ~vm.event.contributorIds.indexOf person.id
          participantIds = _.chain(vm.lookup['Participations'])
          .pluck('participantId').compact().value()
          return 'Participant' if ~participantIds.indexOf person.id
          return 'Visitor'
    }
    
    return vm # # end EventDetailCtrl,  return is required for controllerAs syntax


EventDetailCtrl.$inject = [
  '$scope', '$rootScope', '$q', '$timeout', '$state', '$stateParams'
  '$location', '$ionicScrollDelegate', '$ionicModal'
  '$log', 'toastr', 'exportDebug'
  'EventsResource', 'UsersResource', 'MenuItemsResource'
  'EventActionHelpers', 'AAAHelpers'
  'ParticipationsResource', 'ContributionsResource', 'TokensResource'
  'appModalSvc', 'geocodeSvc'
  'utils', 'devConfig'
  'ionicMaterialMotion', 'ionicMaterialInk'
]

angular.module 'starter.events'
  .controller 'EventDetailCtrl', EventDetailCtrl
