services = angular.module('services')

services.factory("GenericErrorHandling", [
  "flash",
  (flash)->
    onFail: (scope)->
      (httpResponse)->
        flash.error   = if httpResponse.status == 0
          "Lost connection to the server"
        else
          "#{httpResponse.status}/#{httpResponse.statusText}: #{httpResponse.data}"
        scope.loading =    false

])
