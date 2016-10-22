describe "WaitingController", ->
  scope   = null
  ctrl    = null
  resques = null

  jobsWaiting = [
    queue: "mail"
    jobs: 3
  ,
    queue: "pdf",
    jobs: 10
  ]

  resqueName = 'test'

  setupController = ()->
    inject((Resques, $rootScope, $routeParams, $controller)->
      scope   = $rootScope.$new()
      resques = Resques
      spyOn(resques,"countJobsWaiting").andCallFake( (resque,success,failure)-> success(jobsWaiting) )
      $routeParams.resque = resqueName

      ctrl    = $controller('WaitingController', $scope: scope)
    )

  beforeEach(module("resqueBrain"))
  beforeEach(setupController())

  it 'exposes the list of jobs running', ->
    expect(scope.jobsWaiting).toEqualData(jobsWaiting)
    expect(scope.totalJobsWaiting).toBe(13)
    expect(resques.countJobsWaiting.mostRecentCall.args[0]).toEqualData({ name: resqueName })
