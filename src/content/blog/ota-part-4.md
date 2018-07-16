+++
title = "Securing OTA Community Edition"
date = "2018-07-12"
tags = ["ota", "open source"]
categories = ["FOTA"]
banner = "img/banners/ota.png"
author = "Andy Doan"
+++

[Part three]({{< ref "ota-part-3.md" >}}) of this blog series showed how to
deploy an OTA Community Edition server in Google Kubernetes Engine that had
a few security holes. This article will describe how to secure it.
<!--more-->

This is the final installment to a series of blogs about implementing OTA
updates in the Linux microPlatform:

* [Part 1]({{< ref "ota-part-1.md" >}}) - How we choose a software update system
* [Part 2]({{< ref "ota-part-2.md" >}}) - What is OTA Community Edition
* [Part 3]({{< ref "ota-part-3.md" >}}) - Deploying OTA Community Edition

### Requirements

You'll need an OTA Community Edition server deployed into GKE as
documented in [part three]({{< ref "ota-part-3.md" >}}) of the blog series.

### Overview

As diagrammed in [part two]({{< ref "ota-part-2.md" >}}) OTA Community
Edition has four public entry points. The device gateway is the only
one of those that is secured by default. The web app, repo server, and
treehub all require custom code to be secured. There are many ways this
can be done and they ultimately depend on how you authenticate and
authorize users in your organization. The solution deployed here is done
in the simplest manner possible so that it's easy for you to see exactly
how and where to make your own customizations.

### DNS Updates
This blog introduces a DNS change. The previous blog created a subdomain
for both "treehub" and "tuf-reposerver". This example uses a single
subdomain called "api" and adds location paths for each service. This
gives a single entry point to focus on for security. We also need a new
entry for an "oauth2" server. In short:

  - Create these records:
    - `api.<ingress_dns_name>`
    - `oauth2.<ingress_dns_name>`
  - Delete these records:
    - `treehub.<ingress_dns_name>` *(now located at `api.<ingress_dns_name>/treehub`)*
    - `tuf-reposerver.<ingress_dns_name>`*(now located at `api.<ingress_dns_name>/repo`)*

### Secure the Reverse Proxy

OTA Community Edition has no authentication support built into it, so
securing it requires making changes to the reverse proxy we created in
the previous blog. Nginx includes the
[ngx_http_auth_request_module](http://nginx.org/en/docs/http/ngx_http_auth_request_module.html)
for securing calls to reverse proxy servers. The approach taken in this
blog is to create an authentication service to handle `auth_requests`.

The ota-blog-part4 GitHub
[branch](https://github.com/OpenSourceFoundries/ota-community-edition/tree/ota-blog-part4)
includes a new service called `oauthful` (oauth + awful). It's
[terribly insecure](https://github.com/OpenSourceFoundries/ota-community-edition/blob/ota-blog-part4/oauthful/app.py),
but shows in the fewest lines of code possible what you need to secure
in your deployment. Deploying this is easy:
~~~
  # Change directories to your ota-community-edition repo from part 3.
  # Pull in changes from upstream repo:
  git pull

  # Check out the branch for this blog:
  git checkout ota-blog-part4

  # To look at the diffs between the 2 blogs visit:
  # https://github.com/OpenSourceFoundries/ota-community-edition/compare/ota-blog-part3...ota-blog-part4

  # Deploy changes with:
  ./contrib/gke/make start-services

  # At this point the new configuration is ready, but you'll have to restart
  # the reverse-proxy to enable it:
  ./contrib/gke/kubectl get pods | grep reverse-proxy | cut -f1 -d\  | xargs ./contrib/gke/kubectl delete pod
~~~

### Verify the APIs Are Secure
~~~
  # Set the URL below to match your domain, and verify you get HTTP 401 errors:
  curl -v http://api.example.com/treehub/api/v3/config
  curl -v http://api.example.com/repo/api/v1/user_repo/root.json

  # Now make sure they work with the "secure token":
  curl -H "Authorization: Bearer BadT0ken5" http://api.example.com/treehub/api/v3/config
  curl -H "Authorization: Bearer BadT0ken5" http://api.example.com/repo/api/v1/user_repo/root.json
~~~

The web interface will also now be secured with HTTP basic authentication.
The username is ignored, so you can enter anything into that value. The
password is `BadT0ken5`.

### Update credentials.zip

As a result of the URL changes, you now need to update your credentials.zip
used for building and signing images. You'll need to update these files:
~~~
  cd generated/ota-ce*

  # Be sure to set <ingress_dns_name> below to match your domain
  # tufrepo.url becomes:
  http://api.<ingress_dns_name>/repo/

  # treehub.json becomes:
  {
    "oauth2": {
      "server": "http://oauth2.<ingress_dns_name>",
      "client_id" : "7a455f3b-2234-43b5-9d13-7d8823494f21",
      "client_secret" : "OTbGcZx6my"
    },
    "ostree": {
        "server": "http://api.<ingress_dns_name>/treehub/api/v3/"
    }
  }

  # You can then update your credentials.zip with:
  zip -u credentials.zip treehub.json tufrepo.url
~~~

### Next Steps

The remaining steps towards an actual secure server are organization
specific. You'll need to first update your Nginx configuration to use
HTTPS and deploy it with matching SSL certificates. Then you'll need
replace the "oauthful" service with your own OAuth2 implementation.
