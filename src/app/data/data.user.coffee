'use strict'

UsersResource = (Resty, amMoment) ->
  data = {
    0:
      firstname  : 'Marky'
      lastname   : 'Mark'
      username   : 'marky'
      displayName: 'marky'
      face       : Resty.lorempixel 200, 200, 'people'
    1:
      firstname  : 'Masie'
      lastname   : 'May'
      username   : 'maymay'
      displayName: 'maymay'
      face       : Resty.lorempixel 200, 200, 'people'
    2:
      firstname  : 'Lucy'
      lastname   : 'Lu'
      username   : 'lulu'
      displayName: 'lulu'
      face       : Resty.lorempixel 200, 200, 'people'
    3:
      firstname  : 'Chucky'
      lastname   : 'Chu'
      username   : 'chuchu'
      displayName: 'chuchu'
      face       : Resty.lorempixel 200, 200, 'people'

  }
  # add id to lorempixel urls
  _.each data, (v,k)->
    v.face += k
    return

    
  return service = new Resty(data)


UsersResource.$inject = ['Resty','amMoment']

angular.module 'starter.core'
  .factory 'UsersResource', UsersResource