'use strict'

UsersResource = (Resty, amMoment) ->
  # coffeelint: disable=max_line_length
  data = {
    10:
      firstname  : 'Michael'
      lastname   : 'Lin'
      username   : 'snaphappi'
      displayName: 'Michael'
      email      : null
      face       : "http://snappi.snaphappi.com/svc/storage/DEQBCEektV/.thumbs/bm~me-2015.jpg"
      about      : ""
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

    # 21:
    #   firstname  : 'Jordan'
    #   lastname   : ''
    #   username   : ''
    #   displayName: ''
    #   face       : null
    # 22:
    #   firstname  : 'Katerina'
    #   lastname   : ''
    #   username   : ''
    #   displayName: ''
    #   face       : null
    # 23:
    #   firstname  : 'Martin'
    #   lastname   : ''
    #   username   : ''
    #   displayName: ''
    #   face       : null
    # 24:
    #   firstname  : 'Misho'
    #   lastname   : ''
    #   username   : ''
    #   displayName: ''
    #   face       : null
    # 25:
    #   firstname  : 'Pamela'
    #   lastname   : ''
    #   username   : ''
    #   displayName: ''
    #   face       : null
    # 26:
    #   firstname  : 'Stassos'
    #   lastname   : ''
    #   username   : ''
    #   displayName: ''
    #   face       : null
    # 27:
    #   firstname  : 'Tony'
    #   lastname   : ''
    #   username   : ''
    #   displayName: ''
    #   face       : null


  }
  # coffeelint: enable=max_line_length
  # add id to lorempixel urls
  _.each data, (v,k)->
    v.face += k if /lorempixel/.test v.face
    return


    
  service = new Resty(data)

  service.randomFaceUrl = (id)->
    id = Date.now() if `id==null`
    return Resty.lorempixel( 200, 200, 'people') + (id % 11)

  return service


UsersResource.$inject = ['Resty','amMoment']

angular.module 'starter.core'
  .factory 'UsersResource', UsersResource