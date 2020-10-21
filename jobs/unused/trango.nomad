// https://github.com/trango-io/trango-self-hosted
// sudo docker container run -d \
//    -p 80:80 \
//    -p 443:443 \
//    --name trango \
//    tak786/trango-self-hosted
//
// Upon first install go to https://$IP:$PORT/
// on chrome you may need to click anyware and type "thisisunsafe"

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
          https = 443
        }
      }
      resources {
        cpu    = 250 # 250 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "http" {}
          port "https" {}
        }
      }
      service {
        name = "trango"
        port = "https"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.trango.rule=HostRegexp(`trango.lazz.tech`)"
        ]

        check {
          type     = "tcp"
          path     = "/"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
  }
}
