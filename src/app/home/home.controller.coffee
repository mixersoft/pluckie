'use strict'

HomeCtrl = ($scope, $q, $timeout, $log, toastr,
  HomeResource, utils
  ionicMaterialMotion, ionicMaterialInk
  ) ->
  vm = this
  vm.title = "Discover"
  vm.events = []
  vm.imgAsBg = utils.imgAsBg

  initialize = ()->
    getData()
    return

  activate = ()->
    # // Set Ink
    ionicMaterialInk.displayEffect()
    setMaterialEffects()
    return

  getData = () ->
    HomeResource.query().then (cards)->
      vm.cards = cards
      toastr.info JSON.stringify( cards)[0...50]
      return cards

  setMaterialEffects = () ->
    # Set Motion
    $timeout ()->
      ionicMaterialMotion.slideUp({
        selector: '.slide-up'
      })
      return
    , 300

    $timeout () ->
      ionicMaterialMotion.fadeSlideInRight({
        startVelocity: 3000
      })
      return
    , 700

    $timeout () ->
      ionicMaterialMotion.blinds({
        startVelocity: 3000
      })
      return
    , 700
    return


  toastr.info "Creating HomeCtrl"

  $scope.$on '$ionicView.loaded', (e) ->
    $log.info "viewLoaded for HomeCtrl"
    initialize()

  $scope.$on '$ionicView.enter', (e) ->
    activate()

  return vm # # end HomeCtrl,  return is required for controllerAs syntax


HomeCtrl.$inject = [
  '$scope', '$q', '$timeout'
  '$log', 'toastr'
  'HomeResource', 'utils'
  'ionicMaterialMotion', 'ionicMaterialInk'
]

angular.module 'starter.home'
  .controller 'HomeCtrl', HomeCtrl
