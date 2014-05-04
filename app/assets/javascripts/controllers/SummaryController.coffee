controllers = angular.module('controllers')
controllers.controller("SummaryController", [
  '$scope', 'Resques',
  ($scope ,  Resques)->

    $scope.allResques = []
    Resques.all(
      ( (resques)->
        window.resques = resques
        _.chain(resques).forEach( (resque)->
          console.log(resque.name)
          Resques.get(resque.name,
            ( (resqueSummary)-> $scope.allResques.push(resqueSummary) ),
            ( (httpResponse)-> alert("Something happened with #{resque.name}") )
          )
        )
      ),
      ( (httpResponse)-> alert("Something went wrong")
      )
    )

])
