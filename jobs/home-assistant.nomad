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
        port_map {
          http = 8123
        }
        volumes = [
          "home-assistant/config:/config", # Contains all relevant configuration files.
          "home-assistant/config/configuration.yaml:/config/configuration.yaml"
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
      template {
        data = <<EOF
# Configure a default setup of Home Assistant (frontend, api, etc)
default_config:

# Text to speech
tts:
  - platform: google_translate

#group: !include groups.yaml
automation: !include automations.yaml
#script: !include scripts.yaml
#scene: !include scenes.yaml

zwave:
  usb_path: /dev/ttyUSB0

zha:
  usb_path: /dev/ttyUSB1
  database_path: /config/zigbee.db
EOF
        destination = "home-assistant/config/configuration.yaml"
      }
      template {
        data = <<EOF
- id: '1601861363140'
  alias: Clothes Washer Active
  description: Clothes Washer sustained motion
  trigger:
  - device_id: 9799f5f871154f01ba6ac7ee2a84a8e4
    domain: binary_sensor
    entity_id: binary_sensor.dishwasher_accelerometer
    for:
      hours: 0
      minutes: 3
      seconds: 0
    platform: device
    type: moving
  condition: []
  action:
  - data:
      message: Active
      title: Clothes Washer
    service: notify.notify
  mode: single
EOF
        destination = "home-assistant/config/automations.yaml"
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
