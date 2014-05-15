describe "Resques", ->
  service     = null
  httpBackend = null

  fakeFailedJob =
    queue: "mail",
    payload: {
      class: "UserWelcomeMailer",
      args: [ 12345 ]
    }
    worker: "p9e942asfhjsfg"
    exception: "Resque::TermException"
    backtrace: [ "foo.rb", "blah.rb" ]
    error: "SIGTERM"
  
  beforeEach(module("resqueBrain"))
  beforeEach(inject(($httpBackend, $injector)->
    httpBackend = $httpBackend
    service     = $injector.get('FailedJobs')
  ))

  afterEach ->
    httpBackend.verifyNoOutstandingExpectation()
    httpBackend.verifyNoOutstandingRequest()

  describe 'retry', ->
    successReceived = null
    errorResponse   = null

    success = ()             -> successReceived = true
    failure = (httpResponse) -> errorResponse = httpResponse

    beforeEach ->
      successReceived = null
      errorResponse   = null

    it 'returns from the backend and calls success', ->
      httpBackend.expectPOST(/\/resques\/test1\/jobs\/failed\/42\/retry/).respond(204)

      service.retry("test1",42,success,failure)

      httpBackend.flush()

      expect(successReceived).toBe(true)
      expect(errorResponse).toBe(null)

    it 'calls the failure callback', ->
      httpBackend.expectPOST(/\/resques\/test1\/jobs\/failed\/42\/retry/).respond(500)

      service.retry("test1",42,success,failure)

      httpBackend.flush()

      expect(successReceived).toBe(null)
      expect(errorResponse).toNotBe(null)

  describe 'get', ->
    job           = null
    errorResponse = null

    success = (results)      -> job = results
    failure = (httpResponse) -> errorResponse = httpResponse

    beforeEach ->
      job           = null
      errorResponse = null

    it 'returns from the backend and calls success', ->
      httpBackend.expectGET(/\/resques\/test1\/jobs\/failed\/42/).respond(200,fakeFailedJob)

      service.get("test1",42,success,failure)

      httpBackend.flush()

      expect(job).toEqualData(fakeFailedJob)
      expect(errorResponse).toBe(null)

    it 'calls the failure callback', ->
      httpBackend.expectGET(/\/resques\/test1\/jobs\/failed\/42/).respond(500)

      service.get("test1",42,success,failure)

      httpBackend.flush()

      expect(job).toBe(null)
      expect(errorResponse).toNotBe(null)

