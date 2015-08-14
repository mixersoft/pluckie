'use strict'

EventDetailCtrl = ($scope, $rootScope, $q, $timeout, $stateParams
  $ionicHistory
  $log, toastr,
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

  getParticipants = (event)->
    return $q.when() if !event.participants
    userids = _.keys event.participants
    userids.unshift event.ownerId
    return UsersResource.get( userids )
    .then (result)->
      participants = _.indexBy result, 'id'
      _.each event.participants, (o)->
        o.user = participants[o.userId]
        return
      return event

  vm.getParticipation = (user)->
    return if !user
    participation = vm.event.participants[user.id]
    if user.id == vm.event.ownerId
      participation = {
        # TODO: allow host to edit participation
        userId: vm.event.ownerId
        seats: 1
        comment: ''
      }
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
    isOwner: ()->
      return vm.event?.ownerId == $rootScope.user?.id
    isParticipant: ()->
      return true if vm.acl.isOwner()
      return vm.event.participants?[$rootScope.user?.id]?
    isContributor: ()->
      return vm.event.contributors?[$rootScope.user?.id]?
  }

  initialize = ()->
    devConfig.loginUser("0").then (user)->   # sets $rootScope.user
      vm.me = $rootScope.user

  getEvent = (id) ->
    return EventsResource.get(id).then (result)->
      vm.event = result
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
      return event

  mergeContributions = (event)->
    _.each event.contributions, (o)->
      return if !o.contributorId?   # null ok
      # event.menuItems[i].contributor
      contribution = {
        contributor: event.contributors[o.contributorId]
        menuItem: event.menuItems[o.menuItemId]
        portions: o.portions
      }
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
  '$ionicHistory'
  '$log', 'toastr'
  'EventsResource', 'UsersResource', 'MenuItemsResource', 'ContributionsResource'
  'utils', 'devConfig'
  'ionicMaterialMotion', 'ionicMaterialInk'
]

angular.module 'starter.events'
  .controller 'EventDetailCtrl', EventDetailCtrl
