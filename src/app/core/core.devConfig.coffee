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

angular.module 'starter.core'
  .factory 'devConfig', DevConfig