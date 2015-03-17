## HEAD

  * Remove spaces in redirect page (#62)
  * Only parse through documents/pages/posts (#56)
  * Simplified `has_alt_urls?` and `has_redirect_to_url?` conditions (#52)
  * Add support for Jekyll 3. (#59)

## 0.6.2 / 2014-09-12

  * Fixed error where `redirect_to` `Document`s were not being output properly (#46)

## 0.6.1 / 2014-09-08

  * Fixed error when the `site.github` config key is not a `Hash` (#43)

## 0.6.0 / 2014-08-22

  * Support redirecting to/from collection documents (#40)

## 0.5.0 / 2014-08-10

### Minor Enhancements

  * Support `redirect_to` property (#32)
  * Automatically prefix redirects with the `baseurl` or GitHub URL. (#26)

### Bug Fixes

  * Remove unnecessary `Array#flatten` (#34)

### Development Fixes

  * Use `be_truthy` instead of `be_true`. (#33)

## 0.4.0 / 2014-05-06

### Major Enhancements

  * Upgrade to Jekyll 2.0 (#27)

### Minor Enhancements

  * Shorten resulting HTML to make redirects quicker (#20)

### Development Fixes

  * Use SVG Travis badge in README (#21)

## 0.3.1 / 2014-01-22

### Bug Fixes

  * Add `safe true` to the `Jekyll::Generator` so it can be run in safe mode (#12)

## 0.3.0 / 2014-01-15

### Major Enhancements

  * `redirect_from` items are now proper permalinks rooted in site source (#8)

### Development Fixes

  * Add forgotten `s` to `gems` in README.md (#7)

## 0.2.0 / 2014-01-04

### Minor Enhancements

  * Allow user to set one or many `redirect_from` URLs
  * Rename from `jekyll-alt-urls` to `jekyll-redirect-from` (props to @benbalter)
  * Namespace now its own module: `JekyllRedirectFrom` (#3)

### Development Fixes

  * Add history file
  * Add specs (#3)
  * Add TravisCI badge (#4)

## 0.1.0 / 2013-12-15

* Birthday!
