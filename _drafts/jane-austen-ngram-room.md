---
layout: post
title: A Room for Jane Austen
summary: Exploration of ngrams and using ngram probabilities to construct sentences and paragraphs.
tags: [fun, profit, hadoop, java, scala]
author: ilan
---
## An Exploration of N-gram In Celebration Of Jane Austen
### The Conjecture
Over the last year I have been thinking, reading and learning about
`words in documents`. And what kind of information can be extracted
from `words in documents`. One interesting avenue of exploration is:
- The probabilities of two words appearing next to each other in a
particular order.
- The probability of three words appearing next to each other ...
- And so on and so forth.

Analysis of these probabilities have all sorts of interesting
implications; and, allow for fun experiments.

2017 is also a year for celebrating the novels of the great author
Jane Austen; as it has been 200 years since she passed on from this
world.

One way of participating in her celebration could be to create a Jane
Austen room, where using ngram probabilities from the words in her
novels, her corpus - one could interact with those probabilities in
various different ways using the game on protocols.

### The Tooling
- [Apache Hadoop](http://hadoop.apache.org/) is the data cruncher.
- [sample-room-scala](https://github.com/gameontext/sample-room-scala) is the base template for the room.
- [Project Gutenberg](https://www.gutenberg.org/) is the data source for the `words in documents` i.e. the novels of Jane Austen.
- [The Book On Stuff Like This](https://web.stanford.edu/~jurafsky/slp3/) is The Book on Stuff Like [This](https://web.stanford.edu/%7Ejurafsky/slp3/4.pdf).

### The documents, their preprocessing and word tokenisation.
#### The Corpus
- [PERSUASION](http://onlinebooks.library.upenn.edu/webbin/gutbook/lookup?num=105) by Jane Austen
- [NORTHANGER ABBEY](http://onlinebooks.library.upenn.edu/webbin/gutbook/lookup?num=121) by Jane Austen
- [LOVE AND FRIENDSHIP AND OTHER EARLY WORKS](http://onlinebooks.library.upenn.edu/webbin/gutbook/lookup?num=1212) by Jane Austen
- [PRIDE AND PREDUJICE](http://onlinebooks.library.upenn.edu/webbin/gutbook/lookup?num=1342) by Jane Austen
- [MANSFIELD PARK](http://onlinebooks.library.upenn.edu/webbin/gutbook/lookup?num=141) by Jane Austen
- [EMMA](http://onlinebooks.library.upenn.edu/webbin/gutbook/lookup?num=158) by Jane Austen
- [SENSE AND SENSIBILITY](http://onlinebooks.library.upenn.edu/webbin/gutbook/lookup?num=161) by Jane Austen
- [LADY SUSAN](http://onlinebooks.library.upenn.edu/webbin/gutbook/lookup?num=946) by Jane Austen

Before crunching the data some preprocessing and decisions on tokenisation of the
words in the document needs to be decided.
#### Preprocessing the text before tokenisation.
##### Remove preamble...

Project Gutenberg provides the text in a natural manner, and also with some pretext which is not really part of the novel:


> The Project Gutenberg EBook of Persuasion, by Jane Austen
>
> This eBook is for the use of anyone anywhere at no cost and with
> almost no restrictions whatsoever.  You may copy it, give it away or
> re-use it under the terms of the Project Gutenberg License included
> with this eBook or online at www.gutenberg.net
>
> Title: Persuasion
>
> Author: Jane Austen
>
> Release Date: June 5, 2008 [EBook #105]
>
> Last Updated: February 15, 2015
>
> Language: English
>
> *** START OF THIS PROJECT GUTENBERG EBOOK PERSUASION ***
>
> Produced by Sharon Partridge and Martin Ward. HTML version
> by Al Haines.
>
> Persuasion
>
>
> by
>
> Jane Austen
>
> (1818)
>
>
> Chapter 1
>
>
> Sir Walter Elliot, of Kellynch Hall, in Somersetshire, was a man who,
...

Everything up to and including the year of publication will not be included in the tokenisation, and n-gram derivation.

##### Change line length...

Also hadoop in its "out-of-the-box" formulation processes one line at time. This means in the initial mapping each value is one line. To be semantically correct this is not ideal as the texts have line endings at non semantic points. Rather than writing new custom initial partitioning for hadoop, the texts will be reformatted so that each paragraph is on one line. This will be done using `fmt`.

```
$ fmt -w 100000 < book.txt > processed/book.txt
```

##### Tokenisation

How should words be decided. In the sense of probability calculations
we need to define what a `word` is; or what a `token` is. And should
new tokens be added in order to provide better semantic sense. It will
be interesting to tokenise in different ways, and then experiment with
the different results.

- Option 1: In this option tokenisation will
  - not remove or delete any punctuation
  - add a beginning of paragraph marker that will be considered a token
  - add an end of paragraph marker that will be considered a token
  - treat punctuation marks themselves as tokens.

  So for example if there is a paragraph such as the below.

  > This is an interesting day. The boy said "Hi!". Lets get going?

  It would be tokenised as

```
<p> <this> <is> <an> <interesting> <day> <.>
<The> <boy> <said> <"> <Hi> <!> <"> <.>
<Lets> <get> <going> <?> <p>
```
