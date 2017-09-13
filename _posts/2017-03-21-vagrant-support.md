---
layout: post
title: Local development with Vagrant
author: erin
tags: [local, vagrant]
---

Setting up the core game services locally can be a tricky business. If you don't fancy [installing our core game services and dependencies](https://book.gameontext.org/walkthroughs/local-docker.html) on your most favorite dev box, ~~have a look at our [Vagrant](https://github.com/gameontext/gameon-vagrant) project~~ clone the [gameon repository](https://github.com/gameontext/gameon), `cd gameon`, and run `vagrant up`, which will set up a virtual machine ready for local development.

Go play!

*Edit 2017-09-13: As noted above, using Vagrant for local development is now even easier. The `gameontext/gameon-vagrant` repository was retired in favor of a Vagrantfile in the `gameontext/gameon` repository itself.
