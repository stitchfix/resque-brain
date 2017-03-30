controllers = angular.module("controllers")
controllers.controller("FailedController", [
  "$scope", "$modal", "$routeParams", "$location", "$timeout", "$animate", "Resques", "GenericErrorHandling", "FailedJobs", "flash",
  ($scope ,  $modal ,  $routeParams ,  $location ,  $timeout ,  $animate ,  Resques ,  GenericErrorHandling ,  FailedJobs ,  flash)->

    DEFAULT_PAGE_SIZE = 10

    backtracesShowing = {}

    $scope.pageSize = $routeParams.pageSize or DEFAULT_PAGE_SIZE
    $scope.possiblePageSizes = _.sortBy(_.union([ 10, 20, 40, 100 ],[ $scope.pageSize ]))

    $scope.pageSizeChanged = ->
      $location.search("pageSize",$scope.pageSize)

    loadFailedJobs = ->
      $scope.loading = true
      Resques.get($routeParams.resque, (
        (overview)->
          $scope.numJobsFailed = overview.failed
          $scope.pages = []
          page = 1
          numPages = Math.ceil($scope.numJobsFailed / $scope.pageSize)

          while page <= numPages
            $scope.pages.push(page)
            page += 1

          Resques.jobsFailed( { name: $routeParams.resque },($scope.currentPage - 1) * $scope.pageSize,$scope.pageSize,
            ( (jobs)->
              $scope.jobsFailed = jobs
              $scope.loading    = false
            ),
            GenericErrorHandling.onFail($scope)
          )
        ),
        GenericErrorHandling.onFail($scope)
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
        $location.search( page: page, pageSize: $scope.pageSize )

    $scope.retry = (job)->
      modalInstance = $modal.open(
        templateUrl: "confirmRetryFailed.html"
        controller: "ConfirmDestructiveFailedQueueActionController"
        backdrop: true
      )
      modalInstance.result.then ->
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

    $scope.clear = (job,skipModal=false)->
      doClear = ->
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
      if skipModal
        doClear()
      else
        modalInstance = $modal.open(
          templateUrl: "confirmClearFailed.html"
          controller: "ConfirmDestructiveFailedQueueActionController"
          backdrop: true
        )
        modalInstance.result.then(doClear)

    $scope.retryAndClear = (job)->
      FailedJobs.retry($routeParams.resque,job.id, (
         ()-> $scope.clear(job,true)
        ),
        GenericErrorHandling.onFail($scope)
      )

    $scope.retryAll         = ->
      modalInstance = $modal.open(
        templateUrl: "confirmRetryFailed.html"
        controller: "ConfirmDestructiveFailedQueueActionController"
        backdrop: true
      )
      modalInstance.result.then ->
        FailedJobs.retryAll($routeParams.resque,loadFailedJobs,GenericErrorHandling.onFail($scope))

    $scope.clearAll         = ->
      modalInstance = $modal.open(
        templateUrl: "confirmClearFailed.html"
        controller: "ConfirmDestructiveFailedQueueActionController"
        backdrop: true
      )
      modalInstance.result.then ->
        FailedJobs.clearAll($routeParams.resque,loadFailedJobs,GenericErrorHandling.onFail($scope))

    $scope.retryAndClearAll = ()-> FailedJobs.retryAndClearAll($routeParams.resque,loadFailedJobs,GenericErrorHandling.onFail($scope))
      

    $scope.currentPage = parseInt($routeParams.page or "1")

    $scope.refresh = loadFailedJobs
    loadFailedJobs()
])
