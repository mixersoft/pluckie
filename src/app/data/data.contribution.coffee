'use strict'
# join table for Event, MenuItem, Users
ContributionsResource = (Resty, amMoment) ->
  # key = [eventId,menuitemId,contributorId]
  data = {
    0:
      eventId: "0"
      menuItemId: "10"
      contributorId: "1"
      portions: 6
      sort: "0"
    1:
      eventId: "0"
      menuItemId: "11"
      contributorId: "0"
      portions: 12
      sort: 5
    2:
      eventId: "0"
      menuItemId: "12"
      contributorId: null
      portions: 0
      sort: "10"
    3:
      eventId: "0"
      menuItemId: "13"
      contributorId: "0"
      portions: 12
      sort: 15
    4:
      eventId: "0"
      menuItemId: "14"
      contributorId: null
      portions: 0
      sort: 20

  }
  return service = new Resty(data)


ContributionsResource.$inject = ['Resty','amMoment']

angular.module 'starter.core'
  .factory 'ContributionsResource', ContributionsResource