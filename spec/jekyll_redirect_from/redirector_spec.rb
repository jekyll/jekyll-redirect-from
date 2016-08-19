require "spec_helper"

describe JekyllRedirectFrom::Redirector do
  let(:redirector)                  { described_class.new }
  let(:post_to_redirect)            { setup_post("2014-01-03-redirect-me-plz.md") }
  let(:doc_to_redirect_from)        { setup_doc("redirect-me-plz.md") }
  let(:doc_to_redirect_to)          { setup_doc("redirect-somewhere-else-plz.html") }
  let(:doc_to_redirect_to_permalnk) { setup_doc("redirect-somewhere-else-im-a-permalink.html") }
  let(:page_with_one)               { setup_page("one_redirect_url.md") }
  let(:page_with_many)              { setup_page("multiple_redirect_urls.md") }
  let(:page_with_one_redirect_to)   { setup_page("one_redirect_to.md") }
  let(:page_with_many_redirect_to)  { setup_page("multiple_redirect_tos.md") }
  let(:page_to_redirect_to_permlnk) { setup_page("tags/how we work.md") }

  it "knows if a page or post is requesting a redirect page" do
    if JekyllRedirectFrom.jekyll_3?
      skip "Don't need to test posts in Jekyll 3"
    else
      expect(redirector.has_alt_urls?(post_to_redirect)).to be_truthy
    end
  end

  it "knows if a document is requesting a redirect page" do
    expect(redirector.has_alt_urls?(doc_to_redirect_from)).to be_truthy
  end

  it "knows if a document is requesting a redirect away" do
    expect(redirector.redirect_to_url(doc_to_redirect_to)).to eql(["http://www.zombo.com"])
  end

  it "knows if a document is requesting a redirect away" do
    expect(redirector.redirect_to_url(doc_to_redirect_to_permalnk)).to eql(["/tags/our-projects/"])
  end

  it "handles one redirect path" do
    expect(redirector.alt_urls(page_with_one)).to eql(["mencius/was/my/father"])
  end

  it "handles many redirect paths" do
    expect(redirector.alt_urls(page_with_many)).to eql(["help", "contact", "let-there/be/light-he-said", "/geepers/mccreepin"])
  end

  it "handles a single redirect_to url" do
    expect(redirector.redirect_to_url(page_with_one_redirect_to)).to eql(["https://www.github.com"])
  end

  it "handles a many redirect_to urls" do
    expect(redirector.redirect_to_url(page_with_many_redirect_to)).to eql(["https://www.jekyllrb.com"])
  end

  it "does not include pages with a redirect in sitemap" do
    expect(destination_sitemap).not_to include(%|one_redirect_to.html|)
  end

  context "refresh page generation" do
    before(:each) do
      described_class.new.generate(@site)
    end

    it "generates the refresh page for the post properly" do
      expect(dest_dir("posts/23128432159832/mary-had-a-little-lamb#{forced_output_ext}")).to exist
    end

    it "generates the refresh pages for the page with multiple redirect_from urls" do
      expect(dest_dir("help")).to be_truthy
      expect(dest_dir("contact")).to be_truthy
      expect(dest_dir("let-there/be/light-he-said")).to be_truthy
      expect(dest_dir("/geepers/mccreepin")).to be_truthy
    end

    it "generates the refresh page for the page with one redirect_from url" do
      expect(dest_dir("mencius/was/my/father#{forced_output_ext}")).to exist
    end

    it "generates the refresh page for the collection with one redirect_to url" do
      expect(dest_dir("articles", "redirect-somewhere-else-plz.html")).to exist
      expect(dest_dir("articles", "redirect-somewhere-else-plz.html").read).to include(%|<meta http-equiv="refresh" content="0; url=http://www.zombo.com">|)
    end

    it "generates the refresh page for the collection with one redirect_to url and a permalink" do
      expect(dest_dir("tags", "our projects", "index")).not_to exist
      expect(dest_dir("tags", "our projects", "index.html")).to exist
      expect(dest_dir("tags", "our projects", "index.html").read).to include(%|<meta http-equiv="refresh" content="0; url=/tags/our-projects/">|)
    end

    it "generates the refresh page for the page with one redirect_to url" do
      expect(dest_dir("one_redirect_to.html")).to exist
      expect(dest_dir("one_redirect_to.html").read).to include(%|<meta http-equiv="refresh" content="0; url=https://www.github.com">|)
    end

    it "generates the refresh page for the page with multiple redirect_to urls" do
      expect(dest_dir("multiple_redirect_tos.html")).to exist
      expect(dest_dir("multiple_redirect_tos.html").read).to include(%|<meta http-equiv="refresh" content="0; url=https://www.jekyllrb.com">|)
    end

    it "does not include any default layout" do
      expect(dest_dir("multiple_redirect_tos.html")).to exist
      expect(dest_dir("multiple_redirect_tos.html").read).not_to include('LAYOUT INCLUDED')
    end

    it "generates the refresh page for the page with one redirect_to url and a permalink" do
      expect(dest_dir("tags", "how we work", "index")).not_to exist
      expect(dest_dir("tags", "how we work", "index.html")).to exist
      expect(dest_dir("tags", "how we work", "index.html").read).to include(%|<meta http-equiv="refresh" content="0; url=/tags/how-we-work/">|)
    end
  end

  context "prefix" do
    it "uses site.url as the redirect prefix" do
      expect(redirector.redirect_url(@site, page_with_one)).to eql("http://jekyllrb.com/one_redirect_url.html")
    end

    it "uses site.github.url as the redirect prefix when site.url is not set" do
      @site.config['url'] = nil
      @site.config['github'] = { "url" => "http://example.github.io/test" }
      expect(redirector.redirect_url(@site, page_with_one)).to eql("http://example.github.io/test/one_redirect_url.html")
    end

    it "uses site.baseurl as the redirect prefix when both site.url and site.github.url is not set" do
      @site.config['url'] = nil
      @site.config['baseurl'] = "/fancy/prefix"
      expect(redirector.redirect_url(@site, page_with_one)).to eql("/fancy/prefix/one_redirect_url.html")
    end

    it "uses site.url + site.baseurl as the redirect prefix when site.github.url is not set" do
      @site.config['url'] = "http://notgithub.io"
      @site.config['baseurl'] = "/fancy/prefix"
      expect(redirector.redirect_url(@site, page_with_one)).to eql("http://notgithub.io/fancy/prefix/one_redirect_url.html")
    end

    it "prefers site.url + site.baseurl over site.github.url" do
      @site.config['url'] = "http://notgithub.io"
      @site.config['baseurl'] = "/fancy/prefix"
      @site.config['github'] = { "url" => "http://example.github.io/test" }
      expect(redirector.redirect_url(@site, page_with_one)).to eql("http://notgithub.io/fancy/prefix/one_redirect_url.html")
    end

    it "prefers site.github.url over site.baseurl when site.url is not set" do
      @site.config['url'] = nil
      @site.config['github'] = { "url" => "http://example.github.io/test" }
      @site.config['baseurl'] = "/fancy/baseurl"
      expect(redirector.redirect_url(@site, page_with_one)).to eql("http://example.github.io/test/one_redirect_url.html")
    end

    it "converts non-string values in site.github.url to strings" do
      @site.config['url'] = nil
      @site.config['github'] = { "url" => TestStringContainer.new("http://example.github.io/test") }
      expect(redirector.redirect_url(@site, page_with_one)).to eql("http://example.github.io/test/one_redirect_url.html")
    end

    it "uses site.url when site.github is set but site.github.url is not" do
      @site.config['github'] = "username"
      expect(redirector.redirect_url(@site, page_with_one)).to eql("http://jekyllrb.com/one_redirect_url.html")
    end

    it "no-ops when site.github.url and site.baseurl and site.url are not set" do
      @site.config['url'] = nil
      expect(redirector.redirect_url(@site, page_with_one)).to eql("/one_redirect_url.html")
    end

    it "should handle site.baseurl being nil" do
      @site.config['baseurl'] = nil
      expect(redirector.redirect_url(@site, page_with_one)).to eql("http://jekyllrb.com/one_redirect_url.html")
    end

    it "no-ops when site.url is empty" do
      @site.config['url'] = ""
      expect(redirector.redirect_url(@site, page_with_one)).to eql("/one_redirect_url.html")
    end
  end
end
