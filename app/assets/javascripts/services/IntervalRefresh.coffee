services = angular.module('services')

services.factory("IntervalRefresh", [
  "$interval",
  ($interval)->
    (refreshFunction,scope,refreshTimeout=30000)->
      refreshFunction()
      intervalPromise = $interval(refreshFunction, refreshTimeout)
      scope.$on("$destroy", -> $interval.cancel(intervalPromise))
])
