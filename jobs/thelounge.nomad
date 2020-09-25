// https://hub.docker.com/r/linuxserver/thelounge
// docker create \
//   --name=thelounge \
//   -e PUID=1000 \
//   -e PGID=1000 \
//   -e TZ=Europe/London \
//   -p 9000:9000 \
//   -v /path/to/appdata/config:/config \
//   --restart unless-stopped \
//   linuxserver/thelounge
// $ docker exec --user node -it [container_name] thelounge add MyUser

job "thelounge" {
  datacenters = ["dc1"]
  type = "service"
  
  group "thelounge" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "thelounge" {
      driver = "docker"
      env {
        "PUID" = "1000"
        "PGID" = "1000"
        "TZ" = "America/Los_Angeles"
      }
      config {
        image = "linuxserver/thelounge"
        port_map {
          http = 9000
        }
        volumes = [
          "thelounge/config:/config" # Contains all relevant configuration files.
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
        name = "thelounge"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.thelounge.rule=Host(`chat.lazz.tech`)",
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
