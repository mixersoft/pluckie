'use strict'

HomeCtrl = (
  $scope, $rootScope, $q, $location, $timeout
  $ionicScrollDelegate, $ionicHistory
  $log, toastr
  HomeResource, EventsResource, MenuItemsResource
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
    loadMore: false
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

    loadMore: ()->
      vm.cards = vm.cards.concat( angular.copy vm.all )
      startMaterialEffects()
      vm.settings.more = false if vm.cards > 12

  }

  appendCardClasses = (items)->
    promises = []
    events = _.filter items, {class:'event'}
    promises.push EventsResource.get( _.pluck( events, 'classId')).then (classItems)->
      _.each events, (item)->
        event = _.find classItems, {id: item.classId}
        if event
          item.title = event['title']
          item.heroPic = event['heroPic']
          # TODO: use gotoState()
          item.target = 'app.event-detail({id:' + event.id + '})'
          item.description = 'Event'
        return
      return classItems

    menuItems = _.filter items, {class:'menuItem'}
    promises.push MenuItemsResource.get( _.pluck( menuItems, 'classId')).then (classItems)->
      _.each menuItems, (item)->
        mitem = _.find classItems, {id: item.classId}
        if mitem
          item.title = mitem['title']
          item.heroPic = mitem['pic']
          # TODO: use gotoState()
          item.target = 'app.menu-item({id:' + mitem.id + '})'
          item.description = 'Menu Item'
        return
      return classItems
    return $q.all promises


  getData = () ->
    HomeResource.query().then (cards)->
      vm.cards = angular.copy( vm.all = cards )
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
    .then (cards)->
      appendCardClasses(cards)
    .then ()->
      vm.cards = angular.copy( vm.all )


    # dev
    DEV_USER_ID = '3'
    devConfig.loginUser( DEV_USER_ID , false).then (user)->
      vm.me = $rootScope.user


  activate = ()->
    $ionicHistory.clearHistory()
    ionicMaterialInk.displayEffect()
    startMaterialEffects()
    return

  $scope.$on '$ionicView.loaded', (e)->
    $log.info "viewLoaded for HomeCtrl"
    initialize()

  $scope.$on '$ionicView.enter', (e)->
    $log.info "viewEnter for HomeCtrl"
    activate()

  $scope.$on '$ionicView.beforeEnter', (e)->
    if $rootScope['welcomeDone']
      _.remove vm.cards, {title:'Welcome'}


  $rootScope.$on '$stateNotFound', (ev, toState)->
    ev.preventDefault()
    toastr.info "Sorry, that option is not ready."

  return # end HomeCtrl


HomeCtrl.$inject = [
  '$scope', '$rootScope', '$q', '$location', '$timeout'
  '$ionicScrollDelegate', '$ionicHistory'
  '$log', 'toastr'
  'HomeResource', 'EventsResource','MenuItemsResource'
  'ionicMaterialMotion', 'ionicMaterialInk'
  'utils', 'devConfig', 'exportDebug'
]

angular.module 'starter.home'
  .controller 'HomeCtrl', HomeCtrl




