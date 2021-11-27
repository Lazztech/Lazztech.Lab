# Keycloak

## Initial Admin OTP 2FA Setup
The admin user is provisioned via environment variables/secrets. From that point to setup OTP 2FA for tha admin do the following:

https://ultimatesecurity.pro/post/2fa/

- sign into keycloak as admin
- go to manage > users
- click view all users
- edit admin
- add "Configure OTP" in the "Required User Actions" field
- save
- signout
- sign back in to keycloak as admin
- you'll then be prompted to setup 2FA OTP

## Datastore
The default datastore is an embedded H2 database. This is mapped as a perstistant storage volume in /opt/jboss/keycloak/standalone/data/.

## Matrix Synapse
- https://matrix-org.github.io/synapse/latest/openid.html#keycloak

## Nextcloud
- https://janikvonrotz.ch/2020/10/20/openid-connect-with-nextcloud-and-keycloak/

