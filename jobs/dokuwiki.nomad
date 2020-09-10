// https://hub.docker.com/r/linuxserver/dokuwiki
// docker create \
//   --name=dokuwiki \
//   -e PUID=1000 \
//   -e PGID=1000 \
//   -e TZ=Europe/London \
//   -e APP_URL=/dokuwiki `#optional` \
//   -p 80:80 \
//   -p 443:443 `#optional` \
//   -v /path/to/appdata/config:/config \
//   --restart unless-stopped \
//   linuxserver/dokuwiki

job "dokuwiki" {
  datacenters = ["dc1"]
  type = "service"
  
  group "dokuwiki" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "dokuwiki" {
      driver = "docker"
      env {
        "PUID" = "1000"
        "PGID" = "1000"
        "TZ" = "America/Los_Angeles"
      }
      config {
        image = "linuxserver/dokuwiki"
        port_map {
          http = 80
        }
        volumes = [
          "dokuwiki/config:/config" # Contains all relevant configuration files.
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
        name = "dokuwiki"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.dokuwiki.rule=Host(`wiki.lazz.tech`)",
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
