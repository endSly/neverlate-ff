'use strict'

this.app = app = angular.module('app', [])

app.controller 'AgenciesListCtrl', ['$rootScope', '$scope', '$http', ($rootScope, $scope, $http) ->
  $http.jsonp('https://neverlate-service.herokuapp.com/api/v1/agencies?callback=JSON_CALLBACK')
    .success (agencies) -> $scope.agencies = agencies
  
  $scope.loadAgency = (agency) ->
    window.location.hash = 'content'
    $rootScope.agency = agency
    $rootScope.$emit 'agencyChanged', agency

]

app.controller 'StopsListCtrl', ['$rootScope', '$scope', '$http', ($rootScope, $scope, $http) ->
  $rootScope.$on 'agencyChanged', (ev, agency) ->
    $scope.agency = agency
    console.log agency
    $http.jsonp("https://neverlate-service.herokuapp.com/api/v1/#{ agency.agency_key }/stops?callback=JSON_CALLBACK")
      .success (stops) ->
        $scope.rootStopsList = _.filter stops, (stop) -> stop.parent_station == '' or stop.parent_station == null
        rootStops = _.object _.pluck(rootStopsList, 'stop_id'), rootStopsList


        $scope.stops = stops
        console.log(rootStops)
]
