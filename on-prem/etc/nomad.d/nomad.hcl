# common configurations for both server(s) and client(s)
datacenter = "dc1"
data_dir = "/opt/nomad"
#
bind_addr = "0.0.0.0"

vault {
    enabled = true
    address = "http://127.0.0.1:8200/"
    task_token_ttl = "1h"
    create_from_role = "nomad-cluster"
    token = "YOUR VAULT TOKEN HERE"
}