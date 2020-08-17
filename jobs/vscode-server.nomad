job "vscode-server" {
  datacenters = ["dc1"]
  type = "service"

  group "development" {
    count = 1
    # For more information and examples on the "ephemeral_disk" stanza, please
    # see the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/ephemeral_disk.html
    #
    ephemeral_disk {
      sticky = true
      migrate = true
      # Size in MB
      size = 300 
    }

    task "code-server" {
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

      env {
        "PUID" = "1000"
        "PGID" = "1000"
        "TZ" = "America/Los_Angeles"
        // "PASSWORD" = "password" #optional
        // "SUDO_PASSWORD" = "password" #optional
        // "PROXY_DOMAIN" = "code-server.my.domain" #optional
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "http" {}
        }
      }
    }
  }
}
