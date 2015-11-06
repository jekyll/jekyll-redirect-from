module JekyllRedirectFrom
  class RedirectPage < Jekyll::Page
    # Initialize a new RedirectPage.
    #
    # site - The Site object.
    # base - The String path to the source.
    # dir  - The String path between the source and the file.
    # name - The String filename of the file.
    def initialize(site, base, dir, name)
      @site = site
      @base = base
      @dir  = dir
      @name = name

      self.process(name)
      self.data = {}
    end

    def generate_redirect_content(item_url)
      self.output = self.content = <<-EOF
<!DOCTYPE html>
<meta charset="utf-8">
<title>Redirecting...</title>
<link rel="canonical" href="#{item_url}">
<meta http-equiv="refresh" content="0; url=#{item_url}">
<h1>Redirecting...</h1>
<a href="#{item_url}">Click here if you are not redirected.</a>
<script>location="#{item_url}"</script>
EOF
    end
  end
end
