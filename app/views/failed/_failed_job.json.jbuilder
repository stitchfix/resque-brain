json.(job, :queue, :payload, :worker, :exception, :error, :backtrace)
json.failedAt job.failed_at.nil?  ? nil : (job.failed_at.to_i  * 1000)
json.retriedAt job.retried_at.nil?  ? nil : (job.retried_at.to_i  * 1000)
