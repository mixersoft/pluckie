'use strict'

MenuIdeasCtrl = ($scope, $q, $timeout, $stateParams
  $log, toastr, $ionicHistory
  MenuItemsResource, utils
  ionicMaterialMotion, ionicMaterialInk
  ) ->
  vm = this
  vm.title = ""     # filter.label, i.e. [ComingSoon|NearMe|PeLive]
  vm.filter = {}
  vm.menuItems = []
  vm.imgAsBg = utils.imgAsBg

  _filters = {
    'starter':
      label: "Starters"
      filterBy: 'Starter'
    'side':
      label: "Sides"
      filterBy: 'Side'
    'main':
      label: "Mains"
      filterBy: 'Main'
    'dessert':
      label: "Desserts"
      filterBy: 'Dessert'
    'drink':
      label: "Drinks"
      filterBy: 'Drink'
    'all':
      label: "Menu Ideas"
  }

  initialize = ()->
    getData()

  activate = ()->
    $ionicHistory.clearHistory()
    vm.filter = _filters[ $stateParams.filter ] || _filters[ 'all' ]
    vm.title = vm.filter.label
    # TODO: use inline ngFilter instead
    vm.filtered =
      if vm.filter.filterBy?
      then _.filter vm.menuItems, {'category': vm.filter.filterBy}
      else vm.menuItems

    # // Set Ink
    ionicMaterialInk.displayEffect()
    setMaterialEffects()

  sortMenus = (items, filter)->
    items = MenuItemsResource.sortByCategory(items)

    switch filter
      when 'category'
        # _.filter items, {'category': }
        'skip'
      when 'mostPopular'
        return _.filter items, 'count_favorites'
      
    return items
    

  getData = () ->
    MenuItemsResource.query().then (menuItems)->
      menuItems = sortMenus(menuItems, $stateParams.filter)
      vm.menuItems = menuItems
      # toastr.info JSON.stringify( menuItems)[0...50]
      return menuItems

  setMaterialEffects = () ->
    # Set Motion
    # $timeout ()->
    #   ionicMaterialMotion.slideUp({
    #     selector: '.slide-up'
    #   })
    #   return
    # , 300

    # $timeout () ->
    #   ionicMaterialMotion.fadeSlideInRight({
    #     startVelocity: 3000
    #   })
    #   return
    # , 700
    
    $timeout () ->
      ionicMaterialMotion.blinds({
        selector: '[nav-view="active"] .animate-blinds .item'
        startVelocity: 1000
      })
      return
    , 300
    return

  resetMaterialEffects = ()->
    selector = '[nav-view="active"] .animate-blinds .item'
    # make view directive: removeClass('in done out')
    return


  # toastr.info "Creating MenuIdeasCtrl"

  $scope.$on '$ionicView.loaded', (e) ->
    $log.info "viewLoaded for MenuIdeasCtrl"
    initialize()

  $scope.$on '$ionicView.enter', (e) ->
    $log.info "viewEnter for MenuIdeasCtrl"
    activate()

  $scope.$on '$ionicView.leave', (e) ->
    $log.info "viewLeave for MenuIdeasCtrl"
    resetMaterialEffects()
   
   

  return vm # # end MenuIdeasCtrl,  return is required for controllerAs syntax


MenuIdeasCtrl.$inject = [
  '$scope', '$q', '$timeout', '$stateParams'
  '$log', 'toastr', '$ionicHistory'
  'MenuItemsResource', 'utils'
  'ionicMaterialMotion', 'ionicMaterialInk'
]

angular.module 'starter.home'
  .controller 'MenuIdeasCtrl', MenuIdeasCtrl
