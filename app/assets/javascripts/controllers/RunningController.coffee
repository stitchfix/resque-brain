controllers = angular.module("controllers")
controllers.controller("RunningController", [
  "$scope", "$modal", "Resques",
  ($scope ,  $modal ,  Resques)->

    $scope.jobsRunning = [
      queue: "mail",
      payload: {
        class: "UserWelcomeMailer",
        args: [ 12345 ]
      }
      runtime: "0:0:02"
      worker: "p9e942asfhjsfg"
      tooLong: false
    ,
      queue: "pdf",
      payload: {
        class: "GeneratePackInMaterialsJob",
        args: [ 947382, true ]
      }
      runtime: "1:34:01"
      worker: "er0ghq3rdfgsefg"
      tooLong: true
    ,
      queue: "purchasing",
      payload: {
        class: "ChargePurchaseJob",
        args: [ 12345, 84762 ]
      }
      runtime: "0:01:12"
      worker: "9seriudfosdfgkl"
      tooLong: false
    ]

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
