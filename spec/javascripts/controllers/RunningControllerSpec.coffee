describe "RunningController", ->
  scope   = null
  ctrl    = null
  resques = null

  jobsRunning = [
    queue: "mail",
    payload: {
      class: "UserWelcomeMailer",
      args: [ 12345 ]
    }
    runtime: "0:0:02"
    worker: "p9e942asfhjsfg"
    tooLong: false
  ,
    queue: "pdf",
    payload: {
      class: "GeneratePackInMaterialsJob",
      args: [ 947382, true ]
    }
    runtime: "1:34:01"
    worker: "er0ghq3rdfgsefg"
    tooLong: true
  ,
    queue: "purchasing",
    payload: {
      class: "ChargePurchaseJob",
      args: [ 12345, 84762 ]
    }
    runtime: "0:01:12"
    worker: "9seriudfosdfgkl"
    tooLong: false
  ]
  resqueName = 'test'

  setupController = ()->
    inject((Resques, $rootScope, $routeParams, $controller)->
      scope   = $rootScope.$new()
      resques = Resques
      spyOn(resques,"jobsRunning").andCallFake( (resque,success,failure)-> success(jobsRunning) )
      $routeParams.resque = resqueName

      ctrl    = $controller('RunningController', $scope: scope)
    )

  beforeEach(module("resqueBrain"))
  beforeEach(setupController())

  it 'exposes the list of jobs running', ->
    expect(scope.jobsRunning).toEqualData(jobsRunning)
    expect(resques.jobsRunning.mostRecentCall.args[0]).toEqualData({ name: resqueName })
