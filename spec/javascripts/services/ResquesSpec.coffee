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

  beforeEach(module("resqueBrain"))
  beforeEach(inject(($httpBackend, $injector)->
    httpBackend = $httpBackend
    service     = $injector.get('Resques')
  ))

  afterEach ->
    httpBackend.verifyNoOutstandingExpectation()
    httpBackend.verifyNoOutstandingRequest()

  describe 'all', ->
    receivedResques = null
    errorResponse   = null

    success = (resques)      -> receivedResques = resques
    failure = (httpResponse) -> errorResponse = httpResponse

    beforeEach ->
      receivedResques = null
      errorResponse   = null


    it 'returns from the backend and calls success', ->
      httpBackend.expectGET(/\/resques/).respond(fakeResques)

      service.all(success,failure)

      httpBackend.flush()

      expect(receivedResques).toEqualData(receivedResques)
      expect(errorResponse).toBe(null)

    it 'returns from the backend and calls failure', ->
      httpBackend.expectGET(/\/resques/).respond(500)

      service.all(success,failure)
      httpBackend.flush()

      expect(receivedResques).toBe(null)
      expect(errorResponse).toNotBe(null)

  describe 'get', ->
    receivedResque = null
    errorResponse  = null

    success = (resque)       -> receivedResque = resque
    failure = (httpResponse) -> errorResponse = httpResponse

    beforeEach ->
      receivedResque = null
      errorResponse  = null

    it 'returns from the backend and calls success', ->
      httpBackend.expectGET(/\/resques\/admin/).respond(adminResque)

      service.get("admin",success,failure)

      httpBackend.flush()

      expect(receivedResque).toEqualData(adminResque)
      expect(errorResponse).toBe(null)

    it 'returns from the backend and calls failure', ->
      httpBackend.expectGET(/\/resques/).respond(500)

      service.get("admin",success,failure)
      httpBackend.flush()

      expect(receivedResque).toBe(null)
      expect(errorResponse).toNotBe(null)
