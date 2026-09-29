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
      let(:encoded) { "https://example.com/%22;alert(document.domain)//" }

      it "percent-encodes the quote in the target" do
        expect(page.redirect_to).to eql(encoded)
      end

      it "keeps the URL inside the JavaScript string" do
        expect(output).to include("<script>location=\"#{encoded}\"</script>")
      end

      it "keeps the URL inside attributes" do
        expect(output).to include("<link rel=\"canonical\" href=\"#{encoded}\">")
        expect(output).to include("<meta http-equiv=\"refresh\" content=\"0; url=#{encoded}\">")
        expect(output).to include("<a href=\"#{encoded}\">Click here if you are not redirected.</a>")
      end
    end

    context "with a closing script tag" do
      let(:to) { 'https://evil.example/"</script><script>alert("rt")</script><a x="' }

      it "percent-encodes the markup characters in the target" do
        expect(page.redirect_to).to eql(
          "https://evil.example/%22%3C/script%3E%3Cscript%3Ealert(%22rt%22)%3C/script%3E%3Ca%20x=%22"
        )
      end

      it "does not emit additional script tags" do
        expect(script_tags(output)).to eql(1)
        expect(output).to_not include("</script><script>")
        expect(output).to_not include("<a x=")
      end
    end

    context "with other unsafe characters" do
      let(:to) { "https://example.com/a b'c`d\\e\tf\u007Fg\u0001h" }

      it "percent-encodes them" do
        expect(page.redirect_to).to eql("https://example.com/a%20b%27c%60d%5Ce%09f%7Fg%01h")
      end
    end

    context "that is already percent-encoded" do
      let(:to) { "https://example.com/a%20b%22c?q=%3C&r=1#frag%3E" }

      it "is not encoded again" do
        expect(page.redirect_to).to eql(to)
        expect(output).to include("<a href=\"https://example.com/a%20b%22c?q=%3C&amp;r=1#frag%3E\">")
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

  context "with a custom layout that outputs the target raw" do
    let(:custom_layout) do
      JekyllRedirectFrom::Layout.new(site).tap do |layout|
        layout.content = <<~HTML
          <script>location="{{ page.redirect.to }}"</script>
          <script>location='{{ page.redirect.to }}'</script>
          <script>location=`{{ page.redirect.to }}`</script>
          <a href="{{ page.redirect.to }}">link</a>
          <a href='{{ page.redirect.to }}'>link</a>
        HTML
      end
    end

    before { site.layouts["redirect"] = custom_layout }

    subject(:page) { JekyllRedirectFrom::RedirectPage.redirect_to(doc, to) }
    let(:output) { render(page) }

    [
      'https://example.com/";alert(1)//',
      "https://example.com/';alert(1)//",
      "https://example.com/`;alert(1)//",
      "https://example.com/${alert(1)}",
      "https://example.com/</script><script>alert(1)</script>",
      'https://example.com/" onmouseover="alert(1)',
      "https://example.com/\\\";alert(1)//",
      "https://example.com/\n</script><script>alert(1)</script>",
    ].each do |target|
      context target.inspect do
        let(:to) { target }

        it "cannot break out of the script or attribute" do
          expect(script_tags(output)).to eql(3)
          expect(output).to_not match(%r!</script><script>!i)
          expect(output).to_not match(%r!\sonmouseover=!i)
          expect(output).to_not include("${")
          url = %r!https://example\.com/[^"'`<>{}\\\s]*!
          expect(output).to include("<script>location=\"#{page.redirect_to}\"</script>")
          expect(output).to include("<script>location='#{page.redirect_to}'</script>")
          expect(output).to include("<script>location=`#{page.redirect_to}`</script>")
          expect(output).to include("<a href=\"#{page.redirect_to}\">link</a>")
          expect(output).to include("<a href='#{page.redirect_to}'>link</a>")
          expect(page.redirect_to).to match(%r!\A#{url}\z!)
        end
      end
    end
  end

  context "a normal target" do
    [
      "https://example.com/path/to/page.html?a=1&b=two%20words&c[]=3#section-2",
      "http://example.com:8080/~user/a+b;c=d,e!f*g(h)@i$j?k=l/m?n#o/p?q",
      "https://example.com/caf%C3%A9?q=%E2%9C%93#%F0%9F%98%80",
      "https://example.com/unicode/café",
    ].each do |target|
      it "leaves #{target.inspect} unchanged" do
        expect(JekyllRedirectFrom::RedirectPage.redirect_to(doc, target).redirect_to).to eql(target)
      end
    end

    it "leaves relative paths with query strings and fragments unchanged" do
      page = JekyllRedirectFrom::RedirectPage.redirect_to(doc, "/bar/baz.html?a=1&b=2#frag")
      expect(page.redirect_to).to eql("http://jekyllrb.com/bar/baz.html?a=1&b=2#frag")
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
