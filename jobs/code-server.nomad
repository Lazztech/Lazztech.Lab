# https://hub.docker.com/r/linuxserver/code-server
// docker create \
//   --name=code-server \
//   -e PUID=1000 \
//   -e PGID=1000 \
//   -e TZ=Europe/London \
//   -e PASSWORD=password `#optional` \
//   -e SUDO_PASSWORD=password `#optional` \
//   -e PROXY_DOMAIN=code-server.my.domain `#optional` \
//   -p 8443:8443 \
//   -v /path/to/appdata/config:/config \
//   --restart unless-stopped \
//   linuxserver/code-server

job "code-server" {
  datacenters = ["dc1"]
  type = "service"
  
  group "code-server" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "code-server" {
      driver = "docker"
      env {
        "PUID" = "1000"
        "PGID" = "1000"
        "TZ" = "America/Los_Angeles"
      }
      config {
        image = "linuxserver/code-server"
        port_map {
          http = 8443
        }
        volumes = [
          "/opt/code-server/config:/config" # Contains all relevant configuration files.
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
        name = "code-server"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.code-server.rule=Host(`code.lazz.tech`)",
          "traefik.http.routers.code-server.tls.certresolver=cloudflare"
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
