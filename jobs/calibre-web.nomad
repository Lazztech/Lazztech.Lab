// https://hub.docker.com/r/linuxserver/calibre-web/
// docker create \
//   --name=calibre-web \
//   -e PUID=1000 \
//   -e PGID=1000 \
//   -e TZ=Europe/London \
//   -e DOCKER_MODS=linuxserver/calibre-web:calibre \
//   -p 8083:8083 \
//   -v path to data:/config \
//   -v path to calibre library:/books \
//   --restart unless-stopped \
//   linuxserver/calibre-web
//
// ssh server@ip
// mkdir /opt/calibre/library/
// exit
// ---- Aquire or create a Calibre metadata.db ---- https://github.com/linuxserver/docker-calibre-web/issues/30
// scp -rp ~/Downloads/metadata.db  server@ip:/opt/calibre/library/
// ssh server@ip
// chmod a+w /opt/calibre/library/metadata.db
//
// On the initial setup screen, 
// enter /books as your calibre library location.
// Default admin login: Username: admin Password: admin123
//
// http://read.lazz.tech/admin/config
// Feature Configuration > Enable Uploads > Check
// External Binaries > Path to Calibre E-Book Converter > /usr/bin/ebook-convert
// External Binaries > Path to Kepubify E-Book Converter > /usr/bin/kepubify
// then save
//
// http://read.lazz.tech/admin/view
// Users > admin > Allow Ebook Viewer > save
//
// http://read.lazz.tech/admin/view
// 

job "calibre-web" {
  datacenters = ["dc1"]
  type = "service"
  
  group "calibre-web" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "calibre-web" {
      driver = "docker"
      env {
        "PUID" = "1000"
        "PGID" = "1000"
        "TZ" = "America/Los_Angeles"
        "DOCKER_MODS" = "linuxserver/calibre-web:calibre"
      }
      config {
        image = "linuxserver/calibre-web"
        port_map {
          http = 8083
        }
        volumes = [
          "data:/config", # Contains all relevant configuration files.
          "/opt/calibre/library:/books"
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
        name = "calibre-web"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.calibre-web.rule=Host(`read.lazz.tech`)",
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
