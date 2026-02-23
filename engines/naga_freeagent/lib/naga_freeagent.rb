# frozen_string_literal: true

require "rails"
require_relative "naga_freeagent/version"
require_relative "naga_freeagent/service"

module NagaFreeagent
  class Error < StandardError; end

  class Engine < ::Rails::Engine
    isolate_namespace NagaFreeagent

    initializer "naga_freeagent.assets.precompile" do |app|
      app.config.assets.precompile += %w( naga_freeagent_manifest.js )
    end

    initializer "naga_freeagent.add_migrations" do |app|
      unless app.root.to_s.match?(%r{#{root}/?})
        app.config.paths["db/migrate"].concat(config.paths["db/migrate"].expanded)
      end
    end

    rake_tasks do
      load "tasks/naga_freeagent_tasks.rake"
    end
  end

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
