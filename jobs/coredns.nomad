# https://coredns.io/manual/toc/
# https://arstechnica.com/gadgets/2020/08/understanding-dns-anatomy-of-a-bind-zone-file/

job "coredns" {
  datacenters = ["dc1"]
  type = "service"

  group "coredns" {
    count = 1
    task "coredns" {
      driver = "docker"
      config {
        image = "coredns/coredns:1.8.0"
        network_mode = "host"
        args = ["-conf", "local/coredns/corefile"]
        port_map {
          dns = 53
          http = 8080
        }
      }

      template {
        data = <<EOF
# used to define a variable holding a set of plugin behaviors
(base) {
    prometheus
    log
}

# . is the catch all and defaults to port 53
. {
  bind {{ env "NOMAD_IP_http" }}
  forward . 1.1.1.1 8.8.8.8
  health
  import base
}

lazz.tech {
    bind {{ env "NOMAD_IP_http" }}
    file local/coredns/zones/db.lazz.tech.zone
    import base
}
EOF
        destination = "local/coredns/corefile"
      }

      template {
        data = <<EOF
$ORIGIN lazz.tech.
@	3600 IN	SOA sns.dns.icann.org. noc.dns.icann.org. (
				{{ timestamp "unix" }} ; serial
				7200       ; refresh (2 hours)
				3600       ; retry (1 hour)
				1209600    ; expire (2 weeks)
				3600       ; minimum (1 hour)
				)

	3600 IN NS ns1.lazz.tech.
	3600 IN NS ns2.lazz.tech.

home                IN A     {{ env "NOMAD_IP_http"}}
nomad               IN A     {{ env "NOMAD_IP_http"}}
traefik             IN A     {{ env "NOMAD_IP_http"}}
consul              IN A     {{ env "NOMAD_IP_http"}}
vault-ui            IN A     {{ env "NOMAD_IP_http"}}
nextcloud           IN A     {{ env "NOMAD_IP_http"}}
wiki                IN A     {{ env "NOMAD_IP_http"}}
read                IN A     {{ env "NOMAD_IP_http"}}
share               IN A     {{ env "NOMAD_IP_http"}}
home-assistant      IN A     {{ env "NOMAD_IP_http"}}
jellyfin            IN A     {{ env "NOMAD_IP_http"}}
git                 IN A     {{ env "NOMAD_IP_http"}}
cicd                IN A     {{ env "NOMAD_IP_http"}}
registry            IN A     {{ env "NOMAD_IP_http"}}
docker              IN A     {{ env "NOMAD_IP_http"}}
code                IN A     {{ env "NOMAD_IP_http"}}
status              IN A     {{ env "NOMAD_IP_http"}}
grafana             IN A     {{ env "NOMAD_IP_http"}}
prometheus          IN A     {{ env "NOMAD_IP_http"}}
scrutiny            IN A     {{ env "NOMAD_IP_http"}}
wireguard           IN A     {{ env "NOMAD_IP_http"}}
keycloak            IN A     {{ env "NOMAD_IP_http"}}
objects      IN A     {{ env "NOMAD_IP_http"}}
EOF
        destination = "local/coredns/zones/db.lazz.tech.zone"
      }

      resources {
        cpu    = 100 # 100 MHz
        memory = 128 # 128MB

        network {
          mbits = 10
          port "dns" {
            static = 53
          }
          port "http" {
            static = 8080
          }
        }
      }

      service {
        name = "coredns"
        port = "http"

        check {
          type     = "http"
          path     = "/health"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
  }
}
