require "jekyll"
require File.expand_path("lib/jekyll-redirect-from.rb")

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = "random"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    Jekyll.logger.log_level = :error

    @fixtures_path = Pathname.new(__FILE__).parent.join("fixtures")
    @dest        = @fixtures_path.join("_site")
    @posts_src   = @fixtures_path.join("_posts")
    @layouts_src = @fixtures_path.join("_layouts")
    @plugins_src = @fixtures_path.join("_plugins")

    @site = Jekyll::Site.new(Jekyll.configuration({
      "source"      => @fixtures_path.to_s,
      "destination" => @dest.to_s,
      "plugins"     => @plugins_src.to_s,
      "collections" => {
        "articles" => { "output" => true },
        "authors"  => {}
      },
      "defaults"    => [{
        "scope"  => { "path" => "" },
        "values" => { "layout" => "layout" }
      }]
    }))

    @dest.rmtree if @dest.exist?
    @site.process
  end

  config.after(:each) do
    @dest.rmtree if @dest.exist?
  end

  def dest_dir(*paths)
    @dest.join(*paths)
  end

  def unpublished_doc
    @site.collections["authors"].docs.first
  end

  def setup_doc(doc_filename)
    @site.collections["articles"].docs.find { |d| d.relative_path.match(doc_filename) }
  end

  def setup_post(file)
    Jekyll::Post.new(@site, @fixtures_path.to_s, "", file)
  end

  def setup_page(file)
    Jekyll::Page.new(@site, @fixtures_path.to_s, File.dirname(file), File.basename(file))
  end

  def new_redirect_page(permalink)
    page = JekyllRedirectFrom::RedirectPage.new(@site, @site.source, "", "index.html")
    page.data["permalink"] = permalink
    page.data["sitemap"] = false
    page
  end

  def destination_sitemap
    @dest.join("sitemap.xml").read
  end

  def forced_output_ext
    JekyllRedirectFrom.jekyll_3? ? ".html" : ""
  end
end

class TestStringContainer
  def initialize(str_value)
    @val = str_value
  end

  def to_s
    @val
  end
end
