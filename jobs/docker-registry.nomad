job "docker-registry" {
  datacenters = ["dc1"]
  type = "service"

  group "registry" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300
    }
    task "docker-registry" {
      driver = "docker"
      config {
        image = "registry:2"
        port_map {
          http = 5000
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
        name = "docker-registry"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.docker-registry.rule=HostRegexp(`registry.lazz.tech`)"

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
