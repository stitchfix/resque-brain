controllers = angular.module('controllers')
controllers.controller("SummaryController", [
  '$scope', 'Resques',
  ($scope ,  Resques)->

    $scope.allResques = []
    Resques.summary(
      ( (resques)-> $scope.allResques = resques ),
      ( (httpResponse)-> alert("Something went wrong") )
    )
])
