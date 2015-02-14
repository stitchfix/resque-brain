describe "RunningController", ->
  scope   = null
  ctrl    = null
  resques = null

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
    inject((Resques, $rootScope, $routeParams, $controller)->
      scope   = $rootScope.$new()
      resques = Resques
      spyOn(resques,"schedule").andCallFake( (resque,success,failure)-> success(schedule) )
      $routeParams.resque = resqueName

      ctrl = $controller('ScheduleController', $scope: scope)
    )

  beforeEach(module("resqueBrain"))
  beforeEach(setupController())

  it 'exposes the schedule', ->
    expect(scope.schedule).toEqualData(schedule)
