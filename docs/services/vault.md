# Hashicorp Vault

This service is used for secret management and in turn is integrated with nomad for injecting secrets into nomad jobs.

### setup vault
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

## Using vault secrets
- https://medium.com/hashicorp-engineering/nomad-integration-with-vault-42b0e5feca78
- https://play.instruqt.com/hashicorp/tracks/nomad-integration-with-vault
- https://www.nomadproject.io/docs/job-specification/template#environment-variables
- https://www.nomadproject.io/docs/integrations/vault-integration

Download and write the nomad-server & nomad-cluster policies to vault:
- https://www.nomadproject.io/docs/integrations/vault-integration#example-configuration

```bash
# Download the policy and token role
$ curl https://nomadproject.io/data/vault/nomad-server-policy.hcl -O -s -L
$ curl https://nomadproject.io/data/vault/nomad-cluster-role.json -O -s -L

# Write the policy to Vault
$ vault policy write nomad-server nomad-server-policy.hcl

# Create the token role with Vault
$ vault write /auth/token/roles/nomad-cluster @nomad-cluster-role.json
```

Retrieve token role based token:
```bash
$ vault token create -policy nomad-server -period 72h -orphan
```


Add the following to /etc/nomad.d/nomad.hcl:
```
vault {
    enabled = true
    address = "http://active.vault.service.consul:8200"
    task_token_ttl = "1h"
    create_from_role = "nomad-cluster"
    token = "s.1gr0YoLyTBVZl5UqqvCfK9RJ"
}
```

Vault secrets can then be used by adding the policy with vault stanza:
```
      vault {
        policies = ["lazztechhub"]
      }
```
Then you can use the template stanza to inject secrets in as environment variables:
```
      template {
        data = <<EOF
{{- with secret "kv/data/lazztechhub-dev" -}}
ACCESS_TOKEN_SECRET={{ .Data.data.access_token_secret }}
{{ end }}
EOF
        destination = "secrets/file.env"
        env         = true
      }
```