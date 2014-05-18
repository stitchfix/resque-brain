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
                             retryAll:
                               method: "POST"
                               url: "/resques/:resqueName/jobs/failed/retry_all"
                               isArray: false
                             clearAll:
                               method: "DELETE"
                               url: "/resques/:resqueName/jobs/failed/clear_all"
                               isArray: false
                           })
    {
      retry: (resqueName, jobId, success, failure)->
        FailedJobs.retry({ resqueName: resqueName, id: jobId }, {}, success, failure)
      clear: (resqueName, jobId, success, failure)->
        FailedJobs.remove({ resqueName: resqueName, id: jobId }, success, failure)
      retryAll: (resqueName, success, failure)->
        FailedJobs.retryAll({ resqueName: resqueName }, {}, success, failure)
      retryAndClearAll: (resqueName, success, failure)->
        FailedJobs.retryAll({ resqueName: resqueName, also_clear: 'true' }, {}, success, failure)
      clearAll: (resqueName, success, failure)->
        FailedJobs.clearAll({ resqueName: resqueName }, success, failure)
      get: (resqueName, jobId, success, failure)->
        FailedJobs.get({ resqueName: resqueName, id: jobId }, success, failure)
    }
])
