job "demo-webapp4" {
  datacenters = ["dc1"]

  group "demo" {
    count = 2

    task "server" {
      env {
        PORT    = "${NOMAD_PORT_http}"
        NODE_IP = "${NOMAD_IP_http}"
      }

      driver = "docker"

      config {
        image = "hashicorp/demo-webapp-lb-guide"
      }

      resources {
        network {
          mbits = 10
          port  "http"{}
        }
      }

      service {
        name = "demo-webapp4"
        port = "http"

        // test regex: https://regex101.com/r/qPKqS3/2
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.webapp4.rule=HostRegexp(`myapp.{domainWildCardRegex:[a-zA-Z0-9+.]+}`)",
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
