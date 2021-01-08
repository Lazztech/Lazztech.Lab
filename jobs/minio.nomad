// https://raw.githubusercontent.com/minio/minio/master/docs/orchestration/docker-compose/docker-compose.yaml
  // minio1:
  //   image: minio/minio:RELEASE.2021-01-05T05-22-38Z
  //   volumes:
  //     - data1-1:/data1
  //     - data1-2:/data2
  //   expose:
  //     - "9000"
  //   environment:
  //     MINIO_ROOT_USER: minio
  //     MINIO_ROOT_PASSWORD: minio123
  //   command: server http://minio{1...4}/data{1...2}
  //   healthcheck:
  //     test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
  //     interval: 30s
  //     timeout: 20s
  //     retries: 3

job "minio" {
  datacenters = ["dc1"]
  type = "service"

  group "dashboard" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300
    }
    task "minio" {
      driver = "docker"
      env {
        MINIO_ROOT_USER = "minio"
        MINIO_ROOT_PASSWORD = "minio123"
      }
      config {
        image = "minio/minio:RELEASE.2021-01-05T05-22-38Z"
        args = ["server", "/data"]
        port_map {
          http = 9000
        }
        volumes = [
          "/opt/minio/:/data", # Contains all relevant configuration files.
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
        name = "minio"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.minio.rule=Host(`objects.lazz.tech`)",
          "traefik.http.routers.minio.tls.certresolver=cloudflare"
        ]

        check {
          type     = "http"
          path     = "/minio/health/live"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
  }
}
