// https://docs.gitea.io/en-us/install-with-docker/
// services:
//   server:
//     image: gitea/gitea:latest
//     container_name: gitea
//     environment:
//       - USER_UID=1000
//       - USER_GID=1000
//     restart: always
//     networks:
//       - gitea
//     volumes:
//       - ./gitea:/data
//       - /etc/timezone:/etc/timezone:ro
//       - /etc/localtime:/etc/localtime:ro
//     ports:
//       - "3000:3000"
//       - "222:22"
job "gitea" {
  datacenters = ["dc1"]
  type = "service"
  
  group "gitea" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "gitea" {
      driver = "docker"
      env {
        "PUID" = "1000"
        "PGID" = "1000"
      }
      config {
        image = "gitea/gitea:latest"
        port_map {
          http = 3000
        }
        volumes = [
          "/opt/gitea:/data", # Contains all relevant configuration files.
          "/etc/timezone:/etc/timezone:ro",
          "/etc/localtime:/etc/localtime:ro"
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
        name = "gitea"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.gitea.rule=Host(`git.lazz.tech`)",
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
