# frozen_string_literal: true

RSpec.describe "redirect target handling" do
  let(:doc) { site.documents.first }

  def render(page)
    site.generate
    Jekyll::Renderer.new(site, page, site.site_payload).run
  end

  def script_tags(output)
    output.scan(%r!<script\b!i).length
  end

  before { site.read }

  context "an absolute URL that tries to break out of the markup" do
    subject(:page) { JekyllRedirectFrom::RedirectPage.redirect_to(doc, to) }
    let(:output) { render(page) }

    context "with a double quote" do
      let(:to) { 'https://example.com/";alert(document.domain)//' }

      it "keeps the URL inside the JavaScript string" do
        expect(output).to include('<script>location="https://example.com/\";alert(document.domain)//"</script>')
      end

      it "escapes the URL in attributes" do
        escaped = "https://example.com/&quot;;alert(document.domain)//"
        expect(output).to include("<link rel=\"canonical\" href=\"#{escaped}\">")
        expect(output).to include("<meta http-equiv=\"refresh\" content=\"0; url=#{escaped}\">")
        expect(output).to include("<a href=\"#{escaped}\">Click here if you are not redirected.</a>")
      end
    end

    context "with a closing script tag" do
      let(:to) { 'https://evil.example/"</script><script>alert("rt")</script><a x="' }

      it "does not emit additional script tags" do
        expect(script_tags(output)).to eql(1)
        expect(output).to_not include("</script><script>")
        expect(output).to_not include("<a x=")
      end

      it "escapes markup characters in the JavaScript string" do
        expect(output).to include('location="https://evil.example/\"\u003c/script\u003e')
      end
    end

    context "with an ampersand" do
      let(:to) { "https://example.com/?a=1&b=2" }

      it "escapes the ampersand for each context" do
        expect(output).to include('<script>location="https://example.com/?a=1\u0026b=2"</script>')
        expect(output).to include('<a href="https://example.com/?a=1&amp;b=2">')
      end
    end
  end

  context "a target with a disallowed scheme" do
    [
      "javascript:alert(document.domain)",
      "JaVaScRiPt:alert(document.domain)",
      " \tjavascript:alert(document.domain)",
      "\u0001javascript:alert(document.domain)",
      "java\nscript:alert(document.domain)",
      "data:text/html,<script>alert(document.domain)</script>",
      "vbscript:msgbox(1)",
    ].each do |target|
      context target.inspect do
        it "is not a valid target" do
          expect(JekyllRedirectFrom::RedirectPage.valid_target?(target)).to be(false)
        end

        it "refuses to build a redirect page" do
          expect do
            JekyllRedirectFrom::RedirectPage.redirect_to(doc, target)
          end.to raise_error(ArgumentError)
        end
      end
    end
  end

  context "valid targets" do
    [
      "/bar", "bar", "/bar/", "../bar", "?q=1", "#anchor", "//example.com/bar",
      "http://example.com", "https://example.com/a?b=c#d", "HTTPS://EXAMPLE.COM",
    ].each do |target|
      it "accepts #{target.inspect}" do
        expect(JekyllRedirectFrom::RedirectPage.valid_target?(target)).to be(true)
      end
    end
  end

  context "when generating the site" do
    let(:bad_targets) do
      {
        "/bad-js.html"    => "javascript:alert(document.domain)",
        "/bad-mixed.html" => "JaVaScRiPt:alert(document.domain)",
        "/bad-space.html" => "  javascript:alert(document.domain)",
      }
    end

    let(:bad_pages) do
      bad_targets.map do |url, target|
        page = JekyllRedirectFrom::PageWithoutAFile.new(site, site.source, "", url.delete("/"))
        page.content = "Original content"
        page.data["redirect_to"] = target
        page
      end
    end

    let(:redirects) { JSON.parse(File.read(dest_dir("redirects.json"))) }

    before do
      allow(Jekyll.logger).to receive(:warn).and_call_original
      site.pages.concat(bad_pages)
      site.generate
      site.render
      site.write
    end

    it "does not turn the page into a redirect" do
      bad_pages.each do |page|
        expect(page.output).to_not match(%r!javascript!i)
        expect(page.output).to include("Original content")
        expect(page.data).to_not have_key("redirect")
      end
    end

    it "does not include the target in redirects.json" do
      bad_targets.each_key do |url|
        expect(redirects).to_not have_key(url)
      end
      expect(redirects.values.join).to_not match(%r!javascript!i)
    end

    it "logs a warning" do
      expect(Jekyll.logger).to have_received(:warn)
        .with("Redirect from:", %r!disallowed redirect_to!).exactly(bad_targets.size).times
    end

    it "still generates valid redirects" do
      expect(redirects["/one_redirect_to_url.html"]).to eql("https://www.github.com")
    end
  end
end
