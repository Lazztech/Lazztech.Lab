# Lazztech.Infrastructure

## Description
This makes use of the Hashicorp stack of technologies for IaC(Infrastructure as Code) provisioning.
- https://www.hashicorp.com/
- https://en.wikipedia.org/wiki/Infrastructure_as_code

## Setup
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

## Local Nomad Vagrant VM


```bash
# https://sourabhbajaj.com/mac-setup/Vagrant/README.html

# Install Virtualbox
brew cask install virtualbox
# Install Vagrant
brew cask install vagrant
```

```bash
# https://learn.hashicorp.com/tutorials/nomad/get-started-install?in=nomad/get-started#vagrant-setup-optional

# Start Development VM
vagrant up
vagrant ssh
nomad agent -dev -bind 0.0.0.0
```

```bash
# From Mac OS host machine
open http://localhost:4646/
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