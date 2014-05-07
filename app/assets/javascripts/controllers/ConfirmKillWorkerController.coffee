controllers = angular.module("controllers")
controllers.controller("ConfirmKillWorkerController", [
  "$scope", "$modalInstance", "job",
  ($scope ,  $modalInstance ,  job)->

    $scope.job = job

    $scope.ok     = -> $modalInstance.close()
    $scope.cancel = -> $modalInstance.dismiss('cancel')

])
