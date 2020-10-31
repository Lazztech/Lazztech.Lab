// https://github.com/statping/statping/wiki/Docker
// docker run -d \
//   -p 8080:8080 \
//   -v /mydir/statping:/app \
//   --restart always \
//   statping/statping

job "statping" {
  datacenters = ["dc1"]
  type = "service"
  
  group "statping" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "statping" {
      driver = "docker"
      config {
        image = "statping/statping"
        port_map {
          http = 8080
        }
        volumes = [
          "/opt/statping/app:/app" # Contains all relevant configuration files.
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
        name = "statping"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.statping.rule=Host(`status.lazz.tech`)",
          "traefik.http.routers.statping.tls.certresolver=cloudflare"
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
