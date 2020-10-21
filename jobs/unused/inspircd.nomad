// https://www.inspircd.org/
// https://hub.docker.com/r/inspircd/inspircd-docker/
// docker run --name ircd -p 6667:6667 inspircd/inspircd-docker
// to include configuration
// docker run --name inspircd -p 6667:6667 -v /path/to/your/config:/inspircd/conf/ inspircd/inspircd-docker
//
// https://ubuntu.com/tutorials/irc-server#1-overview
// https://www.digitalocean.com/community/tutorials/how-to-set-up-an-irc-server-on-ubuntu-14-04-with-inspircd-2-0-and-shalture

job "inspircd" {
  datacenters = ["dc1"]
  type = "service"
  
  group "inspircd" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300 # 300MB
    }
    task "inspircd" {
      driver = "docker"
      config {
        image = "inspircd/inspircd-docker"
        // volumes = [
        //   "inspircd/data:/inspircd/conf/", # Contains all relevant configuration files.
        // ]
      }
            template {
        data = <<EOF
<config format="xml">
<define name="bindip" value="1.2.2.3">
<define name="localips" value="&bindip;/24">

####### SERVER CONFIGURATION #######

<server
        name="chat.lazz.tech"
        description="lazzarini chat"
        id="1LZ"
        network="chat.lazz.tech">


####### ADMIN INFO #######

<admin
       name="gian"
       nick="gian"
       email="gianlazzarini@gmail.com">

####### PORT CONFIGURATION #######

<bind
      port="6667"
      type="clients">
EOF
        destination = "inspircd/data/inspircd.conf"
      }
      resources {
        cpu    = 250 # 250 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "clientsplaintext" {
            static = 6667
          }
        }
      }
      service {
        name = "inspircd"
        port = "clientsplaintext"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.inspircd.rule=Host(`irc.lazz.tech`)",
        ]

        check {
          type     = "tcp"
          path     = "/"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
  }
}
