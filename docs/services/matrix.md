# Matrix

Chat protocol

# Synapse

- https://hub.docker.com/r/matrixdotorg/synapse

The matrix synapse server requires a configuration file located as `/data/homeserver.yaml` inside the container.

The generation of the configurations is handled via an init-container. 

- https://kubernetes.io/docs/concepts/workloads/pods/init-containers/

However to try out and see the output follow the section below.

```bash
# Run this to generate and output configuration files in your current working directory.
# The command below will result in the following files:
# - matrix.lazz.tech.log.config
# - matrix.lazz.tech.signing.key
# - homeserver.yaml
$ docker run -it --rm \
    --mount type=bind,src="$(pwd)",dst=/data \
    -e SYNAPSE_SERVER_NAME=matrix.lazz.tech \
    -e SYNAPSE_REPORT_STATS=yes \
    matrixdotorg/synapse:latest generate
```

A sample config for reference is available at:
- https://github.com/matrix-org/synapse/blob/develop/docs/sample_config.yaml

# Registering a new user

```bash
# run this from within the matrix synapse server for interactive user configuration
$ register_new_matrix_user -c /data/homeserver.yaml http://localhost:8008
New user localpart [root]: gian
Password: 
Confirm password: 
Make admin [no]: yes
Sending registration request...
Success!
```