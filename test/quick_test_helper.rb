# frozen_string_literal: true

if ENV['RAILS_ENV'] == 'test'
  $LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..'))
  def rails_require(file)
    require "app/#{file}"
  end

  def lib_require(file)
    require "lib/#{file}"
  end
else
  def rails_require(*); end
end
