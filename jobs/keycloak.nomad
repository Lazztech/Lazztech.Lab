// https://www.keycloak.org/getting-started/getting-started-docker
// docker run -p 8080:8080 -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin quay.io/keycloak/keycloak:11.0.3

job "keycloak" {
  datacenters = ["dc1"]
  type = "service"

  group "keycloak" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "keycloak" {
      driver = "docker"
      env {
        KEYCLOAK_USER="admin"
        KEYCLOAK_PASSWORD="admin"
        PROXY_ADDRESS_FORWARDING="true"
      }
      config {
        image = "quay.io/keycloak/keycloak:11.0.3"
        port_map {
          http = 8080
        }
        volumes = [
          "/opt/keycloak/config:/config", # Contains all relevant configuration files.
          "/etc/localtime:/etc/localtime:ro"
        ]
      }
//       template {
//         data = <<EOF

//         destination = "keycloak/config/automations.yaml"
//       }
      resources {
        cpu    = 250 # 250 MHz
        memory = 512 # 512 MB

        network {
          mbits = 10
          port "http" { }
        }
      }

      service {
        name = "keycloak"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.keycloak.rule=HostRegexp(`keycloak.lazz.tech`)",
          "traefik.http.routers.keycloak.tls.certresolver=cloudflare"
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
