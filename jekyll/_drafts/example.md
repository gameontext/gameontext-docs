---
layout: post
title: Example blog post
summary: Tweet-length summary of the post
tags: [fun, profit]
author: erin
---
http://jekyllrb.com/docs/structure/

Drafts are unpublished posts.
The format of these files is without a date: title.md

## Make sure author is listed in `_data/authors.yml` !

* [Use template to link event pictures]({{ page.url }}#including-media-at-the-end-of-posts)
* Remember that posts are jekll/liquid + markdown, [syntax highlighting]({{ page.url }}#syntax-highlighting) is different
* Use only h2 - h6 ...
* Define tags in front matter: 

  tags: [array, of, tags]
  or
  tags:
  - game-on
  - microservices
  - java
  - liberty

  One or multiple tags can be added to a post.
* Text can be **bold**, _italic_, or ~~strikethrough~~.
* [Link to another page](another-page).
* There should be whitespace between paragraphs.

<!--more-->

## [](#header-2)Header 2

> This is a blockquote following a header.
>
> When something is important enough, you do it even if the odds are not in your favor.

### [](#header-3)Header 3

Some text

#### [](#header-4)Header 4

*   This is an unordered list following a header.
*   This is an unordered list following a header.
*   This is an unordered list following a header.

##### [](#header-5)Header 5

1.  This is an ordered list following a header.
2.  This is an ordered list following a header.
3.  This is an ordered list following a header.

###### [](#header-6)Header 6

| head1        | head two          | three |
|:-------------|:------------------|:------|
| ok           | good swedish fish | nice  |
| out of stock | good and plenty   | nice  |
| ok           | good `oreos`      | hmm   |
| ok           | good `zoute` drop | yumm  |

### There's a horizontal rule below this.

* * *

## Lists 

### Here is an unordered list:

*   Item foo
*   Item bar
*   Item baz
*   Item zip

### And an ordered list:

1.  Item one
1.  Item two
1.  Item three
1.  Item four

### And a nested list:

- level 1 item
  - level 2 item
  - level 2 item
    - level 3 item
    - level 3 item
- level 1 item
  - level 2 item
  - level 2 item
  - level 2 item
- level 1 item
  - level 2 item
  - level 2 item
- level 1 item

### Definition lists can be used with HTML syntax.

<dl>
<dt>Name</dt>
<dd>Godzilla</dd>
<dt>Born</dt>
<dd>1952</dd>
<dt>Birthplace</dt>
<dd>Japan</dd>
<dt>Color</dt>
<dd>Green</dd>
</dl>

## Images 

### Small image

![](https://assets-cdn.github.com/images/icons/emoji/octocat.png)

### Large image

![](https://guides.github.com/activities/hello-world/branching.png)

### Including media at the end of posts

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

## Syntax highlighting
{% highlight javascript linenos %}{% raw %}
// Javascript code with syntax highlighting.
var fun = function lang(l) {
  dateformat.i18n = require('./lang/' + l)
  return true;
}
{% endraw %}{% endhighlight %}


{% highlight ruby linenos %}
# Ruby code with syntax highlighting with line numbers
GitHubPages::Dependencies.gems.each do |gem, version|
  s.add_dependency(gem, "= #{version}")
end
{% endhighlight %}

```
Long, single-line code blocks should not wrap. They should horizontally scroll if they are too long. This line should be long enough to demonstrate this.
```

```
The final element.
```
