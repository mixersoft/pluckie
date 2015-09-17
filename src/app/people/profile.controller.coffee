'use strict'

ProfileCtrl = (
  $scope, $rootScope, $q, $location, $timeout, $state, $stateParams
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
    editing: false
    changePassword: false
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
    resetForm: ()->
      vm.person = angular.copy(vm.me)
      $timeout ()->
        vm.settings.editing = false
      return
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
          activate()
          return user
      updateProfile: (person, changePassword)->
        if changePassword.new?
          # validate changePassword.old
          promise = $q.when changePassword
        else
          promise = $q.when()
        promise
        .catch (o)->
          # error updating password
          return o
        .then ()->
          # update profile attributions
          id = vm.me.id
          return UsersResource.put(id, person)


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
    vm.settings.editing = false
    vm.settings.changePassword = false
    userid = $stateParams.id
    if !userid
      # me, copy in case we need to reset
      vm.person = angular.copy(vm.me)
      promise = $q.when vm.person
    else if userid == vm.me.id
      vm.person = vm.me
      promise = $q.when vm.person
    else
      promise = UsersResource.get(userid)
      .then (user)->
        return vm.person = user
    return promise

  $scope.$watch 'vm.person', (newV, oldV)->
    vm.settings.editing = true if $state.is('app.me')
  , true


  $scope.$on '$ionicView.loaded', (e)->
    $log.info "viewLoaded for ProfileCtrl"
    initialize()

  $scope.$on '$ionicView.enter', (e)->
    $log.info "viewEnter for ProfileCtrl"
    activate()

  return # end ProfileCtrl


ProfileCtrl.$inject = [
  '$scope', '$rootScope', '$q', '$location', '$timeout', '$state', '$stateParams'
  '$ionicScrollDelegate'
  '$log', 'toastr'
  'UsersResource'
  'appModalSvc'
  'utils', 'devConfig', 'exportDebug'
]

angular.module 'starter.home'
  .controller 'ProfileCtrl', ProfileCtrl
