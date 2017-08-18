# frozen_string_literal: true

class NoSuchResque < StandardError
  def initialize(param_name, param_value)
    super "No resque named '#{param_value}' (based on param '#{param_name}')"
  end
end
