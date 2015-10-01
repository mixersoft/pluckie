'use strict'
# join table for Event, MenuItem, Users
ParticipationsResource = (Resty, amMoment) ->
  className = 'Participations'
  # key = [eventId,menuitemId,contributorId]
  data = {
    0:
      eventId: '0'
      participantId: '0'
      responseId: null
      responseName: null
      response: 'Yes'
      seats: 2
      comment: 'Your host'
    1:
      eventId: '0'
      participantId: '1'
      response: 'Yes'
      seats: 1
      comment: 'T-shirt ramen!'
    2:
      eventId: '0'
      participantId: '2'
      response: 'Yes'
      seats: 3
      comment: 'The whole family is coming'
    10:
      eventId: '1'
      participantId: '1'
      response: 'Yes'
      seats: 1
      comment: 'Your host'
    11:
      eventId: '1'
      participantId: '0'
      response: 'Yes'
      seats: 1
      comment: 'MasieMay in the house!'
    12:
      eventId: '1'
      participantId: '10'
      response: 'Maybe'
      seats: 3
      comment: 'Might go to the beach'
    13:
      comment: "Only if it doesn't rain on the plain in Spain"
      eventId: "1"
      participantId: null
      response: "Maybe"
      responseId: "mypretty~thewickedwitchoftheeast"
      responseName: "The Wicked Witch of the East"
      seats: "3"
    20:
      eventId: '2'
      participantId: '10'
      response: 'Yes'
      seats: 3
      comment: 'Your host'
    30:
      eventId: '3'
      participantId: '10'
      response: 'Yes'
      seats: 3
      comment: 'Your host'
  }
  service = new Resty(data, className)

  service.setResponseId = (data, passcode, peek)->
    return data if data['participantId']?
    throw new Exception "ERROR: expecting data.responseName" if !data.responseName
    key = [passcode, data['responseName'].toLowerCase()].join('~').replace(/ /g,'')
    return key if peek
    data['responseId'] = key
    return data

  service.formatResponse = (data)->
    copy  = angular.copy data
    copy['targetId'] = data.participantId || data.recipient

  return service


ParticipationsResource.$inject = ['Resty','amMoment']

angular.module 'starter.core'
  .factory 'ParticipationsResource', ParticipationsResource