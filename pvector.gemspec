# frozen_string_literal: true

require_relative "lib/pvector/version"

Gem::Specification.new do |spec|
  spec.name = "pvector"
  spec.version = Pvector::VERSION
  spec.authors = ["Erik Olson"]
  spec.email = ["xorgnak@gmail.com"]

  spec.summary = "keyword analysis from plain-text"
  spec.description = "Local plaintext search."
  spec.homepage = "https://github.com/xorgnak/pvector"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "pstore"
  spec.add_dependency "rwordnet"
  spec.add_dependency "rackup"
  spec.add_dependency "sinatra"
  spec.add_dependency "wikipedia-client"

  spec.add_dependency "serialport"

  spec.add_dependency "llamafile"

  spec.add_dependency "gnu-remind"

  spec.add_dependency "meiou"

  spec.add_dependency "fortunecookie"

  spec.add_dependency "cardtrick"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
