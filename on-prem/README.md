# On Prem

## HP Microserver Gen 8
- appears to already have grub boot usb drive setup
    - http://blog.thestateofme.com/2015/01/21/howto-factory-reset-ilo-4-on-hp-microserver-gen8/
- installing new os requires inserting live usb and rebooting. thats it.
- ubuntu 20 lts minimal desktop install

---

- ### linux nomad install
- nomad server.hcl example
- nomad client1.hcl example
- with non-dev setup containers are accessible outside the machines localhost
- ### linux docker install
  - https://www.nomadproject.io/docs/drivers/docker.html#client-requirements
- docker user group permissions
  - sudo usermod -G docker -a nomad

- ### setup traefik
- traefik.nomad container based job works

- ### linux consul install
```bash
$ sudo mkdir /etc/consul.d
$ sudo chmod a+w /etc/consul.d
$ consul agent \
  -server \
  -bootstrap-expect=1 \
  -node=agent-one \
  -data-dir=/tmp/consul \
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
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
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
$ sudo mkdir --parents /etc/vault.d
# create dir for vault data
$ sudo mkdir -p /etc/vault.d/data
# create and enter vault config file
$ sudo tee /etc/vault.d/vault.hcl <<EOF
ui = true
disable_mlock = true

storage "raft" {
  path    = "/etc/vault.d/data"
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
```
# systemctl status vault output should look like
gian@gian-ProLiant-MicroServer-Gen8:/etc/vault.d$ sudo systemctl status vault
● vault.service - "HashiCorp Vault - A tool for managing secrets"
     Loaded: loaded (/etc/systemd/system/vault.service; enabled; vendor preset: enabled)
     Active: activating (auto-restart) (Result: exit-code) since Mon 2020-09-28 20:36:47 PDT; 3s ago
       Docs: https://www.vaultproject.io/docs/
    Process: 98690 ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl (code=exited, status=203/EXEC)
   Main PID: 98690 (code=exited, status=203/EXEC)
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