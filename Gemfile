source "https://rubygems.org"
gemspec

if ENV["GH_PAGES"]
  gem "github-pages"
end

unless ENV["JEKYLL_VERSION"].to_s.empty?
  gem "jekyll", ENV["JEKYLL_VERSION"]
end
