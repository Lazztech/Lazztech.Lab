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
      env {
        "TZ" = "America/Los_Angeles"
      }
      config {
        image = "homeassistant/home-assistant:stable"
        network_mode = "host"
        port_map {
          http = 8123
        }
        volumes = [
          "/opt/home-assistant/config:/config", # Contains all relevant configuration files.
          "/etc/localtime:/etc/localtime:ro"
        ]
        devices = [
          {
            host_path = "/dev/ttyUSB0"
            container_path = "/dev/ttyUSB0"
          },
          {
            host_path = "/dev/ttyUSB1"
            container_path = "/dev/ttyUSB1"
          }
        ]
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 512 # 512MB

        network {
          mbits = 10
          mode = "host"
          port "http" {
            static = 8123
          }
        }
      }

      service {
        name = "home-assistant"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.home-assistant.rule=HostRegexp(`home-assistant.lazz.tech`)",
          "traefik.http.routers.home-assistant.tls.certresolver=cloudflare"
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
