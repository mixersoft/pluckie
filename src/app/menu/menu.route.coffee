'use strict'

appRun = (routerHelper) ->
  routerHelper.configureStates getStates()

getStates = ->
  [
    state: 'app.menu-ideas'
    config:
      url: '/ideas/:filter'
      views:
        'menuContent':
          templateUrl: 'menu/menu-idea.html'
          controller: 'MenuIdeasCtrl as vm'
  ,
    state: 'app.menu-item'
    config:
      url: '/menu-item/:id'
      views:
        'menuContent':
          templateUrl: 'menu/menu-item.html'
          controller: 'MenuItemCtrl as vm'
  ]

appRun.$inject = ['routerHelper']

angular
  .module 'starter.menu'
  .run appRun
