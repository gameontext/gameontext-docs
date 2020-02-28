---
title: Application Architecture
url: "/architecture/"
weight: 3
type: book
aliases:
- "/microservices/"
---

Game On! is an application composed of several microservices. The set of services
has changed over time. The best practice with microservice architectures is still
to start with a monolith or (at least) with very large chunks. We started with two
large blobs, and [refined the granularity of services as the application
evolved]({{< relref "chronicles/_index.md" >}}).

The core and secondary services are described below, with attention paid to the
characteristics that made each into a standalone, autonomous microservice.
