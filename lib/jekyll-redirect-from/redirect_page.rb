# frozen_string_literal: true

module JekyllRedirectFrom
  # Specialty page which implements the redirect path logic
  class RedirectPage < Jekyll::Page
    # Use Jekyll's native absolute_url filter
    include Jekyll::Filters::URLFilters

    DEFAULT_DATA = {
      "sitemap" => false,
      "layout"  => "redirect",
    }.freeze

    # Schemes which may be used for an absolute redirect target. Anything else
    # (e.g. `javascript:` or `data:`) could execute script on the redirect page.
    ALLOWED_SCHEMES = %w(http https).freeze

    # Browsers ignore leading and trailing C0 control characters and spaces, and
    # tabs and newlines anywhere in a URL, when determining its scheme.
    URL_STRIP_REGEX = %r![\t\n\r]!.freeze
    URL_TRIM_REGEX = %r!\A[\u0000-\u0020]+|[\u0000-\u0020]+\z!.freeze
    SCHEME_REGEX = %r!\A([a-z][a-z0-9+\-.]*):!i.freeze

    # Characters which must be escaped for a JSON string to be safely embedded
    # in an HTML <script> element.
    JS_ESCAPE_REGEX = %r![<>&\u2028\u2029]!.freeze

    # Returns true if the given target is a relative path or an http(s) URL
    def self.valid_target?(to)
      normalized = to.to_s.gsub(URL_STRIP_REGEX, "").gsub(URL_TRIM_REGEX, "")
      scheme = normalized[SCHEME_REGEX, 1]
      scheme.nil? || ALLOWED_SCHEMES.include?(scheme.downcase)
    end

    # Creates a new RedirectPage instance from a source path and redirect path
    #
    # site - The Site object
    # from - the (URL) path, relative to the site root to redirect from
    # to   - the relative path or URL which the page should redirect to
    def self.from_paths(site, from, to)
      page = RedirectPage.new(site, site.source, "", "redirect.html")
      page.set_paths(from, to)
      page
    end

    # Creates a new RedirectPage instance from the path to the given doc
    def self.redirect_from(doc, path)
      RedirectPage.from_paths(doc.site, path, doc.url)
    end

    # Creates a new RedirectPage instance from the doc to the given path
    def self.redirect_to(doc, path)
      RedirectPage.from_paths(doc.site, doc.url, path)
    end

    # Overwrite the default read_yaml method since the file doesn't exist
    def read_yaml(_base, _name, _opts = {})
      self.content = self.output = ""
      self.data ||= DEFAULT_DATA.dup
    end

    # Helper function to set the appropriate path metadata
    #
    # from - the relative path to the redirect page
    # to   - the relative path or absolute URL to the redirect target
    def set_paths(from, to)
      unless self.class.valid_target?(to)
        raise ArgumentError, "Disallowed redirect target: #{to.inspect}"
      end

      @context ||= context
      from = ensure_leading_slash(from)
      to = %r!^https?://!.match?(to) ? to : absolute_url(to)
      data.merge!(
        "permalink" => from,
        "redirect"  => {
          "from"  => from,
          "to"    => to,
          "to_js" => js_escape(to.to_json),
        }
      )
    end

    def redirect_from
      data["redirect"]["from"] if data["redirect"]
    end

    def redirect_to
      data["redirect"]["to"] if data["redirect"]
    end

    private

    def js_escape(json)
      json.gsub(JS_ESCAPE_REGEX) { |char| format("\\u%04x", char.ord) }
    end

    def context
      JekyllRedirectFrom::Context.new(site)
    end
  end
end
