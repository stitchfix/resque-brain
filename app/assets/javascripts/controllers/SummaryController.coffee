controllers = angular.module('controllers')
controllers.controller("SummaryController", [
  '$scope', 'Resques', "GenericErrorHandling", "IntervalRefresh",
  ($scope ,  Resques ,  GenericErrorHandling ,  IntervalRefresh)->

    $scope.allResques          = []
    $scope.totalFailed         = 0
    $scope.totalRunning        = 0
    $scope.totalRunningTooLong = 0
    $scope.totalWaiting        = 0

    setResquesAndDeriveTotals = (resques)->
      sumField = (list,field)->
        _.chain(list).pluck(field).reduce((acc,val)-> acc + val).value()

      $scope.allResques          = resques
      $scope.totalFailed         = sumField(resques,"failed")
      $scope.totalRunning        = sumField(resques,"running")
      $scope.totalRunningTooLong = sumField(resques,"runningTooLong")
      $scope.totalWaiting        = sumField(resques,"waiting")
      $scope.loading             = false

    $scope.refresh = ->
      $scope.loading = true
      Resques.summary(
        setResquesAndDeriveTotals,
        GenericErrorHandling.onFail($scope),
        "flush"
      )

    IntervalRefresh($scope.refresh,$scope)
])
