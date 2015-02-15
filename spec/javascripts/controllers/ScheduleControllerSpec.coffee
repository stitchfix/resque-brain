describe "RunningController", ->
  scope       = null
  ctrl        = null
  resques     = null
  httpBackend = null
  location    = null
  flash       = null

  schedule = [
    {
      queue:"foo_queue"
      name:"foo"
      cron:null
      klass:"BarJob"
      description:"Some awesome job"
      every:null
      args:null
      frequencyEnglish:null
    },
    {
      queue:"bar_queue"
      name:"bar"
      cron:null
      klass:"BazJob"
      description:"Some crappy job"
      every:null
      args:[1, "foo", true]
      frequencyEnglish:null
    },
    {
      queue:"foo_queue"
      name:"baz"
      cron:null
      klass:"BarJob"
      description:"Some awesome job"
      every:null
      args:["blah"]
      frequencyEnglish:null
    }
  ]
  resqueName = 'test'

  setupController = ()->
    inject((Resques, $rootScope, $routeParams, $location, $httpBackend, $controller, _flash_)->

      scope       = $rootScope.$new()
      resques     = Resques
      httpBackend = $httpBackend
      location    = $location
      flash       = _flash_

      spyOn(resques,"schedule").andCallFake( (resque,success,failure)-> success(schedule) )
      $routeParams.resque = resqueName

      ctrl = $controller('ScheduleController', $scope: scope)
    )

  beforeEach(module("resqueBrain"))
  beforeEach(setupController())

  afterEach ->
    httpBackend.verifyNoOutstandingExpectation()
    httpBackend.verifyNoOutstandingRequest()

  describe 'loading', ->
    it 'exposes the schedule', ->
      expect(scope.schedule).toEqualData(schedule)

  describe 'queue a job', ->
    it 'hits the backend and redirects to the running page', ->
      scope.queue(schedule[1])
      httpBackend.expectPOST("/resques/test/schedule/queue.json", { job_name: schedule[1].name }).respond(201)
      httpBackend.flush()
      expect(location.path()).toBe("/test/running")

  describe 'queue a non-existent', ->
    it 'hits the backend and shows an error', ->
      scope.queue(schedule[1])
      httpBackend.expectPOST("/resques/test/schedule/queue.json", { job_name: schedule[1].name }).respond(404)
      httpBackend.flush()
      expect(location.path()).toNotBe("/test/running")
      expect(flash.error).toBe("404/undefined: undefined")

