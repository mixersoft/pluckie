'use strict'

appRun = (routerHelper) ->
  routerHelper.configureStates getStates()

getStates = ->
  [
    state: 'app.onboard'
    config:
      url: '/how-it-works'
      views:
        'menuContent':
          templateUrl: 'onboard/onboard.html'
          controller: 'OnboardCtrl as vm'
  ,
    state: 'app.welcome'
    config:
      url: '/welcome'
      views:
        'menuContent':
          templateUrl: 'onboard/welcome.html'
          controller: 'OnboardCtrl as vm'
  ]

appRun.$inject = ['routerHelper']

angular
  .module 'starter.home'
  .run appRun
