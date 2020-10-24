# Docker Registry
Minimal self hosted docker registry setup.

- https://docs.docker.com/registry/
- https://github.com/kwk/docker-registry-frontend

- https://www.macadamian.com/learn/creating-a-private-docker-registry/
- https://medium.com/@cnadeau_/private-docker-registry-part-1-basic-local-example-c409582e0e3f
- https://medium.com/@cnadeau_/private-docker-registry-part-2-lets-add-basic-authentication-6a22e5cd459b
- https://medium.com/@cnadeau_/private-docker-registry-part-3-lets-use-azure-storage-ca1d959c581e
- https://medium.com/@cnadeau_/private-docker-registry-part-4-lets-secure-the-registry-250c3cef237

- https://stackoverflow.com/questions/49674004/docker-repository-server-gave-http-response-to-https-client

```
sudo touch /etc/docker/daemon.json 
sudo nano /etc/docker/daemon.json
# add this: { "insecure-registries":["registry.lazz.tech:5000"] }
sudo service docker restart
```