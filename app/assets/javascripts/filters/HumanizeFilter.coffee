filters = angular.module('filters')
filters.filter('humanize',
  ->
    (input)->
      _.capitalize(input.split("_").join(" "))
)
