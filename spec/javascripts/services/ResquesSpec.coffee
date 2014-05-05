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
      
#  describe 'get', ->
#    receivedResque = null
#    errorResponse  = null
#
#    success = (resque)       -> receivedResque = resque
#    failure = (httpResponse) -> errorResponse = httpResponse
#
#    beforeEach ->
#      receivedResque = null
#      errorResponse  = null
#
#    it 'returns from the backend and calls success', ->
#      httpBackend.expectGET(/\/resques\/admin/).respond(adminResque)
#
#      service.get("admin",success,failure)
#
#      httpBackend.flush()
#
#      expect(receivedResque).toEqualData(adminResque)
#      expect(errorResponse).toBe(null)
#
#    it 'returns from the backend and calls failure', ->
#      httpBackend.expectGET(/\/resques/).respond(500)
#
#      service.get("admin",success,failure)
#      httpBackend.flush()
#
#      expect(receivedResque).toBe(null)
#      expect(errorResponse).toNotBe(null)
