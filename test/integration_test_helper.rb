# frozen_string_literal: true

require 'test_helper'
require 'capybara/rails'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
Capybara.default_driver    = :poltergeist

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  def sanity_check
    yield
  end

  def page_assertion_error_message(page)
    page.html
  end
end
