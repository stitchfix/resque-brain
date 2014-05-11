controllers = angular.module("controllers")
controllers.controller("FailedController", [
  "$scope", "$modal", "$routeParams", "$location", "Resques",
  ($scope ,  $modal ,  $routeParams ,  $location ,  Resques)->

    PAGE_SIZE = 10

    backtracesShowing = {}

    $scope.backtraceShowing = (job)->
      index = _.indexOf($scope.jobsFailed,job)
      backtracesShowing[index]

    $scope.toggleBacktrace = (job)->
      index = _.indexOf($scope.jobsFailed,job)
      console.log(index)
      backtracesShowing[index] = if backtracesShowing[index] == true
        false
      else if backtracesShowing[index] == false
        true
      else
        true

    $scope.goToPage = (page)->
      $scope.currentPage = page.page
      $scope.start = page.start

      Resques.jobsFailed( { name: $routeParams.resque },$scope.start,PAGE_SIZE,
        ( (jobs)->
          $scope.jobsFailed = jobs
          $location.hash = "top"
          $anchorScroll()
        ),
        ( (httpResponse)-> alert("Problem") )
      )
    $scope.goToPage({ page: 1, start: 0 })

    Resques.summary(
      ( (summary)->
        $scope.numJobsFailed = (_.find(summary, (oneSummary)-> oneSummary.name == $routeParams.resque) or {}).failed
        $scope.pages = []
        page = 1
        numPages = Math.ceil($scope.numJobsFailed / PAGE_SIZE)

        while page <= numPages
          $scope.pages.push({ page: page, start: (page-1) * PAGE_SIZE})
          page += 1
      ),
      ( (httpResponse)-> alert("Problem") )
    )

])
