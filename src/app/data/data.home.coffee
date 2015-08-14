'use strict'

HomeResource = (Resty, amMoment) ->
  data = {
    0:
      title: "Coming Soon"
      heroPic: "http://lorempixel.com/400/200/food/1"
      target: "app.events({filter:'comingSoon'})"
    1:
      title: "Nearby"
      heroPic: "http://lorempixel.com/400/200/food/2"
      target: "app.events({filter:'nearby'})"
    2:
      title: "How It Works"
      heroPic: "http://lorempixel.com/400/200/food/3"
      target: "app.onboard"
    3:
      title: "Someplace Fun"
      heroPic: "http://lorempixel.com/400/200/food/4"
      target: "app.events({filter:'someplaceFun'})"
    4:
      title: "Picnics"
      heroPic: "http://lorempixel.com/400/200/food/5"
      target: "app.events({filter:'picnics'})"
    5:
      title: "Recent"
      heroPic: "http://lorempixel.com/400/200/food/6"
      target: "app.events({filter:'recent'})"


  }
  return service = new Resty(data)


HomeResource.$inject = ['Resty','amMoment']

angular.module 'starter.core'
  .factory 'HomeResource', HomeResource