## HEAD

### Major Enhancements

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
