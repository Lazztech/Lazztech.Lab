# Lazztech.Infrastructure

Documentation:
- https://lazztech-infrastructure.netlify.app/

# Services
- ✅ : runs stably
- 🚧 : needs work though runs
- 🛑 : work in progress & may not deploy
- ❌ : no longer used

| Status      | Service Name | Purpose | Comments     |
| :---        |    :----:   | :----: |          ---: |
| ❌ | Ackee | Analytics | Pretty stable |
| ✅ | Adminer | DB Admin | Pretty stable |
| ✅ | Cluster Issuer | Issues SSL | Needs cert-manager helm |
| ✅ | Internal Cert | Internal SSL | Uses DNS01 via cert-manager helm |
| ✅ | Internal DDNS | *.internal subdomain to LAN IP | Works great |
| ✅ | Lazztech Cert | External SSL | Needs cert-manager helm |
| ✅ | Lazztech DDNS | *.lazz.tech domains to WAN IP | Needs cert-manager helm |
| ✅ | Code-Server | VSCode Web Server | Needs more recourses |
| 🚧 | Deepstack | AI web interface | Various uses |
| 🚧 | Docker-Registry-Frontend | Registry Frontend | Basic and works |
| 🚧 | Docker-Registry | Registry for containers | works |
| 🚧 | Double-take | Facial Recognition | WIP |
| 🛑 | Drone-runner | CICD runner | WIP |
| 🛑 | Drone | CICD Frontend | WIP |
| 🚧 | Freeipa | AD Alternative | Deploys though not yet documented |
| 🚧 | Gitea | Git server | Works well for mirrors |
| 🚧 | Frigate | Object detection NVR | Uses Google Coral USB TPU |
| 🚧 | Geoip | geoip | For analytics |
| ✅ | Ghost | Wordpress alternative | Works great behind CDN |
| 🚧 | Grafana | Metric UI | WIP |
| ✅ | Home Assistant | Home Automation | Assumes usb zigbee |
| 🚧 | Jellyfin | Media server | WIP |
| ✅ | Homer | Start page | Works great |
| 🚧 | Keycloak | SSO | Deploys though not yet documented |
| 🚧 | Matrix | Chat | Needs work though seems good |
| ✅ | MongoDB | NoSQL | Document db |
| ✅ | Mosquitto | MQTT | Document db |
| 🚧 | Nextcloud | GSuite Alternative | WIP |
| 🚧 | Node-red | Low code automation | WIP |
| ✅ | PGWeb | DB Admin | Simple though low on features |
| 🛑 | Plausible | Analytics | Needs work |
| ✅ | Postgres | SQL DB | Works well |
| ✅ | QuakeJS | WASM Quake3 | Free for all! |
| 🚧 | Redis | Key value & cache | Handy |
| ✅ | Snapdrop | Airdrop alternative | Handy |
| 🛑 | Wg-access-server | Wireguard & UI | Needs work or replacement |
| ✅ | Wikijs | Wiki | Switching from Dokuwiki |










