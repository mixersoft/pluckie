'use strict'

otherwisePath = '/app/home'

appRun = (routerHelper) ->
  routerHelper.configureStates getStates(), otherwisePath

getStates = ->
  [
    state: 'tab'
    config:
      url: '/tab'
      abstract: true
      templateUrl: 'layout/tabs.html'
  ,
    state: 'app'
    config:
      url: '/app'
      abstract: true
      templateUrl: 'layout/sidemenu.html'
      # controller: 'AppCtrl'
      # controllerAs: 'vm'
  ]

appRun.$inject = ['routerHelper']

angular
  .module 'starter.layout'
  .run appRun
