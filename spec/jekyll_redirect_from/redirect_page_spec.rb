# Encoding: utf-8

require "spec_helper"

describe JekyllRedirectFrom::RedirectPage do
  let(:permalink)     { "/posts/12435151125/larry-had-a-little-lamb" }
  let(:redirect_page) { new_redirect_page(permalink) }
  let(:item_url)      { File.join(@site.config["url"], "2014", "01", "03", "moving-to-jekyll.md") }
  let(:page_content)  { redirect_page.generate_redirect_content(item_url) }

  context "#generate_redirect_content" do
    it "sets the #content to the generated refresh page" do
      expect(page_content).to eq("<!DOCTYPE html>\n<html lang=\"en-US\">\n<meta charset=\"utf-8\">\n<title>Redirecting…</title>\n<link rel=\"canonical\" href=\"#{item_url}\">\n<meta http-equiv=\"refresh\" content=\"0; url=#{item_url}\">\n<h1>Redirecting…</h1>\n<a href=\"#{item_url}\">Click here if you are not redirected.</a>\n<script>location=\"#{item_url}\"</script>\n</html>\n")
    end

    it "contains the meta refresh tag" do
      expect(page_content).to include("<meta http-equiv=\"refresh\" content=\"0; url=#{item_url}\">")
    end

    it "contains JavaScript redirect" do
      expect(page_content).to include("location=\"http://jekyllrb.com/2014/01/03/moving-to-jekyll.md\"")
    end

    it "contains canonical link in header" do
      expect(page_content).to include("<link rel=\"canonical\" href=\"http://jekyllrb.com/2014/01/03/moving-to-jekyll.md\">")
    end

    it "contains a clickable link to redirect" do
      expect(page_content).to include("<a href=\"http://jekyllrb.com/2014/01/03/moving-to-jekyll.md\">Click here if you are not redirected.</a>")
    end
  end

  context "when determining the write destination" do
    context "of a redirect page meant to be a dir" do
      let(:permalink_dir) { "/posts/1914798137981389/larry-had-a-little-lamb/" }
      let(:redirect_page) { new_redirect_page(permalink_dir) }

      it "knows to add the index.html if it's a folder" do
        expected = dest_dir("posts", "1914798137981389", "larry-had-a-little-lamb", "index.html").to_s
        dest = redirect_page.destination("/")
        dest = "#{@site.dest}#{dest}" unless dest.start_with? @site.dest
        expect(dest).to eql(expected)
      end
    end

    context "of a redirect page meant to be a file" do
      it "knows not to add the index.html if it's not a folder" do
        expected = dest_dir("posts", "12435151125", "larry-had-a-little-lamb#{forced_output_ext}").to_s
        dest = redirect_page.destination("/")
        dest = "#{@site.dest}#{dest}" unless dest.start_with? @site.dest
        expect(dest).to eql(expected)
      end
    end
  end

  context "when writing to disk" do
    let(:redirect_page_full_path) { redirect_page.destination(@site.dest) }

    before(:each) do
      redirect_page.generate_redirect_content(item_url)
      redirect_page.write(@site.dest)
    end

    it "fetches the path properly" do
      expect(redirect_page_full_path).to match /\/spec\/fixtures\/\_site\/posts\/12435151125\/larry-had-a-little-lamb#{forced_output_ext}$/
    end

    it "is written to the proper location" do
      expect(File.exist?(redirect_page_full_path)).to be_truthy
    end

    it "writes the context we expect" do
      expect(File.read(redirect_page_full_path)).to eql(page_content)
    end
  end
end
