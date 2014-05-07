angular.module("directives").directive("rbNav", [
  "$location","Resques",
  ($location , Resques)->
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

      scope.viewOverview =          -> $location.path("/#{scope.resqueSelected}")
      scope.viewRunning  =          -> $location.path("/#{scope.resqueSelected}/running")
      scope.viewWaiting  =          -> $location.path("/#{scope.resqueSelected}/waiting")
      scope.viewFailed   =          -> $location.path("/#{scope.resqueSelected}/failed")
      scope.viewSummary  =          -> $location.path("/")

      Resques.all(
        ( (resques)-> scope.resques = resques ),
        ( (httpResponse)-> alert("Something busted, yo"))
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
