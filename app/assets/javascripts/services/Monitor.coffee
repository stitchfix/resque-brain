services = angular.module('services')

# Factory for creating Monitor instances.  A Monitor exposes information about a specific resque aspect you
# want monitored, for example the number of failed jobs.  A Monitor is:
#
# name:: logical name
# title:: human-facing name
# icon:: a glyphicon representing the monitor for help in visual distinction
# count:: a count of what's being monitored
# warning:: a function that returns true if the count represents a "warning" condition
# danger:: a function that returns true if the count represents a "danger" condition
# supplementalWarning:: a function that returns an additional human-facing string if there is a warning or danger condition
#
services.factory("Monitor", [
  ()->
    # Create a new Monitor.
    #
    # attributes:: recognizes the following attributes (all required unless otherwise stated):
    #              count:: The count of what is being monitored
    #              name:: logical name of this monitor, not human-facing
    #              title:: Human-readable title for this monitor
    #              icon:: glyphicon name to go along (optional but recommended)
    #              unit:: units of what is being monitored
    #              warnOn:: show a warning state if the count is this or greater (default: 1).  A value of 'never' 
    #                       will ensure this monitor never goes into a warning state
    #              dangerOn:: show a danger/alert state if the count is this or greater (default: 10).  A value of 'never' 
    #                         will ensure this monitor never goes into a danger state
    #              supplementalWarning:: if present, shows an additional value to explain the warning
    (attributes={})->
      name      = attributes.name
      icon      = attributes.icon
      unit      = attributes.unit
      title     = attributes.title    or (attributes.name[0].toUpperCase() + attributes.name.substring(1))
      warnOn    = attributes.warnOn   or 1
      dangerOn  = attributes.dangerOn or 10
      count     = attributes.count
      warnCount = attributes.warnCount or count
      supplementalWarning = attributes.supplementalWarning

      warning = ->
        if warnOn == 'never'
          false
        else if warnCount >= warnOn
          true

      danger = ->
        if dangerOn == 'never'
          false
        else if warnCount >= dangerOn
          true

      {
        name: name
        icon: icon
        unit: unit
        title: title
        count: count
        warning: warning
        danger: danger
        supplementalWarning: ->
          if warning() or danger()
            supplementalWarning
      }
                 

])
