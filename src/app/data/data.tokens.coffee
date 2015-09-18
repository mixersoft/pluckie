'use strict'
# Manages Tokens on Classes
TokensResource = (Resty, amMoment, $q) ->
  # key = [eventId,menuitemId,contributorId]
  data = {
    'abcd':
      ownerId: '10'
      target: 'Event:2'  # ClassName:id
      views: 2
      expireCount: 3
      expireDate: moment().weekday(4).hour(20).startOf('hour').toJSON()
      accessors: []
    '1234':
      ownerId: '1'
      target: 'Event:1'  # ClassName:id
      views: 12
      expireCount: 100
      expireDate: moment().weekday(4).add(14,'d').hour(20).startOf('hour').toJSON()
      accessors: []

  }
  service = new Resty(data)

  service.isValid = (token, className, id)->
    return $q.reject('INVALID') if !token
    return $q.when()
    .then ()->
      return service.get(token) if _.isString token
      return token
    .then (result)->
      target = [className,id].join(':')
      return $q.reject('INVALID') if result.target != target
      return $q.reject('EXPIRED') if service.isTokenValid(result) == false
      # save after incrementing token.views
      skip = nakedPut.call(service, result.id, _.pick(result, ['views','accessors']))
      return 'VALID'

  service.isTokenValid = (token)->
    token.views++
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