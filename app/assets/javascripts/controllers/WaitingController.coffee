controllers = angular.module("controllers")
controllers.controller("WaitingController", [
  "$scope", "$modal", "$routeParams", "flash", "Resques", "GenericErrorHandling",
  ($scope ,  $modal ,  $routeParams ,  flash ,  Resques ,  GenericErrorHandling)->

    $scope.refresh = ->
      $scope.loading = true
      Resques.jobsWaiting( { name: $routeParams.resque },
        ( (jobs)->
            $scope.jobsWaiting      = jobs
            $scope.totalJobsWaiting = _.reduce($scope.jobsWaiting, ((acc,waitingInQueue)-> acc + waitingInQueue.jobs.length),0)
            $scope.loading          = false
        ),
        GenericErrorHandling.onFail($scope)
      )

    $scope.refresh()

])
