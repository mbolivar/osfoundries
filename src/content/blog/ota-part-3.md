+++
title = "Deploying OTA Community Edition"
date = "2018-06-27"
tags = ["ota", "open source"]
categories = ["FOTA"]
banner = "img/banners/ota.png"
author = "Andy Doan"
+++

Continuing with the OTA blog series [part one]({{< ref "ota-part-1.md" >}}) and [part two]({{< ref "ota-part-2.md" >}}), this article shows you how to deploy OTA Community Edition inside Google's Kubernetes Engine (GKE). After completion of these instructions, you'll have an OTA server available on the internet with a single QEMU device registered to it.
<!--more-->

### Requirements

You'll need a few things in place to be able to deploy this to GKE:

 * An account with the [Google Cloud Platform](https://console.cloud.google.com) (GCP).
 * A Project defined in your GCP account.
 * Git and Docker to run the deployment scripts.

It's also highly recommended that you are able to add DNS records to a domain you own. Otherwise, you'll have to edit /etc/hosts to access the services.

### Overview

OTA Community Edition deploys several [micro-services]({{< ref "ota-part-2.md" >}}) to Kubernetes. However, it doesn't come with any built-in security. The approach taken by this article is to expose the unsafe services via a single nginx reverse-proxy. This will make it obvious what services need to be locked down. Part four of the blog series will describe an approach for securing the reverse-proxy. When the deployment is completed, you'll have a system with these caveats:

 * **INSECURE** - Anyone can push to the TreeHub
 * **INSECURE** - Anyone can access and manage devices via the web application

Part 4 of the blog series will go into the details of securing everything.

### One-Time Only Steps

First get the OTA Community Edition source. This article relies on 3 out-of-tree patches to streamline the process:
~~~
  git clone -b ota-blog-part3 https://github.com/OpenSourceFoundries/ota-community-edition
  cd ota-community-edition

  # If you are curious about the out-of-tree patches:
  git log -3
~~~

OTA Community Edition has several dependencies that aren't easy to install. This article uses a container provided by the project to make things easier. If you have the tools installed locally you can always skip this step and call things like `kubectl` and `gcloud` directly.
~~~
  # Build the container:
  ./contrib/gke/docker-build.sh
~~~

With the container in place, you need to configure the `gcloud` tools to use your GCP project:
~~~
  EXTRA_ARGS="-it" ./contrib/gke/gcloud auth login
  ./contrib/gke/gcloud config set project <YOUR PROJECT>
  # You can use any GCP region you wish below
  ./contrib/gke/gcloud config set compute/zone us-central1-c
~~~

### Deploy OTA Community Edition

The ota-blog-part3 branch of OTA Community Edition includes a helper script to deploy OTA Community Edition. The script isn't very long and is worth taking a close look at to understand the mechanics of deploying OTA Community Edition. Deploying is as simple as:
~~~
  ./create-cluster.sh example.com
~~~

### Set up DNS

You now need DNS entries in place to access the OTA server. Add the following entries into your DNS management tool:
~~~
 # Get the IP of the nginx reverse-proxy:
 ./contrib/gke/kubectl get svc reverse-proxy

 # Point these entries at the reverse-proxy IP:
 tuf-reposerver.<DNS_NAME>, treehub.<DNS_NAME>, app.<DNS_NAME>

 # Get the IP of the device gateway:
 ./contrib/gke/kubectl get svc gateway-service
 # Point <SERVER_NAME> at this IP
~~~

If you don't have real DNS in place, you can hack your /etc/hosts with something like:
~~~
  # A quick entry generator for /etc/hosts:
 echo $(./contrib/gke/kubectl get svc reverse-proxy -o json | jq -r '.status.loadBalancer.ingress[0].ip')    treehub.<DNS_NAME> tuf-reposerver.<DNS_NAME>  app.<DNS_NAME>
~~~

As a sanity check, you can validate everything is working with:
~~~
  curl http://tuf-reposerver.<DNS_NAME>/api/v1/user_repo/targets.json
  curl http://treehub.<DNS_NAME>/api/v3/config
~~~

### Secure the TUF Keys

OTA Community Edition is running and exposed to the internet. The nginx reverse-proxy has no built-in security and the TUF private keys are available to **anyone**. This can be fixed even though the reverse-proxy has no authentication/authorization logic. In fact, it's a great example of how TUF protects you from the leaking of a private key. The ota-blog-part3 branch includes a script to make it easy:
~~~
  ./rotate-keys.sh example.com
~~~

### Upload an Image

[Uploading an image](https://app.foundries.io/docs/0.22/reference/linux-ota.html#upload-image-to-ats-garage) is a great way to validate the server is working and will be needed when you register a device:
~~~
  wget https://app.foundries.io/mp/lmp/0.22/artifacts/other-intel-corei7-64/other/intel-corei7-64-ostree_repo.tar.bz2
  tar -xf intel-corei7-64-ostree_repo.tar.bz2
  # if you hacked /etc/hosts then include "--network host"
  docker run --rm -it -v $PWD:/build --workdir=/build opensourcefoundries/aktualizr \
    ota-publish -m intel-corei7-64  -c ./credentials.zip -r ostree_repo
~~~

### Register a Device
OTA Community Edition requires [implicit provisioning](https://github.com/advancedtelematic/aktualizr/blob/master/docs/implicit-provisioning.adoc). Creating a device is fairly easy:
~~~
  # DEVICE_ID = The name of the device to appear in OTA Community Edition
  # SERVER_NAME = Your gateway server. eg SERVER_NAME=ota-ce.example.com
  ./contrib/gke/make SERVER_NAME=<SERVER_NAME> DEVICE_ID=<DEVICE_ID> SKIP_CLIENT=true new-client
~~~

Configuring your device is fairly simple. Remote access, however, isn't
always the same. Here are the files you'll need to copy to your device:

 * generated/`<SERVER_NAME>`/server_ca.pem to /var/sota/root.crt
 * generated/`<SERVER_NAME>`/devices/`<DEVICE_ID>`/client.pem /var/sota/client.pem
 * generated/`<SERVER_NAME>`/devices/`<DEVICE_ID>`/pkey.pem /var/sota/pkey.pem

If you haven't set up DNS entries, you'll need to add a line to
/etc/hosts on the target device. The public IP comes from the gateway-service:
~~~
  ./contrib/gke/kubectl get svc gateway-service -o json \
    | jq -r '.status.loadBalancer.ingress[0].ip'

  # /etc/hosts on target would get something like:
  ota-ce.example.com <ip-from-comand-above>
~~~

Finally create a /var/sota/sota.toml on your target device:
~~~
# /var/sota/sota.toml
[gateway]
http = true
socket = false

[network]
socket_commands_path = "/tmp/sota-commands.socket"
socket_events_path = "/tmp/sota-events.socket"
socket_events = "DownloadComplete, DownloadFailed"

[p11]
module = ""
pass = ""
uptane_key_id = ""
tls_ca_id = ""
tls_pkey_id = ""
tls_clientcert_id = ""

[tls]
server = "https://ota-ce.example.com:8443"
ca_source = "file"
pkey_source = "file"
cert_source = "file"

[provision]
server = "https://ota-ce.example.com:8443"
p12_password = ""
expiry_days = "36000"
provision_path = ""

[uptane]
polling = true
polling_sec = 10
device_id = ""
primary_ecu_serial = ""
# NOTE - this might need to change depending on your CPU
primary_ecu_hardware_id = "intel-corei7-64"
director_server = "https://ota-ce.example.com:8443/director"
repo_server = "https://ota-ce.example.com:8443/repo"
key_source = "file"

[pacman]
type = "ostree"
os = ""
sysroot = ""
ostree_server = "https://ota-ce.example.com:8443/treehub"
packages_file = "/usr/package.manifest"

[storage]
type = "filesystem"
path = "/var/sota/"
uptane_metadata_path = "metadata"
uptane_private_key_path = "ecukey.der"
uptane_public_key_path = "ecukey.pub"
tls_cacert_path = "root.crt"
tls_pkey_path = "pkey.pem"
tls_clientcert_path = "client.pem"

[import]
uptane_private_key_path = ""
uptane_public_key_path = ""
tls_cacert_path = "/var/sota/root.crt"
tls_pkey_path = ""
tls_clientcert_path = ""
~~~
