---
layout: post
title: Room on a chip
summary: Tweet-length summary of the post
tags:
  - eps8266
  - iot
  - websockets
  - arduino
  - microservices
author: ozzy
---

[Game On!](https://gameontext.org/) is a fun little text adventure written using a Microservice architecture. It's also extensible, allowing users to write their own 'Rooms' (locations within the text adventure world), that run as Microservices, in the cloud, on their own systems, etc.

I've played with Arduino's and Raspberry Pi's, and similar for quite some time. I tried having an Arduino read data from a Floppy Drive, which was fun, and ultimately led to  [a crazy floppy disk autoloader](http://hackaday.com/2012/03/31/floppy-autoloader-takes-the-pain-out-of-archiving-5000-amiga-disks/). From there, I ended up moving on from Arduino to the Maple, then from there to a Teensy 3.0, and most recently, a rather fun little collection of boards based around a Chip known as the [ESP8266](https://en.wikipedia.org/wiki/ESP8266)

![esp8266 board](http://bit.ly/2tAIOE8)
<!-- http://www.my-iota.com/Development%20boards/Witty%20Cloud%20(GizWits)%20-%20ESP8266%20Development%20Board/Witty%20Cloud%20(GizWits)%20-%20ESP8266%20Development%20Board_files/image002.jpg -->

There are some nice things about one of the ESP8266 boards I had ([Witty Cloud / GizWits](http://bit.ly/2u3bsQg)):
<!-- http://www.my-iota.com/Development%20boards/Witty%20Cloud%20(GizWits)%20-%20ESP8266%20Development%20Board/Witty%20Cloud%20(GizWits)%20-%20ESP8266%20Development%20Board.htm -->
* you program it using the Arduino API,
* it has built in WiFi, 4MB of flash to store your code, 64k of instruction ram, and 96k of data ram to play with.
* it runs at 80mhz or so
* it has an LED light that can change color
* it has a light sensor

That's pretty impressive for something that costs around 5$ shipped.

When you know there are Arduino JSON libraries, and Arduino WebSocket libraries that can run on it, you start wondering: is it possible to host a Room for Game On on an ESP8266 ?

I had a spare moment at a weekend, so decided to find out! =)
<!--more-->

I figured I'd create a room that allowed players in the room to alter the color of the light, and read the light sensors value.

Starting with a recent version of the Arduino IDE, I added support for the ESP8266 via the [board manager](https://github.com/esp8266/Arduino#installing-with-boards-manager) , and then downloaded the ArduinoJson and Websockets libraries via the Library Manager.

That much will automatically add the #includes for the libraries we plan to use.

Arduino projects have 2 methods that you work out from, "setup" that's called exactly once when the device starts, or reboots, and then "loop" which is effectively called from a while(true) loop.

We use setup to configure initial state for the device, things like configuring the GPIO lines to be input, or output, and setting their initial states.. and in the case of the esp8266, we'll also use it to connect to the wifi, and launch our websocket server.

Setting up the GPIO is fairly simple..

    //setup the gpio..
    pinMode(15, OUTPUT);
    pinMode(12, OUTPUT);
    pinMode(13, OUTPUT);
    pinMode(4,INPUT);
    pinMode(A0,INPUT);

Connecting to the WiFi is similarly not too complicated..

    //connect to the wifi..
    WiFiMulti.addAP("MYSSID", "MYWIFIPASSWORD");
    while(WiFiMulti.run() != WL_CONNECTED) {
        delay(100);
    }
    Serial.printf("[SETUP] COMPLETE.\n");
    Serial.printf("[SETUP] IP address: ");
    Serial.println(WiFi.localIP());

Lastly, we need to handle the WebSocket.. the WebSocket library requires you to declare the WebSocket, initialize it during setup, then call the websockets loop function in your loop.

So outside the setup function we add..

    WebSocketsServer webSocket = WebSocketsServer(9999);

And inside our setup function we add..

    webSocket.begin();

And inside the loop function we add..

    webSocket.loop();

Great, if we ran that now, it'd start up, connect to the wifi, and open the worlds most pointless websocket on port 9999. We need to tell the websocket what to do when someone sends messages to it. We do this by adding a new method like this...

    void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
    }

and then telling the websocket to call that when it gets a message by adding the following line to setup, after websocket.begin();

    webSocket.onEvent(webSocketEvent);

Now we're really cooking =) we can add a switch statement to that webSocketEvent method, to process the different types of event that occur..

    switch(type) {
      case WStype_DISCONNECTED:
          break;
      case WStype_CONNECTED:
          break;
      case WStype_TEXT:
          break;
      case WStype_BIN:
          break;
    }

This should feel pretty familiar if you've read any of the Java Room examples. Let's add some simple debug to the case statements so we can see them being invoked over the serial link.

    switch(type) {
      case WStype_DISCONNECTED:
          Serial.printf("[%u] Disconnected!\n", num);
          break;
      case WStype_CONNECTED:
          {
              IPAddress ip = webSocket.remoteIP(num);
              Serial.printf("[%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);
            // send ack to game on.
            webSocket.sendTXT(num, "ack,{\"version\":[1]}");
          }
          break;
      case WStype_TEXT:
          Serial.printf("[%u] get Text: (len:%d) %s\n", num, length, payload);

          break;
      case WStype_BIN:
          //game-on doesn't use binary payloads, but let's log any we find.
          Serial.printf("[%u] get binary length: %u\n", num, length);
          hexdump(payload, length);
          break;
    }

Our first bit of real Game On! response handling has snuck in there. When a socket connects to us, we'll send back an "ack,{"version":[1]}" response. That's enough to meet the game's handshake requirements, so we get proper room events coming through as type WStype_TEXT in future. If you run this sketch as is, and [register your websocket address with Game On!](/walkthroughs/register-room.html) then you'll see all the room packets go past after you enter your room.  Don't forget you need to use port forwarding, or something similar to route an internet facing address & port back to the witty on port 9999, or Game On! will not be able to reach you!

So now we're recieving proper [Game On! websocket protocol packets](/architecture/websocket-protocol.html):

>  The protocol used by Game On! is text (rather than binary), and uses a simple comma-delimited header followed by a JSON payload. `Just,like,{"this": "ok?"}`

The first thing we need to do is split that initial packet up to extract the routing information away from the payload. We'll add a utility method that takes in the string, and initialises an array of pointers to the different parts. Because we're running on a small device, we make some attempt to save memory: instead of creating new strings for each of the parts, we'll write null terminating zeros into the string where the commas were, thus creating 3 strings indexed by the array passed in.

    //breaks up a routed message into an array of char*
    //note we only process up to 3 segments ever.
    void splitRouting(char *message, int len, char *split[]){
      //the first segment will always start at the front of the buffer.
      split[0] = message;
      int i=0;
      int j=1;
      while(i<len && j<3){
        if(message[i] == '{'){
          break;
        }
        if(message[i] == ',' && i<(len-1)){
          //store the index for the 'next' segment,
          split[j++] = &message[i+1];
          //write a null terminator into the buffer to terminate the last segment.
          message[i] = '\0';
        }
        i++;
      }
    }

That allows us to write something looking a little like this, within the `WStype_TEXT` case statement..

    if(payload!=NULL){
        char *parts[3];
        splitRouting((char*)payload,length,parts);
        //parts[0] is the routing type
        //parts[1] is the site id for the room (in case the one socket is managing multiple rooms)
        //parts[2] is the json payload for the message.
        String gameonType = String(parts[0]);
        if(gameonType=="roomHello"){
          addPlayer(parts[2],num);
        }else if(gameonType=="room"){
          processCommand(parts[2],num);
        }else if(gameonType=="roomGoodbye"){
          removePlayer(parts[2],num);
        }else{
          Serial.println("ERROR, badly formatted gameon websocket packet");
          Serial.println((char *)payload);
        }
    }else{
      Serial.println("ERROR, empty websocket packet.");
    }

Which as you can see is now calling a bunch of new functions: `addPlayer`, `processCommand`, and `removePlayer`.

`addPlayer` handles sending the player the initial room description, which also carries information about the room inventory etc back to Game On. It also handles sending a message to everyone saying the Player has entered the room.

`removePlayer` just sends the message to everyone saying the player has left..

It's kind of crude to treat the `roomHello` and `roomGoodbye` in this manner, but it's enough to give the impression the room knows what it's doing, even though it's not making any attempt to see if the `roomHello` is for a player already in the room, or if the `roomGoodbye` is for a player still in the room via another connection.

That leaves `processCommand`, which basically takes the input from the user, uses the Arduino String library to lowercase it, and compares it against a fixed set of expected commands, like `/look` or `/go` and then sends the appropriate response back.

Yes, the source code snippets have kind of stopped here ;-p You can view the full project [on GitHub](https://github.com/gameontext/esp8266-room/), but it's worth covering a few more of the important methods before we're done here.

Most messages are chat type messages, or text destined for the player, or other players in the room. For those we use a utility method called `sendMessageToRoom`. It performs a little string manipulation, then uses ArduinoJson to build up the JSON object expected by the game protocol. The object is serialized out into a buffer, which is then sent to the websocket of the user, or broadcast to all websockets, depending on if the message is just for the user, or for everyone. See `sendMessageToRoom` for more.

Actual chat messages are even simpler, and are handled by the function `sendChatMessage`, they are always broadcast, and cannot have different messages for different players in the room.

The initial location response, also sent if the player issues `/look`, is handled by the `sendLocation` function, you'll notice it's adding a bunch of entries to the 'objects' field in the JSON...

    JsonArray& objects = root.createNestedArray("objects");
    objects.add("RGBLed");
    objects.add("LDR");
    objects.add("Button");

which creates a list of objects in the Game On UI that the user is able to interact with. Well, at least it tells the user the objects are there. The interaction is handled entirely by what you do within the `processCommand` function, where I have blocks of code like:

    if(contentLower=="/examine button"){
      String allMessage = username+" investigates the button";
      int buttonValue = digitalRead(4);
      //another 'be careful not to append String to "" constant' example
      String userMessage = "It appears to be a momentary contact switch, attached to GPIO4, it currently has the state ";
      userMessage += buttonValue;
      userMessage += ". Sadly unless the room owner sits there holding the button down, that value is unlikely to change.";
      sendMessageToRoom(allMessage,userMessage,userid,num);
    }

That handle sending an appropriate response to the room & to the player when `/examine` button is sent.

Lastly there's a utility method that handles when a player uses `/go` to exit the room, this function builds a Game On JSON object with a type of `exit` with the `exitId` set to the direction the player has requested via `/go`.

It's quite fun playing with getting a Room running on a little device like this. It can really serve to remind you just how easy some things are in Java, or just when running on a machine that measures RAM in Gigabytes, rather than Kilobytes. Plus it's a great visual aid to demonstrate how Microservices can really be Micro, the entire device comes in around the same size as a large postage stamp.
