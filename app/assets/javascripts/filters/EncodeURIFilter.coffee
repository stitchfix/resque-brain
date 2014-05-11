filters = angular.module('filters')
filters.filter('encodeuri',
  ->
    (input)-> encodeURIComponent(input)
)
