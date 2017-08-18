# frozen_string_literal: true

json.call(schedule_element, :queue, :name, :cron, :klass, :description, :every, :args)
json.frequencyEnglish schedule_element.frequency_in_words
