describe "SummaryController", ->
  scope   = null
  ctrl    = null
  resques = null

  fakeResques = [
      name: "www"
    ,
      name: "admin"
  ]

  adminResque =
    name: "admin"
    failed: 12
    running: 10
    runningTooLong: 3
    waiting: 123

  wwwResque =
    name: "admin"
    failed: 2
    running: 1
    runningTooLong: 1
    waiting: 12

  setupController = ()->
    inject((Resques, $rootScope, $controller)->
      scope   = $rootScope.$new()
      resques = Resques
      spyOn(resques,"summary").andCallFake( (success,failure)-> success([adminResque,wwwResque]))

      ctrl    = $controller('SummaryController', $scope: scope)
    )

  beforeEach(module("resqueBrain"))
  beforeEach(setupController())

  it 'exposes the list of resques', ->
    expect(scope.allResques).toEqualData([adminResque,wwwResque])

  it 'summarizes the values across all resques', ->
    expect(scope.totalFailed).toBe(14)
    expect(scope.totalRunning).toBe(11)
    expect(scope.totalWaiting).toBe(135)
