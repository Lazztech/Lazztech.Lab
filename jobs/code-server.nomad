job "code-server" {
  datacenters = ["dc1"]
  // type = "service"

  group "code-server" {
    count = 1

    ephemeral_disk {
      sticky = true
      migrate = true
      # Size in MB
      size = 300 
    }

    task "code-server" {
      env {
        "PUID" = "1000"
        "PGID" = "1000"
        "TZ" = "America/Los_Angeles"
        // "PASSWORD" = "password" #optional
        // "SUDO_PASSWORD" = "password" #optional
        // "PROXY_DOMAIN" = "code-server.my.domain" #optional
      }
      
      driver = "docker"

      config {
        # https://hub.docker.com/r/linuxserver/code-server
        // docker create \
        //   --name=code-server \
        //   -e PUID=1000 \
        //   -e PGID=1000 \
        //   -e TZ=Europe/London \
        //   -e PASSWORD=password `#optional` \
        //   -e SUDO_PASSWORD=password `#optional` \
        //   -e PROXY_DOMAIN=code-server.my.domain `#optional` \
        //   -p 8443:8443 \
        //   -v /path/to/appdata/config:/config \
        //   --restart unless-stopped \
        //   linuxserver/code-server
        image = "linuxserver/code-server"
        port_map {
          http = 8443
        }
        
        # Contains all relevant configuration files.
        volumes = [
          "code-server/config:/config"
        ]
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
        name = "code-server"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.code-server.rule=Host(`code.localhost`)"
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
