'use strict'

HandyStuff = ($window, $document, amMoment
  $location, $state
  $ionicPlatform, $cordovaInAppBrowser, $log, toastr
  ) ->
  self = {
    isDev: ()->
      return false if ionic.Platform.isWebView()
      return $location.host() == 'localhost'
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

    ###
    # @description convert string to 32 bit signed integer
    ###
    a2nHash: (str)->
      hash = 0
      return hash if str.length == 0
      for i in [0...str.length]
        char = str.charCodeAt(i)
        hash = ((hash<<5) - hash) + char
        hash = hash & hash # Convert to 32bit signed integer
      return hash


    ###
    # @description add a random offset to latlon to mask exact location
    # @param latlon Array, [lat,lon] expressed as decimal
    ###
    maskLatLon: (latlon, key)->
      # +- .0025 to lat/lon
      key = key[0..10]
      offset = {
        lat: (self.a2nHash( latlon[0] + key ) % 25) / 10000
        lon: (self.a2nHash( latlon[1] + key ) % 25) / 10000
      }
      # console.log offset
      return [latlon[0]+offset.lat, latlon[1]+offset.lon]


    ###
    # @description helper function for recording state changes as GoogleAnalytics pageview
    # @param page string url
    # @param title string, using $state.current.name by default
    ###
    ga_PageView: (page, title, append)->
      if append
        data = {
          page: $location.path() + page
          title: $state.current.name + title
        }
      else
        data = {
          page: page || $location.path()
          title: title || $state.current.name
        }
      if self.isDev()
        $log.warn "ga-debug, page=" + JSON.stringify data
        return
      ga('set', data)
      ga('send', 'pageview')

    ga_Send: ()->
      if self.isDev()
        $log.warn "ga-debug, send=" + JSON.stringify _.values arguments
        return
      ga.apply(this, arguments)
      

  }
  return self


HandyStuff.$inject = ['$window', '$document', 'amMoment'
'$location', '$state'
'$ionicPlatform', '$cordovaInAppBrowser', '$log', 'toastr'
]

angular.module 'starter.core'
  .factory 'utils', HandyStuff
