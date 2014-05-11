describe "FailedController", ->
  scope    = null
  ctrl     = null
  resques  = null
  location = null

  jobsFailed = _.map([1,2,3,4,5,6,7,8,9,10,11,12,13], (i)->
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

  testResque =
    name: "test"
    failed: 12
    running: 10
    runningTooLong: 3
    waiting: 123

  wwwResque =
    name: "admin"
    failed: 2
    running: 1
    runningTooLong: 1
    waiting: 12

  resqueName = 'test'

  setupController = (page)->
    inject((Resques, $rootScope, $routeParams, $location, $controller)->
      scope    = $rootScope.$new()
      location = $location
      resques  = Resques
      spyOn(resques,"jobsFailed").andCallFake( (resque,start,count,success,failure)->
        success(jobsFailed.slice(start,start + count))
      )
      spyOn(resques,"summary").andCallFake( (success,failure)-> success([testResque,wwwResque]))
      $routeParams.resque = resqueName
      $routeParams.page = page if page

      ctrl    = $controller('FailedController', $scope: scope)
    )

  beforeEach(module("resqueBrain"))

  describe 'loading the controller', ->
    describe "without a page specified", ->
      beforeEach(setupController())
      it 'exposes the list of jobs running', ->
        expect(scope.jobsFailed).toEqualData(jobsFailed.slice(0,10))
        expect(scope.numJobsFailed).toBe(12)
        expect(scope.pages).toEqualData( [ 1, 2 ] )
        expect(resques.jobsFailed.mostRecentCall.args[0]).toEqualData({ name: resqueName })
        expect(resques.jobsFailed.mostRecentCall.args[1]).toBe(0)
        expect(resques.jobsFailed.mostRecentCall.args[2]).toBe(10)
        expect(scope.currentPage).toBe(1)
    describe "with a page specified", ->
      beforeEach(setupController(2))
      it 'exposes the list of jobs running', ->
        expect(scope.jobsFailed).toEqualData(jobsFailed.slice(10,13))
        expect(scope.numJobsFailed).toBe(12)
        expect(scope.pages).toEqualData( [ 1, 2 ] )
        expect(resques.jobsFailed.mostRecentCall.args[0]).toEqualData({ name: resqueName })
        expect(resques.jobsFailed.mostRecentCall.args[1]).toBe(10)
        expect(resques.jobsFailed.mostRecentCall.args[2]).toBe(10)
        expect(scope.currentPage).toBe(2)

  describe "goToPage", ->
    beforeEach(setupController())
    it 'fetches the next page of data', ->
      scope.goToPage(2)
      expect(location.search()["page"]).toBe(2)
