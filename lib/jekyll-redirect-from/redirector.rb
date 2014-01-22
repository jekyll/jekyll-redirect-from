module JekyllRedirectFrom
  class Redirector < Jekyll::Generator
    safe true

    def generate(site)
      original_pages = site.pages.dup
      generate_alt_urls(site, site.posts)
      generate_alt_urls(site, original_pages)
    end

    def generate_alt_urls(site, list)
      list.each do |item|
        if has_alt_urls?(item)
          alt_urls(item).flatten.each do |alt_url|
            redirect_page = RedirectPage.new(site, site.source, "", "")
            redirect_page.data['permalink'] = alt_url
            redirect_page.generate_redirect_content(item.url)
            site.pages << redirect_page
          end
        end
      end
    end

    def has_alt_urls?(page_or_post)
      page_or_post.data.has_key?('redirect_from') &&
        !alt_urls(page_or_post).nil? &&
        !alt_urls(page_or_post).empty?
    end

    def alt_urls(page_or_post)
      Array[page_or_post.data['redirect_from']].flatten
    end
  end
end
