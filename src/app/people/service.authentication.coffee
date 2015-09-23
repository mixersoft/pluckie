'use strict'

# helper functions for managing user Authentication, Authorization, & Accounting
# works with sign-in-register directive
AAAHelpers = ($rootScope, $q, $location, $stateParams
  UsersResource
  appModalSvc
  devConfig, $log, toastr)->
  self = {
    signIn: (person, fnComplete)->
      return $q.when()
      .then (result)->
        # TODO: do password sign-in
        return UsersResource.query({username:person.username})
      .then (results)->
        if results.length
          return person = results.shift()
        return $q.reject("NOT FOUND")
      .then (person)->
        return devConfig.loginUser( person.id , true)
        .then (user)->
          # $rootScope.$emit 'user:sign-in', $rootScope['user']
          return fnComplete?(user) || user
      .catch (err)->
        $rootScope.$emit 'user:sign-out'
        if err == 'NOT FOUND'
          toastr.warning "The Username/password combination was not found. Please try again."
          return false # try again

        if _.isString err
          err = {
            message: err
          }
        err['isError'] = true
        return fnComplete?(err) || err

    register: (person, fnComplete)->
      return $q.when()
      .then (result)->
        return $q.reject('REQUIRED VALUE') if !person.username
        return UsersResource.query({username:person.username})
      .then (results)->
        if results.length
          return $q.reject('DUPLICATE USERNAME')
        person.face = UsersResource.randomFaceUrl()
        return UsersResource.post(person)
      .then (person)->
        return devConfig.loginUser( person.id , true)
        .then (user)->
          # $rootScope.$emit 'user:sign-in', $rootScope['user']
          return fnComplete?(user) || user
      .catch (err)->
        $rootScope.$emit 'user:sign-out'
        if err == 'REQUIRED VALUE'
          toastr.warning "Expecting a username. Please try again."
          return false # try again
        if err == 'DUPLICATE USERNAME'
          toastr.warning "That username was already taken. Please try again."
          return false # try again

        if _.isString err
          err = {
            message: err
          }
        err['isError'] = true
        return fnComplete?(err) || err
  }
  
  return self # AAAHelpers


AAAHelpers.$inject = ['$rootScope', '$q', '$location', '$stateParams'
'UsersResource'
'appModalSvc'
'devConfig', '$log', 'toastr']


angular.module 'starter.profile'
  .factory 'AAAHelpers', AAAHelpers
