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

> "By default, registration of new users via Matrix clients is disabled."
- https://github.com/matrix-org/synapse#registering-a-new-user-from-a-client

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

# Invite token based registration

For an in-between option of neither enabling open registration nor having to make an account for everyone the plugin below can be used for invite token based registration links.

- https://matrix.org/docs/projects/other/matrix-registration

# Element Client

The element client can be configured via json:
- https://github.com/vector-im/element-web/blob/develop/docs/config.md