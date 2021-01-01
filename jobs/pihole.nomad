job "pihole" {
  datacenters = ["dc1"]
  type = "service"

  group "pihole" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "pihole" {
      driver = "docker"
      env {
        "TZ" = "America/Los_Angeles"
      }
      config {
        image = "pihole/pihole:latest"
        port_map {
          dns = 53
          otherDns = 67
          http = 80
        }
        volumes = [
          "/opt/pihole/:/etc/pihole/", # Contains all relevant configuration files.
          "pihole-custom-list/custom.list:/etc/pihole/custom.list",
          "/opt/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/"
        ]
        cap_add = [
			    "NET_ADMIN",
		    ]
      }
      template {
        data = <<EOF
192.168.1.11 home
192.168.1.11 nomad.lazz.tech
192.168.1.11 traefik.lazz.tech
192.168.1.11 consul.lazz.tech
192.168.1.11 vault-ui.lazz.tech
192.168.1.11 nextcloud.lazz.tech
192.168.1.11 wiki.lazz.tech
192.168.1.11 read.lazz.tech
192.168.1.11 share.lazz.tech
192.168.1.11 home-assistant.lazz.tech
192.168.1.11 jellyfin.lazz.tech
192.168.1.11 git.lazz.tech
192.168.1.11 cicd.lazz.tech
192.168.1.11 registry.lazz.tech
192.168.1.11 docker.lazz.tech
192.168.1.11 code.lazz.tech
192.168.1.11 status.lazz.tech
192.168.1.11 grafana.lazz.tech
192.168.1.11 prometheus.lazz.tech
192.168.1.11 scrutiny.lazz.tech
192.168.1.11 wireguard.lazz.tech
192.168.1.11 keycloak.lazz.tech
EOF
        destination = "pihole-custom-list/custom.list"
      }
      resources {
        cpu    = 250 # 250 MHz
        memory = 512 # 512MB

        network {
          mbits = 10
          port "dns" {
            static = 53
          }
          port "otherDns" {
            static = 67
          }
          port "http" {}
        }
      }

      service {
        name = "pihole"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.pihole.rule=HostRegexp(`pihole.lazz.tech`)",
          "traefik.http.routers.pihole.tls.certresolver=cloudflare"
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
