'use strict'

HandyStuff = ($window, $document, amMoment
  $ionicPlatform, $cordovaInAppBrowser, toastr
  ) ->
  self = {
    # format img.src as background img
    # usage: img.hero(ng-style="{{imgInBg(url)}}")
    imgAsBg: (url)->
      return {
        'background': "url({src}) center center".replace('{src}', url)
        'background-size': 'cover'
      }

    openExternalLink: (ev, src)->
      return true if ionic.Platform.isWebView() == false

      # use inAppBrowser plugin, then preventDefault()

      ev.preventDefault()
      $ionicPlatform.ready ()->
        options = {
          location: 'no'
          clearcache: 'yes'
          toolbar: 'yes'
        }
        # $cordovaInAppBrowserProvider.setDefaultOptions(options)
        target = '_blank'  # [_blank|_system]
        windowRef = $cordovaInAppBrowser.open( src, target, options)
        .then (ev)->
          return ev
        .catch (err)->
          toastr.error("Error openExternalLink")
      # $rootScope.$on '$cordovaInAppBrowser:loadstart', (e, ev)->
      # $rootScope.$on '$cordovaInAppBrowser:loadstop', (e, ev)->
      # $rootScope.$on '$cordovaInAppBrowser:loaderror', (e, ev)->
      # $rootScope.$on '$cordovaInAppBrowser:exit', (e, ev)->
      return false

  }
  return self


HandyStuff.$inject = ['$window', '$document', 'amMoment'
'$ionicPlatform', '$cordovaInAppBrowser', 'toastr'
]

angular.module 'starter.core'
  .factory 'utils', HandyStuff
