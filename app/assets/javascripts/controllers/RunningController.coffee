controllers = angular.module("controllers")
controllers.controller("RunningController", [
  "$scope", "$modal", "$routeParams", "Resques", "GenericErrorHandling",
  ($scope ,  $modal ,  $routeParams ,  Resques ,  GenericErrorHandling)->

    $scope.loading = true

    Resques.jobsRunning( { name: $routeParams.resque },
      ( (jobs)->
        $scope.jobsRunning = jobs
        $scope.loading     = false
      ),
      GenericErrorHandling.onFail($scope)
    )

    $scope.killJob = (job)->
      modalInstance = $modal.open(
        templateUrl: "confirmKillWorker.html"
        controller: "ConfirmKillWorkerController"
        backdrop: true
        resolve:
          job: -> job
      )
      modalInstance.result.then ->
        $scope.jobsRunning = _.without($scope.jobsRunning,job)


])
