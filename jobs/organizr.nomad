// https://hub.docker.com/r/organizr/organizr
// docker create \
//   --name=organizr \
//   -v <path to data>:/config \
//   -e PGID=<gid>  \
//   -e PUID=<uid>  \
//   -p 80:80 \
//   -e fpm="false" \ # optional
//   -e branch="v2-master" \ # optional
//   organizr/organizr

job "organizr" {
  datacenters = ["dc1"]
  type = "service"

  group "dashboard" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300
    }
    task "organizr" {
      driver = "docker"
      env {
        "PUID" = "1000"
        "PGID" = "1000"
        "fpm" = "false"
        "branch" = "v2-master"
      }
      config {
        image = "organizr/organizr"
        port_map {
          http = 80
        }
        volumes = [
          "organizr/config:/config" # Contains all relevant configuration files.
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
        name = "organizr"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.organizr.rule=HostRegexp(`organizr.lazz.tech`)"
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
