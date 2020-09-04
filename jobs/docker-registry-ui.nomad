// docker run \
// -d \
// -p 80:80 \
// -e URL=http://127.0.0.1:5000 \
// -e DELETE_IMAGES=true \ 
// joxit/docker-registry-ui:static

job "docker-registry-ui" {
  datacenters = ["dc1"]
  type = "service"

  group "registry" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300
    }
    task "docker-registry-ui" {
      driver = "docker"
      env {
        "URL" = "http://registry.localhost:8080/"
        "DELETE_IMAGES" = "true"
      }
      config {
        image = "joxit/docker-registry-ui:static"
        port_map {
          http = 80
        }
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
        name = "docker-registry-ui"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.docker-registry-ui.rule=HostRegexp(`registry-ui.lazz.tech`)"
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
