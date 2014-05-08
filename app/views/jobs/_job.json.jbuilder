json.(job, :queue, :payload, :worker)
json.tooLong job.too_long
json.startedAt job.started_at.nil? ? nil : (job.started_at.to_i * 1000)
