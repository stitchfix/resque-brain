resqueBrain = angular.module('resqueBrain',[
  'templates',
  'ngRoute',
  'ui.bootstrap',
  'controllers'
])

resqueBrain.config([ '$routeProvider',
  ($routeProvider)->
    $routeProvider
      .when('/',
        templateUrl: "index.html"
        controller: 'DashboardController'
      )
])

controllers = angular.module('controllers',[])
controllers.controller("DashboardController", [ '$scope',
  ($scope)->
    $scope.navCollapsed = true
])
