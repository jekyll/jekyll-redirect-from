require "spec_helper"

describe JekyllRedirectFrom::Redirector do
  let(:redirector)                  { described_class.new }
  let(:post_to_redirect)            { setup_post("2014-01-03-redirect-me-plz.md") }
  let(:page_with_one)               { setup_page("one_redirect_url.md") }
  let(:page_with_many)              { setup_page("multiple_redirect_urls.md") }
  let(:page_with_one_redirect_to)   { setup_page("one_redirect_to.md") }
  let(:page_with_many_redirect_to)  { setup_page("multiple_redirect_tos.md") }

  it "knows if a page or post is requesting a redirect page" do
    expect(redirector.has_alt_urls?(post_to_redirect)).to be_truthy
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

  context "refresh page generation" do
    before(:all) do
      described_class.new.generate(@site)
    end

    it "generates the refresh page for the post properly" do
      expect(destination_file_exists?("posts/23128432159832/mary-had-a-little-lamb")).to be_truthy
    end

    it "generates the refresh pages for the page with multiple redirect_from urls" do
      expect(destination_file_exists?("help")).to be_truthy
      expect(destination_file_exists?("contact")).to be_truthy
      expect(destination_file_exists?("let-there/be/light-he-said")).to be_truthy
      expect(destination_file_exists?("/geepers/mccreepin")).to be_truthy
    end

    it "generates the refresh page for the page with one redirect_from url" do
      expect(destination_file_exists?("mencius/was/my/father")).to be_truthy
    end

    it "generates the refresh page for the page with one redirect_to url" do
      expect(destination_file_exists?("one_redirect_to.html")).to be_truthy
      expect(destination_file_contents("one_redirect_to.html")).to include(%|<meta http-equiv=refresh content="0; url=https://www.github.com">|)
    end

    it "generates the refresh page for the page with multiple redirect_to urls" do
      expect(destination_file_exists?("multiple_redirect_tos.html")).to be_truthy
      expect(destination_file_contents("multiple_redirect_tos.html")).to include(%|<meta http-equiv=refresh content="0; url=https://www.jekyllrb.com">|)
    end
  end
end
