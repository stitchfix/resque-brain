controllers = angular.module("controllers")
controllers.controller("OverviewController", [
  "$scope", "$routeParams", "IntervalRefresh", "Resques", "GenericErrorHandling", "Monitor",
  ($scope ,  $routeParams ,  IntervalRefresh ,  Resques ,  GenericErrorHandling ,  Monitor)->

    $scope.refresh = ->
      $scope.loading = true

      Resques.get(
        $routeParams.resque,
        ( (overview)->
          $scope.monitors = [
            Monitor(
              name: 'failed'
              unit: 'Job'
              icon: 'remove'
              warnOn: 'never'
              dangerOn: 1
              count: overview.failed
            ),
            Monitor(
              name: 'running'
              count: overview.running
              warnCount: overview.runningTooLong
              icon: 'random'
              warnOn: 1
              dangerOn: 50
              unit: 'Job'
              supplementalWarning: "#{overview.runningTooLong} for too long"
            ),
            Monitor(
              name: 'waiting'
              count: overview.waiting
              warnOn: 1000
              dangerOn: 'never'
              icon: 'time'
              unit: 'Job'
            )
          ]
          $scope.loading = false
        ),
        GenericErrorHandling.onFail($scope),
      )

    IntervalRefresh($scope.refresh,$scope)

])
