// https://github.com/RobinLinus/snapdrop
// https://hub.docker.com/r/linuxserver/snapdrop
// docker create \
//   --name=snapdrop \
//   -e PUID=1000 \
//   -e PGID=1000 \
//   -e TZ=Europe/London \
//   -p 80:80 \
//   -p 443:443 \
//   -v path to config:/config \
//   --restart unless-stopped \
//   linuxserver/snapdrop

job "snapdrop" {
  datacenters = ["dc1"]
  type = "service"
  
  group "snapdrop" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "snapdrop" {
      driver = "docker"
      env {
        "PUID" = "1000"
        "PGID" = "1000"
        "TZ" = "America/Los_Angeles"
      }
      config {
        image = "linuxserver/snapdrop"
        port_map {
          http = 80
          https = 443
        }
        volumes = [
          "snapdrop/config:/config" # Contains all relevant configuration files.
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
        name = "snapdrop"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.snapdrop.rule=Host(`share.lazz.tech`)",
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
