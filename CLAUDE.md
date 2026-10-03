# CLAUDE.md

jekyll-redirect-from is a Jekyll plugin gem that generates redirect pages from `redirect_from` and `redirect_to` front matter.

## Commands

- [`script/bootstrap`](script/bootstrap) installs dependencies.
- [`script/cibuild`](script/cibuild) runs [`script/test`](script/test) (rspec), [`script/fmt`](script/fmt) (RuboCop) and `rake build`. Run it before committing. `script/fmt -a` autocorrects style offenses.

## Changelog

[`History.markdown`](History.markdown) is updated by @jekyllbot under `## HEAD` when a PR is merged, so don't add entries by hand in a feature PR.

## Releasing

[`script/release`](script/release) runs `script/cibuild`, then `bundle exec rake release`, which tags `vX.Y.Z`, pushes the branch and the tag, and pushes the gem to RubyGems. It asks for no confirmation, so running it publishes immediately.

Releases happen only after a maintainer explicitly approves them. Agents may open a release-prep PR that bumps [`lib/jekyll-redirect-from/version.rb`](lib/jekyll-redirect-from/version.rb) and renames `## HEAD` in `History.markdown` to `## X.Y.Z / YYYY-MM-DD`, but must never run `script/release`, `rake release` or `gem push`, push a tag, or create a GitHub Release. A published gem version can't be reused, even if it's yanked.
