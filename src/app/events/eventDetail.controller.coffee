'use strict'

EventDetailCtrl = ($scope, $rootScope, $q, $timeout, $stateParams
  $ionicHistory, $location, $ionicScrollDelegate
  $log, toastr, exportDebug
  EventsResource, UsersResource, MenuItemsResource, ContributionsResource
  utils, devConfig
  ionicMaterialMotion, ionicMaterialInk
  ) ->
  vm = this
  vm.me = null
  vm.title = "Event Detail"
  vm.event = {}
  vm.imgAsBg = utils.imgAsBg
  vm.getLabel_Location = (item, user={}) ->
    return item.address if user.hasJoined
    return item.neighborhood


  vm.getParticipationByUser = (user)->
    return if !user
    participation = vm.event.participants[user.id]
    return false if !participation
    contributions = _.filter vm.event.contributions, {contributorId: user.id}
    # contributions isNull
    participation.contributions = _.map contributions, (o)->
      return {
        menuItem: vm.event.menuItems[o.menuItemId]
        portions: o.portions
      }
    return participation

  vm.acl = {
    isVisitor: ()->
      return true if !$rootScope.user
      return !vm.acl.isParticipant()
    isOwner: ()->
      return vm.event?.ownerId == $rootScope.user?.id
    isParticipant: ()->
      return true if vm.acl.isOwner()
      return vm.event.participants?[$rootScope.user?.id]?
    isContributor: ()->
      return vm.event.contributors?[$rootScope.user?.id]?
  }

  vm.settings = {
    view:
      menu: 'more'   # [less|more|contribute]
  }

  vm.on = {
    scrollTo: (anchor)->
      $location.hash(anchor)
      $ionicScrollDelegate.anchorScroll(true)
      return

    menuView: (value)->
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
        if vm.acl.isParticipant() == false
          return vm.on.menuView(next) # skip
        if vm.event.summary.myParticipation.isFullyParticipating
          return vm.on.menuView(next) # skip
      vm.on.scrollTo('menu')
      return vm.settings.view.menu = values[next]

    bookSeats: ()->
      toastr.info("transitionTo app.events.booking")




  }

  initialize = ()->
    DEBUG_USER_ID = "3"
    devConfig.loginUser( DEBUG_USER_ID ).then (user)->   # sets $rootScope.user
      vm.me = $rootScope.user

  getEvent = (id) ->
    return EventsResource.get(id).then (result)->
      vm.event = result
      exportDebug.set( 'event', vm['event'] )
      # toastr.info JSON.stringify( result)[0...50]
      return result

  getEventUsers = (event)->
    UsersResource.get( event.ownerId )
    .then (result)->
      # ownerId => host
      event.host = result
      # toastr.info JSON.stringify( result )[0...50]
      return event

  getContributions = (event)->
    # using contributors join table
    ContributionsResource.query({ 'eventId' : event.id })
    .then (result)->
      event.contributions = result
      return event

  getMenuItems = (event)->
    event.menuItemIds = _.chain( event.contributions).pluck( 'menuItemId' ).compact().uniq().value()
    MenuItemsResource.get( event.menuItemIds )
    .then (result)->
      # ownerId => host
      event.menuItems = _.indexBy result,'id'
      toastr.info JSON.stringify( result )[0...50]
      return event

  getContributors = (event)->
    event.contributorIds = _.chain( event.contributions)
      .pluck( 'contributorId' ).compact().uniq().value()
    UsersResource.get( event.contributorIds )
    .then (result)->
      event.contributors = _.indexBy result, 'id'
      event.booking.contributors = _.keys( event.contributors ).length
      return event


  getParticipants = (event)->
    participants = {}
    # list host first
    participants[event.ownerId] =  event.participants[event.ownerId] || {
      userId: event.ownerId
      seats: 1
      comment: 'Your host'
    }
    event.participants = _.defaults participants, event.participants
    event.participantIds = _.keys event.participants
    return UsersResource.get( event.participantIds )
    .then (result)->
      participants = _.indexBy result, 'id'
      _.each event.participants, (o)->
        o.user = participants[o.userId]
        return
      return event

  mergeContributions = (event)->
    # add backlinks
    _.each event.contributions, (o)->
      return if !o.contributorId?   # null ok
      # TODO: add rule, contributor must be a participant
      if !event.participants[o.contributorId]
        $log.warn "WARNING: contributor is not a registered participant"
      # event.menuItems[i].contributor
      contribution = {
        contributor: event.contributors[o.contributorId]
        menuItem: event.menuItems[o.menuItemId]
        portions: o.portions
      }
      event.booking.portions += o.portions
      if _.isArray event.menuItems[o.menuItemId]['contributions']
        event.menuItems[o.menuItemId]['contributions'].push contribution
      else
        event.menuItems[o.menuItemId]['contributions'] = [ contribution ]

      # event.contributors[i].menuItem
      if _.isArray event.contributors[o.contributorId]['contribution']
        event.contributors[o.contributorId]['contributions'].push contribution
      else
        event.contributors[o.contributorId]['contributions'] = [contribution]
      return

    return event

  getDerivedValues_Event = (event)->
    summary = {
      countdown: ''
      booking:
        seats: 0
        seatsPct: ''
        parties: 0         # count of indivivdual parties aka participants        contributors: 0
      views:
        count: 0
      participation:
        contributors: 0
        contributorsPct: ''
        menuItems: 0
        menuItemContributions: 0
        menuItemContributionsPct: ''
        portions: 0
        portionsPct: ''
      myParticipation:
        isFullyParticipating: false
        portions: 0
        portionsPct: ''
    }

    # public stats
    summary['countdown'] = moment(event.startTime).fromNow()
     
    _.each event.participants, (o)->
      if o.seats
        summary.booking['seats'] += o.seats
        summary.booking['parties'] += 1
      return
    summary.booking['seatsPct'] = Math.round( summary.booking.seats/event.seatsTotal * 100 )
    event.seatsOpen = event.seatsTotal - summary.booking.seats

    if vm.acl.isParticipant()
      event.myParticipation = vm.getParticipationByUser(vm.me)
      myParticipation = summary['myParticipation']
      myParticipation['isFullyParticipating'] = false

    if vm.acl.isContributor()
      myParticipation = summary['myParticipation']
      _.each event.myParticipation.contributions, (o)->
        myParticipation['portions'] += o.portions
        return
      myParticipation['portionsPct'] =
        Math.round( myParticipation['portions'] /
          (event.myParticipation['seats'] * event.seatsTotal) * 100
        )
      if myParticipation['portionsPct'] > 85
        myParticipation['isFullyParticipating'] = true 

    if vm.acl.isOwner()
      contributors = []
      participation = summary['participation']
      _.each event.contributions, (o)->
        participation['menuItems'] += 1
        return if !o.contributorId?   # null ok
        contributors.push( o.contributorId )
        participation['menuItemContributions'] += 1
        participation['portions'] += o.portions
        return
      participation['contributors'] = _.uniq(contributors).length
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

  getDerivedValues_MenuItems = (event)->
    _.each event.menuItems, (mi)->
      mi.summary = {
        portions: 0
        portionsPct: 0
        portionsRemaining: event.seatsTotal
        isContributed: false
      }
      _.each mi.contributions, (c)->
        mi.summary['portions'] += c.portions
        return
      mi.summary['portionsRemaining'] = Math.max(event.seatsTotal - mi.summary['portions'], 0)
      mi.summary['portionsPct'] =
        Math.round( mi.summary['portions'] /
          (event.seatsTotal) * 100
        )
      if mi.summary['portionsPct'] > 85
        mi.summary['isContributed'] = true
      return
    return

    
  activate = ()->
    getData()
    # // Set Ink
    ionicMaterialInk.displayEffect()
    setMaterialEffects()

  getData = () ->
    $ionicHistory.goBack() if !$stateParams.id
    id = $stateParams.id
    getEvent(id)
    .then (event)->
      getEventUsers(event)
    .then (event)->
      getContributions(event)
    .then (event)->
      getParticipants(event)
    .then (event)->
      promises = []
      promises.push getMenuItems(event)
      promises.push getContributors(event)
      $q.all( promises).then ()->
        mergeContributions(event)
        return event
    .then (event)->
      getDerivedValues_Event(event)
      getDerivedValues_MenuItems(event)
      


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


  toastr.info "Creating EventDetailCtrl"

  $scope.$on '$ionicView.loaded', (e) ->
    $log.info "viewLoaded for EventDetailCtrl"
    initialize()

  $scope.$on '$ionicView.enter', (e) ->
    $log.info "viewEnter for EventDetailCtrl"
    activate()
   
  return vm # # end EventDetailCtrl,  return is required for controllerAs syntax


EventDetailCtrl.$inject = [
  '$scope', '$rootScope', '$q', '$timeout', '$stateParams'
  '$ionicHistory', '$location', '$ionicScrollDelegate'
  '$log', 'toastr', 'exportDebug'
  'EventsResource', 'UsersResource', 'MenuItemsResource', 'ContributionsResource'
  'utils', 'devConfig'
  'ionicMaterialMotion', 'ionicMaterialInk'
]

angular.module 'starter.events'
  .controller 'EventDetailCtrl', EventDetailCtrl
