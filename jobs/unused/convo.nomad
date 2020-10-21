// https://convos.chat/
// docker run -it -p 8080:3000 \
//   -v $HOME/convos/data:/data \
//   nordaaker/convos:stable

job "convo" {
  datacenters = ["dc1"]
  type = "service"
  
  group "convo" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "convo" {
      driver = "docker"
      // env {
      //   "PUID" = "1000"
      //   "PGID" = "1000"
      //   "TZ" = "America/Los_Angeles"
      // }
      config {
        image = "nordaaker/convos:stable"
        port_map {
          http = 3000
        }
        volumes = [
          "convo/data:/data", # Contains all relevant configuration files.
          "convo/themes:/data/themes"
        ]
      }
      // artifact {
      //   source      = "https://raw.githubusercontent.com/Nordaaker/convos/master/public/themes/hacker.css"
      //   destination = "convo/themes/hacker.css"
      //   mode        = "file"
      // }
      resources {
        cpu    = 250 # 250 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "http" {}
        }
      }
      service {
        name = "convo"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.convo.rule=Host(`chat.lazz.tech`)",
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
