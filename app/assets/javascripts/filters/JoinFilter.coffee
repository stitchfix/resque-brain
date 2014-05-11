filters = angular.module('filters')
filters.filter('join',
  ->
    (input)->
      input.join("\n")
)
