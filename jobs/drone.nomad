// https://docs.drone.io/server/provider/gitea/
// docker run \
//   --volume=/var/lib/drone:/data \
//   --env=DRONE_GITEA_SERVER={{DRONE_GITEA_SERVER}} \
//   --env=DRONE_GITEA_CLIENT_ID={{DRONE_GITEA_CLIENT_ID}} \
//   --env=DRONE_GITEA_CLIENT_SECRET={{DRONE_GITEA_CLIENT_SECRET}} \
//   --env=DRONE_RPC_SECRET={{DRONE_RPC_SECRET}} \
//   --env=DRONE_SERVER_HOST={{DRONE_SERVER_HOST}} \
//   --env=DRONE_SERVER_PROTO={{DRONE_SERVER_PROTO}} \
//   --publish=80:80 \
//   --publish=443:443 \
//   --restart=always \
//   --detach=true \
//   --name=drone \
//   drone/drone:1

job "drone" {
  datacenters = ["dc1"]
  type = "service"
  
  group "drone" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "drone" {
      driver = "docker"
      env {
        DRONE_GITEA_SERVER="http://git.lazz.tech"
        DRONE_GITEA_CLIENT_ID="71c50f63-f82a-4d8d-96dd-0ca2d2463734"
        DRONE_GITEA_CLIENT_SECRET="G8KuBqkgBhkuAiN_VvMIq0sClCKhnGo3iOE_RfhiWlM="
        DRONE_RPC_SECRET="bea26a2221fd8090ea38720fc445eca6d91b1561382a053378c4f348e5f79647"
        DRONE_SERVER_HOST="cicd.lazz.tech"
        DRONE_SERVER_PROTO="http"
      }
      config {
        image = "drone/drone:1"
        port_map {
          http = 80
        }
        volumes = [
          "/opt/drone:/data"
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
        name = "drone"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.drone.rule=Host(`cicd.lazz.tech`)",
          "traefik.http.routers.drone.tls.certresolver=cloudflare"
        ]

        check {
          type     = "http"
          path     = "/"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }

// https://docs.drone.io/runner/docker/installation/linux/
// docker run -d \
//   -v /var/run/docker.sock:/var/run/docker.sock \
//   -e DRONE_RPC_PROTO=https \
//   -e DRONE_RPC_HOST=drone.company.com \
//   -e DRONE_RPC_SECRET=super-duper-secret \
//   -e DRONE_RUNNER_CAPACITY=2 \
//   -e DRONE_RUNNER_NAME=${HOSTNAME} \
//   -p 3000:3000 \
//   --restart always \
//   --name runner \
//   drone/drone-runner-docker:1

    task "drone-runner" {
      driver = "docker"
      env {
        DRONE_RPC_PROTO="http"
        DRONE_RPC_HOST="cicd.lazz.tech"
        DRONE_RPC_SECRET="bea26a2221fd8090ea38720fc445eca6d91b1561382a053378c4f348e5f79647"
        DRONE_RUNNER_CAPACITY=2
        DRONE_RUNNER_NAME="Micro8 Container Runner"
      }
      config {
        image = "drone/drone-runner-docker:1"
        port_map {
          http = 3000
        }
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
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
        name = "drone-container-runner"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.drone-runner.rule=Host(`drone-container-runner.lazz.tech`)",
          "traefik.http.routers.drone-runner.tls.certresolver=cloudflare"
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
