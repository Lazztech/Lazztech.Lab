# Lazztech.Infrastructure

## Description
This makes use of the Hashicorp stack of technologies for IaC(Infrastructure as Code) provisioning.
- https://www.hashicorp.com/
- https://en.wikipedia.org/wiki/Infrastructure_as_code

## Setting Hosts File
*For Mac*

```bash
$ sudo nano /etc/hosts
# add the line below
192.168.1.11    nomad.lazz.tech
192.168.1.11    traefik.lazz.tech
192.168.1.11    consul.lazz.tech
192.168.1.11    vault-ui.lazz.tech

192.168.1.11    code.lazz.tech
192.168.1.11    registry.lazz.tech
192.168.1.11    registry-ui.lazz.tech
192.168.1.11    home-assistant.lazz.tech
192.168.1.11    heimdall.lazz.tech
192.168.1.11    homebridge.lazz.tech
192.168.1.11    url.lazz.tech
192.168.1.11    urls.lazz.tech
192.168.1.11    trango.lazz.tech
192.168.1.11    wireguard.lazz.tech
192.168.1.11    wiki.lazz.tech
192.168.1.11    subspace.lazz.tech
```

```bash
# flush dns cache
$ sudo killall -HUP mDNSResponder
# flush chrome dns by opening the following as a url
chrome://net-internals/#dns
```

## WIP: Local Setup -- Working
*For Mac*

First install Docker for Mac:
- https://docs.docker.com/docker-for-mac/install/

```bash
# install brew package manger
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

```bash
# install nomad: https://learn.hashicorp.com/tutorials/nomad/get-started-install?in=nomad/get-started
$ brew install nomad
```

```bash
# start nomad in dev mode:
$ sudo nomad agent -dev -bind 0.0.0.0
# start consul raw-exec nomad job
$ nomad job run jobs/mac-exec/consul.nomad 
# start traefik raw-exec nomad job
$ nomad job run jobs/mac-exec/traefik.nomad
# start vault raw-exec nomad job
$ nomad job run jobs/mac-exec/vault.nomad
```

```bash
# open nomad ui
$ nomad ui
# open consul ui
$ open http://localhost:8500/
# open traefik ui
$ open http://127.0.0.1:8081/
# open vault ui
$ open http://127.0.0.1:8200/
```

```bash
# start example job 1
$ nomad job run jobs/examples/webapp1.nomad
# start example job 2
$ nomad job run jobs/examples/webapp2.nomad
# start example job 3
$ nomad job run jobs/examples/webapp3.nomad
# start example job 4
$ nomad job run jobs/examples/webapp4.nomad

# open traefik route to example job 1
$ open http://localhost:8080/myapp1
# open traefik route to example job 2
$ open http://localhost:8080/myapp2
# open traefik route to example job 3
$ open http://localhost:8080/myapp3
# open traefik route to example job 4
$ open http://myapp.localhost:8080/
```

## WIP: Local Vagrant VM Setup -- Working
*For Mac*

```bash
# https://sourabhbajaj.com/mac-setup/Vagrant/README.html

# install virtualbox
MacBook:Lazztech.Infrastructure me$ brew cask install virtualbox
# install vagrant
MacBook:Lazztech.Infrastructure me$ brew cask install vagrant
```

```bash
# https://learn.hashicorp.com/tutorials/nomad/get-started-install?in=nomad/get-started#vagrant-setup-optional

# start development vm
MacBook:Lazztech.Infrastructure me$ vagrant up
# ssh into vm
MacBook:Lazztech.Infrastructure me$ vagrant ssh
# from vm, start nomad in dev mod
vagrant@nomad:~$ nomad agent -dev -bind 0.0.0.0
```

```bash
# test nomad ui
MacBook:Lazztech.Infrastructure me$ nomad ui
# start traefik job
MacBook:Lazztech.Infrastructure me$ nomad job run jobs/traefik.nomad

# start example job 1
MacBook:Lazztech.Infrastructure me$ nomad job run jobs/examples/webapp1.nomad
# start example job 2
MacBook:Lazztech.Infrastructure me$ nomad job run jobs/examples/webapp2.nomad
# start example job 3
MacBook:Lazztech.Infrastructure me$ nomad job run jobs/examples/webapp3.nomad

