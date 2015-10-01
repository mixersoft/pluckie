'use strict'
# Manages Tokens on Classes
TokensResource = (Resty, amMoment, $q) ->
  className = 'Tokens'
  # key = [eventId,menuitemId,contributorId]
  data = {
    'abcd':
      ownerId: '10'
      target: 'Event:2'  # ClassName:id
      views: 2
      expireCount: 30
      expireDate: moment().weekday(4).add(7,'d').hour(20).startOf('hour').toJSON()
      accessors: []
    '1234':
      ownerId: '1'
      target: 'Event:1'  # ClassName:id
      views: 12
      expireCount: 100
      expireDate: moment().weekday(4).add(14,'d').hour(20).startOf('hour').toJSON()
      accessors: []
    '1234567':
      ownerId: '1'
      target: 'Event:1'  # ClassName:id
      views: 3
      expireCount: 10
      expireDate: moment().weekday(4).add(7,'d').hour(20).startOf('hour').toJSON()
      accessors: []
    'justforfun':
      ownerId: '10'
      target: 'Event:3'  # ClassName:id
      views: 3
      expireCount: 50
      expireDate: moment(new Date('2015-10-03')).hour(23).toJSON()
      accessors: []


  }
  service = new Resty(data, className)

  service.isValid = (token, className, id)->
    return $q.reject('INVALID') if !token
    return $q.when()
    .then ()->
      return service.get(token) if _.isString token
      return token
    .then (result)->
      target = [className,id].join(':')
      return $q.reject('INVALID') if result.target != target
      result.views++  # increment views before checking validity
      skip = nakedPut.call(service, result.id, _.pick(result, ['views','accessors']))
      return $q.reject('EXPIRED') if service.isTokenValid(result) == false
      return 'VALID'

  service.isTokenValid = (token)->
    return false if token.views > token.expireCount
    return false if new Date() > new Date(token.expireDate)
    return true

  nakedPut = service.put
  service.put = (id, o, owner)->
    return service.get(id)
    .then (old)->
      return $q.reject('NO_ACCESS') if old.ownerId != owner.id
      return nakedPut(id, o)
  
  return service


TokensResource.$inject = ['Resty','amMoment', '$q']

angular.module 'starter.core'
  .factory 'TokensResource', TokensResource