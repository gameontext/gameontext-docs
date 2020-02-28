---
layout: post
title: "Moving GameOn to Kubernetes"
date: "2018-01-10 01:01"
author: ozzy
tags: [ java, kubernetes, local ]

---
## Game On! and Kubernetes

Here at Game On! central, we've been considering how to run on Kubernetes for quite some time, and during a pause in the recent Holiday Season, we had a chance to add Kubernetes support allowing you to run the core services locally.

This work partly builds on an earlier attempt to bring Game On! to Kubernetes back in May last year. We learnt a few lessons from that attempt, and like to think this
attempt is a little cleaner.

{{< image src="/files/2018-gokube/gokube.png" title="Game On! running on Kubernetes" >}}

## Running Game On! in Kubernetes

Want to try it out? we've tested on [minikube](https://github.com/kubernetes/minikube), and [IBM Cloud Private (ICP)](https://github.com/IBM/deploy-ibm-cloud-private).

It's as simple as;

- Setup your minikube/icp, and have [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed locally, and configured to talk to your cluster.
  - For minikube, you'll need to enable ingress with `minikube addons enable ingress`
  - For ICP, this means you must execute the '[configure client](https://github.com/IBM/deploy-ibm-cloud-private/blob/master/README.md)' steps to authenticate to the cluster
- Clone the [gameon root repository](https://github.com/gameontext/gameon)
  - `git clone https://github.com/gameontext/gameon.git`
- `cd` to the cloned project, then into the `kubernetes` directory
  - `cd gameon/kubernetes`
- set the environment variable `GAMEON_HOST` to the ip of your kubernetes cluster, if you are using minikube, this is probably 192.168.99.100, if you are using ICP via Vagrant, it will default to 192.168.27.100 (unless you altered the network in the Vagrantfile)
  - `export GAMEON_HOST=192.168.99.100`
- run `./go-run.sh up` this will do the following for you..
  - create the kubernetes namespace `gameon-system`
  - edit `ingress.yaml` and `gameon-configmap.yaml` to insert your cluster ip as appropriate.
  - create a new self signed certificate/keypair, and load it into a kubernetes config map
  - create the ingress, config map, couchdb, kafka, auth, mediator, map, player, and webapp deployments and services in kubernetes.

To check on progress, you can check the cluster gui, or use kubectl to check on the status of the pods in the `gameon-system` namespace. ( `kubectl get pods --namespace=gameon-system -o wide`)

After a short while, once the the pods are all up and running, you should be able to access your Game On! at `https://gameon.192.168.99.100.xip.io`

Swap `192.168.99.100` for your cluster ip, the same value you set in `GAMEON_HOST`

If you want to remove Game On! from your cluster, run `./go-run.sh down` and the script will remove the artifacts it created.

## Whats actually happening here?

Each of the core services has their own yaml, that contains both a kubernetes [service](https://kubernetes.io/docs/concepts/services-networking/service/), and a [deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/). The deployment defines a [replica set](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/) that will deploy the appropriate Game On! image in a pod, with the appropriate environment variables set with values from the [config map](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) defined by `gameon-configmap.yaml`. The certificate used by the core services to sign and validate JWTs is mapped into each container [as a file](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#populate-a-volume-with-data-stored-in-a-configmap), where the startup scripts are able to convert it into the keystore/truststore that are required by the Java pods.

The `ingress.yaml` defines a [kubernetes ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) that acts as the front door for the whole setup, routing requests to the appropriate service. Requets are mapped using the path part of the URL just as happens in the `proxy` service when running outside of Kubernetes. `ingress.yaml` also defines and enables HTTPS for the front door, and if we wanted, we could [configure a certificate](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) to be used for HTTPS in the yaml here.

Lastly, we're using [xip.io](http://xip.io/) which is a handy service that allows you to create hostnames that map to ip addresses, without needing to edit `/etc/hosts` etc. Any url ending in `ipaddress.xip.io` resolves to `ipaddress`, so in our case `gameon.192.168.99.100.xip.io` will resolve to `192.168.99.100`, this is great, because ingress definitions require a hostname, not an ip address, and this lets us create one for testing, without any setup.

*TIP:* _your router may be "helpful" and block dns resolution for ip addresses in private networks, such as 192.168.x.x or 10.x.x.x, if so, look in your router for if you can configure a Domain Whitelist for xip.io for RFC1918 responses. This is required at least for OpenWRT/LEDE. If you can't unblock that, you'll have to resort to editing /etc/hosts or equivalent for your platform._

## Pods of fun!

Now it's running inside Kubernetes, in future, we'll be able to scale the number of services, for better availability, and to enable graduated rollouts of newer service versions.

For now, thanks to handy tools like the [IBM Cloud Private monitoring service](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0/featured_applications/deploy_monitoring.html) we can look at say, how much ram each pod is using...

You can see similar, but less detailed information from minikube's dashboard, or install heapster with `minikube addons enable heapster`

As becomes quite apparent from the charts, Kafka eats almost 5 times the memory of our average service! Why not have a dig around and see what you can find out!

{{< media >}}
  {{< image src="/files/2018-gokube/memperpodwithkafka.png" >}}
  {{< image src="/files/2018-gokube/memperpodwithoutkafka.png" >}}
{{< /media >}}
