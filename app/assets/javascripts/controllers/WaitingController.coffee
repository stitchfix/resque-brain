controllers = angular.module("controllers")
controllers.controller("WaitingController", [
  "$scope", "$modal", "$routeParams", "flash", "Resques", "GenericErrorHandling", "IntervalRefresh",
  ($scope ,  $modal ,  $routeParams ,  flash ,  Resques ,  GenericErrorHandling ,  IntervalRefresh)->

    $scope.refresh = ->
      $scope.loading = true
      Resques.countJobsWaiting( { name: $routeParams.resque },
        ( (jobs)->
            $scope.jobsWaiting      = jobs
            $scope.totalJobsWaiting = _.reduce($scope.jobsWaiting, ((acc,waitingInQueue)-> acc + waitingInQueue.jobs),0)
            $scope.loading          = false
        ),
        GenericErrorHandling.onFail($scope)
      )

    IntervalRefresh($scope.refresh,$scope)
])
