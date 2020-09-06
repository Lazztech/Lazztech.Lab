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
          "local/providers.toml:/etc/traefik/providers.toml"
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
      address = "127.0.0.1:8500"
      scheme  = "http"
      
[providers.file]
    filename = "/etc/traefik/providers.toml"
EOF

        destination = "local/traefik.toml"
      }

      template {
        data = <<EOF
        [http.routers]
          [http.routers.nomad]
            service = "nomad"
            rule = "Host(`nomad.lazz.tech`)"
          [http.routers.vault]
            service = "vault"
            rule = "Host(`vault-ui.lazz.tech`)"
          [http.routers.consul]
            service = "consul"
            rule = "Host(`consul.lazz.tech`)"
    
        [http.services]
          [[http.services.nomad.loadBalancer.servers]]
            url = "http://127.0.0.1:4646/"
          [[http.services.consul.loadBalancer.servers]]
            url = "http://127.0.0.1:8500/"
          [[http.services.vault.loadBalancer.servers]]
            url = "http://127.0.0.1:8200/"
EOF
        destination = "local/providers.toml"
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
          "traefik.http.routers.api.rule=Host(`traefik.lazz.tech`)",
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
