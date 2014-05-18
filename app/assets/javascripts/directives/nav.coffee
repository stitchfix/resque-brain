angular.module("directives").directive("rbNav", [
  "$location","Resques", "GenericErrorHandling",
  ($location , Resques,   GenericErrorHandling)->
    templateUrl: "nav.html"
    link: (scope) ->

      scope.viewResque   = (resque,section='overview') ->
        path = {
          overview: ''
          running: '/running'
          waiting: '/waiting'
          failed:  '/failed'
        }[section] or ''
        $location.path("/#{resque.name}#{path}")

      scope.viewOverview = -> $location.path("/#{scope.resqueSelected}").search({})
      scope.viewRunning  = -> $location.path("/#{scope.resqueSelected}/running").search({})
      scope.viewWaiting  = -> $location.path("/#{scope.resqueSelected}/waiting").search({})
      scope.viewFailed   = -> $location.path("/#{scope.resqueSelected}/failed").search({})
      scope.viewSummary  = -> $location.path("/").search({})

      Resques.all(
        ( (resques)-> scope.resques = resques ),
        GenericErrorHandling.onFail(scope)
      )

      scope.navCollapsed = true

      matched = $location.path().match(/\/([^\/]+)/)
      if matched
        scope.resqueSelected = matched[1]
      else
        scope.resqueSelected = null

      scope.activeClass = (name)->
        if name == 'overview' and $location.path().match(/^\/[^\/]+\/?$/)
          'active'
        else if name == 'running' and $location.path().match(/\/[^\/]+\/running/)
          'active'
        else if name == 'waiting' and $location.path().match(/\/[^\/]+\/waiting/)
          'active'
        else if name == 'failed' and $location.path().match(/\/[^\/]+\/failed/)
          'active'
        else
          ''
])
