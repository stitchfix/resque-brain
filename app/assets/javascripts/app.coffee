resqueBrain = angular.module('resqueBrain',[
  'templates',
  'ngRoute',
  'ngResource',
  'ui.bootstrap',
  'controllers',
  'directives',
  'services'
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
        controller: 'DashboardController'
      )
      .when('/:resque/waiting',
        templateUrl: "waiting.html"
        controller: 'DashboardController'
      )
      .when('/:resque/failed',
        templateUrl: "failed.html"
        controller: 'DashboardController'
      )
])

controllers = angular.module('controllers',[])
directives  = angular.module('directives',[])
services    = angular.module('services',[])

controllers.controller("DashboardController", [
  '$scope', '$location', '$modal', '$route', 'Resques',
  ($scope ,  $location ,  $modal ,  $route ,  resques)->


    $scope.exceptionCollapsed = true
    $scope.showDetails = ->
      $scope.exceptionCollapsed = !$scope.exceptionCollapsed

    $scope.allResques = resques.all
    
    $scope.killWorker = ->
      $modal.open(
        templateUrl: "confirmKillWorker.html"
        controller: 'DashboardController'
        backdrop: true
      )

])
