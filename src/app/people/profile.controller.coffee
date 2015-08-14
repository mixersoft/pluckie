'use strict'

ProfileCtrl = ($scope, $timeout, $log, toastr, ionicMaterialMotion, ionicMaterialInk) ->
  vm = this
  vm.title = 'Profile'
  

  activate = ()->
    # // Set Ink
    ionicMaterialInk.displayEffect()
    setMaterialEffects()

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
    return


  toastr.info "Creating ProfileCtrl"
  
  $scope.$on '$ionicView.loaded', (e) ->
    $log.info "viewLoaded for ProfileCtrl"

  $scope.$on '$ionicView.enter', (e) ->
    activate()

  return vm # end ProfileCtrl, return is required for controllerAs syntax

ProfileCtrl.$inject = [
  '$scope', '$timeout', '$log'
  'toastr'
  'ionicMaterialMotion', 'ionicMaterialInk'
  ]

angular.module 'starter.profile'
  .controller 'ProfileCtrl', ProfileCtrl
