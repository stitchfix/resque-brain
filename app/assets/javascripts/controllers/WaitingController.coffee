controllers = angular.module("controllers")
controllers.controller("WaitingController", [
  "$scope", "$modal", "$routeParams", "Resques",
  ($scope ,  $modal ,  $routeParams ,  Resques)->

    Resques.jobsWaiting( { name: $routeParams.resque },
      ( (jobs)->
          $scope.jobsWaiting      = jobs
          $scope.totalJobsWaiting = _.reduce($scope.jobsWaiting, ((acc,waitingInQueue)-> acc + waitingInQueue.jobs.length),0)
      ),
      ( (httpResponse)-> alert("Problem") )
    )

])
