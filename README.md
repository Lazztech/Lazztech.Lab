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
