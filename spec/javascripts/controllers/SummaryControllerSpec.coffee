describe "SummaryController", ->
  scope   = null
  ctrl    = null
  resques = null

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

  setupController = ()->
    inject((Resques, $rootScope, $controller)->
      scope   = $rootScope.$new()
      resques = Resques
      spyOn(resques,"all").andCallFake( (success,failure)-> success(fakeResques))
      spyOn(resques,"get").andCallFake( (resqueName,success,failure)-> success(adminResque))

      ctrl    = $controller('SummaryController', $scope: scope)
    )

  beforeEach(module("resqueBrain"))
  beforeEach(setupController())

  it 'exposes the list of resques', ->
    expect(scope.allResques).toEqualData([adminResque,adminResque,adminResque])
