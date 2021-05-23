# On Prem
Dev journal and documentation on my home server setup.

### Directories:
The ".d" directories are a linux convention for holding configuration files. Typically these are stored like "/etc/asdf.d".
The systemd directory is used for systemctl service configurations. These allow "services" which are executable code to be kept alive with automatic restart/startup.
This setup depends on a combination of a few core systemctl/systemd services to be running.

All assumed to be in /etc/ directory:
- consul.d/ # Configurations for setting up Consul service discovery service
  - consul.hcl # used by consul via the --config arg
- dnsmasq.d/ # Configurations for setting up DNS via dnsmasq
  - > "Dnsmasq is typically configured via a dnsmasq.conf or a series of files in the /etc/dnsmasq.d directory. In Dnsmasq's configuration file (e.g. /etc/dnsmasq.d/10-consul)"
  - https://learn.hashicorp.com/tutorials/consul/dns-forwarding#dnsmasq-setup
  - consul.conf # used to configure dnsmasq to work in conjunction with consul service discovery. This allows services in nomad jobs to connect to each other.
- nomad.d/
  - needs to be documented...
- vault.d/
  - needs to be documented...
- systemd/
  - network/
    - needs to be documented...
  - system/
    - vault.service # systemd/systemctl vault service configuration file



## HP Microserver Gen 8

### Machine Specs:
- Intel Celeron, dual core @ 2.5 GHz
- 10Gb EMMC DDR Ram
- 1x 2tb HP 3.5 inch spinning rust
- ubuntu 20 lts minimal desktop
- Boot drive setup for booting right to usb?
  - appears to already have grub boot usb drive setup
  - http://blog.thestateofme.com/2015/01/21/howto-factory-reset-ilo-4-on-hp-microserver-gen8/
  - installing new os requires inserting live usb and rebooting. thats it.

---

Setup notes:

- ### linux nomad setup
- nomad server.hcl example
- nomad client1.hcl example
- with non-dev or binding 0.0.0.0 setup containers are accessible outside the machines localhost

```bash
# setup example server.hcl
$ tee server.hcl <<EOF
# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/tmp/server1"

# Give the agent a unique name. Defaults to hostname
name = "server1"

# Enable the server
server {
  enabled = true

  # Self-elect, should be 3 or 5 for production
  bootstrap_expect = 1
}

# For Prometheus metrics
telemetry {
  collection_interval = "1s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}
EOF
# setup example client1.hcl
$ tee client1.hcl <<EOF
# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/tmp/client1"

# Give the agent a unique name. Defaults to hostname
name = "client1"

# Enable the client
client {
    enabled = true

    # For demo assume we are talking to server1. For production,
    # this should be like "nomad.service.consul:4647" and a system
    # like Consul used for service discovery.
    servers = ["127.0.0.1:4647"]

    host_volume "acme" {
        path = "/acme"
        read_only = false
    }
}

# For Prometheus metrics
telemetry {
  collection_interval = "1s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}

ports {
    http = 4646
}

plugin "docker" {
        config {
                allow_caps = ["ALL"]
        }
}
EOF
# start server
$ nomad agent -config server.hcl
# start client
$ sudo nomad agent -config client1.hcl
# deploying jobs remotely 
$ nomad job run -address=http://192.168.1.11:4646 jobs/homer.nomad
```

- ### linux docker install
  - https://www.nomadproject.io/docs/drivers/docker.html#client-requirements
- docker user group permissions
  - sudo usermod -G docker -a nomad

- ### setup traefik
- traefik.nomad container based job works

