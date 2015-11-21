# geocode.service.coffee
'use strict'

###
# @description Google Maps Geocode Service v3
# see https://developers.google.com/maps/documentation/geocoding/intro
###

Geocoder = ($q, $ionicPlatform, KEYS, appModalSvc)->

  ## private methods & attributes
  _geocoder = null

  init = ()->
    # wait for google JS libs to load
    _geocoder = new google.maps.Geocoder()

  mathRound6 = (v)->
    return Math.round( v * 1000000 )/1000000 if _.isNumber v
    return v

 


  $ionicPlatform.ready ->
    init()
    return


  ## factory object
  self = {

    ###
    @description an Entry Point for this service, returns an object with a geocode location
    @return object { address: location: place_id:(options) }
      'NOT FOUND', 'CANCELED', 'ERROR'
    ###
    getLatLon: (address)->
      self.displayGeocode(address)
      .then (result)->
        return 'CANCELED' if !result # CANCELED?
        return 'NOT FOUND' if result == 'ZERO_RESULTS' # CANCELED?

        if result.override?.location
          location = result.override?.location
        else
          location = result['geometry']['location']
          location = [location.lat() , location.lng()]

        # round to 6 significant digits
        location = _.map location, (v)->
          return Math.round( v * 1000000 ) / 1000000

        resp = {
          address: result.override?.address || result['formatted_address']
          location: location  # resolve [lat,lon]
        }
        resp['place_id'] = result['place_id'] if !result.override
        return resp
      .catch (err)->
        return 'ERROR'


    ###
    @description launches addressMap modal to allow user to verifiy location of address
    @param address String
    @return object, same structure as geocodeResult
    ###
    displayGeocode: (address)->
      return self.geocode(address)
      .then (result)->
        console.log ["Geocode result, count=", result.length] if _.isArray result
        if result == 'ZERO_RESULTS'
          return 'ZERO_RESULTS'

        if result.length > 1
          return self.chooseFromMatches(address, result)
          .then (result)->
            return result?[0]

        if result?[0].partial_match # result.length == 1
          return self.confirmPartialMatch(address, result[0])

        # perfect match, still confirm
        return self.checkAddress(address, result[0])

      .catch (err)->
        console.warn err
        return

    # called by self.displayGeocode() and PartialMatchCtrl.updateGeocode()
    geocode: (address)->
      return $q.reject("Geocoder JS lib not ready") if !_geocoder?
      dfd = $q.defer()
      # geocode address
      _geocoder.geocode({ "address": address }, (result, status)->
        switch status
          when 'OK'
            return dfd.resolve result
          when 'ZERO_RESULTS'
            return dfd.resolve 'ZERO_RESULTS'
          else
            console.err ['geocodeSvc.geocode()', status]
            return dfd.reject {
              status: status
              result: result
            }
      )
      return dfd.promise

    checkAddress: (address, geoCodeResult)->
      return self.confirmPartialMatch(address, geoCodeResult)

    confirmPartialMatch: (address, geoCodeResult)->
      return appModalSvc.show(
        'blocks/components/address-map.template.html'
        'PartialMatchCtrl as vm'
        {
          address: address
          geoCodeResult: geoCodeResult
        })
      .then (modalResult)->
        # console.log ["confirmPartialMatch:", geoCodeResult]
        override = {}
        if !modalResult || modalResult == 'CANCELED'
          return []

        mm = modalResult
        geoCodeResult.override = {}
        if mm['marker-moved']
          geoCodeResult.override['location'] = mm.location
        if mm['address-changed']
          geoCodeResult.override['address']= mm.addressDisplay

        return geoCodeResult
      .catch (err)->
        return $q.reject(err)

    chooseFromMatches: (results)->
      result = results[0]
      return $q.when [result]



    ###
    # Utility Methods
    ###

    # round to 6 decimals for google Maps API
    getLocationFromGeocodePoint : (point)->
      if point?['geometry']?.location?
        # geocode result
        return [
          mathRound6 point['geometry']['location'].lat()
          mathRound6 point['geometry']['location'].lng()
        ]
      if point.getPosition?
        # marker position
        return [
          mathRound6 point.getPosition().lat()
          mathRound6 point.getPosition().lng()
        ]
      return null

    ###
    # @description add a 'random' offset to latlon to mask exact location
    # @param latlon Array, [lat,lon] expressed as decimal
    ###
    maskLatLon: (latlon, key)->
      # +- .0025 to lat/lon
      key = key[0..10]
      offset = {
        lat: (self.a2nHash( latlon[0] + key ) % 25) / 10000
        lon: (self.a2nHash( latlon[1] + key ) % 25) / 10000
      }
      # console.log offset
      return [
        mathRound6 latlon[0]+offset.lat
        mathRound6 latlon[1]+offset.lon
      ]

    ###
    @description: get google Map object for angular-google-maps,
      configured map places marker or circle at location
    @params: options
      id: string optional
      location: [lat,lon] render circle or marker at location
      type: [circle, marker]
      circleRadius: 500, in meters
      draggableMap: true
      draggableMarker: true
    ###
    getMapConfig: (options)->
      _.defaults options, {
        id: '1'
        location: []
        type: 'marker'
        circleRadius: 500
        draggableMap: true
        draggableMarker: true
      }
      # if useStaticMap=false
      #   mapSrc = "https://maps.googleapis.com/maps/api/staticmap?"
      #   params = {}
      #   params['size'] = "400x400"
      #   params['markers'] = options.markerLocation.join(',') if options.markerLocation?
      #   qs = _.map (v, k)-> [k,v].join("=")
      #   mapSrc += encodeURIComponent(qs.join('&'))
      #   $log.info("Static Map=" + mapSrc)

      gMapPoint = {
        latitude: mathRound6( options.location[0])
        longitude: mathRound6( options.location[1])
      }

      mapConfigOptions = {
        'map':
          options:
            draggable: options.draggableMap
      }
      switch options.type
        when 'circle'
          mapConfigOptions['circle'] = {
            center: gMapPoint
            stroke:
              color: '#FF0000'
              weight: 1
            radius: options.circleRadius
            fill:
              color: '#FF0000'
              opacity: '0.2'
          }
        when 'marker'
          mapConfigOptions['marker'] = {
            idKey: options.id
            coords: gMapPoint
            options: {
              draggable: options.draggableMarker
            }
          }
          if options.draggableMarker
            mapConfigOptions['marker']['events'] = {
              'click': (mapModel, eventName, originalEventArgs)->
                check = mapModel
                return
              'dragend': options.dragendMarker
            }

      return mapConfig = {
        type: options.type
        center: angular.copy gMapPoint
        zoom: 14
        scrollwheel: false
        # event.map.options
        options: mapConfigOptions
      }

    ###
    @description update the marker location on an angular-google-map config object
    ###
    updateMapMarker: (mapConfig, location, recenter=true)->
      if location?.length
        gMapPoint = {
          latitude: mathRound6( location[0] )
          longitude: mathRound6( location[1] )
        }
        mapConfig['center'] = gMapPoint
        switch mapConfig.type
          when 'circle'
            mapConfig.options[ 'circle' ]['center'] = gMapPoint
          when 'marker'
            mapConfig.options[ 'marker' ]['coords'] = gMapPoint

        if recenter
          mapConfig.center = angular.copy gMapPoint
      return
  }

  return self

