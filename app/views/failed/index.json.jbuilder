# frozen_string_literal: true

json.array! @jobs_failed, partial: 'failed_job', as: :job
