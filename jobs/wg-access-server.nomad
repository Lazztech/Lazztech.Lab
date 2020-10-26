// https://github.com/Place1/wg-access-server
// https://www.youtube.com/watch?v=GZRTnP4lyuo
//
// # use this for the secret key
// openssl rand -base64 32
//
// docker run \
//   -it \
//   --rm \
//   --cap-add NET_ADMIN \
//   --device /dev/net/tun:/dev/net/tun \
//   -v wg-access-server-data:/data \
//   -e "WIREGUARD_PRIVATE_KEY=$(wg genkey)" \
//   -p 8000:8000/tcp \
//   -p 51820:51820/udp \
//   place1/wg-access-server

job "wg-access-server" {
  datacenters = ["dc1"]
  type = "service"
  
  group "wg-access-server" {
	count = 1
	ephemeral_disk {
	  sticky = true
	  migrate = true
	  size = 300 # 300MB
	}
	task "wg-access-server" {
	  driver = "docker"
	  env {
		WG_WIREGUARD_PRIVATE_KEY=""
		WG_ADMIN_PASSWORD=""
		WG_EXTERNAL_HOST="24.18.203.15"
	  }
	  config {
		image = "place1/wg-access-server:v0.3.0"
		volumes = [
		    "/opt/wg-access-server-data:/data",
			"wg-access-server-config/config.yaml:/config.yaml"
		]
		cap_add = [
			"NET_ADMIN",
		]
		devices = [
			{
				host_path = "/dev/net/tun"
				container_path = "/dev/net/tun"
			}
		]
	  }
//       template {
//         data = <<EOF
// loglevel: info
// wireguard:
//   externalHost: "24.18.203.15"
// EOF
//         destination = "wg-access-server-config/config.yaml"
//       }
	  resources {
		cpu    = 250 # 250 MHz
		memory = 256 # 256MB

		network {
		  mbits = 10
		  port "udp" {
			  static = 51820
		  }
		  port "tcp" {
              static = 8000
          }
		}
	  }
	  service {
		name = "wg-access-server"
		port = "tcp"

		tags = [
		  "traefik.enable=true",
		  "traefik.http.routers.wg-access-server.rule=Host(`wireguard.lazz.tech`)",
          "traefik.http.routers.wg-access-server.tls.certresolver=cloudflare"
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
