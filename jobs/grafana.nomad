// https://hub.docker.com/r/grafana/grafana/
// https://grafana.com/docs/grafana/latest/installation/docker/
// docker run -d --name=grafana -p 3000:3000 grafana/grafana

job "grafana" {
  datacenters = ["dc1"]
  type = "service"
  
  group "grafana" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "grafana" {
      driver = "docker"
      
      config {
        image = "grafana/grafana"
        port_map {
          http = 8443
        }
        volumes = [
          "/opt/grafana/config:/config" # Contains all relevant configuration files.
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
        name = "grafana"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.grafana.rule=Host(`grafana.lazz.tech`)",
          "traefik.http.routers.grafana.tls.certresolver=cloudflare"
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
