'use strict'

ProfileCtrl = (
  $scope, $rootScope, $location
  $ionicScrollDelegate
  $log, toastr
  UsersResource
  appModalSvc
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
  }

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
      loginUser: (person)->
        devConfig.loginUser( person.id )
        .then (user)->   # sets $rootScope.user
          vm.me = $rootScope.user
          toastr.info "You are now " + person.displayName
          $scope.dev.settings.show = 'less'
          return user
  }

  initialize = ()->
    # dev
    DEV_USER_ID = '0'
    devConfig.loginUser( DEV_USER_ID , false)
    .then (user)->
      vm.me = $rootScope.user
      activate()
      vm.on.scrollTo()

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
  'UsersResource'
  'appModalSvc'
  'utils', 'devConfig', 'exportDebug'
]

angular.module 'starter.home'
  .controller 'ProfileCtrl', ProfileCtrl
