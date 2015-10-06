'use strict'

MenuItemCtrl = (
  $scope, $rootScope, $q, $location, $stateParams, $timeout
  $ionicScrollDelegate
  $log, toastr
  MenuItemsResource, ContributionsResource, EventsResource
  appModalSvc
  utils, devConfig, exportDebug
  )->

  vm = this
  vm.title = "Menu"
  vm.me = null      # current user, set in initialize()
  vm.menuItem = {}
  vm.menuItemIds = []   # sorted array of menuItemIds
  vm.lookup = {
    'MenuItems': {}
    'Events': {}
    'EventsByMenuId': {}
  }
  vm.imgAsBg = utils.imgAsBg
  vm.openExternalLink = (ev, item)->
    utils.ga_Send('send', 'event'
            , 'engagement', 'menu-item', 'open-link:' + item.id, 2)
    return utils.openExternalLink(ev, item.link)
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
        i = vm.menuItemIds.indexOf(menuItem.id)
        return if i == -1
        $log.info "scroll to index=" + i
        return if i == 0
        menuItems = document.getElementsByClassName('menu-item')
        found = _.find menuItems, (o)->
          return true if o.parentNode.parentNode.id == 'menu-item'
        return if !found
        $container = angular.element(found.parentNode)
        if _.isEmpty($container)
          $log.warn "Error: could not find menuItem in DOM, id="+menuItem.id
        menuItemDom = $container.children()[i]
        return if !menuItemDom
        pos = ionic.DomUtil.getPositionInParent(menuItemDom)
        $ionicScrollDelegate.scrollTo(pos.left, pos.top, false)
        return
      ,10

    toggleFeaturedIn: (item)->
      item.showFeatured = !item.showFeatured
      $log.info "showFeatured=" + item.showFeatured
      return item.showFeatured

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
    DEV_USER_ID = null # '0'
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
    vm.menuItemIds = if $stateParams['menu'] then $stateParams['menu'].split(',') else null
    getMenuItems(vm.menuItemIds || [curId])
    .then (result)->
      vm.menuItem = vm.lookup['MenuItems'][curId]
      return vm.menuItem
    .then (itemCurrent)->
      # xxsetPrevNextItems(itemCurrent)
      # vm.nextDomId = xxreorderPrevNextDom()
      vm.menuItemIds = sorted =
        _.pluck MenuItemsResource.sortByCategory(vm.lookup['MenuItems']), 'id'
      return itemCurrent
    .then ()->
      # vm.lookup['EventsByMenuId'] = {} if !vm.lookup['EventsByMenuId']
      # vm.lookup['Events'] = {} if !vm.lookup['Events']
      promises = []
      _.each vm.menuItemIds, (mid)->
        dfd = $q.defer()
        promises.push dfd
        $timeout ()->
          getEventIdsByMenuItemId(mid).then (eventIds)->
            getEvents(eventIds)
          .then ()->
            dfd.resolve()
        ,5  # add some time for rendering events
      return $q.all(promises)

  getMenuItems = (ids)->
    # vm.lookup['MenuItems'] = {} if !vm.lookup['MenuItems']
    ids = _.difference ids, _.pluck(vm.lookup['MenuItems'],'id')
    if !ids.length
      return $q.when vm.lookup['MenuItems']
    return MenuItemsResource.get( ids )
    .then (result)->
      _.each result, (o)->
        vm.lookup['MenuItems'][o.id] = o
        return
      return vm.lookup['MenuItems']

  getEventIdsByMenuItemId = (mid)->
    filter = {menuItemId: mid}
    return ContributionsResource.query(filter).then (results)->
      eventIds = _.chain( results ).pluck('eventId').uniq().value()
      vm.lookup['EventsByMenuId'][mid] = eventIds
      # $log.info "EventIds=" + JSON.stringify eventIds
      return eventIds

  getEvents = (eids)->
    missing = _.difference eids, _.keys vm.lookup['Events']
    return $q.when() if _.isEmpty missing
    $log.info "loading EventIds=" + JSON.stringify missing
    return EventsResource.get(missing).then (results)->
      _.each results, (o)->
        vm.lookup['Events'][o.id] = o
      $log.info "loaded Event, title=" + JSON.stringify _.pluck( results, 'title')
      return


  $scope.$on '$ionicView.loaded', (e)->
    $log.info "viewLoaded for MenuItemCtrl"
    initialize()

  $scope.$on '$ionicView.enter', (e)->
    $log.info "viewEnter for MenuItemCtrl"
    activate()

  $scope.$on '$ionicView.beforeLeave', (e)->
    $log.info "viewLeave for MenuItemCtrl"
    $location.search('menu', null)

  return # end MenuItemCtrl


MenuItemCtrl.$inject = [
  '$scope', '$rootScope', '$q', '$location','$stateParams', '$timeout'
  '$ionicScrollDelegate'
  '$log', 'toastr'
  'MenuItemsResource', 'ContributionsResource', 'EventsResource'
  'appModalSvc'
  'utils', 'devConfig', 'exportDebug'
]

angular.module 'starter.home'
  .controller 'MenuItemCtrl', MenuItemCtrl
