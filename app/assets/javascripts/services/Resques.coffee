services = angular.module('services')

services.factory("Resques", [
  "$resource", "$q",
  ($resource ,  $q)->
    summary = []
    Resques = $resource("/resques/:resqueName", { "format": "json" })

    all = (success,failure)              -> Resques.query(success,failure)
    get = (resqueName,success,failure)   -> Resques.get({"resqueName": resqueName},success,failure)
    refreshSummaries = (success,failure) ->
      all(
        ( (resques)->
          promises = _.chain(resques).map( (resque)->
            get(
              resque.name,
              ( (resqueSummary)-> summary.push(resqueSummary) ),
              ( (httpResponse) -> summary.push({ name: resque.name, error: "Problem retreiving #{resque.name}"}) )
            ).$promise
          ).value()
          $q.all(promises)["finally"]( -> success(summary))
        ),
        ( (httpResponse)-> failure(httpResponse) )
      )

    {
      all: all
      get: get
      summary: (success,failure)->
        if summary.length > 0
          success(summary)
        else
          refreshSummaries(success,failure)
    }
])
