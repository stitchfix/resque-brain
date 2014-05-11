describe "Resques", ->
  service     = null
  httpBackend = null

  fakeResques = [
      name: "www"
    ,
      name: "admin"
    ,
      name: "file-upload"
  ]
  adminResque =
    name: "admin"
    failed: 12
    running: 10
    runningTooLong: 3
    waiting: 123

  fakeJobs = [
    queue: "mail",
    payload: {
      class: "UserWelcomeMailer",
      args: [ 12345 ]
    }
    startedAt: (new Date()).getTime()
    worker: "p9e942asfhjsfg"
    tooLong: false
  ,
    queue: "pdf",
    payload: {
      class: "GeneratePackInMaterialsJob",
      args: [ 947382, true ]
    }
    startedAt: (new Date()).getTime()
    worker: "er0ghq3rdfgsefg"
    tooLong: true
  ,
    queue: "purchasing",
    payload: {
      class: "ChargePurchaseJob",
      args: [ 12345, 84762 ]
    }
    startedAt: (new Date()).getTime()
    worker: "9seriudfosdfgkl"
    tooLong: false
  ]

  fakeFailedJobs = [
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

  beforeEach(module("resqueBrain"))
  beforeEach(inject(($httpBackend, $injector)->
    httpBackend = $httpBackend
    service     = $injector.get('Resques')
  ))

  afterEach ->
    httpBackend.verifyNoOutstandingExpectation()
    httpBackend.verifyNoOutstandingRequest()

  describe 'summary', ->
    receivedResques = null
    errorResponse   = null

    success = (resques)      -> receivedResques = resques
    failure = (httpResponse) -> errorResponse = httpResponse

    beforeEach ->
      receivedResques = null
      errorResponse   = null

    it 'returns from the backend and calls success', ->
      httpBackend.expectGET(/\/resques/).respond(fakeResques)
      httpBackend.expectGET(new RegExp("/resques/#{fakeResques[0].name}")).respond(adminResque)
      httpBackend.expectGET(new RegExp("/resques/#{fakeResques[1].name}")).respond(adminResque)
      httpBackend.expectGET(new RegExp("/resques/#{fakeResques[2].name}")).respond(adminResque)

      service.summary(success,failure)

      httpBackend.flush()

      expect(receivedResques).toEqualData([adminResque,adminResque,adminResque])
      expect(errorResponse).toBe(null)

    it 'returns from the backend and calls failure', ->
      httpBackend.expectGET(/\/resques/).respond(500)
      
      service.summary(success,failure)
      httpBackend.flush()

      expect(receivedResques).toBe(null)
      expect(errorResponse).toNotBe(null)

    it 'returns only those it fetched', ->
      httpBackend.expectGET(/\/resques/).respond(fakeResques)
      httpBackend.expectGET(new RegExp("/resques/#{fakeResques[0].name}")).respond(adminResque)
      httpBackend.expectGET(new RegExp("/resques/#{fakeResques[1].name}")).respond(500)
      httpBackend.expectGET(new RegExp("/resques/#{fakeResques[2].name}")).respond(adminResque)
      
      service.summary(success,failure)
      httpBackend.flush()

      expect(receivedResques).toEqualData([adminResque,{name: fakeResques[1].name, error: "Problem retreiving #{fakeResques[1].name}"},adminResque])
      expect(errorResponse).toBe(null)

    describe 'when we have already fetched them', ->
      beforeEach ->
        httpBackend.expectGET(/\/resques/).respond(fakeResques)
        httpBackend.expectGET(new RegExp("/resques/#{fakeResques[0].name}")).respond(adminResque)
        httpBackend.expectGET(new RegExp("/resques/#{fakeResques[1].name}")).respond(adminResque)
        httpBackend.expectGET(new RegExp("/resques/#{fakeResques[2].name}")).respond(adminResque)

        service.summary(success,failure)

        httpBackend.flush()

      describe 'and we do not ask to re-fetch', ->
        it 'does not request again', ->
          receivedResques = null

          service.summary(success,failure)

          expect(receivedResques).toEqualData([adminResque,adminResque,adminResque])
          expect(errorResponse).toBe(null)

      describe 'and we ask to re-fetch', ->
        it 'does requests again', ->
          receivedResques = null

          httpBackend.expectGET(/\/resques/).respond([ fakeResques[0] ])
          httpBackend.expectGET(new RegExp("/resques/#{fakeResques[0].name}")).respond(adminResque)

          service.summary(success,failure,"flush")

          httpBackend.flush()

          expect(receivedResques).toEqualData([adminResque])
          expect(errorResponse).toBe(null)

  describe 'jobsRunning', ->
    receivedJobs  = null
    errorResponse = null

    success = (jobs)         -> receivedJobs = jobs
    failure = (httpResponse) -> errorResponse = httpResponse

    beforeEach ->
      receivedJobs  = null
      errorResponse = null


    it 'returns from the backend and calls success', ->
      httpBackend.expectGET(/\/resques\/foobar\/jobs\/running/).respond(fakeJobs)

      service.jobsRunning({ name: "foobar"},success,failure)

      httpBackend.flush()

      expect(receivedJobs).toEqualData(fakeJobs)
      expect(errorResponse).toBe(null)

    it 'returns from the backend and calls failure', ->
      httpBackend.expectGET(/\/resques\/foobar\/jobs\/running/).respond(500)
      
      service.jobsRunning({ name: "foobar" },success,failure)
      httpBackend.flush()

      expect(receivedJobs).toBe(null)
      expect(errorResponse).toNotBe(null)

  describe 'jobsWaiting', ->
    receivedJobs  = null
    errorResponse = null

    success = (jobs)         -> receivedJobs = jobs
    failure = (httpResponse) -> errorResponse = httpResponse

    beforeEach ->
      receivedJobs  = null
      errorResponse = null


    it 'returns from the backend and calls success', ->
      byQueue = _.chain(fakeJobs).groupBy("queue").map( (queue,jobs)-> { queue: queue, jobs: jobs }).value()
      httpBackend.expectGET(/\/resques\/foobar\/jobs\/waiting/).respond(byQueue)

      service.jobsWaiting({ name: "foobar"},success,failure)

      httpBackend.flush()

      expect(receivedJobs).toEqualData(byQueue)
      expect(errorResponse).toBe(null)

    it 'returns from the backend and calls failure', ->
      httpBackend.expectGET(/\/resques\/foobar\/jobs\/waiting/).respond(500)
      
      service.jobsWaiting({ name: "foobar" },success,failure)
      httpBackend.flush()

      expect(receivedJobs).toBe(null)
      expect(errorResponse).toNotBe(null)

  describe 'jobsFailed', ->
    receivedJobs  = null
    errorResponse = null

    success = (jobs)         -> receivedJobs = jobs
    failure = (httpResponse) -> errorResponse = httpResponse

    beforeEach ->
      receivedJobs  = null
      errorResponse = null


    it 'returns from the backend and calls success', ->
      httpBackend.expectGET(/\/resques\/foobar\/jobs\/failed.*count=12.*start=2/).respond(fakeFailedJobs)

      service.jobsFailed({ name: "foobar"},2,12,success,failure)

      httpBackend.flush()

      expect(receivedJobs).toEqualData(fakeFailedJobs)
      expect(errorResponse).toBe(null)

    it 'returns from the backend and calls failure', ->
      httpBackend.expectGET(/\/resques\/foobar\/jobs\/failed/).respond(500)
      
      service.jobsFailed({ name: "foobar" },2,12,success,failure)
      httpBackend.flush()

      expect(receivedJobs).toBe(null)
      expect(errorResponse).toNotBe(null)
