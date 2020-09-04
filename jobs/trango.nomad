// https://github.com/trango-io/trango-self-hosted
// sudo docker container run -d \
//    -p 80:80 \
//    -p 443:443 \
//    --name trango \
//    tak786/trango-self-hosted

job "trango" {
  datacenters = ["dc1"]
  type = "service"
  
  group "trango" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "trango" {
      driver = "docker"
      config {
        image = "tak786/trango-self-hosted"
        port_map {
          http = 80
        //   https = 443
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
        name = "trango"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.trango.rule=HostRegexp(`trango.lazz.tech`)"
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
