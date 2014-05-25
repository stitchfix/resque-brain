if ENV['RAILS_ENV']
  def rails_require(*)
  end
else
  $: << File.expand_path(File.join(File.dirname(__FILE__),'..'))
  def rails_require(file)
    require "app/#{file}"
  end

  def lib_require(file)
    require "lib/#{file}"
  end
end
