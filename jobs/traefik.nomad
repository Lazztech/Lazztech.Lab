job "traefik" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "service"

  group "traefik" {
    count = 1

    volume "acme" {
      type      = "host"
      read_only = false
      source    = "acme"
    }

    task "traefik" {
      driver = "docker"

      volume_mount {
        volume      = "acme"
        destination = "/acme"
        read_only   = false
      }

      config {
        image        = "traefik:v2.2"
        network_mode = "host"

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
      }

      template {
        data = <<EOF
[entryPoints]
    [entryPoints.http]
    address = ":80"
    [entryPoints.https]
    address = ":443"
    [entryPoints.traefik]
    address = ":8081"

[accessLog]
[log]
  level = "DEBUG"
  filepath = "/var/log/traefik.log"

[certificatesResolvers.letsencrypt.acme]
  email = "gianlazzarini@gmail.com"
  storage = "acme.json"
  [certificatesResolvers.letsencrypt.acme.httpChallenge]
    # used during the challenge
    entryPoint = "http"

[api]
    dashboard = true
    insecure  = true

# Enable Consul Catalog configuration backend.
[providers.consulCatalog]
    prefix           = "traefik"
    exposedByDefault = false

    [providers.consulCatalog.endpoint]
      # https://docs.docker.com/docker-for-mac/networking/#use-cases-and-workarounds
      address = "127.0.0.1:8500"
      scheme  = "http"
EOF

        destination = "local/traefik.toml"
      }

      resources {
        cpu    = 100
        memory = 128

        network {
          mbits = 10

          port "http" {
            static = 80
          }
          port "https" {
            static = 443
          }
          port "api" {
            static = 8081
          }
        }
      }

      service {
        name = "traefik"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.api.rule=Host(`traefik.lazz.tech`, `traefik.localhost`)",
          "traefik.http.routers.api.entrypoints=https",
          "traefik.http.routers.api.service=api@internal",
          "traefik.http.routers.api.tls=true",
          "traefik.http.routers.api.tls.certresolver=letsencrypt",
          "traefik.http.routers.api.middlewares=authelia@docker",
        ]

        check {
          name     = "alive"
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
