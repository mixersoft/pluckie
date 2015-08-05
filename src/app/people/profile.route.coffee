'use strict'

appRun = (routerHelper) ->
  routerHelper.configureStates getStates()

getStates = ->
  [
    state: 'app.profile'
    config:
      url: '/profile'
      views:
        'menuContent':
          templateUrl: 'people/profile.html'
          controller: 'ProfileCtrl as vm'
  ]

appRun.$inject = ['routerHelper']

angular
  .module 'starter.profile'
  .run appRun
