// docker run \
//   --net=host \
//   --name=homebridge \
//   -e PUID=<UID> -e PGID=<GID> \
//   -e HOMEBRIDGE_CONFIG_UI=1 \
//   -e HOMEBRIDGE_CONFIG_UI_PORT=8080 \
//   -v </path/to/config>:/homebridge \
//   oznu/homebridge

job "homebridge" {
  datacenters = ["dc1"]
  type = "service"

  group "homebridge" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "homebridge" {
      driver = "docker"
      env {
        "HOMEBRIDGE_CONFIG_UI" = "1"
        "HOMEBRIDGE_CONFIG_UI_PORT" = "8080"
      }
      config {
        image = "oznu/homebridge"
        port_map {
          http = 8080
        }
        volumes = [
          "opt/homebridge/config:/config", # Contains all relevant configuration files.
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
        name = "homebridge"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.homebridge.rule=HostRegexp(`homebridge.lazz.tech`)"
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
