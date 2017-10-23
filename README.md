# Game On! blog

[![Build Status](https://travis-ci.org/gameontext/gameontext.github.io.svg?branch=master)](https://travis-ci.org/gameontext/gameontext.github.io)

Customized github minimal theme. Built using Docker to avoid the annoyance of maintaining a local ruby development environment (with apologies to lovers of Ruby).

## Running jekyll

```
docker-compose up
```

This will perform any updates to the gemfile and start jekyll listening on port 4000.

The `--drafts` option is included, so you will see any draft posts.

## Updating dependencies

```
docker-compose run site depends update
```
