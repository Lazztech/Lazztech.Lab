job "demo-webapp2" {
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
        name = "demo-webapp2"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.myOtherHttpRouter.rule=PathPrefix(`/myapp2`)",
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
