# frozen_string_literal: true

shared_examples 'a redirect page' do
  context "being a page" do
    before { subject.read_yaml(nil, nil, nil) }

    it "returns no content" do
      expect(subject.content).to eql("")
    end

    it "returns no output" do
      expect(subject.output).to eql("")
    end

    it "sets default data" do
      expect(subject.to_liquid["layout"]).to eql("redirect")
      expect(subject.to_liquid["sitemap"]).to be_falsey
    end

    it "sets the paths" do
      expect(subject.to_liquid["permalink"]).to eql(from)
      expect(subject.to_liquid).to have_key("redirect")
      expect(subject.to_liquid["redirect"]["from"]).to eql(from)
      expect(subject.to_liquid["redirect"]["to"]).to eql("#{site_url}#{to}")
    end

    it "sets the permalink" do
      expect(subject.to_liquid["permalink"]).to eql(from)
    end

    it "sets redirect metadata" do
      expect(subject.to_liquid).to have_key("redirect")
      expect(subject.to_liquid["redirect"]["from"]).to eql(from)
      expect(subject.to_liquid["redirect"]["to"]).to eql("#{site_url}#{to}")
    end
  end

  context "generating" do
    before { site.generate }
    let(:output) { Jekyll::Renderer.new(site, subject, site.site_payload).run }

    it "renders the template" do
      expect(output).to_not be_nil
      expect(output.to_s).to_not be_empty
    end

    it "contains the meta refresh tag" do
      expect(output).to match("<meta http-equiv=\"refresh\" content=\"0; url=#{site_url}#{to}\">")
    end

    it "contains the javascript redirect" do
      expect(output).to match("<script>location=\"#{site_url}#{to}\"</script>")
    end

    it "contains canonical link in header" do
      expect(output).to match("<link rel=\"canonical\" href=\"#{site_url}#{to}\">")
    end

    it "contains the clickable link" do
      expect(output).to match("<a href=\"#{site_url}#{to}\">Click here if you are not redirected.</a>")
    end
  end
end

describe JekyllRedirectFrom::RedirectPage do
  let(:from) { "/foo" }
  let(:to) { "/bar" }
  let(:site_url) { site.config["url"] }
  subject { described_class.from_paths(site, from, to) }
  before { site.read }

  it_behaves_like 'a redirect page'

  describe 'redirecting to' do
    let(:doc) { site.documents.first }
    let(:page) { described_class.redirect_to(doc, to) }

    context "a relative path" do
      let(:to) { "/bar" }

      it "redirects" do
        expect(page.to_liquid["permalink"]).to eql("/2014/01/03/redirect-me-plz.html")
        expect(page.to_liquid).to have_key("redirect")
        expect(page.to_liquid["redirect"]["to"]).to eql("#{site_url}#{to}")
        expect(page.to_liquid["redirect"]["from"]).to eql("/2014/01/03/redirect-me-plz.html")
      end

      context "with no leading slash" do
        let(:to) { "bar" }

        it "redirects" do
          expect(page.to_liquid).to have_key("redirect")
          expect(page.to_liquid["redirect"]["to"]).to eql("#{site_url}/#{to}")
        end
      end

      context "with a trailing slash" do
        let(:to) { "/bar/" }

        it "redirects" do
          expect(page.to_liquid).to have_key("redirect")
          expect(page.to_liquid["redirect"]["to"]).to eql("#{site_url}#{to}")
        end
      end
    end

    context "an absolute URL" do
      let(:to) { "https://foo.invalid" }

      it "redirects" do
        expect(page.to_liquid["permalink"]).to eql("/2014/01/03/redirect-me-plz.html")
        expect(page.to_liquid).to have_key("redirect")
        expect(page.to_liquid["redirect"]["to"]).to eql("https://foo.invalid")
        expect(page.to_liquid["redirect"]["from"]).to eql("/2014/01/03/redirect-me-plz.html")
      end
    end
  end

  describe 'redirecting from' do
    let(:doc) { site.documents.first }
    let(:page) { described_class.redirect_from(doc, from) }

    it "sets liquid data for the page" do
      expect(page.to_liquid["permalink"]).to eql(from)
      expect(page.to_liquid).to have_key("redirect")
      expect(page.to_liquid["redirect"]["from"]).to eql(from)
      expected = "http://jekyllrb.com/2014/01/03/redirect-me-plz.html"
      expect(page.to_liquid["redirect"]["to"]).to eql(expected)
    end

    context "when redirect from has no extension" do
      let(:from) { "/foo" }

      it "adds .html" do
        expected = File.expand_path "foo.html", site.dest
        expect(page.destination("/")).to eql(expected)
      end
    end

    context "when redirect from is a directory" do
      let(:from) { "/foo/" }

      it "knows to add the index.html" do
        expected = File.expand_path "foo/index.html", site.dest
        expect(page.destination("/")).to eql(expected)
      end

      it "uses HTML" do
        expect(page.output_ext).to eql(".html")
      end
    end

    context "when redirect from is an HTML file" do
      let(:from) { "/foo.html" }

      it "adds .html" do
        expected = File.expand_path "foo.html", site.dest
        expect(page.destination("/")).to eql(expected)
      end
    end

    context "when redirect from is another extension" do
      let(:from) { "/foo.htm" }

      it "doesn't add .html" do
        expected = File.expand_path "foo.htm", site.dest
        expect(page.destination("/")).to eql(expected)
      end

      it "honors the extension" do
        expect(page.output_ext).to eql(".htm")
      end
    end

    context "when redirect from has no leading slash" do
      let(:from) { "foo" }

      it "adds the slash" do
        expected = File.expand_path "foo.html", site.dest
        expect(page.destination("/")).to eql(expected)
      end

      it "uses HTML" do
        expect(page.output_ext).to eql(".html")
      end
    end
  end
end
