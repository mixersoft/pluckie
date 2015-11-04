'use strict'

ProfileCtrl = (
  $scope, $rootScope, $q, $location, $timeout, $state, $stateParams
  $ionicScrollDelegate
  ParticipationsResource, EventsResource
  $log, toastr
  UsersResource, AAAHelpers
  utils, devConfig, exportDebug
  )->
    # coffeelint: disable=max_line_length
    ANON_USER = {
      id: false
      displayName: 'Just Visiting?'
      face: 'http://38.media.tumblr.com/acccd28f5b5183011cca2f279874da79/tumblr_inline_niuxsprCsL1t9pm9x.png'
    }
    # coffeelint: enable=max_line_length

    vm = this
    vm.title = "Profile"
    vm.me = null      # current user, set in initialize()
    vm.lookup = {}
    vm.imgAsBg = utils.imgAsBg
    vm.isDev = utils.isDev
    vm.acl = {
      isVisitor: ()->
        return true if !$rootScope.user
      isUser: ()->
        return true if $rootScope.user
    }
    vm.settings = {
      view:
        show: 'signin'    # [signin|profile|account]
      editing: false
      changePassword: false
    }
    vm.on = {
      scrollTo: (anchor)->
        $location.hash(anchor)
        $ionicScrollDelegate.anchorScroll(true)
        return

      setView: (value)->
        if 'value==null'
          next = if vm.settings.show == 'less' then 'more' else 'less'
          return vm.settings.show = next
        return vm.settings.show = value
      resetForm: ()->
        vm.person = angular.copy(vm.me)
        vm.settings.view.show = "profile"
        $timeout ()->
          vm.settings.editing = false
        return

      showSignInRegister: (action)->
        return AAAHelpers.showSignInRegister.call(vm, action)
        .then (user)->
          vm.me = $rootScope.user
          activate()
          $log.info vm.me

      signOut: ()->
        vm.me = devConfig.signOut()
        $rootScope.$emit 'user:sign-out'
        activate()


      notReady: (value)->
        toastr.info "Sorry, " + value + " is not available yet"
        return false

      updateProfile: (person, changePassword)->
        if changePassword.new?
          # validate changePassword.old
          promise = $q.when changePassword
        else
          promise = $q.when()
        promise
        .catch (o)->
          # error updating password
          return o
        .then ()->
          # update profile attributions
          id = vm.me.id
          return UsersResource.put(id, person)
        .then (result)->
          _.extend vm.me, result
          vm.person = angular.copy(vm.me)
          $log.info "Updated profile " + JSON.stringify vm.person
          $timeout ()->vm.settings.editing = false
    }

    $scope.dev = {
      settings:
        show: 'less'
      on:
        selectUser: ()->
          UsersResource.query()
          .then (result)->
            vm.people = _.indexBy result, 'id'
            $scope.dev.settings.show = 'admin'
            $timeout ()-> vm.on.scrollTo('admin-change-user')
        loginUser: (person)->
          devConfig.loginUser( person.id )
          .then (user)->   # sets $rootScope.user
            vm.me = $rootScope.user
            toastr.info "You are now " + person.displayName
            $scope.dev.settings.show = 'less'
            activate()
            return user

    }

    initialize = ()->
      # dev
      DEV_USER_ID =
        if utils.isDev() then '10' else null # '0'
      devConfig.loginUser( DEV_USER_ID , false)
      .then (user)->
        vm.me = $rootScope.user
        activate()
        vm.on.scrollTo()

    activate = ()->
      if $state.is('app.me')
        vm.person = angular.copy(vm.me)
        if _.isEmpty vm.person
          vm.person = ANON_USER
          vm.settings.view.show = 'signin'
        else
          vm.settings.view.show = 'profile'
        vm.settings.editing = false
        vm.settings.changePassword = false
        getMyEvents(vm.me)
        return

      if $state.is('app.profile')
        userid = $stateParams.id
        if !userid
          toastr.warning "Sorry, that profile was not found."
          $rootScope.goBack()
          return
        else if userid == vm.me.id
          # looking at my own profile
          vm.person = vm.me
          promise = $q.when vm.person
        else
          # viewing someone else's profile
          promise = UsersResource.get(userid)
          .then (user)->
            return vm.person = user
        return promise
        .then (user)->
          getMyEvents(user)

    getMyEvents = (user)->
      return $q.when()
      .then ()->
        return ParticipationsResource.query({participantId: user.id})
      .then (result)->
        eventIds = _.pluck result, 'eventId'
        vm.lookup['ParticipationsByEventId'] = _.indexBy result, 'eventId'
        return EventsResource.get(eventIds)
      .then (result)->
        vm.lookup['Events'] = _.indexBy result, 'id'
        now = new Date().toJSON()
        _.each result, (o)->
          o['calendar'] = moment(o.startTime).calendar()
          o['isComplete'] = o.startTime < now
          return
        result = _.sortBy( result, 'startTime').reverse()
        vm.lookup['Hosting'] = _.filter result, {ownerId: user.id}
        vm.lookup['Participating'] = _.filter result, (o)-> return o.ownerId != user.id
        return result
      .then (result)->
        'done'



    $scope.$watch 'vm.person', (newV, oldV)->
      vm.settings.editing = true if $state.is('app.me')
    , true


    $scope.$on '$ionicView.loaded', (e)->
      $log.info "viewLoaded for ProfileCtrl"
      initialize()

    $scope.$on '$ionicView.enter', (e)->
      $log.info "viewEnter for ProfileCtrl"
      activate()

    return # end ProfileCtrl


ProfileCtrl.$inject = [
  '$scope', '$rootScope', '$q', '$location', '$timeout', '$state', '$stateParams'
  '$ionicScrollDelegate'
  'ParticipationsResource', 'EventsResource'
  '$log', 'toastr'
  'UsersResource', 'AAAHelpers'
  'utils', 'devConfig', 'exportDebug'
]

angular.module 'starter.home'
  .controller 'ProfileCtrl', ProfileCtrl
