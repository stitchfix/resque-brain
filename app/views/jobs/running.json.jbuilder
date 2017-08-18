# frozen_string_literal: true

json.array! @jobs, partial: 'running_job', as: :job