- ### linux consul install
```bash
$ sudo mkdir /etc/consul.d
$ sudo tee /etc/consul.d/consul.hcl <<EOF
# Full configuration options can be found at https://www.consul.io/docs/agent/options.html

# data_dir
# This flag provides a data directory for the agent to store state. This is required
# for all agents. The directory should be durable across reboots. This is especially
# critical for agents that are running in server mode as they must be able to persist
# cluster state. Additionally, the directory must support the use of filesystem
# locking, meaning some types of mounted folders (e.g. VirtualBox shared folders) may
# not be suitable.
data_dir = "/opt/consul"

# client_addr
# The address to which Consul will bind client interfaces, including the HTTP and DNS
# servers. By default, this is "127.0.0.1", allowing only loopback connections. In
# Consul 1.0 and later this can be set to a space-separated list of addresses to bind
# to, or a go-sockaddr template that can potentially resolve to multiple addresses.
client_addr = "0.0.0.0"

# ui
# Enables the built-in web UI server and the required HTTP routes. This eliminates
# the need to maintain the Consul web UI files separately from the binary.
ui = true

# bootstrap
# This flag is used to control if a server is in "bootstrap" mode.
# It is important that no more than one server per datacenter be running in this mode.
# Technically, a server in bootstrap mode is allowed to self-elect as the Raft leader.
# It is important that only a single node is in this mode; otherwise, consistency
# cannot be guaranteed as multiple nodes are able to self-elect. It is not recommended
# to use this flag after a cluster has been bootstrapped.
#bootstrap=true

# server
# This flag is used to control if an agent is in server or client mode. When provided,
# an agent will act as a Consul server. Each Consul cluster must have at least one
# server and ideally no more than 5 per datacenter. All servers participate in the Raft
# consensus algorithm to ensure that transactions occur in a consistent, linearizable
# manner. Transactions modify cluster state, which is maintained on all server nodes to
# ensure availability in the case of node failure. Server nodes also participate in a
# WAN gossip pool with server nodes in other datacenters. Servers act as gateways to
# other datacenters and forward traffic as appropriate.
#server = true
EOF
$ sudo chmod a+w /etc/consul.d
$ consul agent \
  -server \
  -bootstrap-expect=1 \
  -node=agent-one \
  -data-dir=/tmp/consul \
  -bind 192.168.1.11 \
  -config-dir=/etc/consul.d
```
- ### setup wireguard vpn
  - add `allow_caps = ["ALL"]` to nomad client.hcl plugin "docker" config
- ### setup ssh
  - https://linuxconfig.org/enable-ssh-on-ubuntu-20-04-focal-fossa-linux
```bash
$ sudo apt install ssh
$ sudo systemctl enable --now ssh
$ sudo systemctl status ssh
```

```bash
$ ssh gian@192.168.1.11
```
- setup host path for dokuwiki volume
```bash
$ sudo mkdir -p /opt/dokuwiki/
```

- ### setup consul dns
- https://www.server-world.info/en/note?os=Ubuntu_20.04&p=dnsmasq&f=1
- https://askubuntu.com/questions/191226/dnsmasq-failed-to-create-listening-socket-for-port-53-address-already-in-use
- https://askubuntu.com/questions/500162/how-do-i-restart-dnsmasq
- https://www.linuxuprising.com/2020/07/ubuntu-how-to-free-up-port-53-used-by.html
- https://discuss.hashicorp.com/t/dns-forwarding-using-systemd-resolved-on-aws-ubuntu-minimal-18-04/1656
- https://stackoverflow.com/questions/41247817/consul-set-up-without-docker-for-production-use
- https://www.findip-address.com/169.254.1.1
- https://serverfault.com/questions/118324/what-is-a-link-local-address

```bash
# check if anything is listening to the dns port 53 (domain)
# it will most likely be systemd-resolved
$ sudo ss -lp "sport = :domain"
# disable systemd-resolved service
$ sudo systemctl disable systemd-resolved
$ sudo systemctl mask systemd-resolved
# stop currently running systemd-resolved service
$ sudo systemctl stop systemd-resolved
# install dnsmasq and allow service to be started
$ sudo apt install dnsmasq
# create directory
$ sudo mkdir /etc/dnsmasq.d
# pipe value into consul.conf file in the newly created dir
$ sudo tee /etc/dnsmasq.d/consul.conf <<EOF
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
listen-address=127.0.0.1
listen-address=169.254.1.1
EOF
# verify content
$ cat /etc/dnsmasq.d/consul.conf
# restart dnsmasq
$ systemctl restart dnsmasq
# check dnsmasq service status
$ systemctl status dnsmasq
```

