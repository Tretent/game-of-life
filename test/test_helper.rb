ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel. Capped at 4 workers: each one drives its own
    # headless Chrome + Puma for system tests, and on many-core machines
    # `test:all` starves the CPU, making Turbo form submissions flaky.
    # Override with PARALLEL_WORKERS if needed.
    parallelize(workers: 4)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
