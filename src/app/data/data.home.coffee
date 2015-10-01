'use strict'

HomeResource = (Resty, amMoment) ->
  className = 'Home'
  # coffeelint: disable=max_line_length
  data = {
    0:
      layout: "tile-center"
      color: "royal"
      title: "Welcome"
      heroPic: '' # "http://www.self.com/wp-content/uploads/2015/03/chef-cooking.jpg"
      target: "app.welcome"
    10:
      layout: "tile-left"
      color: ""
      title: "Coming Soon"
      heroPic: "http://lghttp.34290.nexcesscdn.net/801006C/new/media/catalog/product/cache/1/image/9df78eab33525d08d6e5fb8d27136e95/5/0/50949.jpg"
      target: "app.events({filter:'comingSoon'})"
    11:
      layout: "tile-left"
      color: ""
      title: "Nearby"
      heroPic: "http://www.offthegridnews.com/wp-content/uploads/2015/02/Google-maps-techmeupDOTnet.jpg"
      target: "app.events({filter:'nearby'})"
    12:
      layout: "tile-center"
      color: "positive"
      title: "How It Works"
      heroPic: '' # "http://www.self.com/wp-content/uploads/2015/03/chef-cooking.jpg"
      target: "app.onboard"
    13:
      layout: "tile-right"
      class: "event"
      classId: 2
      target: 'app.className'
    15:
      layout: "tile-right"
      color: ""
      class: "menuItem"
      classId: 22
      target: 'app.className'
    16:
      layout: "tile-left"
      color: ""
      title: "Menu Ideas"
      heroPic: "http://lorempixel.com/400/200/food/4"
      target: "app.menu-ideas({filter:'all'})"
    17:
      layout: "tile-right"
      color: ""
      class: "menuItem"
      classId: 24
      target: 'app.className'
    18:
      layout: "tile-left"
      color: ""
      title: "Recent Meals"
      heroPic: "http://lorempixel.com/400/200/food/6"
      target: "app.events({filter:'recent'})"
    19:
      layout: "tile-right"
      class: "event"
      classId: 0
      target: 'app.className'
    20:
      layout: "tile-left"
      color: ""
      title: "Mains"
      heroPic: "http://lorempixel.com/400/200/food/7"
      target: "app.menu-ideas({filter:'main'})"
    26:
      layout: "tile-left"
      color: ""
      title: "Sides"
      heroPic: "http://lorempixel.com/400/200/food/8"
      target: "app.menu-ideas({filter:'side'})"
  }
  # coffeelint: enable=max_line_length
  return service = new Resty(data, className)


HomeResource.$inject = ['Resty','amMoment']

angular.module 'starter.core'
  .factory 'HomeResource', HomeResource