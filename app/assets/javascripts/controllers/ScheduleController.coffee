controllers = angular.module("controllers")
controllers.controller("ScheduleController", [
  "$scope", "$modal", "$routeParams", "$location", "$http", "Resques", "GenericErrorHandling",
  ($scope ,  $modal ,  $routeParams ,  $location ,  $http , Resques ,  GenericErrorHandling)->

    $scope.loading = true
    Resques.schedule($routeParams.resque,
      ( (schedule)->
        $scope.schedule = schedule
        $scope.loading = false
      ),
      GenericErrorHandling.onFail($scope)
    )

    $scope.queue = (scheduleElement)->
      $http.post(
        "/resques/#{$routeParams.resque}/schedule/queue.json",
        { job_name: scheduleElement.name }).success(
          (data,status,headers,config)->
            $location.path("/#{$routeParams.resque}/running")
        ).error(
          (data,status,headers,config)->
            GenericErrorHandling.onFail($scope)({ status: status, data: data })
        )

])
