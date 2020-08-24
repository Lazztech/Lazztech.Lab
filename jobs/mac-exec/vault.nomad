job "vault" {
  datacenters = ["dc1"]
  group "vault" {
    count = 1
    task "vault" {
      driver = "raw_exec"
            
      config {
        command = "vault"
        args    = ["server", "-dev"]
      }
      artifact {
        source = "https://releases.hashicorp.com/vault/1.5.2/vault_1.5.2_darwin_amd64.zip"
      }
    }
  }
}