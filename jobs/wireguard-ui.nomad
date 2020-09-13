// https://www.youtube.com/watch?v=cQIu2IXw3o0
// https://github.com/subspacecloud/subspace
// docker create \
//     --name subspace \
//     --restart always \
//     --network host \
//     --cap-add NET_ADMIN \
//     --volume /usr/bin/wg:/usr/bin/wg \
//     --volume /data:/data \
//     --env SUBSPACE_HTTP_HOST=subspace.example.com \
//     subspacecloud/subspace:latest

job "wireguard-ui" {
  datacenters = ["dc1"]
  type = "service"
  
  group "wireguard-ui" {
	count = 1
	ephemeral_disk {
	  sticky = true
	  migrate = true
	  size = 300 # 300MB
	}
	task "wireguard-ui" {
	  driver = "docker"
	  env {
		  "SUBSPACE_HTTP_HOST" = "subspace.lazz.tech"
	  }
	  config {
		image = "subspacecloud/subspace:latest"
        network_mode = "host"
		port_map {
          http = 80
        }
		volumes = [
		    "wireguard/config:/usr/bin/wg",
			"subspace/data:/data"
		]
		cap_add = [
			"NET_ADMIN"
		]
	  }
	  resources {
		cpu    = 500 # 500 MHz
		memory = 256 # 256MB

		network {
		  port "http" {}
		}
	  }
	  service {
		name = "wireguard"
		port = "http"

		tags = [
		  "traefik.enable=true",
		  "traefik.http.routers.subspace.rule=HostRegexp(`subspace.lazz.tech`)"
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
