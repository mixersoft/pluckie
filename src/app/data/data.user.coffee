'use strict'

UsersResource = (Resty, amMoment) ->
  # coffeelint: disable=max_line_length
  data = {
    10:
      firstname  : 'Michael'
      lastname   : 'Lin'
      username   : 'mixersoft'
      displayName: 'Michael'
      face       : "http://snappi.snaphappi.com/svc/storage/DEQBCEektV/.thumbs/bm~me-2015.jpg"
    0:
      firstname  : 'Masie'
      lastname   : 'May'
      username   : 'maymay'
      displayName: 'maymay'
      face       : Resty.lorempixel 200, 200, 'people'
    1:
      firstname  : 'Marky'
      lastname   : 'Mark'
      username   : 'marky'
      displayName: 'marky'
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
  # coffeelint: enable=max_line_length
  # add id to lorempixel urls
  _.each data, (v,k)->
    v.face += k if /lorempixel/.test v.face
    return

    
  return service = new Resty(data)


UsersResource.$inject = ['Resty','amMoment']

angular.module 'starter.core'
  .factory 'UsersResource', UsersResource