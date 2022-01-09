# Local docker dev environment

This project aim to simplify local web development using docker containers. 
It contains necessary stuff to have a running local dev environment with your custom dev hostname

## Features 
* Automatic subdomain creation when docker containers start
* Secure by design with HTTPS support auto configuration
* Use Traefik with basic config done for you

## Example

You have a docker web dev project, all you need to do is to add some labels on the container(s) which will be exposed as a dedicated subdomain name. 
Automatically...

For example, we setup a local domain name that point to our localhost, like : `mylocaldomain.net` 
when everything is setup when you start a container named my-project_my-service, it will be accessible on this URL : `https://my-project_my-service.mylocaldomain.net`.

## How it works ?

To achieve this, we need some basic theory explanation. 

### Setup a domain name

First we need to have a domain name configured in a DNS server where we define a 'wildcard' A zone to point to our localhost.

You don't have one ? No problem with some extra configuration you can have a local only working DNS server using tools like dnsmasq.

### Use a reverse proxy

One we achieve that, we have request coming into our computer, but we need something that receive these requests and dispatch them to the right docker containers (and container port).
We use a well known reverse proxy for this purpose, called traefik, it will be shipped and configured as a docker container in this repo to ease config, all you have to do is to config some env vars and you are ready to go (look at the installation and configuration section)

So traefik will be configured with all automatic features that you can adjust later to your need with env vars or docker container labels.

### Run your container

So basically all you have to do is to run your container by adding them a docker label called `traefik.enable=true` in the service docker-compose file definition, then traefik will :
* Detect the container automatically
* Read its labels, if there is a label called traefik.enable wich is `true` then it will be reverse poxyfied
* Traefik automatically detect exposed port and use it, if your container expose multiple port you will need to tell traefik wich one to use

## Installation

Clone this repository, copy the .env.dist to .env then edit it.
Then you just need to launch `./setup.sh`this bash script will : 
* Generate a new Certificate authority
* Generate a default certificate signed with de previously generated Certificate authority
* Start traefik with defaut configuration so the generated certificate will be used

Then all you need to do is to add the generated Certificate Authority to be trusted in you web browser, you just need to do this once.

The filename to import in your webrowser is `ssl/ca.crt` don't forget to empty your browser cache !

Traefik will now auto start when docker start, please remember that traefik will listen to your host 80 and 443 port, these port need to be free.