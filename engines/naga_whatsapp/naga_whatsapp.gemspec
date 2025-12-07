require_relative "lib/naga_whatsapp/version"

Gem::Specification.new do |spec|
  spec.name        = "naga_whatsapp"
  spec.version     = NagaWhatsapp::VERSION
  spec.authors     = [ "Zee" ]
  spec.email       = [ "zee@nagas.io" ]
  spec.homepage    = "nagas.io"
  spec.summary     = "Private Nagaworks Gem for Whatsapp connection"
  spec.description = "Encapsulate various internal functionalities for Whatsapp in a private gem/module to be reused in other projects"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.2.2"
  spec.add_dependency "whatsapp_sdk", "~> 1.0.3"

  spec.add_development_dependency "rspec-rails", "~> 6.0.0"
  spec.add_development_dependency "webmock", "~> 3.18.1"
  spec.add_development_dependency "mysql2", "~> 0.5"
end
