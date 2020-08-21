job "homebridge" {
  datacenters = ["dc1"]
  type = "service"

  group "homebridge" {
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

    task "homebridge-server" {
      driver = "docker"

      config {
        // docker run \
        //   --net=host \
        //   --name=homebridge \
        //   -e PUID=<UID> -e PGID=<GID> \
        //   -e HOMEBRIDGE_CONFIG_UI=1 \
        //   -e HOMEBRIDGE_CONFIG_UI_PORT=8080 \
        //   -v </path/to/config>:/homebridge \
        //   oznu/homebridge
        image = "oznu/homebridge"

        port_map {
          http = 8080
        }
      }

      # It is possible to set environment variables which will be
      # available to the task when it runs.
      env {
        "HOMEBRIDGE_CONFIG_UI" = "1"
        "HOMEBRIDGE_CONFIG_UI_PORT" = "8080"
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
        name = "homebridge"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.homebridge.rule=Host(`homebridge.localhost`)",
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
