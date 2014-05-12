services = angular.module('services')

services.factory("GenericErrorHandling", [
  "flash",
  (flash)->
    onFail: (scope)->
      (httpResponse)->
        flash.error   = "#{httpResponse.status}/#{httpResponse.statusText}: #{httpResponse.data}"
        scope.loading =    false

])
