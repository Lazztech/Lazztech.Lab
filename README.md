# Lazztech.Infrastructure

Documentation:
- https://lazztech-infrastructure.netlify.app/

## SSL

https://cert-manager.io/docs/installation/kubernetes/

```bash
# install cert-manager
$ kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.yaml

# uninstall command if needed
$ kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.yaml
```

## Storage
Default k3s local-path persistent volume claims are used and can be found in `/var/lib/rancher/k3s/storage`

- https://rancher.com/docs/k3s/latest/en/storage/
## Backup

Velero is recommended for backups.

- https://velero.io/docs/v1.6/

```bash
# install the client cli
$ brew install velero
```

```bash
# create file for s3 compatible object storage credentials
$ touch ~/.lab-backup-credentials
# manually add contents with the following format:
[default]
aws_access_key_id=<AWS_ACCESS_KEY_ID>
aws_secret_access_key=<AWS_SECRET_ACCESS_KEY>
```

```bash
# install server side support via the client cli
$ velero install \
  --provider velero.io/aws \
  --bucket lazztech-lab \
  --plugins velero/velero-plugin-for-aws:v1.0.0 \
  --backup-location-config s3Url=https://sfo3.digitaloceanspaces.com,region=sfo3 \
  --secret-file ~/.lab-backup-credentials \
  --use-restic \
  --default-volumes-to-restic
```

```bash
# run backup
$ velero backup create homelab
# check status of backup
$ velero backup describe homelab
# check logs from backup
$ velero backup logs homelab
```

```bash
# run restore
$ velero restore create --from-backup BACKUP_NAME
# status of backup
$ velero restore describe YOUR_RESTORE_NAME
```

```bash
# uninstall commands if needed
$ kubectl delete namespace/velero clusterrolebinding/velero
$ kubectl delete crds -l component=velero
```

## Monitoring

Kube prometheus stack via helm installs prometheus, alertmanager & grafana.

```bash
# add helm repo
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# install kube-prometheus-stack
$ helm install prometheus prometheus-community/kube-prometheus-stack

# apply grafana ingress
$ kubectl apply -f helm/grafana-ingress.yaml

# uninstall command if needed
$ helm uninstall prometheus
```

> Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.

Grafana:
- https://grafana.internal.lazz.tech/
- default username: admin
- default password: prom-operator

## Logging

Loki is used in conjunction with the prometheus stack for monitoring logging.

```bash
# add helm repo
$ helm repo add loki https://grafana.github.io/loki/charts

# install loki
$ helm upgrade --install loki loki/loki-stack
```

> Loki can now be added as a datasource in Grafana.
> See http://docs.grafana.org/features/datasources/loki/ for more detail.

Add loki as a data source in grafana with `http://loki:3100` as the url.

## Services
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
| 🛑 | Drone | CICD | WIP |
| 🚧 | Freeipa | AD Alternative | Deploys though not yet documented |
| 🚧 | Gitea | Git server | Works well for mirrors |
| 🚧 | Frigate | Object detection NVR | Uses Google Coral USB TPU |
| 🚧 | Geoip | geoip | For analytics |
| ✅ | Ghost | Wordpress alternative | Works great behind CDN |
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








