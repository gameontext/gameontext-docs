# Game On! blog

[![Build Status](https://travis-ci.org/gameontext/gameontext.github.io.svg?branch=master)](https://travis-ci.org/gameontext/gameontext.github.io)

Customized github minimal theme. Built using Docker to avoid the annoyance of maintaining a local ruby development environment (with apologies to lovers of Ruby).

**Remember: [Posts are jekyll/liquid templates, that also happen to use markdown formatting](https://raw.githubusercontent.com/gameontext/gameontext.github.io/master/_drafts/example.md)**

## Running jekyll

```
docker-compose pull
docker-compose up
```

This will perform any updates to the gemfile and start jekyll listening on port 4000.

The `--drafts` option is included, so you will see any draft posts.

To validate your posts, use  
```
docker-compose run --rm site jekyll build
docker-compose run --rm site htmlproofer --assume-extension ./_site
```

## Updating dependencies

```
docker-compose run site depends update
```

## Including media (tweets / videos) at the end of posts

Define the following in the page's front matter: 
```
media: 
- type: ...
  content: '...'
- type: image
  content: '<img tag with no width or height />'
- type: video
  content: 'paste youtube embed string'
- type: tweet
  content: 'paste twitter embed string'
```

If you have several tweets in the same post, remove the script element from each tweet, and add as a separate media element
```
- type: script
  content: '<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>'
```

Then add the following at the end of your post: 
```
{% include media.html items=page.media %}
```

See [2017-10-31-lagom-gets-in-the-game.md](https://github.com/gameontext/gameontext.github.io/blob/master/_posts/2017-10-31-lagom-gets-in-the-game.md) as an example.
