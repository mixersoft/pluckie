'use strict'

ProfileCtrl = (
  $scope, $rootScope, $location
  $ionicScrollDelegate
  $log, toastr
  utils, devConfig, exportDebug
  )->

  vm = this
  vm.title = "Profile"
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

  initialize = ()->
    if $rootScope.user?
      vm.me = $rootScope.user
    return

  activate = ()->
    return

  $scope.$on '$ionicView.loaded', (e)->
    $log.info "viewLoaded for ProfileCtrl"
    initialize()

  $scope.$on '$ionicView.enter', (e)->
    $log.info "viewEnter for ProfileCtrl"
    activate()

  return # end ProfileCtrl


ProfileCtrl.$inject = [
  '$scope', '$rootScope', '$location'
  '$ionicScrollDelegate'
  '$log', 'toastr'
  'utils', 'devConfig', 'exportDebug'
]

angular.module 'starter.home'
  .controller 'ProfileCtrl', ProfileCtrl
