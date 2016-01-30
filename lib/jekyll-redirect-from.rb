require "jekyll"

module JekyllRedirectFrom
  def self.jekyll_3?
    @jekyll_3 ||= (Jekyll::VERSION >= '3.0.0')
  end
end

require "jekyll-redirect-from/version"
require "jekyll-redirect-from/redirect_page"
require "jekyll-redirect-from/redirector"
