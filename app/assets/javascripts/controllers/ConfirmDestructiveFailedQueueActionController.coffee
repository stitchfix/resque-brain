controllers = angular.module("controllers")
controllers.controller("ConfirmDestructiveFailedQueueActionController", [
  "$scope", "$modalInstance",
  ($scope ,  $modalInstance) ->

    $scope.ok     = -> $modalInstance.close()
    $scope.cancel = -> $modalInstance.dismiss('cancel')

])
