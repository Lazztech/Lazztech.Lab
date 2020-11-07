# Nextcloud

## Reverse Proxy
Nextcloud requires a bit of setup to get it working behind the Traefik reverse proxy. Nextcloud tries to serve a self signed cert and force redirects via an nginx install inside of the Nextcloud docker container. It requires a bit of modification to the `/config/nginx/site-confs/default` file to allow Traefik to handle the ssl & https redirect. This is performed via the Nomad template stanza to inject in the modified `default` file via a docker volume on the appropriate path.

Below are the key modifications made to this file to make it all work:
```
#server { # Commented out so that external traefik reverse proxy can handle the redirects
#    listen 80;
#    listen [::]:80;
#    server_name _;
#    return 301 https://$host$request_uri;
#}
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    listen 80; # Needed for external traefik reverse proxy
```

The other detail is this needs to be added to the traefik config:
```
[serversTransport]
  insecureSkipVerify = "true"
```

Here's the resource that led me to this solution:
- https://www.reddit.com/r/Traefik/comments/d89x7d/trying_to_get_nextcloud_to_load_with_traefik_v2/?utm_source=share&utm_medium=ios_app&utm_name=iossmf
- https://community.traefik.io/t/nextcloud-traefik-uncooperative-redirecting-to-https/5340
- https://help.nextcloud.com/t/nextcloud-migration-to-traefik-failing-looking-for-help-troubleshooting/79129/2
- https://community.traefik.io/t/https-requests-not-working-for-docker-nextcloud-plain-http-request-sent-to-https-port/2847