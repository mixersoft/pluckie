'use strict'

HomeResource = (Resty, amMoment) ->
  # coffeelint: disable=max_line_length
  data = {
    0:
      layout: "tile-left"
      color: ""
      title: "Coming Soon"
      heroPic: "http://lghttp.34290.nexcesscdn.net/801006C/new/media/catalog/product/cache/1/image/9df78eab33525d08d6e5fb8d27136e95/5/0/50949.jpg"
      target: "app.events({filter:'comingSoon'})"
    1:
      layout: "tile-left"
      color: ""
      title: "Nearby"
      heroPic: "http://www.offthegridnews.com/wp-content/uploads/2015/02/Google-maps-techmeupDOTnet.jpg"
      target: "app.events({filter:'nearby'})"
    2:
      layout: "tile-center"
      color: "positive"
      title: "How It Works"
      heroPic: '' # "http://www.self.com/wp-content/uploads/2015/03/chef-cooking.jpg"
      target: "app.onboard"
    3:
      layout: "tile-right"
      class: "event"
      classId: 2
      target: 'app.className'
    4:
      layout: "tile-left"
      color: ""
      title: "Popular Menus"
      heroPic: "http://lorempixel.com/400/200/food/4"
      target: "app.menu({filter:'popular'})"
    5:
      layout: "tile-right"
      color: ""
      class: "menuItem"
      classId: 24
      target: 'app.className'
    6:
      layout: "tile-left"
      color: ""
      title: "Recent"
      heroPic: "http://lorempixel.com/400/200/food/6"
      target: "app.events({filter:'recent'})"


  }
  # coffeelint: enable=max_line_length
  return service = new Resty(data)


HomeResource.$inject = ['Resty','amMoment']

angular.module 'starter.core'
  .factory 'HomeResource', HomeResource