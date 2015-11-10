'use strict'

HomeCtrl = (
  $scope, $rootScope, $location
  $ionicScrollDelegate
  $log, toastr
  appModalSvc
  utils, devConfig, exportDebug
  )->

  vm = this
  vm.title = "Home"
  vm.me = null      # current user, set in initialize()
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
      appModalSvc.show('home/sign-in.html', vm, {
        xyz: "hello world"
      })
      .then (result)->
        # result from modal
        toastr.info result


    close: (o)->
      $log.info "CloseModal called"

  }

  initialize = ()->
    # return
    if $rootScope.user?
      vm.me = $rootScope.user

  activate = ()->
    return

  $scope.$on '$ionicView.loaded', (e)->
    $log.info "viewLoaded for HomeCtrl"
    initialize()

  $scope.$on '$ionicView.enter', (e)->
    $log.info "viewEnter for HomeCtrl"
    activate()

  return # end HomeCtrl


HomeCtrl.$inject = [
  '$scope', '$rootScope', '$location'
  '$ionicScrollDelegate'
  '$log', 'toastr'
  'utils', 'devConfig', 'exportDebug'
]

angular.module 'starter.home'
  .controller 'HomeCtrl', HomeCtrl




