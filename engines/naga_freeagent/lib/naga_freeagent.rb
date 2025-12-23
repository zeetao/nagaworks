# frozen_string_literal: true

require_relative "naga_freeagent/version"

module NagaFreeagent
  class Error < StandardError; end

  class Configuration
    attr_accessor :oauth_id, :oauth_secret

    def initialize
      @oauth_id = nil
      @oauth_secret = nil
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
