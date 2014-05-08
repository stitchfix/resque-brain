describe "WaitingController", ->
  scope   = null
  ctrl    = null
  resques = null

  jobsWaiting = [
    queue: "mail"
    jobs: [
      queue: "mail",
      payload: {
        class: "UserWelcomeMailer",
        args: [ 12345 ]
      }
      runtime: "0:0:02"
      worker: "p9e942asfhjsfg"
      tooLong: false
    ]
  ,
    queue: "pdf",
    jobs: [
      queue: "pdf",
      payload: {
        class: "GeneratePackInMaterialsJob",
        args: [ 947382, true ]
      }
      runtime: "1:34:01"
      worker: "er0ghq3rdfgsefg"
      tooLong: true
    ]
  ]
    
  resqueName = 'test'

  setupController = ()->
    inject((Resques, $rootScope, $routeParams, $controller)->
      scope   = $rootScope.$new()
      resques = Resques
      spyOn(resques,"jobsWaiting").andCallFake( (resque,success,failure)-> success(jobsWaiting) )
      $routeParams.resque = resqueName

      ctrl    = $controller('WaitingController', $scope: scope)
    )

  beforeEach(module("resqueBrain"))
  beforeEach(setupController())

  it 'exposes the list of jobs running', ->
    expect(scope.jobsWaiting).toEqualData(jobsWaiting)
    expect(scope.totalJobsWaiting).toBe(2)
    expect(resques.jobsWaiting.mostRecentCall.args[0]).toEqualData({ name: resqueName })
