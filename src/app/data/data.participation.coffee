'use strict'
# join table for Event, MenuItem, Users
ParticipationsResource = (Resty, amMoment) ->
  # key = [eventId,menuitemId,contributorId]
  data = {
    0:
      eventId: '0'
      participantId: '0'
      seats: 2
      comment: 'Your host'
    1:
      eventId: '0'
      participantId: '1'
      seats: 1
      comment: 'T-shirt ramen!'
    2:
      eventId: '0'
      participantId: '2'
      seats: 3
      comment: 'The whole family is coming'
  }
  return service = new Resty(data)


ParticipationsResource.$inject = ['Resty','amMoment']

angular.module 'starter.core'
  .factory 'ParticipationsResource', ParticipationsResource