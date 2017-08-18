describe "FailedController", ->
  scope      = null
  ctrl       = null
  resques    = null
  failedJobs = null
  location   = null
  modal      = null

  jobsFailed = _.map([1,2,3,4,5,6,7,8,9,10,11,12,13], (i)->
    id: i
    queue: "mail",
    payload: {
      class: "UserWelcomeMailer",
      args: [ 12345 ]
    }
    worker: "worker#{i}"
    exception: "Resque::TermException"
    backtrace: [ "foo.rb", "blah.rb" ]
    error: "SIGTERM"
  )

  updatedJob =
    id: 2
    queue: "mail",
    payload: {
      class: "UserWelcomeMailer",
      args: [ 12345 ]
    }
    worker: "worker1"
    exception: "Resque::TermException"
    backtrace: [ "foo.rb", "blah.rb" ]
    error: "SIGTERM"
    retriedAt: (new Date).getTime()

  testResque =
    name: "test"
    failed: 12
    running: 10
    runningTooLong: 3
    waiting: 123

  resqueName = 'test'

  setupController = (page,pageSize,andAlso)->
    inject((Resques, FailedJobs, $rootScope, $routeParams, $location, $controller, $modal)->
      scope      = $rootScope.$new()
      location   = $location
      resques    = Resques
      failedJobs = FailedJobs
      modal      = $modal
      spyOn(resques,"jobsFailed").andCallFake( (resque,start,count,success,failure)->
        success(jobsFailed.slice(start,start + count))
      )
      spyOn(resques,"get").andCallFake( (resque,success,failure)-> success(testResque))
      modalInstance =
        result:
          then: (f)-> f()
      spyOn(modal,"open").andCallFake( () -> modalInstance)

      $routeParams.resque = resqueName
      $routeParams.page = page if page
      $routeParams.pageSize = pageSize if pageSize

      if andAlso
        andAlso()

      ctrl    = $controller('FailedController', $scope: scope)
    )

  beforeEach(module("resqueBrain"))

  describe 'loading the controller', ->
    describe "without a page specified", ->
      describe "without a page size", ->
        beforeEach(setupController())
        it 'exposes the list of jobs running', ->
          expect(scope.jobsFailed).toEqualData(jobsFailed.slice(0,10))
          expect(scope.numJobsFailed).toBe(12)
          expect(scope.pages).toEqualData( [ 1, 2 ] )
          expect(resques.jobsFailed.mostRecentCall.args[0]).toEqualData({ name: resqueName })
          expect(resques.jobsFailed.mostRecentCall.args[1]).toBe(0)
          expect(resques.jobsFailed.mostRecentCall.args[2]).toBe(10)
          expect(scope.currentPage).toBe(1)
      describe "with a page size", ->
        beforeEach(setupController(null,5))
        it 'exposes the list of jobs running', ->
          expect(scope.jobsFailed).toEqualData(jobsFailed.slice(0,5))
          expect(scope.numJobsFailed).toBe(12)
          expect(scope.pages).toEqualData( [ 1, 2, 3 ] )
          expect(resques.jobsFailed.mostRecentCall.args[0]).toEqualData({ name: resqueName })
          expect(resques.jobsFailed.mostRecentCall.args[1]).toBe(0)
          expect(resques.jobsFailed.mostRecentCall.args[2]).toBe(5)
          expect(scope.currentPage).toBe(1)

    describe "with a page specified", ->
      describe "without a page size", ->
        beforeEach(setupController(2))
        it 'exposes the list of jobs running', ->
          expect(scope.jobsFailed).toEqualData(jobsFailed.slice(10,13))
          expect(scope.numJobsFailed).toBe(12)
          expect(scope.pages).toEqualData( [ 1, 2 ] )
          expect(resques.jobsFailed.mostRecentCall.args[0]).toEqualData({ name: resqueName })
          expect(resques.jobsFailed.mostRecentCall.args[1]).toBe(10)
          expect(resques.jobsFailed.mostRecentCall.args[2]).toBe(10)
          expect(scope.currentPage).toBe(2)

      describe "with a page size", ->
        beforeEach(setupController(2,5))
        it 'exposes the list of jobs running', ->
          expect(scope.jobsFailed).toEqualData(jobsFailed.slice(5,10))
          expect(scope.numJobsFailed).toBe(12)
          expect(scope.pages).toEqualData( [ 1, 2, 3 ] )
          expect(resques.jobsFailed.mostRecentCall.args[0]).toEqualData({ name: resqueName })
          expect(resques.jobsFailed.mostRecentCall.args[1]).toBe(5)
          expect(resques.jobsFailed.mostRecentCall.args[2]).toBe(5)
          expect(scope.currentPage).toBe(2)

  describe "goToPage", ->
    beforeEach(setupController())
    it 'fetches the next page of data', ->
      scope.goToPage(2)
      expect(location.search()["page"]).toBe(2)

  describe "retry", ->
    beforeEach ->
      setupController(null, null, ->
        spyOn(failedJobs,"retry").andCallFake( (resqueName, jobId, success,failure)-> success() )
        spyOn(failedJobs,"get").andCallFake( (resqueName, jobId, success,failure)-> success(updatedJob) )
        
      )
    it 'calls retry then get on FailedJobs', ->
      scope.retry(scope.jobsFailed[1])
      expect(scope.jobsFailed[1]).toEqualData(updatedJob)

      expect(failedJobs.retry.mostRecentCall.args[0]).toEqualData(resqueName)
      expect(failedJobs.retry.mostRecentCall.args[1]).toEqualData(jobsFailed[1].id)
      expect(failedJobs.get.mostRecentCall.args[0]).toEqualData(resqueName)
      expect(failedJobs.get.mostRecentCall.args[1]).toEqualData(jobsFailed[1].id)
      expect(modal.open.mostRecentCall.args[0].templateUrl).toBe("confirmRetryFailed.html")
      expect(modal.open.mostRecentCall.args[0].controller).toBe("ConfirmDestructiveFailedQueueActionController")
      expect(modal.open.mostRecentCall.args[0].backdrop).toBe(true)

  describe "clear", ->
    beforeEach ->
      setupController(null, null, ->
        spyOn(failedJobs,"clear").andCallFake( (resqueName, jobId, success,failure)-> success() )
      )
    describe "default call", ->
      it 'calls clear then re-fetches all jobs', ->
        scope.clear(scope.jobsFailed[1])

        expect(failedJobs.clear.mostRecentCall.args[0]).toEqualData(resqueName)
        expect(failedJobs.clear.mostRecentCall.args[1]).toEqualData(jobsFailed[1].id)
        expect(modal.open.mostRecentCall.args[0].templateUrl).toBe("confirmClearFailed.html")
        expect(modal.open.mostRecentCall.args[0].controller).toBe("ConfirmDestructiveFailedQueueActionController")
        expect(modal.open.mostRecentCall.args[0].backdrop).toBe(true)
    describe "called with param to skip modal nag", ->
      it 'calls clear then re-fetches all jobs', ->
        scope.clear(scope.jobsFailed[1],true)

        expect(failedJobs.clear.mostRecentCall.args[0]).toEqualData(resqueName)
        expect(failedJobs.clear.mostRecentCall.args[1]).toEqualData(jobsFailed[1].id)
        expect(modal.open).not.toHaveBeenCalled()

  describe "retryAndClear", ->
    beforeEach ->
      setupController(null, null, ->
        spyOn(failedJobs,"retry").andCallFake( (resqueName, jobId, success,failure)-> success() )
        spyOn(failedJobs,"clear").andCallFake( (resqueName, jobId, success,failure)-> success() )
      )
    it 'calls clear then re-fetches all jobs', ->
      scope.retryAndClear(scope.jobsFailed[1])

      expect(failedJobs.clear.mostRecentCall.args[0]).toEqualData(resqueName)
      expect(failedJobs.clear.mostRecentCall.args[1]).toEqualData(jobsFailed[1].id)
      expect(failedJobs.retry.mostRecentCall.args[0]).toEqualData(resqueName)
      expect(failedJobs.retry.mostRecentCall.args[1]).toEqualData(jobsFailed[1].id)

  describe "retryAll", ->
    beforeEach ->
      setupController(null, null, ->
        spyOn(failedJobs,"retryAll").andCallFake( (resqueName, success,failure)-> success() )
      )
    it 'calls retry then get on FailedJobs', ->
      scope.retryAll()

      expect(failedJobs.retryAll.mostRecentCall.args[0]).toEqualData(resqueName)
      expect(modal.open.mostRecentCall.args[0].templateUrl).toBe("confirmRetryFailed.html")
      expect(modal.open.mostRecentCall.args[0].controller).toBe("ConfirmDestructiveFailedQueueActionController")
      expect(modal.open.mostRecentCall.args[0].backdrop).toBe(true)

  describe "clearAll", ->
    beforeEach ->
      setupController(null, null, ->
        spyOn(failedJobs,"clearAll").andCallFake( (resqueName, success,failure)-> success() )
      )
    it 'calls clear then re-fetches all jobs', ->
      scope.clearAll()

      expect(failedJobs.clearAll.mostRecentCall.args[0]).toEqualData(resqueName)
      expect(modal.open.mostRecentCall.args[0].templateUrl).toBe("confirmClearFailed.html")
      expect(modal.open.mostRecentCall.args[0].controller).toBe("ConfirmDestructiveFailedQueueActionController")
      expect(modal.open.mostRecentCall.args[0].backdrop).toBe(true)

  describe "retryAndClearAll", ->
    beforeEach ->
      setupController(null, null, ->
        spyOn(failedJobs,"retryAndClearAll").andCallFake( (resqueName, success,failure)-> success() )
      )
    it 'calls clear then re-fetches all jobs', ->
      scope.retryAndClearAll()

      expect(failedJobs.retryAndClearAll.mostRecentCall.args[0]).toEqualData(resqueName)
