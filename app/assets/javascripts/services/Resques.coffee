services = angular.module('services')

services.factory("Resques", [
  "$resource", "$q",
  ($resource ,  $q)->
    summary = []
    Resques = $resource("/resques/:resqueName", { "format": "json" })
    ResqueJobs = $resource("/resques/:resqueName/jobs/:jobType", { "format" : "json" })

    addToSummaryKeepingSorted = (summary,resqueSummary)->
      summary.push(resqueSummary)
      summary.sort(
        (a,b)->
          nameA = (a.name or "").toLocaleUpperCase()
          nameB = (b.name or "").toLocaleUpperCase()
          nameA.localeCompare(nameB)
      )

    all = (success,failure)              -> Resques.query(success,failure)
    get = (resqueName,success,failure)   -> Resques.get({"resqueName": resqueName},success,failure)
    refreshSummaries = (success,failure) ->
      summary = []
      all(
        ( (resques)->
          promises = _.chain(resques).map( (resque)->
            get(
              resque.name,
              ( (resqueSummary)-> addToSummaryKeepingSorted(summary,resqueSummary) ),
              ( (httpResponse) -> addToSummaryKeepingSorted(summary,{ name: resque.name, error: "Problem retreiving #{resque.name}"}))
            ).$promise
          ).value()
          $q.all(promises)["finally"]( -> success(summary))
        ),
        ( (httpResponse)-> failure(httpResponse) )
      )

    {
      all: all
      get: get
      summary: (success,failure,flush)->
        if summary.length <= 0 or flush == "flush"
          refreshSummaries(success,failure)
        else
          success(summary)

      jobsRunning: (resque,success,failure)->
        ResqueJobs.query({ resqueName: resque.name, jobType: "running" }, success, failure)
      jobsWaiting: (resque,success,failure)->
        ResqueJobs.query({ resqueName: resque.name, jobType: "waiting" }, success, failure)
      jobsFailed:  (resque,start,count,success,failure)->
        ResqueJobs.query({ resqueName: resque.name, jobType: "failed", count: count, start: start }, success, failure)
    }
])
