'use strict'

appRun = (routerHelper) ->
  routerHelper.configureStates getStates()

getStates = ->
  [
    state: 'app.home'
    config:
      url: '/home'
      views:
        'menuContent':
          templateUrl: 'home/home.html'
          controller: 'HomeCtrl as vm'
  ]

appRun.$inject = ['routerHelper']

angular
  .module 'starter.home'
  .run appRun
