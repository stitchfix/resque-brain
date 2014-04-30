resqueBrain = angular.module('resqueBrain',[
  'templates',
  'ngRoute',
  'ui.bootstrap',
  'controllers',
  'directives'
])

resqueBrain.config([ '$routeProvider',
  ($routeProvider)->
    $routeProvider
      .when('/',
        templateUrl: "index.html"
        controller: 'DashboardController'
      )
      .when('/running',
        templateUrl: "running.html"
        controller: 'DashboardController'
      )
      .when('/waiting',
        templateUrl: "waiting.html"
        controller: 'DashboardController'
      )
      .when('/failed',
        templateUrl: "failed.html"
        controller: 'DashboardController'
      )
])

controllers = angular.module('controllers',[])
directives  = angular.module('directives',[])

controllers.controller("DashboardController", [
  '$scope', '$location',
  ($scope ,  $location)->
    $scope.navCollapsed = true

    $scope.viewOverview = -> $location.path("/")
    $scope.viewRunning  = -> $location.path("/running")
    $scope.viewWaiting  = -> $location.path("/waiting")
    $scope.viewFailed   = -> $location.path("/failed")

    $scope.navElementClass = (name)->
      if name == 'overview' and $location.path() == '/'
        'active'
      else if name == 'running' and $location.path() == '/running'
        'active'
      else if name == 'waiting' and $location.path() == '/waiting'
        'active'
      else if name == 'failed' and $location.path() == '/failed'
        'active'
      else
        ''

])
