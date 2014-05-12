controllers = angular.module("controllers")
controllers.controller("RunningController", [
  "$scope", "$modal", "$routeParams", "Resques",
  ($scope ,  $modal ,  $routeParams ,  Resques)->

    $scope.loading = true

    Resques.jobsRunning( { name: $routeParams.resque },
      ( (jobs)->
        $scope.jobsRunning = jobs
        $scope.loading     = false
      ),
      ( (httpResponse)-> alert("Problem") )
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
