# frozen_string_literal: true
##################################################################################
#     Rbcli -- A framework for developing command line applications in Ruby      #
#     Copyright (C) 2024 Andrew Khoury <akhoury@live.com>                        #
##################################################################################
require_relative "lib/rbcli/version"

Gem::Specification.new do |spec|
  spec.name = "rbcli"
  spec.version = Rbcli::VERSION
  spec.authors = ["Andrew Khoury"]
  spec.email = ["akhoury@live.com"]

  spec.summary = "A CLI Application/Tooling Framework for Ruby"
  spec.description = "Rbcli is a framework to quickly develop command-line tools and applications."
  spec.homepage = "https://akhoury6.github.io/rbcli/"
  spec.license = "MIT"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "https://akhoury6.github.io/rbcli/"
  spec.metadata["source_code_uri"] = "https://github.com/akhoury6/rbcli"
  spec.metadata["changelog_uri"] = "https://github.com/akhoury6/rbcli/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      # (f == File.basename(__FILE__)) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .github .circleci appveyor Gemfile])
      !f.start_with?(*%w[lib/ exe/ sig/ LICENSE VERSION README])
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.6.10"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "colorize", "~> 1.1"
  spec.add_dependency "octokit", "~> 8.1"
  spec.add_dependency "faraday-retry", "~> 2.2" # Required for octokit
  spec.add_dependency "json-schema", "~> 4.3"
  spec.add_dependency "bigdecimal", "~> 3.1" # Required for json-schema
  spec.add_dependency "erb", "~> 4.0"
  spec.add_dependency "deep_merge", "~> 1.2"
  spec.add_dependency "paint", "~> 2.3"
  spec.add_dependency "erubis", "~> 2.7"
  spec.add_dependency "rest-client", "~> 2.1"
  spec.add_dependency "toml", "~> 0.3"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end