controllers = angular.module("controllers")
controllers.controller("OverviewController", [
  "$scope", "$routeParams", "Resques", "GenericErrorHandling",
  ($scope ,  $routeParams ,  Resques ,  GenericErrorHandling)->

    $scope.refresh = ->
      $scope.loading = true

      Resques.summary(
        ( (summary)->
          $scope.overview = (_.find(summary, (oneSummary)-> oneSummary.name == $routeParams.resque) or {})
          $scope.loading = false
        ),
        GenericErrorHandling.onFail($scope),
        "flush"
      )

     $scope.refresh()
])
