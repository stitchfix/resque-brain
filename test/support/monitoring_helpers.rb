class ExceptionResque
  def name
    "exception_resque"
  end

  def jobs_running
    raise "BOOM"
  end

  def jobs_failed(*)
    raise "BOOM"
  end

  def failed(*)
    raise "BOOM"
  end

  def waiting_by_queue(*)
    raise "BOOM"
  end

end
module MonitoringHelpers
  def assert_check_result(check_result, resque_name: nil, scope: nil, check_count: nil, message: nil)
    assert_equal resque_name , check_result.resque_name , message.to_s
    if scope.nil?
      assert_nil check_result.scope, message.to_s
    else
      assert_equal scope, check_result.scope, message.to_s
    end
    if check_count.nil?
      assert_nil check_result.check_count, message.to_s
    else
      assert_equal check_count, check_result.check_count, message.to_s
    end
  end

  def assert_exception(exception, message_match:, backtrace_includes:)
    assert_match message_match,exception.message
    assert_match backtrace_includes,exception.backtrace.join(',')
  end
end
