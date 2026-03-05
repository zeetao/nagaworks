# frozen_string_literal: true

require "naga_freeagent"
require "webmock/rspec"
require "logger"

# Mock Rails for testing as it's used in Service for logging
module Rails
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end unless defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger

# If Rails is defined but logger is nil, we still need to provide one
if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger.nil?
  def Rails.logger
    @logger ||= Logger.new(STDOUT)
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    NagaFreeagent.configure do |c|
      c.oauth_id = "test_id"
      c.oauth_secret = "test_secret"
    end
  end
end
