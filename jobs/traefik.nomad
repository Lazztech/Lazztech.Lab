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
      env {
        CF_API_EMAIL="gianlazzarini@gmail.com"
        CF_API_KEY=""
      }
      // volume_mount {
      //   volume      = "acme"
      //   destination = "/acme"
      //   read_only   = false
      // }

      config {
        image        = "traefik:v2.2"
        network_mode = "host"

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
          "local/providers.toml:/etc/traefik/providers.toml",
          "/opt/traefik/acme:/acme"
        ]
      }

      template {
        data = <<EOF
[entryPoints]
    [entryPoints.http]
    address = ":80"
    [entryPoints.https]
    address = ":443"
    [entryPoints.mqtt]
    address = ":1883"
    [entryPoints.traefik]
    address = ":8081"

[serversTransport]
  insecureSkipVerify = "true"

[accessLog]
[log]
  level = "DEBUG"

# Needs to challenge domain name server to get wildcard ssl cert
[certificatesResolvers.cloudflare.acme]
  email = "gianlazzarini@gmail.com"
  storage = "acme/acme.json"
  [certificatesResolvers.cloudflare.acme.dnsChallenge]
    provider = "cloudflare"
    resolvers = ["1.1.1.1:53", "1.0.0.1:53"]

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
    [http.routers.nomad.tls]
      certresolver = "cloudflare"
  [http.routers.vault]
    service = "vault"
    rule = "Host(`vault-ui.lazz.tech`)"
    [http.routers.vault.tls]
      certresolver = "cloudflare"
  [http.routers.consul]
    service = "consul"
    rule = "Host(`consul.lazz.tech`)"
    [http.routers.consul.tls]
      certresolver = "cloudflare"

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
          "traefik.http.routers.traefik.entrypoints=http",
          "traefik.http.routers.traefik.rule=Host(`traefik.lazz.tech`)",
          "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme=https",
          "traefik.http.routers.traefik.middlewares=traefik-https-redirect",
          "traefik.http.routers.traefik-secure.entrypoints=https",
          "traefik.http.routers.traefik-secure.rule=Host(`traefik.lazz.tech`)",
          "traefik.http.routers.traefik-secure.tls=true",
          "traefik.http.routers.traefik-secure.tls.certresolver=cloudflare",
          "traefik.http.routers.traefik-secure.tls.domains[0].main=lazz.tech",
          "traefik.http.routers.traefik-secure.tls.domains[0].sans=*.lazz.tech",
          "traefik.http.routers.traefik-secure.service=api@internal",

          "traefik.http.routers.http-catchall.rule=hostregexp(`{host:.+}`)",
          "traefik.http.routers.http-catchall.entrypoints=http",
          "traefik.http.routers.http-catchall.middlewares=redirect-to-https@consulcatalog",
          "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
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
