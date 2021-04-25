---
layout: post
title: Cars, Pi cameras and ASCII art&#58; Microservices with Liberty and Game On!
author: adam_P
tags: [iot, hacking]
---
> Post recovered from the Liberty development blog. Pictures are missing (we'll find them eventually).

The Liberty microservices team, based in IBM Hursley in the UK, decided to include some ASCII art in Game On!. From there, it was but a short step to driving a remote-controlled car around the floor of the latest WebSphere User Group meeting at IBM Southbank, taking pictures with a Raspberry Pi camera to render as ASCII art.

## Game On!

Game On! is both a sample microservices application and throwback text adventure brought to you by the WASdev team at IBM. It aims to enable exploration of microservice architectures from two points of view:

* **As a player**: On the one hand, you can be entertained by the creativity of other peer developers, exploring the game’s rooms; on the other hand, you can navigate a distributed system, exit by exit.

* **As a developer**: Learn about microservice architectures and supporting infrastructure by extending the game with your own services. Write your own rooms to see how they interact with the rest of the system and to experiment with different strategies for building resilient distributed systems.

## Polyglot to the rescue

Text is one way to display information to the user but we wanted to add images. Game On! is text-based, though, and doesn’t support images. So we thought it would be cool if we could display some ASCII art and, even better, provide a way for images to be converted on-the-fly.

Our initial approach was to create a new room for Game On! which would display some ASCII art pictures (we imaginatively titled this the picture room). This would be hosted in its own Docker container and it would register with the Game On! map service at startup. The [simple Java room example](https://github.com/gameontext/gameon-simpleroom) provided a good starting point. It shows all the skeleton code needed to connect a room to Game On! and how to handle things like security and creating the correct JSON data structures. Great, we were up and running with a new Game On! room in about 10 minutes (after a few minor tweaks to the Java code, such as setting the correct developer API key).

Now all we needed was a Java library to do the image-to-ASCII conversion for us and we would be good to go. Unfortunately, this wasn’t as easy as it first sounded because there isn’t a readily available library for Java. The library that a lot of people use is [GraphicsMagick](https://www.graphicsmagick.org/) but that is native code. A little bit of searching revealed that there exists a node.js module called [image-to-ascii](https://www.npmjs.com/package/image-to-ascii). Normally this would be the end of the investigation, but with microservices we could quickly add in a new technology, even from other runtimes and languages.

We configured a Docker container to run a node.js instance with the image-to-ascii module installed. We then added a very simple web interface with [express](https://www.npmjs.com/package/express): not even REST, just an endpoint that accepts an image and returns ASCII art. We called this the image service. After that, we just configured the Game On! room to call out to the image service.

So now we have a nice polyglot environment and, because IBM Bluemix supports both node.js and Liberty runtimes, there won’t be a problem when we deploy this to the cloud in the future.

## Smile please

Once we had static images, we immediately wanted to use a camera to capture live pictures; something altogether much more interesting (oh look, new shiny!). We had a camera in the office that plugged into a Raspberry Pi; Liberty is such a lighweight application server that it happily runs on a Pi. So we built another Game On! room (again based on the Java simple room template) but moved it be running on the Pi: we called this the camera room (you can tell we’re in development and not marketing…). Here is a picture showing the room running in Game On! and the camera taking a picture of one of the team (note the obligatory coffee pot in the foreground, this was a bit of a late night coding session in the office :-) ):

[[Game On! camera and ascii art]]

This was interesting as it was starting to not only show how to communicate with devices (think Internet of Things) but also what happens when more than one person tries to control the same physical device. The increasing number of microservice interactions between Game On!, node, and the Pi also nicely serves to illustrate the fact that increased remote calls is something that is part of a microservices environment. The good news is that Game On! contains plenty of code showing how to do things like re-establishing WebSocket connections, handling timeouts, and a whole plethora of things that can happen when one service tries to call another.

## Backseat drivers!

Having got the camera working, always getting the same image (albeit a live one instead of a static one) soon got a little bit boring. We needed a way to move the camera around so that it could take different pictures. Enter the Liberty Car. For those that don’t know, the Liberty Car is a remote-controlled car that is controlled using a Liberty instance running on a Pi, which is housed within the car. Hhhmmm, so that would be something that can be moved using a Pi…perfect! We removed the old Pi that was in the car and replaced it with the one running our Game On camera room:

[[Liberty Car and Camera]]

One of the key tenets of microservices is the separation of concern between services and how each one should have a clearly defined responsibility. Rather than add functionality to the camera room, we added another room to control the car (car room). To that end, we further decomposed the existing camera room into a camera service that would let you take a picture and could be accessed independently from Game On.

Earlier, I mentioned how increased numbers of remote calls, and their associated overheads, are one of the costs of using a microservices architecture. The sample flows below show just how quickly these calls start to add up, and why you need to be defining your API up front: think Test Driven Development but with APIs and Swagger.

Taking a picture:
```
Browser <-> Game On (docker) <-> Car Room (Pi) <-> Camera Service (Pi) <-> Image Service (node.js)
```

Driving the car:
```
Browser <-> Game On (docker) <-> Car Room (Pi) <-> Car Service (Pi)
```

Re-using the camera service:
```
3rd Party App <-> Camera Service (Pi)
```

## The final picture

At a high level, this is how we had all the services talking to each other:

[[GameOn Demo Architecture]]

This architecture shows:

* A virtual machine with 7 Docker containers, each running an instance of Liberty
* A polyglot environment with both node.js and Liberty runtimes
* A Raspberry Pi running Liberty, with 4 deployed applications
* Service re-use; being able to drive the car, or take pictures, through Game On! or using a second web interface

## WebSphere User Group

Finally, we took this to the latest WebSphere User Group (WUG) which was held in IBM’s Southbank offices.

[[Game On stand at the WUG]]

We had lots of people stop by and ask us a whole range of questions, for example:

* So what are microservices?
* Why is Liberty a good fit for microservices?
* You’ve done, what!?! with a text adventure…
* Can you take the car off the blocks so that I can drive it around ? (which was fun because, of course, we said yes)

Game On! gives us a really great context within which to answer these questions. The fact that it’s available online and the code is in GitHub means that you can write your own rooms and learn about microservices with Liberty whenever and wherever you want.