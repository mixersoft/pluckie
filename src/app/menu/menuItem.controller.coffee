'use strict'

MenuItemCtrl = (
  $scope, $rootScope, $q, $location, $stateParams, $timeout
  $ionicScrollDelegate
  $log, toastr
  MenuItemsResource
  appModalSvc
  utils, devConfig, exportDebug
  )->

  vm = this
  vm.title = "Menu"
  vm.me = null      # current user, set in initialize()
  vm.menuItem = {}
  vm.listIds = []   # sorted array of menuItemIds
  vm.lookup = {}
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

    scrollToItem: (menuItem)->
      $timeout ()->
        i = vm.listIds.indexOf(menuItem.id)
        return if i == -1
        $log.info "scroll to index=" + i
        menuItems = document.getElementsByClassName('menu-item')
        found = _.find menuItems, (o)->
          return true if o.parentNode.parentNode.id == 'menu-item'
        $container = angular.element(found.parentNode)
        if _.isEmpty($container)
          $log.warn "Error: could not find menuItem in DOM, id="+menuItem.id
        menuItemDom = $container.children()[i]
        pos = ionic.DomUtil.getPositionInParent(menuItemDom)
        $ionicScrollDelegate.scrollTo(pos.left, pos.top, false)
        return

    xxloadNext: ()->
      $scope.$broadcast('scroll.infiniteScrollComplete')
      $timeout ()->
        setPrevNextItems(vm.menuItem)
        newNextId = reorderPrevNextDom(vm.nextDomId)
        # reorder Dom elements
        $next.parent().prepend($next)
        nextDom = document.getElementById(newNextId)
        $nextDom = angular.element(nextDom)
        $ionicScrollDelegate.resize()
        _isInfiniteScrollLoading = false
      ,1000
      return
        
  }

  $scope.dev = {
    settings: {}
    on: {}
  }


  initialize = ()->
    # dev
    DEV_USER_ID = '0'
    devConfig.loginUser( DEV_USER_ID , false)
    .then (user)->
      vm.me = $rootScope.user
      vm.on.scrollTo()

  activate = ()->
    $ionicHistory.goBack() if !$stateParams.id
    getData()
    .then ()->
      vm.on.scrollToItem(vm.menuItem)
      



  getData = (curId)->
    curId = $stateParams['id'] if `curId==null`
    vm.listIds = if $stateParams['menu'] then $stateParams['menu'].split(',') else null
    getMenuItems(vm.listIds || [curId])
    .then (result)->
      vm.menuItem = vm.lookup['MenuItems'][curId]
      return vm.menuItem
    .then (itemCurrent)->
      # xxsetPrevNextItems(itemCurrent)
      # vm.nextDomId = xxreorderPrevNextDom()
      vm.listIds = sorted = _.pluck MenuItemsResource.sortByCategory(vm.lookup['MenuItems']), 'id'
      return itemCurrent

  getMenuItems = (ids)->
    vm.lookup['MenuItems'] = {} if !vm.lookup['MenuItems']
    ids = _.difference ids, _.pluck(vm.lookup['MenuItems'],'id')
    if !ids.length
      return $q.when vm.lookup['MenuItems']
    return MenuItemsResource.get( ids )
    .then (result)->
      _.each result, (o)->
        vm.lookup['MenuItems'][o.id] = o
        return
      return vm.lookup['MenuItems']

  xxsetPrevNextItems = (current)->
    if !vm.listIds
      vm.prev = vm.next = null
      return
    vm.listIds = sorted = _.pluck MenuItemsResource.sortByCategory(vm.lookup['MenuItems']), 'id'
    i = sorted.indexOf(current.id)
    vm.prev = if i==0 then null else sorted[i-1]
    vm.next = if i+1==sorted.length then null else sorted[i+1]

  xxreorderPrevNextDom = (nextDomId)->
    if !nextDomId || nextDomId == 'menu-item-b'
      # then 'menu-item-a'
      vm.menuItemA = vm.menuItem
      vm.menuItemB = if vm.next then vm.lookup['MenuItems'][vm.next] else {}
    else
      # nextDom = 'menu-item-a'
      vm.menuItemB = vm.menuItem
      vm.menuItemA = if vm.next then vm.lookup['MenuItems'][vm.next] else {}
    vm.nextDomId =
      if nextDomId? == 'menu-item-b'
      then 'menu-item-a'
      else 'menu-item-b'
    $log.info "a/b reordered, next=" + vm.nextDomId
    return vm.nextDomId


  $scope.$on '$ionicView.loaded', (e)->
    $log.info "viewLoaded for MenuItemCtrl"
    initialize()

  $scope.$on '$ionicView.enter', (e)->
    $log.info "viewEnter for MenuItemCtrl"
    activate()

  return # end MenuItemCtrl


MenuItemCtrl.$inject = [
  '$scope', '$rootScope', '$q', '$location','$stateParams', '$timeout'
  '$ionicScrollDelegate'
  '$log', 'toastr'
  'MenuItemsResource'
  'appModalSvc'
  'utils', 'devConfig', 'exportDebug'
]

angular.module 'starter.home'
  .controller 'MenuItemCtrl', MenuItemCtrl
