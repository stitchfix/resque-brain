controllers = angular.module("controllers")
controllers.controller("RunningController", [
  "$scope", "$modal", "$routeParams", "IntervalRefresh", "Resques", "GenericErrorHandling",
  ($scope ,  $modal ,  $routeParams ,  IntervalRefresh ,  Resques ,  GenericErrorHandling)->

 
    $scope.refresh = ->
      $scope.loading = true

      Resques.jobsRunning( { name: $routeParams.resque },
        ( (jobs)->
          $scope.jobsRunning = jobs
          $scope.loading     = false
        ),
        GenericErrorHandling.onFail($scope)
      )

    IntervalRefresh($scope.refresh,$scope)

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
