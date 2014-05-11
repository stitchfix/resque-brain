resqueBrain = angular.module('resqueBrain',[
  'templates',
  'ngRoute',
  'ngResource',
  'ui.bootstrap',
  'controllers',
  'directives',
  'services',
  'filters'
])

resqueBrain.config([ '$routeProvider',
  ($routeProvider)->
    $routeProvider
      .when('/',
        templateUrl: "summary.html"
        controller: 'SummaryController'
      )
      .when('/:resque',
        templateUrl: "overview.html"
        controller: 'DashboardController'
      )
      .when('/:resque/running',
        templateUrl: "running.html"
        controller: 'RunningController'
      )
      .when('/:resque/waiting',
        templateUrl: "waiting.html"
        controller: 'WaitingController'
      )
      .when('/:resque/failed',
        templateUrl: "failed.html"
        controller: 'FailedController'
      )
])

controllers = angular.module('controllers',[])
directives  = angular.module('directives',[])
services    = angular.module('services',[])
filters     = angular.module('filters',[])

controllers.controller("DashboardController", [
  '$scope', '$location', '$modal', '$route', 'Resques',
  ($scope ,  $location ,  $modal ,  $route ,  resques)->


    $scope.exceptionCollapsed = true
    $scope.showDetails = ->
      $scope.exceptionCollapsed = !$scope.exceptionCollapsed

])
