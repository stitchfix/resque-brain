describe "FailedController", ->
  scope   = null
  ctrl    = null
  resques = null

  jobsFailed = [
    queue: "mail",
    payload: {
      class: "UserWelcomeMailer",
      args: [ 12345 ]
    }
    worker: "p9e942asfhjsfg"
    exception: "Resque::TermException"
    backtrace: [ "foo.rb", "blah.rb" ]
    error: "SIGTERM"
  ,
    queue: "mail",
    payload: {
      class: "UserWelcomeMailer",
      args: [ 12345 ]
    }
    worker: "p9e942asfhjsfg"
    exception: "Resque::TermException"
    backtrace: [ "foo.rb", "blah.rb" ]
    error: "SIGTERM"
  ]

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

  setupController = ()->
    inject((Resques, $rootScope, $routeParams, $controller)->
      scope   = $rootScope.$new()
      resques = Resques
      spyOn(resques,"jobsFailed").andCallFake( (resque,start,count,success,failure)-> success(jobsFailed) )
      spyOn(resques,"summary").andCallFake( (success,failure)-> success([testResque,wwwResque]))
      $routeParams.resque = resqueName

      ctrl    = $controller('FailedController', $scope: scope)
    )

  beforeEach(module("resqueBrain"))
  beforeEach(setupController())

  describe 'loading the controller', ->
    it 'exposes the list of jobs running', ->
      expect(scope.jobsFailed).toEqualData(jobsFailed)
      expect(scope.numJobsFailed).toBe(12)
      expect(scope.pages).toEqualData( [ { page: 1, start: 0 }, { page: 2, start: 10 } ] )
      expect(resques.jobsFailed.mostRecentCall.args[0]).toEqualData({ name: resqueName })
      expect(resques.jobsFailed.mostRecentCall.args[1]).toEqualData(0)
      expect(resques.jobsFailed.mostRecentCall.args[2]).toEqualData(10)
      expect(scope.currentPage).toBe(1)

  describe "goToPage", ->
    it 'fetches the next page of data', ->
      scope.goToPage({ page: 2, start: 10})
      expect(scope.currentPage).toBe(2)
      expect(resques.jobsFailed.mostRecentCall.args[0]).toEqualData({ name: resqueName })
      expect(resques.jobsFailed.mostRecentCall.args[1]).toEqualData(10)
      expect(resques.jobsFailed.mostRecentCall.args[2]).toEqualData(10)
