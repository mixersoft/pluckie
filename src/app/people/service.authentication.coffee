'use strict'

# helper functions for managing user Authentication, Authorization, & Accounting
# works with sign-in-register directive
# for more ideas
# see: http://brewhouse.io/blog/2014/12/09/authentication-made-simple-in-single-page-angularjs-applications.html
#
AAAHelpers = ($rootScope, $q, $location, $timeout
  UsersResource
  appModalSvc
  utils, devConfig, $log, toastr)->
  self = {
    isAnonymous: ()->
      return true if _.isEmpty $rootScope.user
      return false

    # example: AAAHelpers.signIn.apply(vm, arguments)
    signIn: (person, fnComplete)->
      return $q.when()
      .then (result)->
        # TODO: do password sign-in
        return $q.reject("NOT FOUND") if !person.username
        username = person.username.toLowerCase().trim()
        return UsersResource.query({username:username})
      .then (results)->
        if results.length
          return person = results.shift()
        return $q.reject("NOT FOUND")
      .then (person)->
        return devConfig.loginUser( person.id , true)
        .then (user)->
          $rootScope.$emit 'user:sign-in', $rootScope['user']
          utils.ga_Send('send', 'event', 'aaa', 'sign-in', 'sign-in', 10)
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

    #  example: AAAHelpers.register.apply(vm, arguments)
    register: (person, fnComplete)->
      return $q.when()
      .then (result)->
        return $q.reject('REQUIRED VALUE') if !person.username
        username = person.username.toLowerCase().trim()
        return UsersResource.query({username:username})
      .then (results)->
        if results.length
          return $q.reject('DUPLICATE USERNAME')
        person.face = UsersResource.randomFaceUrl()
        user = angular.copy person
        user.username = user.username.toLowerCase().trim()
        return UsersResource.post(user)
      .then (person)->
        return devConfig.loginUser( person.id , true)
        .then (user)->
          # $rootScope.$emit 'user:sign-in', $rootScope['user']
          utils.ga_Send('send', 'event', 'aaa', 'register', 'register', 10)
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

    # exaple AAAHelpers.showSignInRegister.apply(vm, arguments)
    showSignInRegister: (initialSlide)->
      vm = this
      SlideController = {
        index: null
        slideLabels: ['signup', 'signin']
        initialSlide: initialSlide || 'signup'
        setSlide: (label)->
          if SlideController.index==null
            $timeout ()->
              # ionSlideBox not yet initialized/compiled, wrap in $timeout
              # $log.info "timeout(0)"
              label = SlideController.initialSlide if !label
              return SlideController.setSlide(label)
            return SlideController.index = 0

          return SlideController.index if `label==null` # for active-slide watch

          label = SlideController.initialSlide if label == 'initial'
          i = SlideController.slideLabels.indexOf(label)
          next = if i >= 0 then i else SlideController.index
          SlideController.index = next
          utils.ga_PageView('/' + label, '.' + label, 'append')
          return

        signIn: (person, fnComplete)->
          return self.signIn(person, fnComplete)
        register: (person, fnComplete)->
          return self.register(person, fnComplete)
      }

      return $q.when()
      .then ()->
        return appModalSvc.show('people/sign-in-sign-up.modal.html', vm, {
          person: {}
          slideCtrl: SlideController
        })
      .then (result)-> # closeModal(result)
        return $q.reject('CANCELED') if `result==null` || result == 'CANCELED'
        return $q.reject(result) if result?['isError']
        return result
  }
  
  return self # AAAHelpers


AAAHelpers.$inject = ['$rootScope', '$q', '$location', '$timeout'
'UsersResource'
'appModalSvc'
'utils', 'devConfig', '$log', 'toastr']


angular.module 'starter.profile'
  .factory 'AAAHelpers', AAAHelpers
