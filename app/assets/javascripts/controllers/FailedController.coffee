controllers = angular.module("controllers")
controllers.controller("FailedController", [
  "$scope", "$modal", "$routeParams", "$location", "$timeout", "$animate", "Resques", "GenericErrorHandling", "FailedJobs", "flash",
  ($scope ,  $modal ,  $routeParams ,  $location ,  $timeout ,  $animate ,  Resques ,  GenericErrorHandling ,  FailedJobs ,  flash)->

    PAGE_SIZE = 10

    backtracesShowing = {}

    loadFailedJobs = ->
      $scope.loading = true
      Resques.summary( (
        (summary)->
          $scope.numJobsFailed = (_.find(summary, (oneSummary)-> oneSummary.name == $routeParams.resque) or {}).failed
          $scope.pages = []
          page = 1
          numPages = Math.ceil($scope.numJobsFailed / PAGE_SIZE)

          while page <= numPages
            $scope.pages.push(page)
            page += 1

          Resques.jobsFailed( { name: $routeParams.resque },($scope.currentPage - 1) * PAGE_SIZE,PAGE_SIZE,
            ( (jobs)->
              $scope.jobsFailed = jobs
              $scope.loading    = false
            ),
            GenericErrorHandling.onFail($scope)
          )
        ),
        GenericErrorHandling.onFail($scope),
        "flush"
      )


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

    $scope.retry = (job)->
      FailedJobs.retry($routeParams.resque,job.id, (
          ()->
            FailedJobs.get($routeParams.resque,job.id,
              (
                (job)->
                  index = _.findIndex($scope.jobsFailed, { id: job.id })
                  if index > -1
                    $scope.jobsFailed[index] = job
                  else
                    flash.warn = "Retried job isn't in our list—try reloading"
              ),
              GenericErrorHandling.onFail($scope)
            )
        ),
        GenericErrorHandling.onFail($scope)
      )

    $scope.clear = (job)->
      FailedJobs.clear($routeParams.resque, job.id, (
          ()->
            index = _.indexOf($scope.jobsFailed,job)
            if index != -1
              $scope.jobsFailed.splice(index,1)

            $timeout( ( -> $animate.enabled(false) ), 500 )
            $timeout( ( -> $animate.enabled(true) ), 1500 )
            $timeout(loadFailedJobs,1000)
        ),
        GenericErrorHandling.onFail($scope)
      )
    $scope.retryAndClear = (job)->
      FailedJobs.retry($routeParams.resque,job.id, (
         ()-> $scope.clear(job)
        ),
        GenericErrorHandling.onFail($scope)
      )

    $scope.retryAll         = ()-> FailedJobs.retryAll($routeParams.resque,loadFailedJobs,GenericErrorHandling.onFail($scope))
    $scope.clearAll         = ()-> FailedJobs.clearAll($routeParams.resque,loadFailedJobs,GenericErrorHandling.onFail($scope))
    $scope.retryAndClearAll = ()-> FailedJobs.retryAndClearAll($routeParams.resque,loadFailedJobs,GenericErrorHandling.onFail($scope))
      

    $scope.currentPage = parseInt($routeParams.page or "1")

    loadFailedJobs()

])
