# docker run  \
# -e PUID=1000   \
# -e PGID=1000   \
# -e TZ=Europe/London \  
# -p 80:80 \
# -p 443:443 \
#  linuxserver/heimdall

job "heimdall" {
  datacenters = ["dc1"]
  type = "service"

  group "dashboard" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300
    }
    task "heimdall" {
      driver = "docker"
      config {
        image = "linuxserver/heimdall"
        port_map {
          http = 80
          https = 443
        }
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "http" {}
          port "https" {}
        }
      }
      service {
        name = "heimdall"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.heimdall.rule=HostRegexp(`heimdall.lazz.tech`, `home`)"
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
