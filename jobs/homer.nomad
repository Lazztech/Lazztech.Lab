// https://github.com/bastienwirtz/homer
// https://github.com/bastienwirtz/homer/blob/master/docs/configuration.md
// docker run -p 8080:8080 \
//  -v /your/local/assets/:/www/assets \
//  b4bz/homer:latest

job "homer" {
  datacenters = ["dc1"]
  type = "service"

  group "dashboard" {
    count = 1
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300
    }
    task "homer" {
      driver = "docker"
      env {
        "PUID" = "1000"
        "PGID" = "1000"
      }
      config {
        image = "b4bz/homer:latest"
        port_map {
          http = 8080
        }
        volumes = [
          "/opt/homer/assets/:/www/assets", # Contains all relevant configuration files.
          "homer/assets/config.yml:/www/assets/config.yml"
        ]
      }
      template {
        data = <<EOF
# Homepage configuration
# See https://fontawesome.com/icons for icons options

# Optional: Use external configuration file. 
# Using this will ignore remaining config in this file
# externalConfig: https://example.com/server-luci/config.yaml

title: "App dashboard"
subtitle: "Lazztech"
# documentTitle: "Welcome" # Customize the browser tab text
# logo: "assets/logo.png"
# Alternatively a fa icon can be provided:
icon: "fas fa-skull-crossbones"

header: true # Set to false to hide the header
footer: false # '<p>Created with <span class="has-text-danger">❤</span> with <a href="https://bulma.io/">bulma</a>, <a href="https://vuejs.org/">vuejs</a> & <a href="https://fontawesome.com/">font awesome</a> // Fork me on <a href="https://github.com/bastienwirtz/homer"><i class="fab fa-github-alt"></i></a></p>' # set false if you want to hide it.

columns: "3" # "auto" or number (must be a factor of 12: 1, 2, 3, 4, 6, 12)
connectivityCheck: true # whether you want to display a message when the apps are not accessible anymore (VPN disconnected for example)

# Optional theming
theme: default # 'default' or one of the theme available in 'src/assets/themes'.

# Optional custom stylesheet
# Will load custom CSS files. Especially useful for custom icon sets.
# stylesheet:
#   - "assets/custom.css"

# Here is the exaustive list of customization parameters
# However all value are optional and will fallback to default if not set.
# if you want to change only some of the colors, feel free to remove all unused key.
colors:
  light:
    highlight-primary: "#3367d6"
    highlight-secondary: "#4285f4"
    highlight-hover: "#5a95f5"
    background: "#f5f5f5"
    card-background: "#ffffff"
    text: "#363636"
    text-header: "#424242"
    text-title: "#303030"
    text-subtitle: "#424242"
    card-shadow: rgba(0, 0, 0, 0.1)
    link-hover: "#363636"
    background-image: "assets/your/light/bg.png"
  dark:
    highlight-primary: "#3367d6"
    highlight-secondary: "#4285f4"
    highlight-hover: "#5a95f5"
    background: "#131313"
    card-background: "#2b2b2b"
    text: "#eaeaea"
    text-header: "#ffffff"
    text-title: "#fafafa"
    text-subtitle: "#f5f5f5"
    card-shadow: rgba(0, 0, 0, 0.4)
    link-hover: "#ffdd57"
    background-image: "assets/your/dark/bg.png"

# Optional message
message:
  # url: "https://<my-api-endpoint>" # Can fetch information from an endpoint to override value below.
  style: "is-warning"
  title: "Work in Progress!"
  content: "Services may change and shouldn't be considered stable. Future announcements may be posted here."

# Optional navbar
# links: [] # Allows for navbar (dark mode, layout, and search) without any links
links:
  - name: "Lazztech Status"
    icon: "fas fa-heartbeat"
    url: "https://status.lazz.tech/"
    target: "_blank" # optional html tag target attribute
  - name: "Lazztech Blog"
    icon: "fas fa-blog"
    url: "https://lazz.tech/"
    target: "_blank" # optional html tag target attribute
  - name: "Infrastructure Repo"
    icon: "fab fa-github"
    url: "https://github.com/lazztech/Lazztech.Infrastructure"
    target: "_blank" # optional html tag target attribute
  - name: "Infrastructure Docs"
    icon: "fas fa-book-dead"
    url: "https://lazztech-infrastructure.netlify.app/"
    target: "_blank" # optional html tag target attribute

# Services
# First level array represent a group.
# Leave only a "items" key if not using group (group name, icon & tagstyle are optional, section separation will not be displayed).
services:
  - name: "Community"
    icon: "fas fa-building"
    items:
      - name: "Nextcloud"
        icon: "fas fa-cloud"
        subtitle: "Files, Chat, Productivity & Collaboration"
        tag: "community"
        url: "http://nextcloud.lazz.tech/"
        # class: "green" # optional custom CSS class for card, useful with custom stylesheet
      - name: "Wiki"
        icon: "fab fa-wikipedia-w"
        subtitle: "Community Wiki"
        tag: "community"
        url: "http://wiki.lazz.tech/"
        # class: "green" # optional custom CSS class for card, useful with custom stylesheet
      - name: "EBook Library"
        icon: "fas fa-book"
        subtitle: "Community Ebook Libary & Reader"
        tag: "community"
        url: "http://read.lazz.tech/"
        # class: "green" # optional custom CSS class for card, useful with custom stylesheet
      - name: "Snapdrop"
        icon: "fas fa-satellite-dish"
        subtitle: "The easiest way to transfer data across devices"
        tag: "community"
        url: "http://share.lazz.tech/"
        # class: "green" # optional custom CSS class for card, useful with custom stylesheet
      - name: "Home Assistant"
        icon: "fas fa-laptop-house"
        subtitle: "Home Automation"
        tag: "community"
        url: "http://home-assistant.lazz.tech/"
        # class: "green" # optional custom CSS class for card, useful with custom stylesheet

  - name: "Lazztech Development"
    icon: "fas fa-code"
    items:
      - name: "dev-lazztechhub-service"
        icon: "fab fa-git-alt"
        subtitle: "Local development deployment"
        tag: "community"
        url: "http://dev-lazztechhub.lazz.tech/graphql"
        # class: "green" # optional custom CSS class for card, useful with custom stylesheet

  - name: "Development Resources"
    icon: "fas fa-code"
    items:
      - name: "Gitea"
        icon: "fab fa-git-alt"
        subtitle: "Local Git mirror"
        tag: "community"
        url: "http://git.lazz.tech/"
        # class: "green" # optional custom CSS class for card, useful with custom stylesheet
      - name: "Drone"
        icon: "fas fa-truck-loading"
        subtitle: "Container native Continous Integration /Continous Delivery"
        tag: "community"
        url: "http://cicd.lazz.tech/"
        # class: "green" # optional custom CSS class for card, useful with custom stylesheet
      - name: "Docker Registry"
        icon: "fab fa-docker"
        subtitle: "minimal registry:2 frontend"
        tag: "community"
        url: "http://docker.lazz.tech/"
        # class: "green" # optional custom CSS class for card, useful with custom stylesheet
      - name: "Code Server"
        icon: "fas fa-laptop-code"
        subtitle: "VSCode web server"
        tag: "community"
        url: "http://code.lazz.tech/"
        # class: "green" # optional custom CSS class for card, useful with custom stylesheet

  - name: "Monitoring"
    icon: "fas fa-heartbeat"
    items:
      - name: "Statping"
        logo: "assets/tools/sample2.png"
        subtitle: "Uptime status and notifications"
        tag: "sysadmin"
        # Optional tagstyle
        tagstyle: "is-success"
        url: "http://status.lazz.tech/"
      - name: "Grafana"
        logo: "assets/tools/sample2.png"
        subtitle: "Monitoring & Visibility"
        tag: "sysadmin"
        # Optional tagstyle
        tagstyle: "is-success"
        url: "http://grafana.lazz.tech/"
      - name: "Prometheus"
        logo: "assets/tools/sample2.png"
        subtitle: "Records real-time metrics"
        tag: "sysadmin"
        # Optional tagstyle
        tagstyle: "is-success"
        url: "http://prometheus.lazz.tech/"
      - name: "Scrutiny"
        logo: "assets/tools/sample2.png"
        subtitle: "Hard Drive S.M.A.R.T Monitoring"
        tag: "sysadmin"
        # Optional tagstyle
        tagstyle: "is-success"
        url: "http://scrutiny.lazz.tech/"

  - name: "SysAdmin"
    icon: "fa fa-server"
    items:
      - name: "Nomad"
        logo: "assets/tools/sample.png"
        # Alternatively a fa icon can be provided:
        # icon: "fab fa-jenkins"
        subtitle: "Workload Orchestrator"
        tag: "sysadmin"
        url: "http://nomad.lazz.tech/"
        # target: "_blank" # optional html tag target attribute
      - name: "Consul"
        logo: "assets/tools/sample2.png"
        subtitle: "Service Discovery"
        tag: "sysadmin"
        # Optional tagstyle
        tagstyle: "is-success"
        url: "http://consul.lazz.tech/"
      - name: "Vault"
        logo: "assets/tools/sample2.png"
        subtitle: "Secrets Management"
        tag: "sysadmin"
        # Optional tagstyle
        tagstyle: "is-success"
        url: "http://vault-ui.lazz.tech/"
      - name: "Traefik"
        logo: "assets/tools/sample2.png"
        subtitle: "Reverse Proxy & Load Balancer"
        tag: "sysadmin"
        # Optional tagstyle
        tagstyle: "is-success"
        url: "http://traefik.lazz.tech/"
      - name: "Unifi"
        logo: "assets/tools/sample2.png"
        subtitle: "Network Management"
        tag: "sysadmin"
        # Optional tagstyle
        tagstyle: "is-success"
        url: "http://unifi/"
      - name: "Wireguard"
        logo: "assets/tools/sample2.png"
        subtitle: "Wireguard VPN Management"
        tag: "sysadmin"
        # Optional tagstyle
        tagstyle: "is-success"
        url: "http://wireguard.lazz.tech/"
EOF
        destination = "homer/assets/config.yml"
      }
      resources {
        cpu    = 250 # 250 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "http" {}
          port "https" {}
        }
      }
      service {
        name = "homer"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.homer.rule=Host(`homer.lazz.tech`, `home`)"
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
