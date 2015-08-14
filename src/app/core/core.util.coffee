'use strict'

HandyStuff = ($window, $document, amMoment) ->
  self = {
    # format img.src as background img
    # usage: img.hero(ng-style="{{imgInBg(url)}}")
    imgAsBg: (url)->
      return {
        'background': "url({src}) center center".replace('{src}', url)
        'background-size': 'cover'
      }
  }
  return self


HandyStuff.$inject = ['$window', '$document', 'amMoment']

angular.module 'starter.core'
  .factory 'utils', HandyStuff
