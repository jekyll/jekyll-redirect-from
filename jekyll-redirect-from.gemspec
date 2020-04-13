# frozen_string_literal: true

require "English"
require_relative "lib/jekyll-redirect-from/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-redirect-from"
  spec.version       = JekyllRedirectFrom::VERSION
  spec.authors       = ["Parker Moore"]
  spec.email         = ["parkrmoore@gmail.com"]
  spec.summary       = "Seamlessly specify multiple redirection URLs " \
                       "for your pages and posts"
  spec.homepage      = "https://github.com/jekyll/jekyll-redirect-from"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)

  spec.executables   = spec.files.grep(%r!^bin/!) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r!^(test|spec|features)/!)
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.4.0"

  spec.add_runtime_dependency "jekyll", ">= 3.3", "< 5.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "jekyll-sitemap", "~> 1.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rubocop-jekyll", "~> 0.10"
end
