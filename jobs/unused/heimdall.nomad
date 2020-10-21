// https://hub.docker.com/r/linuxserver/heimdall/
// docker create \
//   --name=heimdall \
//   -e PUID=1000 \
//   -e PGID=1000 \
//   -e TZ=Europe/London \
//   -p 80:80 \
//   -p 443:443 \
//   -v /path/to/appdata/config:/config \
//   --restart unless-stopped \
//   linuxserver/heimdall

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
      env {
        "PUID" = "1000"
        "PGID" = "1000"
        "TZ" = "America/Los_Angeles"
      }
      config {
        image = "linuxserver/heimdall"
        port_map {
          http = 80
          https = 443
        }
        volumes = [
          "heimdall/config:/config" # Contains all relevant configuration files.
        ]
      }
      resources {
        cpu    = 250 # 250 MHz
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
          "traefik.http.routers.heimdall.rule=HostRegexp(`heimdall.lazz.tech`)"
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
