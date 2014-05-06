if ENV['RAILS_ENV']
  def rails_require(*)
  end
else
  $: << File.expand_path(File.join(File.dirname(__FILE__),'..','app'))
  def rails_require(file)
    require file
  end
end
