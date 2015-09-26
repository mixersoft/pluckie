'use strict'

EventDetailCtrl = ($scope, $rootScope, $q, $timeout, $state, $stateParams
  $ionicHistory, $location, $ionicScrollDelegate, $ionicModal
  $log, toastr, exportDebug
  EventsResource, UsersResource, MenuItemsResource
  EventActionHelpers, AAAHelpers
  ParticipationsResource, ContributionsResource, TokensResource
  appModalSvc
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
    if showExactLocation
      # add complete address
      event['visibleAddress'] = [event.address, event.neighborhood].join(', ')
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
      if event.setting.isExclusive || $state.params.invitation
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
    isAnonymous: ()->
      return true if !$rootScope.user.id
      return false

    isVisitor: ()-> ## has not responded to or joined event
      return true if _.isEmpty $rootScope.user
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

      vm.on.scrollTo('menu')
      if value == 'contribute'
        toastr.info "Contribute a suggested Menu Item or add a new one."
      return vm.settings.view.menu = values[next]

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
      $state.transitionTo state, params
      return

    'getShareLink': ()->EventActionHelpers.getShareLink.apply(vm, arguments)
    'showShareLink': ()->EventActionHelpers.showShareLink.apply(vm, arguments)

    showSignIn: (initialSlide)->
      return AAAHelpers.showSignInRegister.apply(vm, arguments)
      .then (result)-> # closeModal(result)
        return $q.reject('CANCELED') if `result==null` || result == 'CANCELED'
        return $q.reject(result) if result?['isError']
        return result

    'beginResponse': ()->
      return EventActionHelpers.beginResponse.apply(vm, arguments)
    
    # called by button.JoinEvent
    # ???:deprecate? is this the same as beginResponse?
    # or do is this action for joinEvent w/o invitation?
    beginBooking: (person, event)->
      return $q.when()
      .then ()->
        return isInvitationRequired(event)
      .then ()->
        return appModalSvc.show('events/booking.modal.html', vm, {
          mm:   # mm == "modal model" instead of view model
            isValidated: (booking)->
              return false if vm.acl.isAnonymous()
              return false if booking.seats < 1
              return true
            signInRegister: (action, person)->
              # update booking user after sign in/register
              return vm.on.showSignIn(action)
              .then (result)->
                _.extend person, result
                return
            submitBooking: (booking, onSuccess)->
              # some sanity checks
              if vm.event.id != booking.event.id
                toastr.warning("You are booking for a different event. title=" +
                  booking.event.title)
              if vm.me.id != booking.person.id
                toastr.warning("You are booking for a different person. name=" +
                  booking.person.displayName)

              vm.createBooking(booking).then (result)->
                onSuccess?(result)
                return result
              return

          myBooking :
            person: person
            event: event
            booking:
              userId: person.id
              seats: 1
              comment: null
        })
      .then (result)->
        $log.info "Contribute Modal resolved, result=" + JSON.stringify result

    


    beginContribute: (mitem)->
      if `mitem==null`
        return appModalSvc.show('events/contribute-new.modal.html', vm, {
        myContribution :
          isNewMenuItem: true
          maxPortions: Math.min(12, vm.event.seatsTotal)
          menuItem:
            id: null
            title: ''
            detail: ''
            category: null
            pic: null
            link: null
          # label: label
          contribution:
            eventId: vm.event.id
            menuItemId: null
            contributorId: vm.me.id
            portions: Math.min(12, vm.event.seatsTotal)
            portionsRequired: null   # TODO: allow create from to set portionsRequired
            comment: null
        })

      dishes = ['Starter','Side','Main','Dessert']
      # label = if dishes.indexOf(mitem.category) > -1 then 'dish' else 'item'
      appModalSvc.show('events/contribute.modal.html', vm, {
        myContribution :
          menuItem: mitem
          # label: label
          contribution:
            eventId: vm.event.id
            menuItemId: mitem.id
            contributorId: vm.me.id
            portions: Math.min(12, mitem.summary.portionsRemaining)
            comment: null
        })
      .then (result)->
        result = _.omit result, ['contributor', 'menuItem']
        $log.info "Contribute Modal resolved, result=" + JSON.stringify result
      return
    submitContribute: (contribution, onSuccess)->
      if contribution.isNewMenuItem
        promise = createMenuItem(contribution.menuItem)
        .then (menuItem)->
          contribution['contribution'].menuItemId = menuItem.id
          contribution.isNewMenuItem = false
          return contribution
        , (err)->
          toastr.error "Error creating NEW menuItem"
      else
        promise = $q.when contribution
      promise.then (contribution)->
        createContribution(contribution).then (result)->
          onSuccess?(result)
          return result
      return
  }

  initialize = ()->
    # dev
    DEV_USER_ID =  null # '0'
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
      participation['contributors'] = yesContributions.length
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
    return distribution

  vm.createBooking = (options)->
    booking = options.booking
    person = options.person

    # add booking as participant to event
    # clean up data
    particip = {
      eventId: options.event.id
      participantId: options.person.id
      seats: parseInt booking.seats
      comment: booking.comment
    }
    ParticipationsResource.post(particip)
    .then (result)->
      # update lookups
      if !~vm.event['participationIds'].indexOf(result.id)
        vm.event['participationIds'].push result.id
        # vm.event['participantIds'].push result.participantId
      vm.lookup['Participations'][result.id] = result
      vm.lookup['Users'][result.participantId] = person
      vm.lookup['MyParticipation'] = vm.getParticipationByUser(person)
      $scope.$broadcast 'lookup-data:changed', {className:'Participations'}
      return result
    .then (participation)->
      $scope.$broadcast 'event:participant-changed', options
      message = "Congratulations, you have just booked " + participation.seats + " seats! "
      message += "Now search for your contribution."
      toastr.info message
      vm.on.scrollTo('cp-participant')
      return participation

  createMenuItem = (menuItem)->
    MenuItemsResource.post(menuItem)
    .then (menuItem)->
      # add to Event
      vm.event['menuItemIds'].push( menuItem.id) if !~vm.event['menuItemIds'].indexOf( menuItem.id)
      # arr.push( xxx ) if !~arr.indexOf( xxx )
      vm.lookup['MenuItems'][menuItem.id] = menuItem
      vm.lookup['MenuItemContributions'][menuItem.id] = []
      $scope.$broadcast 'lookup-data:changed', {className:'MenuItem'}
      return menuItem


  createContribution = (options)->
    menuItem = options.menuItem
    contrib = options.contribution
    # clean up data
    contrib.portions = parseInt contrib.portions

    return $q.reject("expecting menuItem") if !menuItem
    isCreate = false
    # TODO: use Resty::methods
    found = _.filter vm.lookup['Contributions']
      , _.pick contrib, ['contributorId','menuItemId','eventId']

    if found.length > 1
      toastr.warning "Warning: same menu item contributed by same person more than once"
    if found.length == 1
      # update portion from existing contrib
      updateObj = angular.copy found[0]
      updateObj['portions'] += contrib.portions
      updateObj['comment'] =
        if updateObj.comment
        then [updateObj.comment, contrib.comment].join('; ')
        else contrib.comment
      # updateObj.sort = Date.now()
      promise = ContributionsResource.put( updateObj.id, updateObj )
    else if vm.lookup['MenuItemContributions'][menuItem.id].length > 0
      # follow-on contribution, create NEW contrib record
      isCreate = true
      updateObj = contrib
      promise = ContributionsResource.post( updateObj )
    else if !_.find(vm.lookup['Contributions'], _.pick(contrib, ['menuItemId','eventId']))
      # first contribution for NEW menuItem
      isCreate = true
      updateObj = contrib
      promise = ContributionsResource.post( updateObj )
    else if vm.lookup['MenuItemContributions'][menuItem.id].length == 0
      # first contribution to existing menuItem
      #   assign contributorId to record,
      found = _.find(vm.lookup['Contributions'], _.pick(contrib, ['menuItemId','eventId']))
      if found.contributorId
        # reset this contribution, it was not from an yesParticipationId
        # if it were, it would have appeared in vm.lookup['MenuItemContributions'][menuItem.id]
        found.portions = 0
        found.contributorId = null
      if !found
        toastr.error "Error: Expecting empty Contribution record for menuItemId="+menuItem.id
      # update portion from existing contrib
      updateObj = angular.copy found
      updateObj['contributorId'] = contrib.contributorId
      updateObj['portions'] += contrib.portions
      updateObj['comment'] =
        if updateObj.comment
        then [updateObj.comment, contrib.comment].join('; ')
        else contrib.comment
      promise = ContributionsResource.put( updateObj.id, updateObj )

   
    else
      toastr.error "Error: no MenuItemContributions record for id="+menuItem.id


    return promise
    .then (result)->
      # register person as contributor
      if !~vm.event['contributorIds'].indexOf( vm.me.id )
        vm.event['contributorIds'].push( vm.me.id )
      vm.lookup['Contributions'][result.id] = result # copy
      # update contrib in MenuItemContributions lookup
      contribs = vm.lookup['MenuItemContributions'][result.menuItemId]
      i = _.findIndex(contribs, {id:result.id})
      if i = -1
        vm.lookup['MenuItemContributions'][result.menuItemId].push result
      else
        vm.lookup['MenuItemContributions'][result.menuItemId][i] = result
      # update MyParticipation.contributionIds,  .contributions
      vm.lookup['MyParticipation'] = vm.getParticipationByUser(vm.me)
      if !~vm.lookup['MyParticipation']?.contributionIds.indexOf( result.id )
        vm.lookup['MyParticipation'].contributionIds.push( result.id )
      # need to getDerivedValues()
      $scope.$broadcast 'lookup-data:changed', {className:'Contributions'}
      return result
    , (err)->
      toastr.error( "Error updating Contribution, o=" + updateObj)
      return
    .then (contribution)->
      $scope.$broadcast 'event:contribution-changed', options
      message = "Congratulations, you are signed-up to contribute " + contribution.portions
      message += " portions of " + options.menuItem.title + "."
      toastr.info message
      vm.on.scrollTo('cp-participant')
      return contribution

  activate = ()->
    getData()
    # // Set Ink
    ionicMaterialInk.displayEffect()
    setMaterialEffects()

  getMap = (event)->
    if event.visibleLocation?
      $timeout ()->
        latlon = {
          latitude: event.visibleLocation[0]
          longitude: event.visibleLocation[1]
        }
        event.map = {
          center: latlon
            # latitude: Math.round((event.location[0]*1000000)/1000000)
            # longitude: Math.round((event.location[1]*1000000)/1000000)
          zoom: 14
          # event.map.options
          options:
            map:
              options:
                draggable: false
            circle:
              center: latlon
              stroke:
                color: '#FF0000'
                weight: 1
              radius: 500
              fill:
                color: '#FF0000'
                opacity: '0.2'
            marker:
              idKey: event.id
              coords: latlon
        }

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
      return eventId = $state.params.id
    .catch (err)->
      if $ionicHistory.backView()
        $ionicHistory.goBack()
      else
        $state.transitionTo('app.events')
        toastr.info "Oops, that invitation was not found."
      return $q.reject()
    .then (eventId)->
      vm.event['ready'] = false
      vm.lookup['Participations']
      vm.lookup['Contributions']
      return getEvent(eventId)
    .then (event)->
      vm.event = event
      exportDebug.set( 'event', vm['event'] )
    .then (event)->
      getEventUsers(event)
    .then (event)->
      getParticipations(event)
    .then (event)->
      getContributions(event)
    .then (event)->
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

  $rootScope.$on 'user:sign-in', (ev, user)->
    return if vm.event.ready == false

  $rootScope.$on 'user:sign-out', ()->
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
          vm.on.scrollTo('admin-change-user')
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
          vm.on.scrollTo()
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
  '$ionicHistory', '$location', '$ionicScrollDelegate', '$ionicModal'
  '$log', 'toastr', 'exportDebug'
  'EventsResource', 'UsersResource', 'MenuItemsResource'
  'EventActionHelpers', 'AAAHelpers'
  'ParticipationsResource', 'ContributionsResource', 'TokensResource'
  'appModalSvc'
  'utils', 'devConfig'
  'ionicMaterialMotion', 'ionicMaterialInk'
]

angular.module 'starter.events'
  .controller 'EventDetailCtrl', EventDetailCtrl
