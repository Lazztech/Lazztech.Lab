# docker run \
# -d \
# --name="home-assistant" \
# -v /PATH_TO_YOUR_CONFIG:/config \
# -v /etc/localtime:/etc/localtime:ro \
# --net=host \
# homeassistant/home-assistant:stable

job "home-assistant" {
  datacenters = ["dc1"]
  type = "service"

  group "home-assistant" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "home-assistant" {
      driver = "docker"
      config {
        image = "homeassistant/home-assistant:stable"
        port_map {
          http = 8123
        }
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
        name = "home-assistant"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.home-assistant.rule=HostRegexp(`home-assistant.lazz.tech`)"
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
