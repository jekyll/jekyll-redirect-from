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
  - /post/123456789
  - /post/123456789/my-amazing-post
```

This will generate the following pages in the destination:

```text
/post/123456789
/post/123456789/my-amazing-post
```

These pages will contain an HTTP-REFRESH meta tag which redirect to your URL.

You can also specify just **one url** like this:

```text
title: My other awesome post
redirect_from: /post/123456798
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
