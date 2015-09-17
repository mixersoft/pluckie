'use strict'

appRun = (routerHelper, $rootScope) ->
  routerHelper.configureStates getStates()

getStates = ->
  [
    state: 'app.profile'
    config:
      url: '/profile/{id}'
      views:
        'menuContent':
          templateUrl: 'people/profile.html'
          controller: 'ProfileCtrl as vm'
  ,
    state: 'app.me'
    config:
      url: '/me'
      views:
        'menuContent':
          templateUrl: 'people/my-profile.html'
          controller: 'ProfileCtrl as vm'
      data:
        requireLogin: true

  ]

appRun.$inject = ['routerHelper', '$rootScope']

angular
  .module 'starter.profile'
  .run appRun
