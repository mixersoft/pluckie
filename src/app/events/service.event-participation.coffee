'use strict'

# helper functions for managing user actions on events
EventActionHelpers = ($rootScope, $q, $location, $stateParams
  TokensResource
  appModalSvc
  $log)->
  self = {
    getShareLinks: (event)->
      vm = this
      target = null
      return $q.when()
      .then ()->
        return TokensResource.get([$stateParams.invitation]) if $stateParams.invitation
        target = ['Event', event.id].join(':')
        return TokensResource.query({target: target})
      .then (results)->
        # TODO: check invitation for expiration
        # use first invitation
        if results.length
          token = results.shift()
          return token if TokensResource.isTokenValid(token)
        return $q.reject('NONE')
      .catch (err)->
        return $q.reject(err) if /EXPIRED|INVALID|NONE/.test(err) == false
        # TODO: check permission to create new Token
        token = {
          ownerId: vm.me.id
          target: target
          views: 0
          expireCount: 100
          expireDate: event.startTime
          accessors:[]
        }
        return TokensResource.post(token)
      .then (token)->
        path = $location.path()
        origin = $location.absUrl().slice(0, -1*path.length)
        eventLink = origin + '/app/event-detail/' + event.id
        invitationLink = origin + '/app/invitation/' + token.id
        shareLinks = {
          'event': if event.setting.isExclusive then false else eventLink
          'invitation': if event.setting.denyForward then false else invitationLink
          # 'token': if event.setting.denyForward then false else token
        }
        return shareLinks

    showShareLink: (event)->
      vm = this
      return $q.when()
      .then ()->
        return self.getShareLinks.call(vm, event)
      .then (shareLinks)->
        return appModalSvc.show('events/sharing.modal.html', vm, {
          mm:
            item: event
            links: shareLinks
        })
      .then (result)-> # closeModal(result)
        return $q.reject('CANCELED') if `result==null` || result == 'CANCELED'
        return $q.reject(result) if result?['isError']
        return result
  }
  
  return self # EventActionHelpers


EventActionHelpers.$inject = ['$rootScope', '$q', '$location', '$stateParams'
'TokensResource'
'appModalSvc'
'$log']


angular.module 'starter.events'
  .factory 'EventActionHelpers', EventActionHelpers
