# JekyllRedirectFrom

Give your Jekyll posts and pages multiple URLs.

When importing your posts and pages from, say, Tumblr, it's annoying and
impractical to create new pages in the proper subdirectories so they, e.g.
`/post/123456789/my-slug-that-is-often-incompl`, redirect to the new post URL.

Instead of dealing with maintaining those pages for redirection, let
`jekyll-redirect-from` handle it for you.

[![Build Status](https://travis-ci.org/jekyll/jekyll-redirect-from.svg?branch=master)](https://travis-ci.org/jekyll/jekyll-redirect-from)

## Installation

Add this line to your application's Gemfile:

    gem 'jekyll-redirect-from'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-redirect-from

Once it's installed into your evironment, add it to your `_config.yml`:

```yaml
gems:
  - jekyll-redirect-from
```

## Usage

The object of this gem is to allow an author to specify multiple URLs for a
page, such that the alternative URLs redirect to the new Jekyll URL. This is

To use it, simply add the array to the YAML front-matter of your page or post:

```yaml
title: My amazing post
redirect_from:
  - /post/123456789/
  - /post/123456789/my-amazing-post/
```

Redirects including a trailing slash will generate a corresponding subdirectory containing an `index.html`, while redirects without a trailing slash will generate a corresponding `filename` without an extension, and without a subdirectory.

For example...

```text
redirect_from:
  - /post/123456789/my-amazing-post
```

...will generate the following page in the destination:

```text
/post/123456789/my-amazing-post
```

While...

```text
redirect_from:
  - /post/123456789/my-amazing-post/
```

...will generate the following page in the destination:

```text
/post/123456789/my-amazing-post/index.html
```

These pages will contain an HTTP-REFRESH meta tag which redirect to your URL.

You can also specify just **one url** like this:

```text
title: My other awesome post
redirect_from: /post/123456798/
```

### Prefix
If `site.baseurl` is set, its value is used as a prefix for the redirect url automatically.
This is useful for scenarios where a site isn't available from the domain root, so the redirects point to the correct path.

**_Note_**: If you are hosting your Jekyll site on [GitHub Pages](https://pages.github.com/), the prefix is set to the pages domain name i.e. `http://example.github.io/project` or a custom `CNAME`.

### Redirect To

Sometimes, you may want to redirect a site page to a totally different website. This plugin also supports that with the `redirect_to` key:

```yaml
title: My amazing post
redirect_to:
  - www.github.com
```

If you have multiple `redirect_to`s set, only the first one will be respected.

**Note**: if using `redirect_to` with collections, your collection's extension **must** end in *.html* in order for `redirect_to` to properly process.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
