resqueBrain = angular.module('resqueBrain',[
  'ngRoute',
  'ngResource',

  'templates',
  'ui.bootstrap',
  'angularMoment',
  'angular-flash.service',
  'angular-flash.flash-alert-directive'

  'controllers',
  'directives',
  'services',
  'filters'
])

resqueBrain.config([
  '$routeProvider', 'flashProvider'
  ($routeProvider ,  flashProvider)->

    flashProvider.errorClassnames.push("alert-danger")
    flashProvider.warnClassnames.push("alert-warning")
    flashProvider.infoClassnames.push("alert-info")
    flashProvider.successClassnames.push("alert-success")

    $routeProvider
      .when('/',
        templateUrl: "summary.html"
        controller: 'SummaryController'
      )
      .when('/:resque',
        templateUrl: "overview.html"
        controller: 'OverviewController'
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
