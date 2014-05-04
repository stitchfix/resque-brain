unless ENV['RAILS_ENV']
  $: << File.expand_path(File.join(File.dirname(__FILE__),'..','app','models'))
  require 'resque_instance'
end
