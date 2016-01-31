module MonitoringHelpers
  def assert_check_result(check_result, resque_name: nil, scope: nil, check_count: nil, message: nil)
    assert_equal resque_name , check_result.resque_name , message.to_s
    assert_equal scope       , check_result.scope       , message.to_s
    assert_equal check_count , check_result.check_count , message.to_s
  end
end
