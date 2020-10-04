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

- ### setup vault
  - https://learn.hashicorp.com/tutorials/vault/getting-started-install
  - https://www.42.mach7x.com/2020/08/11/error-initializing-storage-of-type-raft-failed-to-create-fsm-failed-to-open-bolt-file-open-home-vault-data-vault-db-permission-denied/
  - https://learn.hashicorp.com/tutorials/vault/raft-deployment-guide?in=vault/day-one-raft
```bash
# Installing Vault
# add repo
$ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
# add repo
$ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
# update & install
$ sudo apt-get update && sudo apt-get install vault
# test install
$ vault
```

```bash
# Deploying Vault

# create & configure systemd vault service
$ sudo tee /etc/systemd/system/vault.service <<EOF
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitInterval=60
StartLimitIntervalSec=60
StartLimitBurst=3
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF
# verify systemd service file content
$ sudo cat /etc/systemd/system/vault.service

# create vault config dir
$ sudo mkdir /opt/raft
# create dir for vault data
$ sudo chown -R vault:vault /opt/raft
# create and enter vault config file
$ sudo tee /etc/vault.d/vault.hcl <<EOF
ui = true
disable_mlock = true

storage "raft" {
  path    = "/opt/raft"
  node_id = "node1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr = "http://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
EOF
# verify vault config file
$ sudo cat /etc/vault.d/vault.hcl
# set the ownership of the /etc/vault.d directory
$ sudo chown --recursive vault:vault /etc/vault.d
# set file permissions
$ sudo chmod 640 /etc/vault.d/vault.hcl

# enable vault systemctl service
$ sudo systemctl enable vault
# start vault service
$ sudo systemctl start vault
# check status of vault service
$ sudo systemctl status vault
```

```bash
# systemctl status vault output should look like this:
● vault.service - "HashiCorp Vault - A tool for managing secrets"
     Loaded: loaded (/etc/systemd/system/vault.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2020-09-29 20:11:48 PDT; 7min ago
       Docs: https://www.vaultproject.io/docs/
   Main PID: 1951208 (vault)
      Tasks: 8 (limit: 11833)
     Memory: 12.3M
     CGroup: /system.slice/vault.service
             └─1951208 /usr/bin/vault server -config=/etc/vault.d/vault.hcl

Sep 29 20:11:48 gian-ProLiant-MicroServer-Gen8 vault[1951208]:                  Version: Vault v1.5.4

# to see logs for troubleshooting incase of problems, then scroll up or down
$ journalctl -u vault
# or
$ journalctl -u vault | cat
```
- open http://vault-ui.lazz.tech/
- Create a new Raft cluster & click next
- enter 5 in the Key shares and 3 in the Key threshold text fields, then click initialize
- download keys then click continue to unseal
- open download, copy one of the keys (not keys_base64) 
- enter it in the Master Key Portion field. Click Unseal to proceed.
- repeat the process for two more keys
- copy the root_token and enter its value in the Token field. Click Sign in.
- Setup vault/nomad integration https://learn.hashicorp.com/tutorials/nomad/vault-postgres?in=nomad/integrate-vault#write-a-policy-for-nomad-server-tokens

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


## UDM

**UDM DNS/HOSTS CONFIG:**
- https://community.ui.com/questions/UDM-UDMPro-Is-it-possible-to-redirect-Hard-coded-DNS-request-by-clients/00088d27-c8b0-42fa-9665-71988d7dbd15
```
$ ssh root@192.168.1.1

# echo "192.168.1.11 my.dns.name" >> /etc/hosts

# pkill -HUP dnsmasq  # tell dnsmasq to reload the hosts file

# nslookup my.dns.name  # confirm the address has been mapped as you expect
Name:      my.dns.nz
Address 1: 192.168.1.11 my.dns.name
```
- https://community.ui.com/questions/UDM-DNS-Configuration/cb79f4ad-04c1-47a2-b3cc-6d3739426bf1
- https://community.ui.com/questions/Dream-Machine-Host-Names/111bd201-e2d0-454e-b592-5b2332492cdd
- https://www.reddit.com/r/Ubiquiti/comments/d9dd8p/udm_pihole/
- https://www.reddit.com/r/Ubiquiti/comments/fw6whf/udm_pro_redirect_all_dns_queries_through_pihole/
- Potentially helpful:
  - https://github.com/wicol/unifi-dns