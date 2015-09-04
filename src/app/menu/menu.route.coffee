'use strict'

appRun = (routerHelper) ->
  routerHelper.configureStates getStates()

getStates = ->
  [
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
