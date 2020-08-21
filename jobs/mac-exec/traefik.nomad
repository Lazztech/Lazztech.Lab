job "traefik" {
  datacenters = ["dc1"]
  group "traefik" {
    count = 1
    task "traefik" {
      driver = "raw_exec"

      config {
        command = "traefik-folder/traefik"
        args    = ["--configFile=local/traefik-folder/traefik.toml"]
      }

      artifact {
        source      = "https://github.com/containous/traefik/releases/download/v2.2.0/traefik_v2.2.0_darwin_amd64.tar.gz"
        destination = "local/traefik-folder"
        mode        = "dir"
      }

      template {
        data = <<EOF
[entryPoints]
    [entryPoints.http]
    address = ":8080"
    [entryPoints.traefik]
    address = ":8081"

[api]
    dashboard = true
    insecure  = true

[accessLog]

# Enable Consul Catalog configuration backend.
[providers.consulCatalog]
    prefix           = "traefik"
    exposedByDefault = false

    [providers.consulCatalog.endpoint]
      address = "127.0.0.1:8500"
      scheme  = "http"
EOF

        destination = "local/traefik-folder/traefik.toml"
      }
    }
  }
}
