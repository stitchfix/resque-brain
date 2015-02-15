angular.module("directives").directive("rbNav", [
  "$location","Resques", "GenericErrorHandling", "NavElement",
  ($location , Resques,   GenericErrorHandling ,  NavElement)->
    templateUrl: "nav.html"
    link: (scope) ->

      Resques.all(
        ( (resques)-> scope.resques = resques ),
        GenericErrorHandling.onFail(scope)
      )

      scope.navCollapsed = true

      window.blah = $location.path()
      matched = $location.path().match(/\/([^\/]+)/)
      if matched
        scope.resqueSelected = matched[1]
      else
        scope.resqueSelected = null

      scope.navElements = [
        NavElement(scope.resqueSelected,'overview','Overview','/',new RegExp("/$")),
        NavElement(scope.resqueSelected,'running','Running Jobs'),
        NavElement(scope.resqueSelected,'waiting','Waiting Jobs'),
        NavElement(scope.resqueSelected,'failed','Failed Jobs')
        NavElement(scope.resqueSelected,'schedule','Schedule')
      ]

      scope.viewResque = (section,resque)->
        resqueName = (resque or {}).name or scope.resqueSelected
        element = _.find(scope.navElements, (navElement)-> navElement.name == section)
        throw Error("No nav element named #{section}") unless element
        element.activate(resqueName)

      scope.viewSummary = -> $location.path("/").search({})

])
