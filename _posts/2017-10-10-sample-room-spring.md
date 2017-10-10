---
layout: post
title: Spring Room!
summary: A sample room made with Java and Spring
tags: [spring, java]
author: quan
---

### Our latest sample room is written in Java with the Spring framework:

- [sample-room-spring](https://github.com/gameontext/sample-room-spring)
- [the room up and running](http://sample-room-spring-962.mybluemix.net)

This post is a brief overview of the creation process.

## Jumpstart with code gen

Using this [guide](https://www.ibm.com/blogs/bluemix/2017/09/creating-running-deploying-spring-microservices-5-minutes/), we made a Spring microservice starter that could be deployed to Bluemix with just a few commands:

<a href="https://imgur.com/3gk5zmP"><img src="https://i.imgur.com/3gk5zmP.png" title="source: imgur.com" /></a>

Time to fill in our own code!

## Borrowing from the Java room

 The [Java room](https://github.com/gameontext/sample-room-java) had a lot of code we could reuse, so that's what we did.
 
 Notable differences:
 
 - We needed a [WebSocketConfig](https://github.com/gameontext/sample-room-spring/blob/master/src/main/java/app/WebSocketConfig.java), that maps our [SocketHandler](https://github.com/gameontext/sample-room-spring/blob/master/src/main/java/app/SocketHandler.java) to `"/room"`
 
 - `org.springframework.web.socket.WebSocketSession` 
 
 <a href="https://imgur.com/l1IOxc1"><img src="https://i.imgur.com/l1IOxc1.png" title="source: imgur.com" /></a>
 
 vs
 
 `javax.websocket.Session`
 
 <a href="https://imgur.com/GqCfa37"><img src="https://i.imgur.com/GqCfa37.png" title="source: imgur.com" /></a>
 
 After some Liberty to Spring porting, we can run `mvn spring-boot:run` to see our Spring room running locally!
 
 <a href="https://imgur.com/dgwNTiN"><img src="https://i.imgur.com/dgwNTiN.png" title="source: imgur.com" /></a>
 
 ## Deploy to Bluemix
 
 After adding [Travis](https://github.com/gameontext/sample-room-spring/blob/master/.travis.yml), [Docker](https://github.com/gameontext/sample-room-spring/blob/master/pom.xml#L75), and [JaCoCo](https://github.com/gameontext/sample-room-spring/blob/master/pom.xml#L83), we were ready to deploy to Bluemix:
 
 `bx dev build`
 
 then
 
 `bx dev deploy`
 
 And our room is deployed with a reachable endpoint!
 
 <a href="https://imgur.com/hdcLdoa"><img src="https://i.imgur.com/hdcLdoa.png" title="source: imgur.com" /></a>
 
 ## Register the room with Game On!
 
 <a href="https://imgur.com/4fvzY6x"><img src="https://i.imgur.com/4fvzY6x.png" title="source: imgur.com" /></a>
 
 ## Done!
 
 `/teleport spring-sample`
 
 <a href="https://imgur.com/wMcyGjJ"><img src="https://i.imgur.com/wMcyGjJ.png" title="source: imgur.com" /></a>
