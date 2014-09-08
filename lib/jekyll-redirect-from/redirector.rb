module JekyllRedirectFrom
  class Redirector < Jekyll::Generator
    safe true

    def generate(site)
      original_pages = site.pages.dup
      generate_alt_urls(site, site.posts)
      generate_alt_urls(site, original_pages)
      generate_alt_urls(site, site.docs_to_write)
    end

    def generate_alt_urls(site, list)
      list.each do |item|
        if has_alt_urls?(item)
          alt_urls(item).each do |alt_url|
            redirect_page = RedirectPage.new(site, site.source, "", "")
            redirect_page.data['permalink'] = alt_url
            redirect_page.generate_redirect_content(redirect_url(site, item))
            site.pages << redirect_page
          end
        end
        if has_redirect_to_url?(item)
          redirect_to_url(item).flatten.each do |alt_url|
            redirect_page = RedirectPage.new(site, site.source, File.dirname(item.url), File.basename(item.url))
            redirect_page.data['permalink'] = item.url
            redirect_page.generate_redirect_content(alt_url)
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

    def has_redirect_to_url?(page_or_post)
      page_or_post.data.has_key?('redirect_to') &&
        !alt_urls(page_or_post).nil? &&
        !alt_urls(page_or_post).empty?
    end

    def redirect_to_url(page_or_post)
      [Array[page_or_post.data['redirect_to']].flatten.first]
    end

    def redirect_url(site, item)
      File.join redirect_prefix(site), item.url
    end

    def redirect_prefix(site)
      config_github_url(site) || config_baseurl(site) || ""
    end

    def config_github_url(site)
      github_config = site.config['github']
      github_config['url'] if github_config.is_a?(Hash)
    end

    def config_baseurl(site)
      site.config.fetch('baseurl', nil)
    end
  end
end
