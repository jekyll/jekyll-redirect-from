require "jekyll"
require File.expand_path("lib/jekyll-redirect-from.rb")

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) do
    Jekyll.logger.log_level = :error

    @fixtures_path = Pathname.new(__FILE__).parent.join("fixtures")
    @dest = @fixtures_path.join("_site")
    @posts_src = File.join(@fixtures_path, "_posts")
    @layouts_src = File.join(@fixtures_path, "_layouts")
    @plugins_src = File.join(@fixtures_path, "_plugins")

    @site = Jekyll::Site.new(Jekyll.configuration({
      "source"      => @fixtures_path.to_s,
      "destination" => @dest.to_s,
      "plugins"     => @plugins_src
    }))

    @dest.rmtree if @dest.exist?
    @site.process
  end

  config.after(:all) do
    @dest.rmtree if @dest.exist?
  end

  def setup_post(file)
    Jekyll::Post.new(@site, @fixtures_path, '', file)
  end

  def setup_page(file)
    Jekyll::Page.new(@site, @fixtures_path, File.dirname(file), File.basename(file))
  end

  def destination_file_exists?(file)
    File.exists?(File.join(@dest.to_s, file))
  end

  def destination_file_contents(file)
    File.read(File.join(@dest.to_s, file))
  end

  def new_redirect_page(permalink)
    page = JekyllRedirectFrom::RedirectPage.new(@site, @site.source, "", "")
    page.data['permalink'] = permalink
    page
  end
end
