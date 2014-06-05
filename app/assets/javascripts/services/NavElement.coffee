services = angular.module('services')

services.factory("NavElement", [
  "$location",
  ($location)->
    # name:: logical name of this nav element
    # title:: human-readable title of this element (defaults to 'name' capitalized)
    # url:: url, relative to resqueSelected, of where this should take the user.  Defaults to "/#{name}"
    # activeRegexp:: regexp on the currentn location that, if matched, indicates this nav element is active.
    #                defaults to /\/#{url}$/
    (resqueSelected,name,title,url,activeRegexp)->
      resqueSelected = resqueSelected
      name           = name
      title          = title        or (name[0].toUpperCase() + name.substring(1))
      url            = url          or "/#{name}"
      activeRegexp   = activeRegexp or new RegExp("#{url}$")

      {
        name: name
        title: title
        url: url

        # Called to 'activate' the nav element, i.e. navigate somewhere
        activate: (resque)->
          resque or= resqueSelected
          $location.path("/#{resque}#{url}").search({})

        # get the class for this nav element depending on if it is active
        activeClass: ->
          if $location.path().match(activeRegexp)
            "active"
      }
])
