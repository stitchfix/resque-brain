controllers = angular.module("controllers")
controllers.controller("OverviewController", [
  "$scope", "$routeParams", "Resques",
  ($scope ,  $routeParams ,  Resques)->

    $scope.loading = true

    Resques.summary(
      ( (summary)->
        $scope.overview = (_.find(summary, (oneSummary)-> oneSummary.name == $routeParams.resque) or {})
        $scope.loading = false
      ),
      ( (httpResponse)-> alert("Problem") )
    )
])
