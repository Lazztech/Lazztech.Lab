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
          "homer/assets/:/www/assets", # Contains all relevant configuration files.
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
subtitle: "Homer"
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
  title: "Optional message!"
  content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

# Optional navbar
# links: [] # Allows for navbar (dark mode, layout, and search) without any links
links:
  - name: "Link 1"
    icon: "fab fa-github"
    url: "https://github.com/bastienwirtz/homer"
    target: "_blank" # optional html tag target attribute
  - name: "link 2"
    icon: "fas fa-book"
    url: "https://github.com/bastienwirtz/homer"

# Services
# First level array represent a group.
# Leave only a "items" key if not using group (group name, icon & tagstyle are optional, section separation will not be displayed).
services:
  - name: "Application"
    icon: "fa fa-code-fork"
    items:
      - name: "Awesome app"
        logo: "assets/tools/sample.png"
        # Alternatively a fa icon can be provided:
        # icon: "fab fa-jenkins"
        subtitle: "Bookmark example"
        tag: "app"
        url: "https://www.reddit.com/r/selfhosted/"
        target: "_blank" # optional html tag target attribute
      - name: "Another one"
        logo: "assets/tools/sample2.png"
        subtitle: "Another application"
        tag: "app"
        # Optional tagstyle
        tagstyle: "is-success"
        url: "#"
  - name: "Other group"
    icon: "fas fa-heartbeat"
    items:
      - name: "Another app"
        logo: "assets/tools/sample.png"
        subtitle: "Another example"
        tag: "other"
        url: "https://www.reddit.com/r/selfhosted/"
        target: "_blank" # optional html a tag target attribute
        # class: "green" # optional custom CSS class for card, useful with custom stylesheet
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
          "traefik.http.routers.homer.rule=HostRegexp(`homer.lazz.tech`, `home`)"
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
