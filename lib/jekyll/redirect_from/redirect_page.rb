module Jekyll
  class RedirectFrom < Generator
    class RedirectPage < Page
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
      end

      def generate_redirect_content(item_url)
        self.content = <<-EOF
        <!DOCTYPE html>
        <html>
        <head>
        <title>Redirecting...</title>
        <link rel="canonical" href="#{item_url}"/>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <meta http-equiv="refresh" content="0; url=#{item_url}" />
        </head>
        <body>
          <p><strong>Redirecting...</strong></p>
          <p><a href='#{item_url}'>Click here if you are not redirected.</a></p>
          <script>
            document.location.href = "#{item_url}";
          </script>
        </body>
        </html>
        EOF
      end
    end
  end
end
