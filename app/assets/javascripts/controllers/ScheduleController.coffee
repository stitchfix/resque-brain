controllers = angular.module("controllers")
controllers.controller("ScheduleController", [
  "$scope", "$modal", "$routeParams", "Resques", "GenericErrorHandling",
  ($scope ,  $modal ,  $routeParams ,  Resques ,  GenericErrorHandling)->

    $scope.loading = true
    Resques.schedule($routeParams.resque,
      ( (schedule)->
        $scope.schedule = schedule
        $scope.loading = false
      ),
      GenericErrorHandling.onFail($scope)
    )

])
