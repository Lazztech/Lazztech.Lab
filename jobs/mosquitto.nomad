// https://hometechhacker.com/mqtt-using-docker-and-home-assistant/
// sudo docker run -itd \
// --name=mqtt \
// --restart=always \
// --net=host \
// -v /storage/mosquitto/config:/mqtt/config:ro \
// -v /storage/mosquitto/data:/mqtt/data \
// -v /storage/mosquitto/log:/mqtt/log \
// toke/mosquitto

job "mosquitto" {
  datacenters = ["dc1"]
  type = "service"

  group "mosquitto" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "mosquitto" {
      driver = "docker"
      env {
        "TZ" = "America/Los_Angeles"
      }
      config {
        image = "toke/mosquitto"
        port_map {
          http = 1883
        }
        volumes = [
          "local:/mqtt/config", # Contains all relevant configuration files.
          "/opt/mosquitto/data:/mqtt/data",
          "/opt/mosquitto/log:/mqtt/log",
        ]
      }
      template {
      destination = "local/mosquitto.conf"
      data = <<EOH
# Place your local configuration in /mqtt/config/conf.d/

pid_file /var/run/mosquitto.pid

persistence true
persistence_location /mqtt/data/

# user mosquitto
allow_anonymous true

# Port to use for the default listener.
port 1883


# log_dest file /mqtt/log/mosquitto.log
log_dest stdout

#include_dir /mqtt/config/conf.d
EOH
      }

      resources {
        cpu    = 100 # 100 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "http" {}
        }
      }

      service {
        name = "mosquitto"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.mosquitto.rule=Host(`mqtt.lazz.tech`)",
          "traefik.http.routers.mosquitto.tls.certresolver=cloudflare"
        ]

        check {
          type     = "tcp"
          path     = "/"
          interval = "30s"
          timeout  = "10s"
        }
      }
    }
  }
}
