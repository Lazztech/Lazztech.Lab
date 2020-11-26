// https://hub.docker.com/r/linuxserver/jellyfin
// docker run -d \
//   --name=jellyfin \
//   -e PUID=1000 \
//   -e PGID=1000 \
//   -e TZ=Europe/London \
//   -e UMASK_SET=<022> `#optional` \
//   -p 8096:8096 \
//   -p 8920:8920 `#optional` \
//   -p 7359:7359/udp `#optional` \
//   -p 1900:1900/udp `#optional` \
//   -v /path/to/library:/config \
//   -v /path/to/tvseries:/data/tvshows \
//   -v /path/to/movies:/data/movies \
//   -v /opt/vc/lib:/opt/vc/lib `#optional` \
//   --device /dev/dri:/dev/dri `#optional` \
//   --device /dev/vcsm:/dev/vcsm `#optional` \
//   --device /dev/vchiq:/dev/vchiq `#optional` \
//   --device /dev/video10:/dev/video10 `#optional` \
//   --device /dev/video11:/dev/video11 `#optional` \
//   --device /dev/video12:/dev/video12 `#optional` \
//   --restart unless-stopped \
//   ghcr.io/linuxserver/jellyfin

job "jellyfin" {
  datacenters = ["dc1"]
  type = "service"

  group "jellyfin" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "jellyfin" {
      driver = "docker"
      env {
        PUID="1000"
        PGID="1000"
        TZ="America/Los_Angeles"
      }
      config {
        image = "linuxserver/jellyfin"
        port_map {
          http = 8096
        }
        volumes = [
          "/opt/jellyfin/library:/config", # Contains all relevant configuration files.
          "/opt/jellyfin/tvseries:/data/tvshows",
          "/opt/jellyfin/movies:/data/movies"
        ]
        // devices = [
        //   {
        //     host_path = "/dev/ttyUSB0"
        //     container_path = "/dev/ttyUSB0"
        //   }
        // ]
      }
      resources {
        cpu    = 250 # 250 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "http" { }
        }
      }

      service {
        name = "jellyfin"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.jellyfin.rule=Host(`jellyfin.lazz.tech`)",
          "traefik.http.routers.jellyfin.tls.certresolver=cloudflare"
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
