json.array! @resques do |resque|
  json.name           resque.name
  json.failed         resque.failed
  json.running        resque.running
  json.runningTooLong resque.running_too_long
  json.waiting        resque.waiting
end
