'use strict'

HomeCtrl = (
  $scope, $rootScope, $q, $location, $timeout
  $ionicScrollDelegate
  $log, toastr
  HomeResource
  ionicMaterialMotion, ionicMaterialInk
  utils, devConfig, exportDebug
  )->

  vm = this
  vm.title = "Discover"
  vm.me = null      # current user, set in initialize()
  vm.imgAsBg = utils.imgAsBg
  vm.acl = {
    isVisitor: ()->
      return true if !$rootScope.user
    isUser: ()->
      return true if $rootScope.user
  }
  vm.settings = {
    show: 'less'
  }
  vm.on = {
    scrollTo: (anchor)->
      $location.hash(anchor)
      $ionicScrollDelegate.anchorScroll(true)
      return

    setView: (value)->
      if 'value==null'
        next = if vm.settings.show == 'less' then 'more' else 'less'
        return vm.settings.show = next
      return vm.settings.show = value

    click: (ev)->
      toastr.info("something was clicked")
  }

  getData = () ->
    HomeResource.query().then (cards)->
      vm.cards = cards
      exportDebug.set( 'home', vm['cards'] )
      # toastr.info JSON.stringify( cards)[0...50]
      return cards

  startMaterialEffects = () ->
    # Set Motion
    $timeout ()->
      ionicMaterialMotion.slideUp({
        selector: '.slide-up'
      })
      return
    , 300

    $timeout () ->
      ionicMaterialMotion.fadeSlideInRight({
        selector: '[nav-view="active"] .animate-fade-slide-in-right .item'
        startVelocity: 3000
      })
      return
    , 700

    # $timeout () ->
    #   ionicMaterialMotion.blinds({
    #     startVelocity: 3000
    #   })
    #   return
    # , 700
    return


  initialize = ()->
    getData()

    # dev
    DEV_USER_ID = '3'
    devConfig.loginUser( DEV_USER_ID , false).then (user)->
      vm.me = $rootScope.user


  activate = ()->
    ionicMaterialInk.displayEffect()
    startMaterialEffects()
    return

  $scope.$on '$ionicView.loaded', (e)->
    $log.info "viewLoaded for HomeCtrl"
    initialize()

  $scope.$on '$ionicView.enter', (e)->
    $log.info "viewEnter for HomeCtrl"
    activate()

  return # end HomeCtrl


HomeCtrl.$inject = [
  '$scope', '$rootScope', '$q', '$location', '$timeout'
  '$ionicScrollDelegate'
  '$log', 'toastr'
  'HomeResource'
  'ionicMaterialMotion', 'ionicMaterialInk'
  'utils', 'devConfig', 'exportDebug'
]

angular.module 'starter.home'
  .controller 'HomeCtrl', HomeCtrl




