services = angular.module('services')

services.factory("Resques", [
  "$resource",
  ($resource)->
    Resques = $resource("/resques/:resqueName", { "format": "json" })
    {
      all: (success,failure)->
        Resques.query(success,failure)
      get: (resqueName,success,failure)->
        Resques.get({"resqueName": resqueName},success,failure)
    }
])
