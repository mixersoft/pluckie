'use strict'

MenuItemCtrl = (
  $scope, $rootScope, $q, $location, $stateParams
  $ionicScrollDelegate
  $log, toastr
  MenuItemsResource
  appModalSvc
  utils, devConfig, exportDebug
  )->

  vm = this
  vm.title = "Menu"
  vm.me = null      # current user, set in initialize()
  vm.menuItem = null
  vm.imgAsBg = utils.imgAsBg
  vm.openExternalLink = utils.openExternalLink
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
        MenuItemsResource.query()
        .then (result)->
          vm.menu = _.indexBy result, 'id'
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

  getMenuItem = (id)->
    MenuItemsResource.get( id )
    .then (result)->
      # ownerId => host
      vm.menuItem =  result
      # vm.lookup['MenuItems'][id] = result
      # toastr.info JSON.stringify( result )[0...50]
      return vm.menuItem

  initialize = ()->
    getData()
    # dev
    DEV_USER_ID = '0'
    devConfig.loginUser( DEV_USER_ID , false)
    .then (user)->
      vm.me = $rootScope.user
      activate()
      vm.on.scrollTo()

  activate = ()->
    menuItemId = $stateParams.id
    if menuItemId != vm.menuItem?.id
      return getMenuItem(menuItemId)
    return $q.when vm.menuItem

  getData = ()->
    $ionicHistory.goBack() if !$stateParams.id
    id = $stateParams.id
    getMenuItem(id)


  $scope.$on '$ionicView.loaded', (e)->
    $log.info "viewLoaded for MenuItemCtrl"
    initialize()

  $scope.$on '$ionicView.enter', (e)->
    $log.info "viewEnter for MenuItemCtrl"
    activate()

  return # end MenuItemCtrl


MenuItemCtrl.$inject = [
  '$scope', '$rootScope', '$q', '$location','$stateParams'
  '$ionicScrollDelegate'
  '$log', 'toastr'
  'MenuItemsResource'
  'appModalSvc'
  'utils', 'devConfig', 'exportDebug'
]

angular.module 'starter.home'
  .controller 'MenuItemCtrl', MenuItemCtrl
