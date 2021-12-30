# Lazztech.Lab

k3s based infrastructure for homelab, smarthome, productivity, collaboration, education, or more.
k3s was selected for its ease of deployment and repeatability of services deployed to it.

k3OS can be used for a dedicated machine/VM or k3d/k3s for local testing.

- https://k3s.io/
- https://k3os.io/
- https://k3d.io/

## SSL

https://cert-manager.io/docs/installation/kubernetes/

```bash
# install cert-manager
$ kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.yaml

# uninstall command if needed
$ kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.yaml
```

## Security Basics

Create a secret, based on the values below, that holds the default admin username & password that will be injected into various services.

```yaml
secret: "admin"
userKey: username
passwordKey: password
```

Setup network policies.

```bash
# apply internal namespace network policy
$ kubectl apply -f k8s/network-policies/network-policy.yaml

# configure ingress to pass through client ip addresses for whitelist support
$ kubectl patch svc traefik -n kube-system -p '{"spec":{"externalTrafficPolicy":"Local"}}'
```

Setup SSO provider.

```bash
# add helm repo for authintik
$ helm repo add authentik https://charts.goauthentik.io
# update
$ helm repo update
# install authentik
$ helm install authentik authentik/authentik -f helm/authentik-config.yaml

# optionally apply any updates to the authentik-config.yaml
$ helm upgrade authentik authentik/authentik -f helm/authentik-config.yaml
```


## Monitoring & Logging

Kube prometheus stack via helm installs prometheus, alertmanager & grafana.

```bash
# add helm repo
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

```bash
# install kube-prometheus-stack
$ helm install prometheus prometheus-community/kube-prometheus-stack --values helm/kube-prometheus-stack-config.yaml

# install loki
$ helm upgrade --install loki grafana/loki -f helm/loki-config.yaml
```

```bash
# uninstall commands if needed
$ helm uninstall prometheus
$ helm uninstall loki
```

> Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.

Grafana:
- https://grafana.internal.lazz.tech/
- default username: your admin secret username
- default password: your admin secret password

> Loki can now be added as a datasource in Grafana.
> See http://docs.grafana.org/features/datasources/loki/ for more detail.

Add loki as a data source in grafana with `http://loki:3100` as the url.

## Resource Recommender

Using a combination of the kubernetes vpa (vertical pod autoscaler) & a project called goldilocks by fairwinds you can make educated decisions on how you set your resource limits & requests based on how your services actually get used.

- https://goldilocks.docs.fairwinds.com/installation/#installation-2
- https://github.com/FairwindsOps/charts/tree/master/stable/vpa

```bash
# add helm repo
$ helm repo add fairwinds-stable https://charts.fairwinds.com/stable

# install fairwinds paired down vpa deployment
$ helm install vpa fairwinds-stable/vpa --namespace vpa --create-namespace

# install fairwinds goldilocks to the default namespace
$ helm install goldilocks --namespace default fairwinds-stable/goldilocks

# activate goldilocks on the default namespace
$ helm install goldilocks --namespace default fairwinds-stable/goldilocks

# apply load to the service you're focused on...
# then open the goldilocks dashboard to get recommendations on resources
$ kubectl -n default port-forward svc/goldilocks-dashboard 8080:80
```

## Kubernetes Dashboard

Lens is recommended:
- https://k8slens.dev/

Metric can be made to work with the monitoring stack from above via opening up the settings for your context:
- Go to prometheus section
- Set to prometheus-operator
- Set prometheus service address to `default/prometheus-kube-prometheus-prometheus:9090`

## Services
- ✅ : runs stably
- 🚧 : needs work though runs
- 🛑 : work in progress & may not deploy
- ❌ : no longer used

| Status      | Service Name | Purpose | Comments     |
| :---        |    :----:   | :----: |          ---: |
| ✅ | Ackee | Analytics | Pretty stable |
| ❌ | Adminer | DB Admin | Pretty stable |
| ✅ | Calibre-web | Ebooks | Pretty stable |
| ✅ | Cluster Issuer | Issues SSL | Needs cert-manager helm |
| ✅ | Internal Cert | Internal SSL | Uses DNS01 via cert-manager helm |
| ✅ | Internal DDNS | *.internal subdomain to LAN IP | Works great |
| ✅ | Lazztech Cert | External SSL | Needs cert-manager helm |
| ✅ | Lazztech DDNS | *.lazz.tech domains to WAN IP | Needs cert-manager helm |
| ✅ | Code-Server | VSCode Web Server | Needs more recourses |
| 🚧 | Deepstack | AI web interface | Various uses |
| ✅ | Docker-Registry | Registry & UI | works |
| 🚧 | Double-take | Facial Recognition | WIP |
| ❌ | Drone | CICD | WIP |
| ✅ | Jenkins| CICD | Simple & well documented with Blue Ocean for containers |
| ❌ | Freeipa | AD Alternative | Deploys though not yet documented |
| 🚧 | Frigate | Object detection NVR | Uses Google Coral USB TPU |
| 🚧 | Geoip | geoip | For analytics |
| ✅ | Ghost | Wordpress alternative | Works great behind CDN |
| ✅ | Gitea | Git server | Works well for mirrors |
| ✅ | Home Assistant | Home Automation | Assumes usb zigbee |
| ✅ | Homer | Start page | Works great |
| 🚧 | Jellyfin | Media server | WIP |
| 🚧 | Keycloak | SSO | Deploys though not yet documented |
| 🚧 | Matrix | Chat | Needs work though seems good |
| ✅ | Minio | Object Storage | Works nicely |
| ✅ | MongoDB | NoSQL | Document db |
| ✅ | Mosquitto | MQTT | Document db |
| 🚧 | Nextcloud | GSuite Alternative | WIP |
| 🚧 | Node-red | Low code automation | WIP |
| ✅ | QuakeJS | WASM Quake3 | Free for all! |
| ❌ | Redis | Key value & cache | Handy |
| ✅ | Scrutiny | Hard drive monitoring | Handy |
| ❌ | Snapdrop | Airdrop alternative | Dissatisfied with usability/reliability |
| ✅ | Uptime-Kuma | Status Page | Stable |
| ✅ | Wg-access-server | Wireguard & UI | Needs work or replacement |
| ✅ | Wikijs | Wiki | Switching from Dokuwiki |








