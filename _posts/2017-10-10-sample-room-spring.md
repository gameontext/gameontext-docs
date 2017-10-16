---
layout: post
title: Spring Room!
tags: [spring, java]
author: quan
---

We have a new sample room written in Java with the Spring framework:

- [sample-room-spring](https://github.com/gameontext/sample-room-spring)
- [the room up and running](http://sample-room-spring-962.mybluemix.net)

This post is a brief overview of the creation process.

## Jumpstart with code gen

Using this [guide](https://www.ibm.com/blogs/bluemix/2017/09/creating-running-deploying-spring-microservices-5-minutes/), we made a Spring microservice starter that could be deployed to Bluemix with just a few commands: 

{% highlight shell_session %}
  $ bx dev create
  ? Select a pattern:                        
  1. Web App
  2. Mobile App
  3. Backend for Frontend
  4. Microservice
  5. MFP
  Enter a number> 4

  ? Select a starter:
  1. Basic
  Enter a number> 1

  ? Select a language:
  1. Java - MicroProfile / Java EE
  2. Node
  3. Python
  4. Java - Spring Framework
  Enter a number> 4

  ? Enter a name for your project> springmsdemo                             
  ? Enter a hostname for your project> springmsdemo
  ? Do you want to add services to your project? [y/n]> y

  ? Select a service:
  1. Cloudant NoSQL Database
  2. Object Storage
  Enter a number> 1

  ? Select a service plan:               
  1. Lite
  2. Standard
  3. Dedicated Hardware
  Enter a number> 1

  Successfully added service to project.               

  ? Do you want to add another service? [y/n]> n
                                    
  The project, springmsdemo, has been successfully saved into the current directory.
  OK
{% endhighlight %}

Time to fill in our own code!

## Borrowing from the Java room

The [Java room](https://github.com/gameontext/sample-room-java) had a lot of code we could reuse, so that's what we did.

Notable differences:

  - We needed a [WebSocketConfig](https://github.com/gameontext/sample-room-spring/blob/master/src/main/java/app/WebSocketConfig.java) to map our [SocketHandler](https://github.com/gameontext/sample-room-spring/blob/master/src/main/java/app/SocketHandler.java) to `/room` [WebSocketConfig](https://github.com/gameontext/sample-room-spring/blob/master/src/main/java/app/WebSocketConfig.java) to map our [SocketHandler](https://github.com/gameontext/sample-room-spring/blob/master/src/main/java/app/SocketHandler.java) to `/room`

  {% highlight java linenos %}
  @Configuration
  @EnableWebSocket
  class WebSocketConfig implements WebSocketConfigurer {

      @Inject
      SocketHandler handler;

      public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
          registry.addHandler(handler, "/room");
      }
  }
  {% endhighlight %}
 
  - We also needed to use a Spring WebSocket  (`org.springframework.web.socket.WebSocketSession`) instead of the standard one (`javax.websocket.Session`). It looks roughly like this (simplified):  (`org.springframework.web.socket.WebSocketSession`) instead of the standard one (`javax.websocket.Session`). It looks roughly like this (simplified): 

  {% highlight java linenos %}
  @Component
  public class SocketHandler extends TextWebSocketHandler {

      private final HashMap<String, WebSocketSession> sessions = new HashMap<>();
      @Inject
      private RoomImplementation roomImplementation;

      @Override
      public void afterConnectionEstablished(WebSocketSession session) throws Exception {
          sessions.put(session.getId(), session);
          session.sendMessage(new TextMessage(Message.ACK_MSG.toString()));
      }

      @Override
      public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
          sessions.remove(session.getId());
          Log.log(Level.INFO, this, "WebSocketSession with Id (" + session.getId() + ") closed with reason: " + status.getReason());
      }

      @Override
      public void handleMessage(WebSocketSession session, WebSocketMessage<?> message) throws Exception {
          roomImplementation.handleMessage(new Message(message.getPayload().toString()), this);
      }

      public void sendMessage(Message message) {
          for (WebSocketSession s : sessions.values()) {
              sendMessageToSession(s, message);
          }
      }

      private boolean sendMessageToSession(WebSocketSession session, Message message) {
          try {
              session.sendMessage(new TextMessage(message.toString()));
              return true;
          } catch (IOException e) {
              ...
          }
      }
      
      ...
  }
  {% endhighlight %}
 
After porting some common code, we can run `mvn spring-boot:run` to see our Spring room running locally!
 
<a href="https://imgur.com/dgwNTiN"><img src="https://i.imgur.com/dgwNTiN.png" title="source: imgur.com" width="600"/></a>
 
## Deploying to Bluemix
 
After adding [Travis](https://github.com/gameontext/sample-room-spring/blob/master/.travis.yml), [Docker](https://github.com/gameontext/sample-room-spring/blob/master/pom.xml#L75), and [JaCoCo](https://github.com/gameontext/sample-room-spring/blob/master/pom.xml#L83), we were ready to deploy to Bluemix:
 
  `bx dev build`
 
then
 
  `bx dev deploy`
 
and our room is deployed as a Cloud Foundry service with a reachable endpoint!
 
<a href="https://imgur.com/hdcLdoa"><img src="https://i.imgur.com/hdcLdoa.png" title="source: imgur.com"  width="600"/></a>
 
## Registering the room with Game On!
 
<a href="https://imgur.com/4fvzY6x"><img src="https://i.imgur.com/4fvzY6x.png" title="source: imgur.com"  width="600"/></a>
 
## Done!
 
`/teleport spring-sample`
 
<a href="https://imgur.com/wMcyGjJ"><img src="https://i.imgur.com/wMcyGjJ.png" title="source: imgur.com"  width="600"/></a>
