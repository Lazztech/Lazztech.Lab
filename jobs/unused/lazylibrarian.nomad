// https://hub.docker.com/r/linuxserver/lazylibrarian
// docker create \
//   --name=lazylibrarian \
//   -e PUID=1000 \
//   -e PGID=1000 \
//   -e TZ=Europe/London \
//   -e DOCKER_MODS=linuxserver/calibre-web:calibre|linuxserver/mods:lazylibrarian-ffmpeg `#optional` \
//   -p 5299:5299 \
//   -v path to data:/config \
//   -v path to downloads:/downloads \
//   -v path to data:/books \
//   --restart unless-stopped \
//   linuxserver/lazylibrarian
//


job "lazylibrarian" {
  datacenters = ["dc1"]
  type = "service"
  
  group "lazylibrarian" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "lazylibrarian" {
      driver = "docker"
      env {
        "PUID" = "1000"
        "PGID" = "1000"
        "TZ" = "America/Los_Angeles"
        "DOCKER_MODS" = "linuxserver/calibre-web:calibre|linuxserver/mods:lazylibrarian-ffmpeg"
      }
      config {
        image = "linuxserver/lazylibrarian"
        port_map {
          http = 5299
        }
        volumes = [
          "data:/config", # Contains all relevant configuration files.
          "downloads:/downloads",
          "data:/books"
        ]
      }
      resources {
        cpu    = 250 # 250 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "http" {}
        }
      }
      service {
        name = "lazylibrarian"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.lazylibrarian.rule=Host(`lazylibrarian.lazz.tech`)",
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
