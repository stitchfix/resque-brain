angular.module("directives").directive("rbNav", [
  "$location","resques",
  ($location , resques)->
    templateUrl: "nav.html"
    link: (scope) ->

      scope.viewResque   = (resque) -> $location.path("/#{resque.name}")
      scope.viewOverview =          -> $location.path("/#{scope.resqueSelected}")
      scope.viewRunning  =          -> $location.path("/#{scope.resqueSelected}/running")
      scope.viewWaiting  =          -> $location.path("/#{scope.resqueSelected}/waiting")
      scope.viewFailed   =          -> $location.path("/#{scope.resqueSelected}/failed")
      scope.viewSummary  =          -> $location.path("/")

      scope.resques = resques.all

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
