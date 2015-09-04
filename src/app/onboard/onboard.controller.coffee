'use strict'

OnboardCtrl = (
  $scope, $rootScope, $q, $state, $timeout
  $ionicSlideBoxDelegate
  $log, toastr
  HomeResource, EventsResource, MenuItemsResource
  ionicMaterialMotion, ionicMaterialInk
  utils, devConfig, exportDebug
  )->

  vm = this
  vm.title = "How It Works"
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
    auto: true
  }
  vm.on = {
    slideChanged : ($index)->
      # toastr.info "slide number " + $index
      return
    slideClick: ()->
      vm.settings.auto = !vm.settings.auto
      if vm.settings.auto
        $ionicSlideBoxDelegate.start()
      else
        $ionicSlideBoxDelegate.stop()
    pagerClick: ($index)->
      # toastr.info "slide number " + $index
      $ionicSlideBoxDelegate.slide($index)
      return
    getStarted: ()->
      $state.transitionTo('app.home')
      $timeout ()->
        $ionicSlideBoxDelegate.slide(0, 0)
    welcomeDone: ()->
      $rootScope['welcomeDone'] = true
      $state.transitionTo('app.home')

  }

  vm.cards = cards_onboard = [
    title   : "Community Meals"
    subTitle: "from the humble to exhalted"
    content : """
    
    """
    template: ''
  ,
    title   : "Find"
    subTitle: "them around the block <span class='nowrap'>or around the world</span>"
    content : """
    Search at home or on the road.
    Whether it be food, friends, or culture you can always discover something new.
    """
  ,
    title   : "Contribute"
    subTitle: "to the shared experience"
    content : """
    Show some pluck, give it your best shot.
    Bring something special and shout it out.
    Or just bring dough.
    """
  ,
    title   : "Host"
    subTitle: "meals for old friends or new"
    content : """
    Let the world come to your door, or just your friends.
    But craft your shared experience with control over the menu and guest list.
    """
  ,
    title   : "Elevate"
    subTitle: "the Community Meal"
  ]


  initialize = ()->
    # dev
    DEV_USER_ID = '3'
    devConfig.loginUser( DEV_USER_ID , false).then (user)->
      vm.me = $rootScope.user


  activate = ()->
    # switch $state.current.name
    #   when 'app.onboard'
    #     vm.cards = cards_onboard
    #   when 'app.welcome'
    #     vm.cards = cards_onboard
    return

  $scope.$on '$ionicView.loaded', (e)->
    $log.info "viewLoaded for OnboardCtrl"
    initialize()

  $scope.$on '$ionicView.enter', (e)->
    $log.info "viewEnter for OnboardCtrl"
    activate()

  return # end OnboardCtrl


OnboardCtrl.$inject = [
  '$scope', '$rootScope', '$q', '$state', '$timeout'
  '$ionicSlideBoxDelegate'
  '$log', 'toastr'
  'HomeResource', 'EventsResource','MenuItemsResource'
  'ionicMaterialMotion', 'ionicMaterialInk'
  'utils', 'devConfig', 'exportDebug'
]

angular.module 'starter.home'
  .controller 'OnboardCtrl', OnboardCtrl




