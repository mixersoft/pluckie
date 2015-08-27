'use strict'

# helper functions to set up dev testing
DevConfig = ($rootScope, UsersResource)->
  self = {
    loginUser : (id)->
      # manually set current user for testing
      return UsersResource.get( id ).then (user)->
        $rootScope['user'] = user
        return user
  }
  
  return self # DevConfig


DevConfig.$inject = ['$rootScope', 'UsersResource']



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