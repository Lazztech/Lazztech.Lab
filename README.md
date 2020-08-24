# Lazztech.Infrastructure

## Description
This makes use of the Hashicorp stack of technologies for IaC(Infrastructure as Code) provisioning.
- https://www.hashicorp.com/
- https://en.wikipedia.org/wiki/Infrastructure_as_code

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

## Azure Nomad Cluster

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

## Resources

**Documentation:**
- https://docs.diladele.com/docker/timezones.html
- https://docs.traefik.io/routing/routers/
- https://regex101.com/
- https://containo.us/traefik/

**Articles:**
- https://github.com/hashicorp/nomad/tree/master/terraform#provision-a-nomad-cluster-in-the-cloud
- https://github.com/hashicorp/nomad/pull/7164
- https://learn.hashicorp.com/tutorials/nomad/load-balancing-traefik
- https://learn.hashicorp.com/collections/nomad/get-started
- https://learn.hashicorp.com/tutorials/consul/get-started-explore-the-ui
- https://github.com/docker/compose/issues/3800
    - https://github.com/docker/compose/issues/3800#issuecomment-285271175

**Media:**
