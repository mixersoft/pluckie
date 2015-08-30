'use strict'

# helper functions to set up dev testing
DevConfig = ($rootScope, UsersResource, $q, $log)->
  self = {
    loginUser : (id, force=true)->
      # manually set current user for testing
      return $q.when( $rootScope.user ) if $rootScope.user? && !force
      return UsersResource.get( id ).then (user)->
        $log.info "Sign-in for id=" + user.id
        return $rootScope['user'] = user

  }
  
  return self # DevConfig


DevConfig.$inject = ['$rootScope', 'UsersResource', '$q', '$log']



ExportDebug = ($window)->
  # export as JS global for introspection
  $window._debug = _debug = {}

  self = {
    set: (label, value) ->
      return if !label
      return _debug[label] = value
    clear: (label)->
      delete _debug[label]
  }
  return self

ExportDebug.$inject = ['$window']


angular.module 'starter.core'
  .factory 'devConfig', DevConfig
  .factory 'exportDebug', ExportDebug