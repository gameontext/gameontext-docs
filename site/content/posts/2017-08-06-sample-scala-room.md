---
layout: post
title: We have a Scala Room!
summary: play with play in scala in game on!
tags: [fun, profit, scala, play]
author: ilan
---

What follows is the stream-of-conciousness and research that lead up to our newest sample room!

## tl;dr

- [advanced adventures](https://book.gameontext.org/walkthroughs/creatingYourOwnRoom.html).
- [sample-room-scala](https://github.com/gameontext/sample-room-scala)
- [the room up and running](http://134.168.52.95:9000/)

## Day 0

So for me 2017/18 is going to include adventures in polyglot.

> This  will include but will not be only restricted to
> `Kotlin`,`Prolog`, `Erlang`, `Racket`, `Haskell`, `Closure`, `Scala`

## Day 1

### Decide on tooling.

- [scala](http://www.scala-lang.org) is the language.
- [sbt](http://www.scala-sbt.org/) is the build tool.
- [giter8](http://www.foundweekends.org/giter8/) to set up starter directories.
- [play](https://www.playframework.com/) is the Websocket Framework.
- [ensime](http://ensime.org) is the plugin for emacs.
  - `play` has a [web socket api](https://www.playframework.com/documentation/2.6.x/ScalaWebSockets)
  - `giter8` has a [starter template](https://github.com/foundweekends/giter8/wiki/giter8-templates) for `play`.
- `ensime` looks fun as a development environment.

### Learn to stop hating and love regexes

```scala
scala> sample
res69: String =
roomHello,<roomId>,{
    "username": "username",
    "userId": "<userId>",
    "version": 1|2
}

scala> pattern
res70: scala.util.matching.Regex = (?s)(\w+),([^,]*),(.*)

scala> val pattern(target,id,payload) = sample
target: String = roomHello
id: String = <roomId>
payload: String =
{
    "username": "username",
    "userId": "<userId>",
    "version": 1|2
}
```

<!--more-->

## Day 2

- Learn about how the play framework works with [json](https://www.playframework.com/documentation/2.6.x/ScalaJson)
- Add some code to parse the (roomHello|roomJoin) message and reply correctly.
- [commit](https://github.com/gameontext/sample-room-scala/commit/28102e83400d7f12a2c843bf5d48da7c34d7ab16)

## Day 3

- add websocket chat response
- [commit](https://github.com/gameontext/sample-room-scala/commit/6dcc22c1a82b09290995831f400ff45c960c3341)

## Day 4

- hack up some room replies when home late after midnight
- [commit](https://github.com/gameontext/sample-room-scala/commit/5e5fdf380f9c6f6e28395cb3902e5820e09f045a)

## Day 5

- tidy up a bit, make the code space a bit more cozy
- [commit](https://github.com/gameontext/sample-room-scala/commit/c132d41cf85b40dc79c38a16a08c5fe3b29e3a1f)
- [commit](https://github.com/gameontext/sample-room-scala/commit/1b065465a6c06e3049297061b2f4df4b54517877)
- start working on "room is running page", which leads to having to understand
  - the [javascript security](https://www.playframework.com/documentation/2.6.x/SecurityHeaders) settings for play
  - and also more specifically [content security policy](https://www.html5rocks.com/en/tutorials/security/content-security-policy/)
  - and [also](https://www.playframework.com/documentation/2.6.x/resources/confs/filters-helpers/reference.conf)
- realise that you need [bootstrap](http://getbootstrap.com/getting-started/) to make it look decent
- using bootstrap, make a *your room is running page* with test buttons, to test web socket calls.
- [commit](https://github.com/gameontext/sample-room-scala/commit/f8b6992d9a21c24bff191058514464ba2e02728f)

## Day 6

ooh, its getting addictive to play with the bootstrap

- make it possible to edit preformed test message, or send arbritary message in the tests provided on the page.
- [commit](https://github.com/gameontext/sample-room-scala/commit/e532f45faa6528d79a3f1d7e2b3ad9ff270de04b)

<a href="http://i.imgur.com/mdfxKtn.png"><img src="http://i.imgur.com/mdfxKtn.png" width="600" /></a>

- learn that in bootstratp 1 == 12 so that the room test screen flows responsively.

## Day 7

stay up until 3am refactoring code unrelated to this, but in Scala.
So all the ensime skillz gained were useful, and got to use partial functions and currying. w00t!

## Day 8

oops... fix repo name from `sample-scala-room` to `sample-room-scala`

- enter the [whale](http://www.scala-sbt.org/sbt-native-packager/formats/docker.html) which has its own native sbt plugin.
- add a secret to conf, using well something from [here](https://randomkeygen.com/), not that secret if its in github though, is it?
  also allow the app to run on any host. also allow web socket calls on any host.
- woohoo and we have docker for the room.. so simple, no docker files. Yay!
- so room is now running locally, and test screen works.. almost ready to publish image to clouds and connect up to gameon!
- [commit](https://github.com/gameontext/sample-room-scala/commit/33cfa37416ea399331fd43814bd0b2da7fd2cf7a)

```bash
sample-room-scala ilanpillemer$ sbt docker:publishLocal
...
[info] Successfully built 6738f15ebd2e
[info] Built image sample-room-scala:1.0-SNAPSHOT
...
sample-room-scala ilanpillemer$ docker images | grep sample
...
sample-room-scala               1.0-SNAPSHOT        6738f15ebd2e        4 seconds ago       817.7 MB
sample-scala-room               1.0-SNAPSHOT        f3ffa05f0f4e        58 minutes ago      817.7 MB
...
sample-room-scala ilanpillemer$ docker run -p 9000:9000 6738f15ebd2e
[info] play.api.Play - Application started (Prod)
[info] p.c.s.AkkaHttpServer - Listening for HTTP on /0:0:0:0:0:0:0:0:9000
```

## Day 9

- add license
- upload image to dockerhub : [ilanpillemer/sample-scala-room](https://hub.docker.com/r/ilanpillemer/sample-room-scala/)
- install [bluemix command line](https://clis.ng.bluemix.net/ui/home.html)
- copy image from docker hub to bluemix
- still have one more ip address available on free tier at blue mix, so use that and start container
  - though no more free ones left now... :(
- http://134.168.52.95:9000/ is up and running...
- register room in gameon!
- go to room and see it working. (roomid: 3a4fb6dee190696852882ba3e78921a4)
- add the proforma stuff to the README
- job done

<a href="http://i.imgur.com/wDzgnTW.png"><img src="http://i.imgur.com/wDzgnTW.png" width="600" /></a>
