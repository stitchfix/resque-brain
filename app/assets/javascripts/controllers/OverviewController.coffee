controllers = angular.module("controllers")
controllers.controller("OverviewController", [
  "$scope", "$routeParams", "Resques",
  ($scope ,  $routeParams ,  Resques)->

    Resques.summary(
      ( (summary)->
        $scope.overview = (_.find(summary, (oneSummary)-> oneSummary.name == $routeParams.resque) or {})
        window.overview = $scope.overview
      ),
      ( (httpResponse)-> alert("Problem") )
    )
])
