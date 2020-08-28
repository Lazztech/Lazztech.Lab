// https://hub.docker.com/r/linuxserver/wireguard
// https://www.youtube.com/watch?v=GZRTnP4lyuo
// docker create \
//   --name=wireguard \
//   --cap-add=NET_ADMIN \
//   --cap-add=SYS_MODULE \
//   -e PUID=1000 \
//   -e PGID=1000 \
//   -e TZ=Europe/London \
//   -e SERVERURL=wireguard.domain.com `#optional` \
//   -e SERVERPORT=51820 `#optional` \
//   -e PEERS=1 `#optional` \
//   -e PEERDNS=auto `#optional` \
//   -e INTERNAL_SUBNET=10.13.13.0 `#optional` \
//   -p 51820:51820/udp \
//   -v /path/to/appdata/config:/config \
//   -v /lib/modules:/lib/modules \
//   --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
//   --restart unless-stopped \
//   linuxserver/wireguard

job "wireguard" {
  datacenters = ["dc1"]
  type = "service"
  
  group "wireguard" {
	count = 1
	ephemeral_disk {
	  sticky = true
	  migrate = true
	  size = 300 # 300MB
	}
	task "wireguard" {
	  driver = "docker"
	  env {
		"PUID" = "1000"
		"PGID" = "1000"
		"TZ" = "America/Los_Angeles"
		"SERVERURL" = "auto"
		"SERVERPORT" = "51820"
		"PEERS" = "1"
		"PEERDNS" = "auto"
		"INTERNAL_SUBNET" = "10.13.13.0"
	  }
	  config {
		image = "linuxserver/wireguard"
		volumes = [
		    "wireguard/config:/config",
		]
		cap_add = [
			"NET_ADMIN",
			"SYS_MODULE"
		]
		sysctl {
			net.ipv4.conf.all.src_valid_mark = "1"
		}
	  }
	  resources {
		cpu    = 500 # 500 MHz
		memory = 256 # 256MB

		network {
		  mbits = 10
		  port "udp" {
			  static = 51820
		  }
		}
	  }
	  service {
		name = "wireguard"
		port = "udp"

		tags = [
		  "traefik.enable=true",
		  "traefik.http.routers.wireguard.rule=HostRegexp(`wireguard.{domainWildCardRegex:[a-zA-Z0-9+.]+}`)"
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
