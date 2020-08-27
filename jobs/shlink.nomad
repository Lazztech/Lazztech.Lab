// https://shlink.io/documentation/install-docker-image/
// docker run \
//     --name my_shlink \
//     -p 8080:8080 \
//     -e SHORT_DOMAIN_HOST=doma.in \
//     -e SHORT_DOMAIN_SCHEMA=https \
//     -e GEOLITE_LICENSE_KEY=kjh23ljkbndskj345 \
//     shlinkio/shlink:stable

job "shlink" {
  datacenters = ["dc1"]
  type = "service"
  
  group "shlink" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "shlink" {
      driver = "docker"
      env {
        "SHORT_DOMAIN_HOST" = "localhost"
        "SHORT_DOMAIN_SCHEMA" = "http"
        "GEOLITE_LICENSE_KEY" = "kjh23ljkbndskj345"
      }
      config {
        image = "shlinkio/shlink:stable"
        port_map {
          http = 8080
        }
        volumes = [
          "shlink/config:/config" # Contains all relevant configuration files.
        ]
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "http" {}
        }
      }
      service {
        name = "shlink"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.shlink.rule=HostRegexp(`url.{domainWildCardRegex:[a-zA-Z0-9+.]+}`)"
        ]

        check {
          type     = "http"
          path     = "/"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
  }
}
