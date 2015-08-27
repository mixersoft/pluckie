'use strict'

EventsCtrl = ($scope, $q, $timeout, $stateParams
  $log, toastr,
  EventsResource, utils
  ionicMaterialMotion, ionicMaterialInk
  ) ->
  vm = this
  vm.title = ""     # filter.label, i.e. [ComingSoon|NearMe|PeLive]
  vm.filter = {}
  vm.events = []
  vm.imgAsBg = utils.imgAsBg
 
  _filters = {
    'comingSoon':
      label: "Coming Soon"
      filterBy: 'startTime'
    'nearby':
      label: "Events Near Me"
      filterBy: 'distance'
    'recent':
      label: "Recent Events"
    'all':
      label: "Events"
  }

  initialize = ()->
    getData()

  activate = ()->
    vm.filter = _filters[ $stateParams.filter ] || _filters[ 'all' ]
    vm.title = vm.filter.label

    # // Set Ink
    ionicMaterialInk.displayEffect()
    setMaterialEffects()

  getData = () ->
    EventsResource.query().then (events)->
      vm.events = events
      toastr.info JSON.stringify( events)[0...50]
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


  toastr.info "Creating EventsCtrl"

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
  '$scope', '$q', '$timeout', '$stateParams'
  '$log', 'toastr'
  'EventsResource', 'utils'
  'ionicMaterialMotion', 'ionicMaterialInk'
]

angular.module 'starter.home'
  .controller 'EventsCtrl', EventsCtrl
