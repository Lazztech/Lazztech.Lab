# Lazztech.Lab

k3s based infrastructure for homelab, smarthome, productivity, collaboration, education, or more.
k3s was selected for its ease of deployment and repeatability of services deployed to it.

k3OS can be used for a dedicated machine or k3d/k3s for local testing.

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

## Storage
Ranchers Longhorn CSI is recommended as the Container Storage Interface (CSI). The default k3s local-path Persistent Volume Claims (PVC) use hostPaths in `/var/lib/rancher/k3s/storage` and aren't supported by velero with automatic restic based volume backup. Longhorn is supported as a first class citizen of k3s.

- https://rancher.com/docs/k3s/latest/en/storage/

```bash
# install longhorn
$ kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml
```

```bash
# check that it's installed
$ kubectl get storageclass
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  27d
longhorn               driver.longhorn.io      Delete          Immediate              true                   37h
```

```bash
# make longhorn default
$ kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
$ kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

```bash
# verify that it's default
$ kubectl get storageclass
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
longhorn (default)   driver.longhorn.io      Delete          Immediate              true                   37h
local-path           rancher.io/local-path   Delete          WaitForFirstConsumer   false                  27d
```

```bash
# apply longhorn ui ingress
$ kubectl apply -f helm/longhorn-ingress.yaml
```

```bash
# uninstall command if needed
$ kubectl delete -f https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml
```

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
  --use-volume-snapshots=false \
  --use-restic \
  --default-volumes-to-restic
```

```bash
# run backup of everything
$ velero backup create homelab
# check status of backup
$ velero backup describe homelab
# check logs from backup
$ velero backup logs homelab
```

```bash
# run backup of a specific selector
$ velero backup create ghost-backup --selector app=ghost
# check status of backup
$ velero backup describe ghost-backup
# check logs from backup
$ velero backup logs ghost-backup
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
```

```bash
# to access prometheus directly
$ kubectl port-forward prometheus-prometheus-kube-prometheus-prometheus-0 9090:9090

# or optionally apply prometheus ingress
$ kubectl apply -f helm/prometheus-ingress.yaml
```

```bash
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

```bash
# uninstall command if needed
$ helm uninstall loki
```

> Loki can now be added as a datasource in Grafana.
> See http://docs.grafana.org/features/datasources/loki/ for more detail.

Add loki as a data source in grafana with `http://loki:3100` as the url.

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
| ✅ | Adminer | DB Admin | Pretty stable |
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
| 🚧 | Freeipa | AD Alternative | Deploys though not yet documented |
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
| 🚧 | Redis | Key value & cache | Handy |
| ✅ | Scrutiny | Hard drive monitoring | Handy |
| ✅ | Snapdrop | Airdrop alternative | Handy |
| ✅ | Uptime-Kuma | Status Page | Stable |
| ✅ | Wg-access-server | Wireguard & UI | Needs work or replacement |
| ✅ | Wikijs | Wiki | Switching from Dokuwiki |








