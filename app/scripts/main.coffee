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
  $rootScope.$on 'agencyChanged', (ev, agency) ->
    $scope.rootStopsList = null

    $scope.agency = agency

    $http.jsonp("#{ host }/api/v1/#{ agency.agency_key }/stops?callback=JSON_CALLBACK")
    .success (stops) ->
      rootStopsList = $scope.rootStopsList = _.filter stops, (stop) -> stop.parent_station == '' or stop.parent_station == null
      rootStops = _.object _.pluck(rootStopsList, 'stop_id'), rootStopsList
 
      boardingStops = _.where(stops, location_type: 2)
      boardingStops = _.where(stops, location_type: 0) if _.isEmpty boardingStops

      _.each boardingStops, (stop) ->
        stop.distance = distance(stop.loc[1], stop.loc[0], $rootScope.location.latitude,  $rootScope.location.longitude)
        
      $scope.boardingStopsByLocation = _.sortBy(boardingStops, 'distance') if $rootScope.location

      $scope.stops = stops
      console.log(rootStops)

  $scope.showStop = (stop) -> 
    $rootScope.$emit('stopShow', stop)
]

app.controller 'StopShowCtrl', ['$rootScope', '$scope', '$http', ($rootScope, $scope, $http) ->
  $rootScope.$on 'stopShow', (ev, stop) ->
    agency = $rootScope.agency
    $scope.stop = stop

    $http.jsonp("#{ host }/api/v1/#{ agency.agency_key }/stops/#{ stop.stop_id }/next-departures?callback=JSON_CALLBACK")
    .success (departures) ->
      $scope.departures = departures = _.sortBy dapartures, (dep) -> dep.departure_time = Date.parse(dep.departure_time)
      

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

