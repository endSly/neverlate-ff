'use strict'

host = 'https://neverlate-service.herokuapp.com'

this.app = app = angular.module('app', [])

app.controller 'AppCtrl', ['$rootScope', '$scope', '$http', ($rootScope, $scope, $http) ->
  
  $rootScope._ = _
  
  watchId = navigator.geolocation.watchPosition (location) ->
    console.log(location)
    $rootScope.location = location.coords
    $rootScope.$emit 'locationChanged', location.coords
]

app.controller 'AgenciesListCtrl', ['$rootScope', '$scope', '$http', ($rootScope, $scope, $http) -> 
  $http.jsonp("#{ host }/api/v1/agencies?callback=JSON_CALLBACK")
    .success (agencies) -> $scope.agencies = agencies
  
  $scope.loadAgency = (agency) ->
    window.location.hash = 'content'
    $rootScope.agency = agency
    $rootScope.$emit 'agencyChanged', agency

]

app.controller 'StopsListCtrl', ['$rootScope', '$scope', '$http', ($rootScope, $scope, $http) ->

  loadStops = (stops) ->
    stopsList = $scope.stopsList = _.filter stops, (stop) -> stop.parent_station == undefined
    stopsHash = _.object _.pluck(stops, 'stop_id'), stops
    
    # Build Stops tree
    _.each stops, (stop) ->
      if stop.parent_station
        stopsHash[stop.parent_station].child_stations ||= []
        stopsHash[stop.parent_station].child_stations.push stop
      
    console.log $scope.stopsList,   stops

    #boardingStops = _.where(stops, location_type: 2)
    #boardingStops = _.where(stops, location_type: 0) if _.isEmpty boardingStops
      
    # Sort Stops by location
    #if $rootScope.location
    #  _.each boardingStops, (stop) ->
    #    stop.distance = distance(stop.loc[1], stop.loc[0], $rootScope.location.latitude,  $rootScope.location.longitude)
    #  $scope.boardingStopsByLocation = _.sortBy(boardingStops, 'distance')
      
    # Sort Stops alphabetically
    #$scope.boardingStopsAlphabetically = _.sortBy(boardingStops, 'stop_name')


    #$scope.stops = stops



  $rootScope.$on 'agencyChanged', (ev, agency) ->
    $scope.agency = agency

    $scope.rootStopsList = null

    $http.jsonp("#{ host }/api/v1/#{ agency.agency_key }/stops?callback=JSON_CALLBACK").success loadStops

  $scope.showStop = (stop) ->
    $rootScope.$emit('stopShow', stop)
]

app.controller 'StopShowCtrl', ['$rootScope', '$scope', '$http', ($rootScope, $scope, $http) ->
  $rootScope.$on 'stopShow', (ev, stop) ->
    agency = $rootScope.agency
    $scope.stop = stop
    console.log stop
    $http.jsonp("#{ host }/api/v1/#{ agency.agency_key }/stops/#{ stop.stop_id }/next-departures?callback=JSON_CALLBACK")
    .success (departures) ->
      $scope.departures = departures = _.sortBy departures, (dep) -> dep.departure_time = Date.parse(dep.departure_time)
      console.log departures

]


# Helpers
distance = (lat1, lon1, lat2, lon2) ->
  degToRad = Math.PI / 180
  radlat1 = degToRad * lat1
  radlat2 = degToRad * lat2
  radlon1 = degToRad * lon1
  radlon2 = degToRad * lon2
  dist = Math.sin(radlat1) * Math.sin(radlat2) + Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radlon1 - radlon2)
  Math.acos(dist) * 111.18957696 / degToRad

