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

## Email Setup

- sign into keycloak as admin
- go to configure > Realm Settings
- click email tab
- add the following:
  - Host: smtp.mailgun.org
  - From: postmaster@mg.lazz.tech
  - Enable SSL: ON
  - Enable Authentication: ON
    - Username: postmaster@mg.lazz.tech
    - Password: ADD_PASSWORD_HERE
- save

Note: the logged in user will need to have an email address for the "Test connection" button to work

## Add User

- sign into keycloak as admin
- go to manage > users
- click "Add User"
- add username
- add email
- add first name
- add last name
- User Enabled: ON
- Email Verified: OFF
- Required User Actions: Configure OTP, Verify Email, Update Password
- save
- click Credentials tab
- enter temporary password
- click Set Password


## Datastore
The default datastore is an embedded H2 database. This is mapped as a perstistant storage volume in /opt/jboss/keycloak/standalone/data/.

## Matrix Synapse
- https://matrix-org.github.io/synapse/latest/openid.html#keycloak

## Nextcloud
- https://janikvonrotz.ch/2020/10/20/openid-connect-with-nextcloud-and-keycloak/

