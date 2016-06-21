# Encoding: utf-8

module JekyllRedirectFrom
  class RedirectPage < Jekyll::Page
    # Initialize a new RedirectPage.
    #
    # site - The Site object.
    # base - The String path to the source.
    # dir  - The String path between the source and the file.
    # name - The String filename of the file.
    def initialize(site, base, dir, name)
      @site = site
      @base = base
      @dir  = dir
      @name = name

      self.process(name)
      self.data = { "layout" => nil }

      data.default_proc = proc do |_, key|
        site.frontmatter_defaults.find(File.join(dir, name), type, key)
      end

      Jekyll::Hooks.trigger :pages, :post_init, self if JekyllRedirectFrom.jekyll_3?
    end

    def generate_redirect_content(item_url)
      self.output = self.content = template.render!(payload(item_url), info)
    end

    private
    def payload(item_url)
      {
        'page' => { 'url' => item_url },
      }
    end

    def info
      {
        :filters   => [Jekyll::Filters]
      }
    end

    def template
      @template ||= Liquid::Template.parse(template_contents)
    end

    def template_contents
      if @site.layouts.key? 'redirect'
        @site.layouts['redirect'].content
      else
        File.read(template_path)
      end
    end

    def template_path
      @template_path ||= File.expand_path '../jekyll-redirect-from.html', File.dirname(__FILE__)
    end
  end
end
