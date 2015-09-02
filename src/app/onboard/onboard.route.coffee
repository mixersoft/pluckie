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
  ]

appRun.$inject = ['routerHelper']

angular
  .module 'starter.home'
  .run appRun
