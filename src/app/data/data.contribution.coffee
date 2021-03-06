'use strict'
# join table for Event, MenuItem, Users
ContributionsResource = (Resty, amMoment) ->
  className = 'Contributions'
  # key = [eventId,menuitemId,contributorId]
  data = {
    0:
      eventId: "0"
      menuItemId: "10"
      contributorId: "1"
      portions: 6
      comment: ''
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
    10:
      eventId: "1"
      menuItemId: "0"
      contributorId: null
      portions: 0
      sort: 20
    11:
      eventId: "1"
      menuItemId: "1"
      contributorId: null
      portions: 0
      sort: 20
    12:
      eventId: "1"
      menuItemId: "2"
      contributorId: null
      portions: 0
      sort: 20
    13:
      eventId: "1"
      menuItemId: "3"
      contributorId: null
      portions: 0
      sort: 20
    20:
      eventId: "2"
      menuItemId: "20"
      contributorId: "10"
      portions: 16
      portionsRequired: 16
      sort: 20
    21:
      eventId: "2"
      menuItemId: "21"
      contributorId: "10"
      portions: 4
      portionsRequired: 6
      sort: 20
    22:
      eventId: "2"
      menuItemId: "22"
      contributorId: "10"
      portions: 20
      portionsRequired: 20
      sort: 20
    23:
      eventId: "2"
      menuItemId: "23"
      contributorId: "10"
      portions: 20
      portionsRequired: 20
      sort: 20
    24:
      eventId: "2"
      menuItemId: "24"
      contributorId: "10"
      portions: 20
      portionsRequired: 20
      sort: 20
    25:
      eventId: "2"
      menuItemId: "25"
      contributorId: null
      portions: 0
      portionsRequired: 40
      sort: 20
    26:
      eventId: "2"
      menuItemId: "26"
      contributorId: null
      portions: 0
      portionsRequired: 40
      sort: 20
    27:
      eventId: "2"
      menuItemId: "27"
      contributorId: null
      portions: 0
      portionsRequired: 40
      sort: 20
    28:
      eventId: "2"
      menuItemId: "28"
      contributorId: "10"
      portions: 20
      portionsRequired: 20
      sort: 20
    29:
      eventId: "2"
      menuItemId: "29"
      contributorId: "10"
      portions: 20
      portionsRequired: 20
      sort: 20

    31:
      eventId: "3"
      menuItemId: "30"
      contributorId: "10"
      portions: 25
      portionsRequired: 25
      sort: 20
    32:
      eventId: "3"
      menuItemId: "22"
      contributorId: "10"
      portions: 25
      portionsRequired: 25
      sort: 20
    33:
      eventId: "3"
      menuItemId: "23"
      contributorId: "10"
      portions: 25
      portionsRequired: 25
      sort: 20
    35:
      eventId: "3"
      menuItemId: "35"
      contributorId: "10"
      portions: 18
      portionsRequired: 25
      sort: 20
    36:
      eventId: "3"
      menuItemId: "36"
      contributorId: null
      portions: 12
      portionsRequired: 25
      sort: 20
    40:
      eventId: "4"
      menuItemId: "40"
      contributorId: "10"
      portions: 12
      portionsRequired: 12
      sort: 20
    41:
      eventId: "4"
      menuItemId: "41"
      contributorId: "10"
      portions: 12
      portionsRequired: 12
      sort: 20
    42:
      eventId: "4"
      menuItemId: "42"
      contributorId: "10"
      portions: 16
      portionsRequired: 16
      sort: 20
    46:
      eventId: "4"
      menuItemId: "26"
      contributorId: null
      portions: 0
      portionsRequired: 12
      sort: 20
    47:
      eventId: "4"
      menuItemId: "27"
      contributorId: null
      portions: 0
      portionsRequired: 12
      sort: 20
    48:
      eventId: "4"
      menuItemId: "43"
      contributorId: "0"
      portions: 12
      portionsRequired: 12
      sort: 20

  }
  return service = new Resty(data, className)


ContributionsResource.$inject = ['Resty','amMoment']

angular.module 'starter.core'
  .factory 'ContributionsResource', ContributionsResource