'use strict'

appRun = ($rootScope, $ionicPlatform, $ionicHistory, $location
  utils, $state, $sessionStorage
  ) ->

    $rootScope['user'] = $sessionStorage['me']

    $ionicPlatform.ready ->
      # Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
      # for form inputs)
      if window.cordova and window.cordova.plugins and window.cordova.plugins.Keyboard
        cordova.plugins.Keyboard.hideKeyboardAccessoryBar true

      if window.StatusBar
        # org.apache.cordova.statusbar required
        StatusBar.styleLightContent()

    $rootScope.goBack = (noBackTarget = 'app.home')->
      if $ionicHistory.backView()
        $ionicHistory.goBack()
      else
        $state.transitionTo(noBackTarget)
      return

    locationSearch = null
    $rootScope.$on '$stateChangeStart', (ev, toState, toParams, fromState, fromParams)->
      # save $location.search and add back after transition
      locationSearch = $location.search()
      return

    $rootScope.$on '$stateChangeSuccess', (ev, toState, toParams, fromState, fromParams)->
      # addback $location.search  after transition
      $location.search( angular.extend(locationSearch, $location.search()) )
      utils.ga_PageView()
      return


    return # appRun

ionicConfig = ($ionicConfigProvider)->
  $ionicConfigProvider.backButton
    .text('')
    .icon('ion-ios-arrow-back')
    .previousTitleText(false)
  return

toastrConfig = (toastrConfig) ->
  angular.extend toastrConfig, {
    timeOut: 4000
    positionClass: 'toast-bottom-right'
  }





appRun.$inject = ['$rootScope', '$ionicPlatform', '$ionicHistory', '$location'
'utils', '$state', '$sessionStorage'
]

ionicConfig.$inject = ['$ionicConfigProvider']
toastrConfig.$inject = ['toastrConfig']

angular
  .module 'starter.core'
  .config toastrConfig
  .config ionicConfig
  .run appRun


