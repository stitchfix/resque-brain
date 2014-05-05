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
      spyOn(resques,"summary").andCallFake( (success,failure)-> success([adminResque,adminResque,adminResque]))

      ctrl    = $controller('SummaryController', $scope: scope)
    )

  beforeEach(module("resqueBrain"))
  beforeEach(setupController())

  it 'exposes the list of resques', ->
    expect(scope.allResques).toEqualData([adminResque,adminResque,adminResque])