# open traefik ui
MacBook:Lazztech.Infrastructure me$ open http://localhost:8081

# open traefik route to example job 1
MacBook:Lazztech.Infrastructure me$ open http://localhost:8080/myapp1
# open traefik route to example job 2
MacBook:Lazztech.Infrastructure me$ open http://localhost:8080/myapp2
# open traefik route to example job 3
MacBook:Lazztech.Infrastructure me$ open http://localhost:8080/myapp3
```

## WIP: On-Prem
*For Mac*

```bash
# start nomad server agent
$ nomad agent -config on-prem/server.hcl
# start nomad client agent 1
$ sudo nomad agent -config on-prem/client1.hcl
# start nomad client agent 2
$ sudo nomad agent -config on-prem/client2.hcl

# run nomad node status to verify the clients are up
$ nomad node status
ID        DC   Name     Class   Drain  Eligibility  Status
fca62612  dc1  client1  <none>  false  eligible     ready
c887deef  dc1  client2  <none>  false  eligible     ready
```

## Soon: Azure

## Nomad Jobs
- [Traefik](https://containo.us/traefik/)
- [Consul](https://www.hashicorp.com/products/consul/)
- [Vault](https://www.hashicorp.com/products/vault/)
- [VSCode Server](https://coder.com/)
- [Docker Registry](https://docs.docker.com/registry/deploying/)
- [Docker Registry UI](https://github.com/Joxit/docker-registry-ui)
- [Home-Assistant](https://www.home-assistant.io/)
- [Homebridge](https://homebridge.io/)
- [Heimdall](https://heimdall.site/)
- [Shlink](https://shlink.io/)
- [Shlink UI](https://shlink.io/documentation/shlink-web-client/)
- [WireGuard](https://www.wireguard.com/)
- [DokuWiki](https://www.dokuwiki.org/dokuwiki)
<!-- - [WireGuard UI](https://github.com/subspacecloud/subspace)
- [Authelia](https://www.authelia.com/) -->

**Watching**
- VPN
    - [Mistborn](https://gitlab.com/cyber5k/mistborn)
    - [Pritunl](https://pritunl.com/)
- Wiki
    - [Wiki.js](https://wiki.js.org/)
    - [Bookstack](https://www.bookstackapp.com/)
    - [Outline](https://github.com/outline/outline)
    - [TiddlyWiki](https://tiddlywiki.com/)
- Chat/Communication/Filesharing
    - [Trango](https://web.trango.io/)
    - [Mattermost](https://mattermost.com/)
- Storage
    - [Minio](https://min.io/)


## Resources

- https://docs.diladele.com/docker/timezones.html
- https://docs.traefik.io/routing/routers/
- https://regex101.com/
- https://containo.us/traefik/
- https://docs.traefik.io/https/acme/
- https://github.com/hashicorp/nomad/tree/master/terraform#provision-a-nomad-cluster-in-the-cloud
- https://github.com/hashicorp/nomad/pull/7164
- https://learn.hashicorp.com/tutorials/nomad/load-balancing-traefik
- https://learn.hashicorp.com/collections/nomad/get-started
- https://learn.hashicorp.com/tutorials/consul/get-started-explore-the-ui
- https://medium.com/hashicorp-engineering/hashicorp-nomad-from-zero-to-wow-1615345aa539
- https://github.com/docker/compose/issues/3800
    - https://github.com/docker/compose/issues/3800#issuecomment-285271175
- https://news.ycombinator.com/item?id=23243248
- https://www.reddit.com/r/selfhosted/comments/ajxtg3/a_simple_wireguard_vpn_server_gui/
- https://www.notion.so/Server-Configs-487708332a2a49b18fa345111b48de58
- https://github.com/codeday/containercfg

## Inspiration
- http://blog.codeday.org/hashicorp-nomad-howto
- https://www.reddit.com/r/selfhosted/
- https://www.reddit.com/r/homelab/
- https://www.reddit.com/r/startpages/
