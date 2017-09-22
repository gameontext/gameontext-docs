---
layout: post
title: Simplified Docker Compose for local development
author: erin
tags:
  - adventure
  - local
  - docker
---

We now have a special branch in the [gameon repository](https://github.com/gameontext/gameon) that contains a snapshot of a smooth end-to-end local development flow with `docker-compose`. 

```
> git clone https://github.com/gameontext/gameon.git
> cd gameon
> ./go-admin.sh up
```
TA-DA!!

Yes, yes. Kubernetes is next, we promise. But with this revision of the Docker Compose path, we dropped a lot of complexity (bye, Amalgam8!) and created a simplified path for getting started. The README.md has been updated with the new TL;DR instructions, and they are ever so much better (and more concise!).

We'll try to cut "releases" of the gameon repository a little more frequently, so there is always a last-known-good state to work from (rather than always using whatever the most recent / experimental docker images are).

Stay tuned! Enjoy! Go play!