Geocoder.$inject = ['$q', '$ionicPlatform', 'starter.core.KEYS', 'appModalSvc']

###
@description Controller for geocodeSvc.confirmPartialMatch() Modal
###
PartialMatchCtrl = ($scope, parameters, $q, geocodeSvc)->
  vm = this
  parseLocation = (geoCodeResult)->
    return {} if _.isEmpty geoCodeResult
    location0 = geocodeSvc.getLocationFromGeocodePoint geoCodeResult
    return {
      'location': location0
      'latlon': location0.join(', ')
      'addressFormatted': geoCodeResult.formatted_address
      'addressDisplay': angular.copy geoCodeResult.formatted_address
    }

  geoCodeResult = parameters.geoCodeResult

  # location0 = [
  #   geocodeSvc.mathRound6 geoCodeResult['geometry']['location'].lat()
  #   geocodeSvc.mathRound6 geoCodeResult['geometry']['location'].lng()
  # ]

  vm['address0'] = parameters.address       # search address
  _.extend vm, parseLocation( geoCodeResult )
  vm['marker-moved'] = false
  vm['map'] = geocodeSvc.getMapConfig {
    location: vm['location']
    type: 'marker'
    draggableMarker: true
    dragendMarker: (marker, eventName, args)->
      vm['location'] = geocodeSvc.getLocationFromGeocodePoint marker
      vm['latlon'] = vm['location'].join(', ')
      vm['marker-moved'] = true
      return
  }

  # vm.geocode = geocodeSvc.geocode
  vm.updateGeocode = (address)->
    return geocodeSvc.geocode(address)
    .then (result)->
      geoCodeResult = result?[0]
      _.extend vm, parseLocation( geoCodeResult )
      vm['address-changed'] = true
      geocodeSvc.updateMapMarker(vm.map, vm.location)
      return
    , (err)->
      return $q.reject err

  $scope.$watch 'vm.addressDisplay', (newV)->
    vm['address-changed'] = true
    return

  return vm

PartialMatchCtrl.$inject = ['$scope', 'parameters', '$q', 'geocodeSvc']

angular.module 'blocks.components'
  .factory 'geocodeSvc', Geocoder
  .controller 'PartialMatchCtrl', PartialMatchCtrl