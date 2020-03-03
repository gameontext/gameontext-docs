---
layout: "post"
title: "Advanced KubecCtl"
date: "2018-10-02 01:01"
author: ozzy
tags: [ kubernetes, local ]
---

We've been heads down figuring out how to take the work we did for Game On! on Kubernetes, and make it even simpler for users to get started.

So our resident techno-wizards have come up with a pile of scripts to help orchestrate the deploy onto K8S, and do some of the config
and setup and boring backgroundy stuff that's required to get a polyglot microservice app up and running in your cluster. (Apparently the
'techno-wizards' prefer other titles like "Software Engineer", but that doesn't sound anywhere near as much fun! so.. Techno-Wizards they shall be!)

Anyway, one of them came wandering over and started describing ancient incantations he'd recently learned that allowed him to check the
status on a bunch of pods. I had him write down some notes to share with the wider world, because we all know that sharing ancient magics
never leads to the ressurection of sand gods bent on destroying the modern world, but instead leads to enlightenment and happiness.

The tale here starts with a simple requirement...

 - "Find out when Game On! has finished launching in the cluster, and is ready to accept requests"
 
The simplest approach here is `kubectl get pods`, and read the output, and wait until the appropriate pods are ready. Of course, 
Game On! deploys to it's own namespace, so the command becomes `kubectl get pods -n gameon-system`. 
 
As you can see from the output, we can easily see which pods are ready by just looking at the READY column, 
and looking for the `1/1` entries :

```bash
kubectl get pods -n gameon-system
NAME                      READY     STATUS    RESTARTS   AGE
auth-1816639685-xejyk     1/1       Running   0          26m
webapp-1816639685-xejyk   1/1       Running   0          26m
mediator-1816639685-xejyk 1/1       Running   0          26m
...
```

We can read the output with `grep`, and just look for `0/` to know when a pod isn't ready yet. 

It's a tad crude, but it works, or rather, worked. Right up until we added istio. 

Once istio was part of the application, each pod now has *two* containers. One as the app itself, and another as the istio sidecar. 
Unfortunately, this means our trick for checking `0/` fails, because `1/2` doesn't start with `0/` so we believe the pod is started.
And since the istio sidecar starts blazingly fast, and our Game On! service needs to boot a JVM, it'll stay in `1/2` for quite a while 
before the app is actually working. 

So, we could improve our `grep`.. 

```bash
kubectl get pods -n gameon-system | tail -n +2 | awk '{print $2;}' | awk -F "/" '{if($1==$2){print "OK";}else{print "BAD"}}' | grep BAD | wc -l
```

As a first pass, this seems almost sane ;)

 - get the pod list
 - lose the headers
 - grab the 'ready' column only
 - test if the values each side of the '/' char are equal
 - check if any lines had values that didn't match

You could improve it a little if you know about `--no-headers`, but the concept is the same, it just uses awk to process the output 
to create something we can use `grep` with. 

_If only there was a better way..._

Kubectl supports "jsonpath" a neat little option that on the surface, allows you to retrieve metadata fields even if they are not
supported by kubectl's `--field-selector` argument. eg. `kubectl get pod auth -n gameon-system -o jsonpath='{.metadata.name}'` will 
return just the name of the pod

You can use it with lists of items too, eg `kubectl get pods -n gameon-system -o jsonpath='{.items..metadata.name}'` will output
the names of all the Game On! pods. Jsonpath is used by a bunch of stuff, and even has some awesome online jsponpath evaluators where you
can test out syntax. Jsonpath includes filters, that allow you to reduce lists to only items matching a filter. 

"Great!" went the Techno-Wizard, I will use that to get the list of all Game On! pods, but filter it to only the Pods that are not ready.

Sadly, there are some minor differences between the implementations, and one of those ends up being quite the drawback for K8S. 

The issue is that the status we want to query is inside a list inside the pod declaration. And the pods themselves are in the list we
are trying to filter. If we wanted to express this in jsonpath, it would end up a little like this...

`{.items[?(@.status.containerStatuses[?(@.ready==false)])].metadata.name}`

Here we are saying take the list of items, where the list of containerStatuses contains an instance of ready being false. Except that
involves processing a nested array, which the K8S JSONPath can't handle. 

So instead, we'll use the `{range}` support in kubectls jsonpath support. 

`kubectl get pods -n gameon-system -o jsonpath='{range .items[*]}{" "}{.metadata.name}{"="}{range .status.containerStatuses[?(@.ready==false)]}{""}{.ready}{end}{end}`

This will use `range` to iterate over the pods (in the `items` array), outputting the name of each pod, then using a nested range to
iterate over the statuses, selecting only those where ready is false. 

For pods that are ready, we'll see output like `auth=` and for not ready pods we'll see `web=false` or possibly `web=falsefalse` (because
false will be output for each time a container stbut atus is false, and with istio-sidecar & the app, there are two possibilities).  The 
output will all be on a single line,  but with a little work we can fix that. 

If we throw in a liberal sprinkling of `tr` commands, and a little grep magic, and a dash of sed.. tada.. 

```bash
kubectl get pods \
   -n gameon-system \
   -o jsonpath='{range .items[*]}{" "}{.metadata.name}{"="}{range .status.containerStatuses[?(@.ready==false)]}{""}{.ready}{end}{end}' \
 | tr ' ' '\n' \
 | grep "=false" \
 | sed -e 's/^\([^-]*\).*=false.*/\1/g' \
 | tr '\n' ' '

```

Here we take the space separated string, swap the spaces for linefeeds, then use grep to filter to only the "not ready" pods, then use 
sed to convert the container names back to their gameon short service names (eg. auth-deploy-c54875487-fhre9s becomes auth), before finally using tr to swap the linefeeds back into spaces!

But why?

Because that gives us a command that everytime we run it will give us back the names of the services that are not ready yet. 

And when we wrap that into a script that calls it at regular intervals, we can meet our initial goal with a little style, by
listing the services we are still waiting for.

```sh
#!/bin/bash

DOTS=""
while [ true ]; do
  NOTREADY=$(kubectl get pods \
  -n gameon-system \
  -o jsonpath='{range .items[*]}{" "}{.metadata.name}{"="}{range .status.containerStatuses[?(@.ready==false)]}{""}{.ready}{end}{end}' \
  | tr ' ' '\n' \
  | grep "=false" \
  | sed -e 's/^\([^-]*\).*=false.*/\1/g' \
  | tr '\n' ' ')
  DOTS="$DOTS."
  if [ -z $NOTREADY ]; then
    break
  fi
  echo -en "\rWaiting for [ $NOTREADY]$DOTS"
  sleep 5
done
```

(Extra points if you can spot what's wrong with the DOTS handling ;) )

And that concludes our tale, as the Techno-Wizard returns once more from whence he came, mumbling about PodSecurityPolicies and 
allowedCapabilities, but that will have to be a tale for another time.