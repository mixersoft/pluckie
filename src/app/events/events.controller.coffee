'use strict'

EventsCtrl = ($scope, $rootScope, $q, $timeout, $stateParams
  $log, toastr, $location
  EventsResource, MenuItemsResource
  AAAHelpers, appModalSvc, geocodeSvc, utils
  ionicMaterialMotion, ionicMaterialInk
  ) ->
    vm = this
    vm.me = null
    vm.title = ""     # filter.label, i.e. [ComingSoon|NearMe|PeLive]
    vm.filter = {}
    # coffeelint: disable=max_line_length
    vm.lookup = {
      'select':       # lookups for form select options
        'category':   ['Potluck', 'Popup']
        'style':      ['Seated','Casual','Grazing','Picnic']
        'attire':     ['Casual','Cocktail','Business','Formal','Fun']
        'cuisine':    ['American','Balkan','California','French','Italian','Japanese','Modern','Thai','Seafood']
        'MenuItemCategories': MenuItemsResource.categoryLookup
      'controlPanelDefaults':
        'Potluck':
          isExclusive: false   # invite Only
          denyGuestShare: false # guests can share event
          denyRsvpFriends: false # guests can rsvp friends
          rsvpFriendsLimit: 12 # guests rsvp limit for friends
          allowSuggestedFee: false # monentary fee in lieu of donation
          allowPublicAddress: false    # only guests see address
          denyParticipantList: false # guests can see Participants
          denyMaybeNoResponseList: false # hide Maybe, No responses
          denyWaitlist: true    # use waitlist if full
          feedVisibility: "public"  # [public|guests|none]
          denyAddMenu: false    # only host can update menu Items
    }
    # coffeelint: enable=max_line_length
    vm.events = []
    vm.imgAsBg = utils.imgAsBg
    vm.isDev = utils.isDev
  
    _filters = {
      'comingSoon':
        label: "Coming Soon"
        sortBy: 'startTime'  # ASC
        filterBy: (o)->
          return o.startTime > new Date().toJSON()
      'nearby':
        label: "Events Near Me"
        sortBy: 'location'
      'recent':
        label: "Recent Events"
        sortBy: (o)->
          return -1 * o.startTime  # DESC
        filterBy: (o)->
          return o.startTime < new Date().toJSON()
      'all':
        label: "Events"
    }

    vm.settings = {
    }

    vm.on = {
      ###
      # @description show create event modal and handle response
      # called by button.ion-plus in app.events
      ###
      beginCreate: (owner, copyEvent)->
        # vm = this
        owner = vm.me if _.isEmpty owner
        EVENT_TYPE = 'Potluck'
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
          utils.ga_PageView($location.path() + '/new' , 'app.event.new')

          if copyEvent
            blankEvent = angular.copy copyEvent
          else
            blankEvent = {
              isPublic: true
              aspiration: 0
              seatsTotal: 0
              setting: vm.lookup['controlPanelDefaults'][EVENT_TYPE]
            }
          # get menuCategoryOptions
          menuCategoryOptions = []
          _.each MenuItemsResource.categoryLookup, (value, key)->
            menuCategoryOptions.push {
              id: key
              value: value
              selected: true
            }
            return
          # initialize startTime
          blankEvent.startTime = moment(new Date()).startOf('hour').toDate()

          modalModel = {
            action: "Create"
            event: blankEvent
            eventType: EVENT_TYPE
            owner: owner
            select: vm.lookup['select']
           
            # for setting event.menu.allowCategoryKeys
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
            menuCategorySelected: _.values( MenuItemsResource.categoryLookup ).join(', ')

            # for setting startTime, duration
            when: # initialize values
              startDate: blankEvent.startTime
              startTime: blankEvent.startTime
              endTime: blankEvent.startTime
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
                return event if !result
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
                event.menu = event.menu || {}
                event.menu['allowCategoryKeys'] = _.keys modalModel.menuCategoryParseSelected()

                createEvent.call(vm, event).then (result)->
                  utils.ga_Send('send', 'event', 'participation', 'create', 'event', 20)
                  onSuccess?(result)
                 
                  return result
              return
          }

          return appModalSvc.show('events/event-new.modal.html', vm, {
            mm: modalModel
          }).then (modal)->
            # modalClose(): deregister $scope.$watch 'modalModel.when'
            'check'

    }

    createEvent = (event)->
      return $q.when()
      .then ()->
        event.ownerId = vm.me.id
        EventsResource.post(event)
      .then (result)->
        $log.info "Event Created, result="+JSON.stringify result
        return result
      .then ()->
        getData()
      .then ()->
        activate()

    initialize = ()->
      vm.filter = _filters[ $stateParams.filter ] || _filters[ 'all' ]
      getData()

    activate = ()->
      vm.filter = _filters[ $stateParams.filter ] || _filters[ 'all' ]
      vm.title = vm.filter.label
      vm.me = $rootScope.user

      # // Set Ink
      ionicMaterialInk.displayEffect()
      setMaterialEffects()

    sortEvents = (items, options)->
      collection = _.chain(items)
      collection = collection.filter(options.filterBy) if options.filterBy
      collection = collection.sortBy(options.sortBy) if options.sortBy
      return items = collection.value()

    getData = () ->
      EventsResource.query().then (events)->
        events = sortEvents(events, vm.filter)
        vm.events = events
        # toastr.info JSON.stringify( events)[0...50]
        return events

    setMaterialEffects = () ->
      # Set Motion
      # $timeout ()->
      #   ionicMaterialMotion.slideUp({
      #     selector: '.slide-up'
      #   })
      #   return
      # , 300

      # $timeout () ->
      #   ionicMaterialMotion.fadeSlideInRight({
      #     startVelocity: 3000
      #   })
      #   return
      # , 700
     
      $timeout () ->
        ionicMaterialMotion.blinds({
          selector: '[nav-view="active"] .animate-blinds .item'
          startVelocity: 1000
        })
        return
      , 300
      return

    resetMaterialEffects = ()->
      selector = '[nav-view="active"] .animate-blinds .item'
      # make view directive: removeClass('in done out')
      return


    # toastr.info "Creating EventsCtrl"

    $scope.$on '$ionicView.loaded', (e) ->
      $log.info "viewLoaded for EventsCtrl"
      initialize()

    $scope.$on '$ionicView.enter', (e) ->
      $log.info "viewEnter for EventsCtrl"
      activate()

    $scope.$on '$ionicView.leave', (e) ->
      $log.info "viewLeave for EventsCtrl"
      resetMaterialEffects()
    
    

    return vm # # end EventsCtrl,  return is required for controllerAs syntax


EventsCtrl.$inject = [
  '$scope', '$rootScope', '$q', '$timeout', '$stateParams'
  '$log', 'toastr', '$location'
  'EventsResource', 'MenuItemsResource'
  'AAAHelpers', 'appModalSvc', 'geocodeSvc', 'utils'
  'ionicMaterialMotion', 'ionicMaterialInk'
]

angular.module 'starter.events'
  .controller 'EventsCtrl', EventsCtrl
