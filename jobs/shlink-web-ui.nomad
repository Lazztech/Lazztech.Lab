// https://shlink.io/documentation/shlink-web-client/
// docker run \
//      --name shlink-web-client \
//      -p 8000:80 \ 
//      -v ${PWD}/servers.json:/usr/share/nginx/html/servers.json \
//      shlinkio/shlink-web-client

job "shlink-ui" {
  datacenters = ["dc1"]
  type = "service"
  
  group "shlink" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "shlink-ui" {
      driver = "docker"
      config {
        image = "shlinkio/shlink-web-client"
        port_map {
          http = 80
        }
        volumes = [
          "shlink-ui/servers.json:/usr/share/nginx/html/servers.json" # Contains all relevant configuration files.
        ]
      }
      template {
        data = <<EOF
[
  {
    "name": "Main server",
    "url": "https://doma.in",
    "apiKey": "09c972b7-506b-49f1-a19a-d729e22e599c"
  },
  {
    "name": "Local",
    "url": "http://url.localhost:8080",
    "apiKey": "580d0b42-4dea-419a-96bf-6c876b901451"
  }
]
EOF

        destination = "shlink-ui/servers.json"
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
        name = "shlink-ui"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.shlink-ui.rule=HostRegexp(`urls.lazz.tech`)"
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
