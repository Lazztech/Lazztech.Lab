// https://docs.docker.com/registry/deploying/
// docker run -d \
//   -p 5000:5000 \
//   --restart=always \
//   --name registry \
//   -v /mnt/registry:/var/lib/registry \
//   registry:2

job "docker-registry" {
  datacenters = ["dc1"]
  type = "service"

  group "registry" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300
    }
    task "docker-registry" {
      driver = "docker"
      config {
        image = "registry:2"
        port_map {
          http = 5000
        }
        volumes = [
          "/opt/docker-registry/registry:/var/lib/registry"
        ]
      }
      resources {
        cpu    = 250 # 250 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "http" { static = 5000 }
        }
      }
      service {
        name = "docker-registry"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.docker-registry.rule=HostRegexp(`registry.lazz.tech`)",
          "traefik.http.routers.docker-registry.tls.certresolver=cloudflare"
        ]

        check {
          type     = "http"
          path     = "/"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }

    task "docker-registry-frontend" {
      driver = "docker"
      env {
        ENV_DOCKER_REGISTRY_HOST="registry.lazz.tech"
        ENV_DOCKER_REGISTRY_PORT="5000"
        ENV_DOCKER_REGISTRY_USE_SSL="1"
      }
      config {
        image = "konradkleine/docker-registry-frontend:v2"
        port_map {
          http = 80
        }
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
        name = "docker-registry-frontend"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.docker-registry-frontend.rule=HostRegexp(`docker.lazz.tech`)",
          "traefik.http.routers.docker-registry-frontend.tls.certresolver=cloudflare"
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
