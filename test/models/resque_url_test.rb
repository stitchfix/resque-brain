require 'quick_test_helper'
require 'minitest/autorun'
rails_require 'models/resque_url'
rails_require 'models/missing_resque_configuration_error'

class ResqueUrlTest < MiniTest::Test

  def setup
    ENV["FOO_BAR_RESQUE_REDIS_URL"] = nil
    ENV["FOO_BAR_REDIS_URL"] = nil
    ENV["RESQUE_BRAIN_INSTANCES_foo_bar"] = nil
    ENV["RESQUE_BRAIN_INSTANCES_foo-bar"] = nil
  end

  def teardown
    ENV["FOO_BAR_RESQUE_REDIS_URL"] = nil
    ENV["FOO_BAR_REDIS_URL"] = nil
    ENV["RESQUE_BRAIN_INSTANCES_foo_bar"] = nil
    ENV["RESQUE_BRAIN_INSTANCES_foo-bar"] = nil
  end

  def test_recognize_uses_RESQUE_BRAIN_INSTANCES_
    resque_url  = ResqueUrl.recognize("RESQUE_BRAIN_INSTANCES_foo-bar")
    assert_equal "foo-bar", resque_url.resque_name
  end

  def test_recognize_uses_RESQUE_REDIS_URL
    resque_url  = ResqueUrl.recognize("FOO_BAR_RESQUE_REDIS_URL")
    assert_equal "foo-bar", resque_url.resque_name
  end

  def test_recognize_uses_REDIS_URL
    resque_url  = ResqueUrl.recognize("FOO_BAR_REDIS_URL")
    assert_equal "foo-bar", resque_url.resque_name
  end

  def test_recognize_returns_nil_for_other_env_vars
    assert_nil ResqueUrl.recognize("SIDEKIQ_URL")
  end

  def test_namespace_env_var
    assert_equal "FOO_BAR_NAMESPACE", ResqueUrl.new("foo-bar").namespace_env_var
  end

  def test_url_uses_RESQUE_BRAIN_INSTANCES_
    ENV["RESQUE_BRAIN_INSTANCES_foo-bar"] = "some url"
    resque_url  = ResqueUrl.new("foo-bar")
    assert_equal "some url",resque_url.url
  end

  def test_url_uses_RESQUE_BRAIN_INSTANCES_with_underscore
    ENV["RESQUE_BRAIN_INSTANCES_foo_bar"] = "some url"
    resque_url  = ResqueUrl.new("foo-bar")
    assert_equal "some url",resque_url.url
  end

  def test_url_uses_RESQUE_REDIS_URL
    ENV["FOO_BAR_RESQUE_REDIS_URL"] = "some url"
    resque_url  = ResqueUrl.new("foo-bar")
    assert_equal "some url",resque_url.url
  end

  def test_url_uses_REDIS_URL
    ENV["FOO_BAR_REDIS_URL"] = "some url"
    resque_url  = ResqueUrl.new("foo-bar")
    assert_equal "some url",resque_url.url
  end

  def test_url_favors_RESQUE_BRAIN_INSTANCES_
    ENV["FOO_BAR_REDIS_URL"] = "some other url"
    ENV["FOO_BAR_RESQUE_REDIS_URL"] = "some other other url"
    ENV["RESQUE_BRAIN_INSTANCES_foo-bar"] = "some url"
    resque_url  = ResqueUrl.new("foo-bar")
    assert_equal "some url",resque_url.url
  end

  def test_url_favors_RESQUE_REDIS_URL
    ENV["FOO_BAR_REDIS_URL"] = "some other url"
    ENV["FOO_BAR_RESQUE_REDIS_URL"] = "some url"
    resque_url  = ResqueUrl.new("foo-bar")
    assert_equal "some url",resque_url.url
  end

  def test_missing_url_blows_up
    resque_url  = ResqueUrl.new("foo-bar")
    ex = assert_raises(MissingResqueConfigurationError) do
      url = resque_url.url
      puts url
    end
    assert_match /foo-bar/, ex.message
    assert_match /FOO_BAR_RESQUE_REDIS_URL/, ex.message
    assert_match /FOO_BAR_REDIS_URL/, ex.message
    assert_match /RESQUE_BRAIN_INSTANCES_foo_bar/, ex.message
    assert_match /RESQUE_BRAIN_INSTANCES_foo-bar/, ex.message
  end
end
