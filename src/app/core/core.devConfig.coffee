'use strict'


# helper functions to set up dev testing
DevConfig = ($rootScope, UsersResource, ParticipationsResource
  $q, $sessionStorage
  $log, exportDebug
  )->

  exportDebug.set('sess', $sessionStorage)

  self = {
    loginUser : (id, force=true)->
      # manually set current user for testing
      $rootScope.user = $sessionStorage['me']
      return $q.when( $rootScope.user ) if $rootScope.user? && !force
      return UsersResource.get( id ).then (user)->
        # check if this is an invitation response sign-in
        if $rootScope['user']?.participation?
          # promote anonymous participation to user participation
          data = angular.copy $rootScope['user'].participation
          data['participantId'] = user.id
          data['responseId'] = null
          data['responseName'] = null
          skip = ParticipationsResource.put(data.id, data)
          .then (result)->
            delete $rootScope['user'].participation
            $rootScope.$broadcast 'event:participant-changed', result

        $rootScope['user'] = $sessionStorage['me'] =  user
        $rootScope.$emit 'user:sign-in', $rootScope['user']
        return $rootScope['user']
      .catch (err)->
        return $rootScope['user'] = $sessionStorage['me'] =  {}
  }
  
  return self # DevConfig


DevConfig.$inject = ['$rootScope', 'UsersResource', 'ParticipationsResource'
'$q', '$sessionStorage'
'$log', 'exportDebug']


ExportDebug = ($window)->
  # export as JS global for introspection
  $window._dbg = _dbg = {}

  self = {
    set: (label, value) ->
      return if !label
      return _dbg[label] = value
    clear: (label)->
      delete _dbg[label]
  }
  return self

ExportDebug.$inject = ['$window']



angular.module 'starter.core'
  .factory 'exportDebug', ExportDebug
  .factory 'devConfig', DevConfig
  