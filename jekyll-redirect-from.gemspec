# frozen_string_literal: true

require_relative "lib/jekyll-redirect-from/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-redirect-from"
  spec.version       = JekyllRedirectFrom::VERSION
  spec.authors       = ["Parker Moore"]
  spec.email         = ["parkrmoore@gmail.com"]
  spec.summary       = "Seamlessly specify multiple redirection URLs for your pages and posts"
  spec.homepage      = "https://github.com/jekyll/jekyll-redirect-from"
  spec.license       = "MIT"

  spec.files         = `git ls-files lib`.split("\n").concat(%w(LICENSE.txt README.md History.markdown))
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.5.0"

  spec.add_runtime_dependency "jekyll", ">= 3.3", "< 5.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "jekyll-sitemap", "~> 1.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rubocop-jekyll", "~> 0.13.0"
end
