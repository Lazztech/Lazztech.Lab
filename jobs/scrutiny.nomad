// https://github.com/AnalogJ/scrutiny
// docker run -it --rm -p 8080:8080 \
// -v /run/udev:/run/udev:ro \
// --cap-add SYS_RAWIO \
// --device=/dev/sda \
// --device=/dev/sdb \
// --name scrutiny \
// analogj/scrutiny

job "scrutiny" {
  datacenters = ["dc1"]
  type = "service"
  
  group "scrutiny" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "scrutiny" {
      driver = "docker"
      env {
        "PUID" = "1000"
        "PGID" = "1000"
        "TZ" = "America/Los_Angeles"
      }
      config {
        image = "analogj/scrutiny"
        port_map {
          http = 8080
        }
        volumes = [
          "/run/udev:/run/udev:ro" # is necessary to provide the Scrutiny collector with access to your device metadata
        ]
        cap_add = [
          "SYS_RAWIO",
        ]
        devices = [
          {
            host_path = "/dev/sda" # sda    disk   1.8T HDS722020ALA330_RSD_HUA
            container_path = "/dev/sda"
          }
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
        name = "scrutiny"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.scrutiny.rule=Host(`scrutiny.lazz.tech`)",
          "traefik.http.routers.scrutiny.tls.certresolver=cloudflare"
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
