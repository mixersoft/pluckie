# geocode.service.coffee
'use strict'

###
# @description Google Maps Geocode Service v3
# see https://developers.google.com/maps/documentation/geocoding/intro
###

Geocoder = ($q, $ionicPlatform, KEYS, appModalSvc, defaultLocation)->

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
        return null if result == 'CANCELED'
        return result if _.isString result  # NOT FOUND, ERROR?

        if result.override?.location
          location = result.override?.location
        else
          location = result['geometry']['location']
          location = [location.lat() , location.lng()]

        # round to 6 significant digits
        location = _.map location, (v)->
          return mathRound6 v

        # console.log ['getLatLon location', location]

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
    @return object, one geocode result or CANCELED, ZERO_RESULTS
    ###
    displayGeocode: (address)->
      return self.geocode(address)
      .then (results)->
        # console.log ["Geocode results, count=", results.length] if _.isArray results
        if results == 'ZERO_RESULTS'
          console.log "ZERO_RESULTS FOUND"
          results = [self.getPlaceholderDefault()]
        
        return self.showResultsAsMap(address, results)
        .then (result)->
          # console.log ["displayGeocode", result]
          return result

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

    getPlaceholderDefault: ()->
      return geoCodeResult = {
        geometry:
          location:
            lat: ()-> return defaultLocation[0]
            lng: ()-> return defaultLocation[1]
        status: 'ZERO_RESULTS'
        formatted_address: '[location not found]'
      }

    # checkAddress: (address, geoCodeResult)->
    #   # use same modal as showResultsAsMap()
    #   return self.showResultsAsMap(address, geoCodeResult)

    showResultsAsMap: (address, geoCodeResults)->
      return appModalSvc.show(
        'blocks/components/address-map.template.html'
        'PartialMatchCtrl as vm'
        {
          address: address
          geoCodeResults: geoCodeResults
        })
      .then (modalResult)->
        # console.log ["showResultsAsMap:", geoCodeResult]
        return modalResult if _.isString modalResult || !modalResult

        mm = modalResult
        # TODO: need to choose 1 result from geoCodeResults, move to head
        geoCodeResult = mm['geoCodeResults'][0]
        geoCodeResult.override = {}
        if mm['marker-moved']
          geoCodeResult.override['location'] = mm.location
        if mm['address-changed']
          geoCodeResult.override['address']= mm.addressDisplay

        return geoCodeResult
      .catch (err)->
        return $q.reject(err)

    # chooseFromMatches: (results)->
    #   return return self.showResultsAsMap(address, results)



    ###
    # Utility Methods
    ###

    ###
    # @description get a location array from an object
    # @param point object of type
    #     _geocoder.geocode() result
    #     marker from ui-gmap-marker dragend event on map
    #     model from ui-gmap-markers click event
    #       {id: latitude: longititde: formatted_address:}
    # @return [lat,lon] round to 6 decimals for google Maps API
    ###
    getLocationFromObj : (point={})->
      if point['geometry']?.location?
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
      if point.longitude?
        return [
          mathRound6 point.latitude
          mathRound6 point.longitude
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
      location: [lat,lon]  or [ [lat,lon], [lat,lon] ], render circle or marker at location
      type: [circle, marker]
      circleRadius: 500, in meters
      draggableMap: true
      draggableMarker: true
    ###
    getMapConfig: (options)->
      _.defaults options, {
        location: []
        markers:[]
        type: 'oneMarker'
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

      mapConfigOptions = {
        'map':
          options:
            draggable: options.draggableMap
      }
      switch options.type
        when 'circle'
          gMapPoint = {
            latitude: mathRound6( options.location[0])
            longitude: mathRound6( options.location[1])
          }
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
        when 'oneMarker'
          gMapPoint = {
            latitude: mathRound6( options.location[0])
            longitude: mathRound6( options.location[1])
          }
          mapConfigOptions['oneMarker'] = {
            idKey: '1'
            coords: gMapPoint
            options: {
              draggable: options.draggableMarker
            }
          }
          if options.draggableMarker
            mapConfigOptions['oneMarker']['events'] = {
              'dragend': options.dragendMarker
            }
        when 'manyMarkers'
          markers = _.map options.markers, (result, i, l)->
            point = result['geometry']['location']
            return {
              'id': i
              'latitude': mathRound6 point.lat()
              'longitude': mathRound6 point.lng()
              'formatted_address': result.formatted_address
            }
          mapConfigOptions['manyMarkers'] = {
            models: markers
            options:
              draggable: options.draggableMarker
            events:
              'click': options.clickMarker
          }
          if options.draggableMarker
            mapConfigOptions['manyMarkers']['events']['dragend'] = options.dragendMarker
          gMapPoint = markers[0]


      return mapConfig = {
        type: options.type
        center: angular.copy gMapPoint
        zoom: 14
        scrollwheel: false
        # event.map.options
        options: mapConfigOptions
      }

  }

  return self

Geocoder.$inject = ['$q', '$ionicPlatform', 'starter.core.KEYS', 'appModalSvc', 'defaultLocation']






###
@description Controller for geocodeSvc.showResultsAsMap() Modal
@param parameters.geoCodeResult Array of geocode results
       parameters.address String, the original search string
###
PartialMatchCtrl = ($scope, parameters, $q, $timeout, geocodeSvc)->
  ERROR_MSG = {
    zeroMsg: "No results found, please try again."
  }
  GEOCODE_RESULT_LIMIT = 5
  vm = this
  vm.isBrowser = not ionic.Platform.isWebView()
  vm.isValidMarker = ()->
    return false if vm['error-address0']
    return true if vm.map.type == 'oneMarker'
    return false
  

  parseLocation = (geoCodeResultOrModel, target)->
    return {} if _.isEmpty geoCodeResultOrModel
    location0 = geocodeSvc.getLocationFromObj( geoCodeResultOrModel )
    resp = {
      'location': location0
      'latlon': location0.join(', ')
      'addressFormatted': geoCodeResultOrModel.formatted_address
      'addressDisplay': angular.copy geoCodeResultOrModel.formatted_address
      'error-address0': null
    }
    # add error message, as necessary
    switch geoCodeResultOrModel.status
      when 'ZERO_RESULTS'
        resp['error-address0'] = ERROR_MSG.zeroMsg
        resp['latlon'] = null
        resp['addressDisplay'] = null

    _.extend target, resp     # copy attributes to view model
    return resp

  setupMap = (address, geoCodeResults, model)->

    if isZeroResult = geoCodeResults=='ZERO_RESULTS'
      geoCodeResults = [geocodeSvc.getPlaceholderDefault()]

    vm['address0'] = address       # search address
    markerCount = if model? then 1 else geoCodeResults.length

    if markerCount == 0
      return

    if markerCount == 1
      selectedLocation = model || vm['geoCodeResults'][0]
      parseLocation( selectedLocation, vm )
      vm['marker-moved'] = false
      mapOptions = {
        type: if isZeroResult then 'none' else 'oneMarker'
        location: vm['location']
        draggableMarker: true
        dragendMarker: (marker, eventName, args)->
          # for type=oneMarker
          vm['location'] = geocodeSvc.getLocationFromObj marker
          vm['latlon'] = vm['location'].join(', ')
          vm['marker-moved'] = true
          return
      }
      mapConfig = geocodeSvc.getMapConfig mapOptions
      return mapConfig

    # markerCount > 1
    vm['latlon'] = null
    vm['addressFormatted'] = '[multiple results]'
    vm['addressDisplay'] = ''
    vm['error-address0'] = null
    mapOptions = {
      type: 'manyMarkers'
      draggableMarker: true     # BUG? click event doesn't work unless true
      markers: geoCodeResults
      clickMarker: (marker, eventName, model)->
        index = model.id
        vm['geoCodeResults'] = [ vm['geoCodeResults'][index] ]
        newMapConfig = setupMap(model.formatted_address, null, model)
        vm['address-changed'] = true
        vm['marker-moved'] = true
        vm['map'] = newMapConfig
        # console.log newMapConfig
        # console.log ['click location', vm['location']]
        return
      dragendMarker: (marker, eventName, model)->
        # for type=oneMarker
        mapOptions.clickMarker(marker, eventName, model)
        return
    }
    return geocodeSvc.getMapConfig mapOptions

    

  # vm.geocode = geocodeSvc.geocode
  vm.updateGeocode = (address)->
    vm.loading = true
    return geocodeSvc.geocode(address)
    .then (results)->
      if results == 'ZERO_RESULTS'
        console.log "ZERO_RESULTS FOUND"
        results = [geocodeSvc.getPlaceholderDefault()]
      return results
    .then (results)->
      vm['geoCodeResults'] = results
      newMapConfig = setupMap(address, vm['geoCodeResults'])
      
      vm['address-changed'] = false  # check again on save event if true
      vm['map'] = newMapConfig
      return
    , (err)->
      return $q.reject err
    .finally ()->
      $timeout ()->
        vm.loading = false
      ,250

  $scope.$watch 'vm.addressDisplay', (newV)->
    vm['address-changed'] = true
    return

  vm['geoCodeResults'] = parameters.geoCodeResults[0...GEOCODE_RESULT_LIMIT]
  vm['map'] = setupMap(parameters.address, vm['geoCodeResults'])
  return vm

PartialMatchCtrl.$inject = ['$scope', 'parameters', '$q', '$timeout', 'geocodeSvc']







ClearFieldDirective = ($compile, $timeout)->
  directive = {
    restrict: 'A',
    require: 'ngModel'
    scope: {}
    link: (scope, element, attrs, ngModel) ->
      inputTypes = /text|search|tel|url|email|password/i
      if element[0].nodeName != 'INPUT'
        throw new Error "clearField is limited to input elements"
      if not inputTypes.test(attrs.type)
        throw new Error "Invalid input type for clearField" + attrs.type


      btnTemplate = """
      <i ng-show="enabled" ng-click="clear()" class="icon ion-close pull-right">&nbsp;</i>
      """
      template = $compile( btnTemplate )(scope)
      element.after(template)

      scope.clear = ()->
        ngModel.$setViewValue(null)
        ngModel.$render()
        scope.enabled = false
        $timeout ()->
          return element[0].focus()
        ,150

      # element.bind 'input', (e)->
      #   scope.enabled = !ngModel.$isEmpty element.val()
      #   return

      element.bind 'focus', (e)->
        scope.enabled = !ngModel.$isEmpty element.val()
        scope.$apply()
        return

      return

  }
  return directive


ClearFieldDirective.$inject = ['$compile', '$timeout']

angular.module 'blocks.components'
  .value 'defaultLocation', [37.77493, -122.419416]  # san francisco
  .factory 'geocodeSvc', Geocoder
  .directive 'clearField', ClearFieldDirective
  .controller 'PartialMatchCtrl', PartialMatchCtrl