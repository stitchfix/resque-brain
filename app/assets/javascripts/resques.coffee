services = angular.module('services')

services.factory("resques", [
  ()->
    {
      all: [
        name: "admin"
      ,
        name: "file-uploader"
      ,
        name: "www"
      ]
    }
])
