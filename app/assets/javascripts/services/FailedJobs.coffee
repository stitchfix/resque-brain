services = angular.module('services')

services.factory("FailedJobs", [
  "$resource",
  ($resource)->
    FailedJobs = $resource("/resques/:resqueName/jobs/failed/:id",
                           { format: "json" },
                           {
                             retry:
                               method: "POST"
                               url: "/resques/:resqueName/jobs/failed/:id/retry"
                               isArray: false
                           })
    {
      retry: (resqueName, jobId, success, failure)->
        FailedJobs.retry({ resqueName: resqueName, id: jobId }, {}, success, failure)
      clear: (resqueName, jobId, success, failure)->
        FailedJobs.remove({ resqueName: resqueName, id: jobId }, success, failure)

      get: (resqueName, jobId, success, failure)->
        FailedJobs.get({ resqueName: resqueName, id: jobId }, success, failure)
    }
])
