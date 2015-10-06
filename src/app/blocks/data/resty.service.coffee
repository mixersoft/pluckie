'use strict'



Resty = ($q, $sessionStorage) ->

  RestyClass = (@_data = {}, className) ->
    if $sessionStorage[className]
      _.extend @_data , $sessionStorage[className]
      console.log "restoring from SessionStorage"
    # alias to mimic ngResource
    @get = RestyClass::get
    @query = (filter)->
      RestyClass::get.call(this, 'all')
      .then (rows)->
        return rows if !filter
        return _.filter rows, filter

    @save = RestyClass::post
    @update = RestyClass::put
    @remove = RestyClass::delete
    @fields = ['id']
    _.each @_data
    , (o)->
      @fields = _.uniq @fields.concat _.keys o
      return
    , this
    @fields = _.uniq @fields.concat ['createdAt', 'updatedAt']

    # save to SessionStorage
    $sessionStorage[className] = @_data
    return


  RestyClass::get = (id) ->
    return $q.when {} if `id==null`
    self = this

    if id=='all'
      result = _.chain( @_data )
      .each (v,k)->
        v.id = k
        self.afterFetch?(v)
        return
      .value()
      return $q.when angular.copy _.values result

    if _.isArray id
      promises = []
      
      _.each id, (i)->
        promises.push RestyClass::get.call(self, i).catch (err)->
          return $q.when null
        return
      return $q.all( promises).then (o)->
        return angular.copy _.compact o

    result = @_data[id]
    if result?
      result.id = id
      self.afterFetch?(result)
      return $q.when angular.copy result
    return $q.reject false

  RestyClass::post = (o)->
    self = this
    return $q.reject false if `o==null`
    id = Date.now() + '' # force string # _.keys( @_data ).length + ''
    o['id'] = id
    o['updatedAt'] = o['createdAt'] = new Date()
    o = _.pick o, @fields
    self.beforeSave?(o)
    return $q.when angular.copy @_data[id] = o

  RestyClass::put = (id, o) ->
    self = this
    id = id + ''
    return $q.reject false if `o==null`
    if @_data[id]?
      o['id'] = id
      o['updatedAt'] = new Date()
      o = _.pick o, @fields
      self.beforeSave?(o)
      o = _.extend @_data[id], o
      return $q.when angular.copy @_data[id] = o
    return $q.reject false

  RestyClass::delete = (id)->
    return $q.reject false if `id==null` || !@_data[id]
    delete @_data[id]
    return $q.when true

  

  # static methods
  RestyClass.lorempixel = (w,h,cat)->
    # [abstract animals business cats city food nightlife fashion people nature sports technics transport]
    src = "http://lorempixel.com/"
    if w?
      if h1?
        src += w + '/' + h + '/'
      else
        src += w + '/' + w + '/' # degrade to square
    if cat?
      src += cat + '/'
    return src

  return RestyClass

Resty.$inject = ['$q', '$sessionStorage']

angular.module 'blocks.data'
  .factory 'Resty', Resty