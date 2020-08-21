job "heimdall" {
  datacenters = ["dc1"]
  type = "service"

  group "dashboard" {
    count = 1

    # The "ephemeral_disk" stanza instructs Nomad to utilize an ephemeral disk
    # instead of a hard disk requirement. Clients using this stanza should
    # not specify disk requirements in the resources stanza of the task. All
    # tasks in this group will share the same ephemeral disk.
    #
    # For more information and examples on the "ephemeral_disk" stanza, please
    # see the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/ephemeral_disk.html
    #
    ephemeral_disk {
      # When sticky is true and the task group is updated, the scheduler
      # will prefer to place the updated allocation on the same node and
      # will migrate the data. This is useful for tasks that store data
      # that should persist across allocation updates.
      # sticky = true
      #
      # Setting migrate to true results in the allocation directory of a
      # sticky allocation directory to be migrated.
      # migrate = true
      #
      # The "size" parameter specifies the size in MB of shared ephemeral disk
      # between tasks in the group.
      size = 300
    }

    task "heimdall-server" {
      driver = "docker"

      config {
        # docker run  \
        # -e PUID=1000   \
        # -e PGID=1000   \
        # -e TZ=Europe/London \  
        # -p 80:80 \
        # -p 443:443 \
        #  linuxserver/heimdall
        image = "linuxserver/heimdall"
        port_map {
          http = 80
          https = 443
        }
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "http" {}
          port "https" {}
        }
      }

      service {
        name = "heimdall"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.heimdall.rule=Host(`heimdall.localhost`)"
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
