require "jekyll/redirect_from/version"
require "jekyll/redirect_from/redirect_page"

module Jekyll
  class RedirectFrom < Generator
    def generate(site)
      original_pages = site.pages.dup
      generate_alt_urls(site, site.posts)
      generate_alt_urls(site, original_pages)
    end

    def generate_alt_urls(site, list)
      list.each do |item|
        if has_alt_urls?(item)
          alt_urls(item).flatten.each do |alt_url|
            redirect_page = RedirectPage.new(site, site.source, File.dirname(alt_url), File.basename(alt_url))
            redirect_page.generate_redirect_content(item.url)
            site.pages << redirect_page
          end
        end
      end
    end

    def has_alt_urls?(page_or_post)
      page_or_post.data.has_key?('alt_urls') &&
        !alt_urls(page_or_post).nil? &&
        alt_urls(page_or_post).is_a?(Array)
    end

    def alt_urls(page_or_post)
      page_or_post.data['alt_urls']
    end
  end
end
