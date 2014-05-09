json.(job, :queue, :payload, :worker, :exception, :error, :backtrace)
json.failedAt job.failed_at.nil?  ? nil : (job.failed_at.to_i  * 1000)
