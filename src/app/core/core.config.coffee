'use strict'

appRun = ($ionicPlatform) ->

  $ionicPlatform.ready ->
    # Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    # for form inputs)
    if window.cordova and window.cordova.plugins and window.cordova.plugins.Keyboard
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar true

    if window.StatusBar
      # org.apache.cordova.statusbar required
      StatusBar.styleLightContent()

  return # appRun

toastrConfig = (toastrConfig) ->
  angular.extend toastrConfig, {
    timeOut: 4000
    positionClass: 'toast-bottom-right'
  }





appRun.$inject = ['$ionicPlatform']

angular
  .module 'starter.core'
  .config toastrConfig
  .run appRun


