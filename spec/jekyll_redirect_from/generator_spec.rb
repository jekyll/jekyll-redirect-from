# frozen_string_literal: true

RSpec.describe JekyllRedirectFrom::Generator do
  before(:each) do
    site.read
    site.generate
    site.render
    site.write
  end

  context "layouts" do
    context "a site with a redirect layout" do
      before { site.layouts["redirect"] = "foo" }

      it "doesn't inject the layout" do
        expect(site.layouts["redirect"]).to eql("foo")
      end
    end

    context "a site without a redirect layout" do
      it "injects the layout" do
        expect(site.layouts["redirect"]).to be_a(JekyllRedirectFrom::Layout)
      end
    end
  end

  context "redirect froms" do
    context "pages" do
      context "a page with a single redirect" do
        let(:page) { site.pages.find { |p| p.url == "/some/other/path" } }

        it "creates the redirect" do
          expect(page).to_not be_nil
          expect(page.output).to match("http://jekyllrb.com/one_redirect_from.html")
        end
      end

      context "a page with multiple redirects" do
        let(:redirects) do
          ["/help", "/contact", "/let-there/be/light-he-said", "/geepers/mccreepin"]
        end

        it "creates all the redirects" do
          redirects.each do |url|
            page = site.pages.find { |p| p.url == url }
            expect(page).to_not be_nil
            expect(page.output).to match("http://jekyllrb.com/multiple_redirect_froms.html")
          end
        end
      end
    end

    context "documents" do
      let(:page) { site.pages.find { |p| p.url == "/articles/23128432159832/mary-had-a-little-lamb" } }

      it "redirects" do
        expect(page).to_not be_nil
        expect(page.output).to match("http://jekyllrb.com/articles/redirect-me-plz.html")
      end
    end
  end

  context "redirect tos" do
    context "pages" do
      context "a single redirect to" do
        let(:page) { site.pages.find { |p| p.url == "/one_redirect_to_url.html" } }

        it "redirects" do
          expect(page.output).to match("https://www.github.com")
        end
      end

      context "multiple redirect tos" do
        let(:page) { site.pages.find { |p| p.url == "/multiple_redirect_tos.html" } }

        it "redirects to the first entry" do
          expect(page.output).to match("https://www.jekyllrb.com")
        end
      end
    end

    context "documents" do
      let(:doc) { site.documents.find { |p| p.url == "/articles/redirect-somewhere-else-plz.html" } }

      it "redirects" do
        expect(doc.output).to match("http://www.zombo.com")
      end
    end
  end

  context "redirects.json" do
    let(:path) { dest_dir("redirects.json") }
    let(:contents) { File.read(path) }
    let(:redirects) { JSON.parse(contents) }
    let(:domain) { "http://jekyllrb.com" }

    it "creates the redirects file" do
      expect(path).to exist
    end

    it "contains redirects" do
      expect(redirects.count).to eql(13)
    end

    it "contains single redirects tos" do
      expect(redirects.keys).to include "/one_redirect_to_path.html"
      expect(redirects["/one_redirect_to_path.html"]).to eql("#{domain}/foo")
    end

    it "contains multiple redirect tos" do
      expect(redirects.keys).to include "/multiple_redirect_tos.html"
      expect(redirects["/multiple_redirect_tos.html"]).to eql("https://www.jekyllrb.com")
    end

    it "contains single redirect froms" do
      expect(redirects.keys).to include "/some/other/path"
      expect(redirects["/some/other/path"]).to eql("#{domain}/one_redirect_from.html")
    end

    it "contains multiple redirect froms" do
      expect(redirects.keys).to include "/help"
      expect(redirects["/help"]).to eql("#{domain}/multiple_redirect_froms.html")

      expect(redirects.keys).to include "/contact"
      expect(redirects["/contact"]).to eql("#{domain}/multiple_redirect_froms.html")
    end

    context "with a user-supplied redirects.json" do
      let(:source_path) { File.join fixtures_path, "redirects.json" }
      before do
        File.write source_path, { "foo" => "bar" }.to_json
        site.reset
        site.read
        site.generate
        site.render
        site.write
      end

      after do
        FileUtils.rm_f source_path
      end

      it "doesn't overwrite redirects.json" do
        expect(path).to exist
        expect(redirects).to eql("foo" => "bar")
      end
    end

    context "when explicitly disabled" do
      let(:site) { Jekyll::Site.new(config.merge("redirect_from" => { "json" => false })) }

      it "does not create the redirects file" do
        expect(path).to_not exist
      end
    end
  end

  context "_redirects" do
    let(:path) { dest_dir("_redirects") }
    let(:contents) { File.read(path) }
    let(:lines) { contents.split("\n") }
    let(:domain) { "http://jekyllrb.com" }

    it "creates the _redirects file" do
      expect(path).to exist
    end

    it "contains a line per redirect" do
      expect(lines.count).to eql(13)
    end

    it "formats each line with an explicit 301 status code" do
      lines.each do |line|
        expect(line).to end_with(" 301")
      end
    end

    it "contains single redirect tos" do
      expect(lines).to include "/one_redirect_to_path.html #{domain}/foo 301"
    end

    it "contains multiple redirect tos" do
      expect(lines).to include "/multiple_redirect_tos.html https://www.jekyllrb.com 301"
    end

    it "contains single redirect froms" do
      expect(lines).to include "/some/other/path #{domain}/one_redirect_from.html 301"
    end

    it "contains multiple redirect froms" do
      expect(lines).to include "/help #{domain}/multiple_redirect_froms.html 301"
      expect(lines).to include "/contact #{domain}/multiple_redirect_froms.html 301"
    end

    it "percent-encodes whitespace in the source path" do
      expect(lines).to include "/tags/our%20projects/ #{domain}/tags/our-projects/ 301"
    end

    context "with a user-supplied _redirects" do
      let(:source_path) { File.join fixtures_path, "_redirects" }
      before do
        File.write source_path, "/foo /bar 301"
        # Jekyll caches static-file mtimes globally; reset so the freshly
        # written source is copied rather than skipped as "unmodified".
        Jekyll::StaticFile.reset_cache
        site.reset
        site.read
        site.generate
        site.render
        site.write
      end

      after do
        FileUtils.rm_f source_path
      end

      it "doesn't overwrite _redirects" do
        expect(path).to exist
        expect(contents).to eql("/foo /bar 301")
      end

      it "automatically includes the underscore-prefixed file in the output" do
        expect(site.config["include"]).to include("_redirects")
      end
    end

    context "when explicitly disabled" do
      let(:site) { Jekyll::Site.new(config.merge("redirect_from" => { "cloudflare" => false })) }

      it "does not create the _redirects file" do
        expect(path).to_not exist
      end
    end
  end

  context "redirectable_document?" do
    let(:generator) { JekyllRedirectFrom::Generator.new }

    it "accepts subclasses of Jekyll::Document" do
      SubclassOfJekyllDocument = Class.new(Jekyll::Document) { define_method(:initialize) {} }
      expect(generator.send(:redirectable_document?, SubclassOfJekyllDocument.new)).to be_truthy
    end

    it "accepts subclasses of Jekyll::Page" do
      SubclassOfJekyllPage = Class.new(Jekyll::Page) { define_method(:initialize) {} }
      expect(generator.send(:redirectable_document?, SubclassOfJekyllPage.new)).to be_truthy
    end
  end
end
