'use strict'

appRun = (routerHelper) ->
  routerHelper.configureStates getStates()

getStates = ->
  [
    state: 'app.events'
    config:
      url: '/events/:filter'
      views:
        'menuContent':
          templateUrl: 'events/events.html'
          controller: 'EventsCtrl as vm'
  ,
    state: 'app.event-detail'
    config:
      url: '/event-detail/:id?:invitation'
      views:
        'menuContent':
          templateUrl: 'events/eventDetail.html'
          controller: 'EventDetailCtrl as vm'
  ,
    state: 'app.event-detail.invitation'
    config:
      url: '^/app/invitation/:invitation'
      views:
        'menuContent':
          templateUrl: 'events/eventDetail.html'
          controller: 'EventDetailCtrl as vm'
  ]

appRun.$inject = ['routerHelper']

angular
  .module 'starter.events'
  .run appRun