### nomad systemd service
- https://learn.hashicorp.com/tutorials/nomad/production-deployment-guide-vm-with-consul#configure-systemd
```bash
# create nomad service file
$ sudo touch /etc/systemd/system/nomad.service
# add content to nomad service file
$ sudo tee /etc/systemd/system/nomad.service <<EOF
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/bin/nomad agent -config /etc/nomad.d
KillMode=process
KillSignal=SIGINT
LimitNOFILE=infinity
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
StartLimitBurst=3
StartLimitIntervalSec=10
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF

# make nomad data dir
$ sudo mkdir --parents /opt/nomad

# common configuration
$ sudo mkdir --parents /etc/nomad.d
$ sudo chmod 700 /etc/nomad.d
$ sudo touch /etc/nomad.d/nomad.hcl
# Note: Replace the datacenter parameter value with the identifier you will use for the datacenter this Nomad cluster is deployed in.
$ sudo tee /etc/nomad.d/nomad.hcl <<EOF
# common configurations for both server(s) and client(s)
datacenter = "dc1"
data_dir = "/opt/nomad"
EOF

# server configuration
$ sudo touch /etc/nomad.d/server.hcl
$ sudo tee /etc/nomad.d/server.hcl <<EOF
# Increase log verbosity
log_level = "DEBUG"

# Give the agent a unique name. Defaults to hostname
name = "server1"

# Enable the server
server {
  enabled = true

  # Self-elect, should be 3 or 5 for production
  bootstrap_expect = 1
}

# For Prometheus metrics
telemetry {
  collection_interval = "1s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}
EOF

# client configuration
$ sudo touch /etc/nomad.d/client.hcl
$ sudo tee /etc/nomad.d/client.hcl <<EOF
# Increase log verbosity
log_level = "DEBUG"

# Give the agent a unique name. Defaults to hostname
name = "client1"

# Enable the client
client {
    enabled = true

    # For demo assume we are talking to server1. For production,
    # this should be like "nomad.service.consul:4647" and a system
    # like Consul used for service discovery.
    servers = ["127.0.0.1:4647"]

  host_volume "acme" {
    path     = "/acme"
    read_only = false
  }
}

# For Prometheus metrics
telemetry {
  collection_interval = "1s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}

ports {
    http = 4646
}

plugin "docker" {
  config {
    allow_caps = ["ALL"]
  }
}
EOF

# enable nomad systemd service
$ sudo systemctl enable nomad
# start nomad systemd service
$ sudo systemctl start nomad
# check status of nomad systemd service
$ sudo systemctl status nomad
```

### consul systemd service
- https://learn.hashicorp.com/tutorials/consul/deployment-guide
```bash
# Create a unique, non-privileged system user to run Consul and create its data directory.
$ sudo useradd --system --home /etc/consul.d --shell /bin/false consul

# create consul data directory
$ sudo mkdir --parents /opt/consul
$ sudo chown --recursive consul:consul /opt/consul

$ sudo mkdir --parents /etc/consul.d
$ sudo touch /etc/consul.d/consul.hcl
$ sudo chown --recursive consul:consul /etc/consul.d
$ sudo chmod 640 /etc/consul.d/consul.hcl

# add content to consul.hcl configuration


# create and configure consul systemd service
$ sudo touch /etc/systemd/system/consul.service
$ sudo tee /etc/systemd/system/consul.service <<EOF
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
Type=notify
User=consul
Group=consul
ExecStart=/usr/bin/consul agent -server -bootstrap-expect=1 -node=agent-one -bind 192.168.1.11 -config-dir=/etc/consul.d/
ExecReload=/usr/bin/consul reload
ExecStop=/usr/bin/consul leave
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

$ sudo systemctl enable consul
$ sudo systemctl start consul
$ sudo systemctl status consul
```