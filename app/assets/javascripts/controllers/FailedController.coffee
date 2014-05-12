controllers = angular.module("controllers")
controllers.controller("FailedController", [
  "$scope", "$modal", "$routeParams", "$location", "Resques", "GenericErrorHandling",
  ($scope ,  $modal ,  $routeParams ,  $location ,  Resques ,  GenericErrorHandling)->

    PAGE_SIZE = 10

    backtracesShowing = {}

    $scope.loading = true

    $scope.backtraceShowing = (job)->
      index = _.indexOf($scope.jobsFailed,job)
      backtracesShowing[index]

    $scope.toggleBacktrace = (job)->
      index = _.indexOf($scope.jobsFailed,job)
      backtracesShowing[index] = if backtracesShowing[index] == true
        false
      else if backtracesShowing[index] == false
        true
      else
        true

    $scope.pages = []

    $scope.goToPage = (page)->
      if page > 0 and page <= $scope.pages.length
        $location.search( page: page )

    $scope.currentPage = parseInt($routeParams.page or "1")
    Resques.jobsFailed( { name: $routeParams.resque },($scope.currentPage - 1) * PAGE_SIZE,PAGE_SIZE,
      ( (jobs)->
        $scope.jobsFailed = jobs
        $scope.loading    = false
      ),
      GenericErrorHandling.onFail($scope)
    )

    Resques.summary(
      ( (summary)->
        $scope.numJobsFailed = (_.find(summary, (oneSummary)-> oneSummary.name == $routeParams.resque) or {}).failed
        $scope.pages = []
        page = 1
        numPages = Math.ceil($scope.numJobsFailed / PAGE_SIZE)

        while page <= numPages
          $scope.pages.push(page)
          page += 1
      ),
      GenericErrorHandling.onFail($scope)
    )
])
