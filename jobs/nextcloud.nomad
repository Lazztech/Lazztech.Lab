// https://hub.docker.com/r/linuxserver/nextcloud/
// docker run -d \
//   --name=nextcloud \
//   -e PUID=1000 \
//   -e PGID=1000 \
//   -e TZ=Europe/London \
//   -p 443:443 \
//   -v /path/to/appdata:/config \
//   -v /path/to/data:/data \
//   --restart unless-stopped \
//   linuxserver/nextcloud
job "nextcloud" {
  datacenters = ["dc1"]
  type = "service"
  
  group "nextcloud" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "nextcloud" {
      driver = "docker"
      env {
        "PUID" = "1000"
        "PGID" = "1000"
        "TZ" = "America/Los_Angeles"
      }
      config {
        image = "linuxserver/nextcloud"
        port_map {
          https = 443
        }
        volumes = [
          "/opt/nextcloud/appdata:/config", # Contains all relevant configuration files.
          "/opt/nextcloud/data:/data"
        ]
      }
      resources {
        cpu    = 250 # 250 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "https" {}
        }
      }
      service {
        name = "nextcloud"
        port = "https"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.nextcloud.rule=Host(`nextcloud.lazz.tech`)",
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
