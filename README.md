# Lazztech.Infrastructure

## Description
This makes use of the Hashicorp stack of technologies for IaC(Infrastructure as Code) provisioning.
- https://www.hashicorp.com/
- https://en.wikipedia.org/wiki/Infrastructure_as_code

## WIP: Local Setup -- Broken
*For Mac*

```bash
# https://brew.sh/

# Install Brew Package Manger
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

```bash
# Install Nomad: https://learn.hashicorp.com/tutorials/nomad/get-started-install?in=nomad/get-started
brew install nomad
# Install Consul:
brew install consul
```

```bash
# Start Nomad in Dev Mode:
sudo nomad agent -dev
# Start Consul in Dev Mode:
sudo consul agent -dev -bind 127.0.0.1
```

```
# Open Nomad UI
open http://localhost:4646/
# Open Consul UI
open http://localhost:8500/
```

## WIP: Local Vagrant VM Setup -- Working
*For Mac*

```bash
# https://sourabhbajaj.com/mac-setup/Vagrant/README.html

# Install Virtualbox
MacBook:Lazztech.Infrastructure me$ brew cask install virtualbox
# Install Vagrant
MacBook:Lazztech.Infrastructure me$ brew cask install vagrant
```

```bash
# https://learn.hashicorp.com/tutorials/nomad/get-started-install?in=nomad/get-started#vagrant-setup-optional

# Start Development VM
MacBook:Lazztech.Infrastructure me$ vagrant up
# SSH Into VM
MacBook:Lazztech.Infrastructure me$ vagrant ssh
# From VM
# Start Nomad in Dev Mode
vagrant@nomad:~$ nomad agent -dev -bind 0.0.0.0
```

```bash
# From Mac OS host machine
# Check Nomad Status
MacBook:Lazztech.Infrastructure me$ nomad status
# Test Nomad UI
MacBook:Lazztech.Infrastructure me$ nomad ui
# Start Demo WebApp Job
MacBook:Lazztech.Infrastructure me$ nomad job run jobs/webapp.nomad
# Start Traefik Job
MacBook:Lazztech.Infrastructure me$ nomad job run jobs/traefik.nomad 
# Open Traefik UI
MacBook:Lazztech.Infrastructure me$ open http://localhost:8081
# Open Traefik Route to Demo WebApp Job
MacBook:Lazztech.Infrastructure me$ open http://localhost:8080/myapp
```

## Azure Nomad Cluster

## Nomad Jobs
- [Traefik](https://containo.us/traefik/)
    - https://learn.hashicorp.com/tutorials/nomad/load-balancing-traefik
- [VSCode Server](https://coder.com/)
- [Docker Registry](https://docs.docker.com/registry/deploying/)
- [Home-Assistant](https://www.home-assistant.io/)
- [Homebridge](https://homebridge.io/)
- [Heimdall](https://heimdall.site/)

## Resources
- https://docs.diladele.com/docker/timezones.html
- https://github.com/hashicorp/nomad/tree/master/terraform#provision-a-nomad-cluster-in-the-cloud
- https://github.com/hashicorp/nomad/pull/7164
- https://learn.hashicorp.com/tutorials/nomad/load-balancing-traefik
- https://learn.hashicorp.com/collections/nomad/get-started
- https://learn.hashicorp.com/tutorials/consul/get-started-explore-the-ui
- https://github.com/docker/compose/issues/3800
    - https://github.com/docker/compose/issues/3800#issuecomment-285271175