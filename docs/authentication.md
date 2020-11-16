# Authentication

There are many technologies that exist to fulfill authentication, user access management and the like. It can be difficult to parse through all the options and technologies. There's SAML(Security Assertion Markup Language), OAuth(open-standard authorization protocol), LDAP(Lightweight Directory Access Protocol), AD(Active Directory), IAM(Identity Access Management) SSO(Single Sign On), OIDC(OpenID Connect), MFA(Multi Factor Authentication) and many others. Then there are services that implement these technologies to put it all together into a cohesive system. There's Azure AD, Okta, JumpCloud, Auth0, Keycloak, Authelia, FreeIPA, Gluu, Anvil and many others.

> "The problem with providing "an answer" is because OAuth2, OpenID Connect, and all of the surrounding protocols do a great job of breaking security protocols down to single-responsibilities. That turns the modelling process into a five-dimensional chess game." [1.]

This document seeks to address and work through the challenge of setting up a manageable system to provision user accounts and user access groups in a free, open source & self hostable way. Additionally I'd like to touch on implementing support for this authentication and user account management infrastructure into newly developed services.

This document will likely change and evolve as time goes on and the setup evolves though, it should be used as the starting point of reference to dive deeper into the setup and reasoning behind the technologies selected to make this happen.

## Why

At the time of writing this we're managing a couple dozen services, most of which have their own account registration process. This quickly becomes untenable and a barrier to productivity. Not to mention the challenges of managing access & security when introducing multiple users. We need a centralized source of truth for credentials/accounts. This way jumping between different services becomes seamless. This is especially the case when services are all located under different subdomains of the same domain name, which results in browsers suggesting the same credential between each service anyways.

These are the services at the time of writing this that we would like to manage the identity/credentials for:
- Nextcloud
- Homeassistant
- Prometheus
- Grafana
- Wiki
- Gitea
- Drone
- Docker Registry
- Statping
- Wireguard
- Unifi
- Any custom developed service

## Open Source/Self Hostable VS. Paid Solutions

The Paid/Closed source solutions can be seen as the state of the art and generally offer the greatest support and ease of use though we've already stated that our desire is to go with self hostable & open source solution to limit cost and maintain ownership of the solution. The paid/closed source solutions are however a helpful point of reference for what can be achieved.

Paid/Closed Source:
- Microsoft Active Directory(And it's many implementations such as Azure AD)
- JumpCloud
- Okta
- Auth0

Grey Area Inbetween:
- [FusionAuth](https://fusionauth.io/)
- [Pritunl](https://pritunl.com/)

Open Source/Self Hostable:
- [Keycloak](https://www.keycloak.org/)
- [Authelia](https://github.com/authelia/authelia)
- [FreeIPA](https://www.freeipa.org/page/Main_Page)
- [Gluu](https://www.gluu.org/)
- [Anvil](https://anvil.io/)
- [ORY](https://www.ory.sh/)
- [dex](https://dexidp.io/)

So immediately we can go ahead and rule out the paid/closed source options as we've already asserted we want an open source self hostable solution. So we'll go ahead and work through the open source/self hostable options. 

Anvil looks like a compelling feature full option however this one is easy to rule out as it's no longer maintained.

Authelia receives frequent mention on the r/selfhosted & r/homelab when searching this topic. It works natively with the traefik reverse proxy we're using. It supports 2FA via google duo and other methods. However as far as I can tell this doesn't provide a solution to manage users accounts and instead works as a gateway auth to the service, where you will then still need to sign in/register an account for each. [6.]

FreeIPA appears to be an identity management service and be provided as a backing service for solutions like Keycloak to achieve SSO. It is open source and sponsored by Redhat. [7.]

Gluu seems to get mentioned though I have yet to see a positive review or account of it actually being used on r/selfhosted or r/homelab. It mostly comes up as an alternative to Keycloak, though not as a primary recommendation. [2.]

FusionAuth & ORY both similarly come up in the same light as Gluu in that they're mentioned as alternatives to Keycloak. The discussions I've seen have yet to say much beyond that. Though there was one account of a user giving up on setting up ORY as they were unable to get it working. [3.]

Keycloak, as far as I saw appears as the most consistently recommended solution, right above Authelia. It appears that if you simply want auth in front of your services, setup with an external service such as Google for OAuth then Authelia is the way to go. However Keycloak can handle the entire process on your own machine. [4.] [5.] It's typically deployed via docker and provides a web ui for managing users, & permission groups. It also gets mentioned as integrating with Traefik with is a positive sign. It's also open source and sponsored by Redhat. Keycloak appears to be able to work stand alone or in conjunction with FreeIPA or other backing services for identity management/AD.

## Keycloak

As you may have guessed, Keycloak presents it's self as the strongest contender. There may be other options that would work well or better for our needs if further investigation was done but Keycloak appears as a strong option.

One detail to note is that in our configuration you'll need the `PROXY_ADDRESS_FORWARDING="true"` environment variable to be able to get it working behind the traefik reverse proxy.

## Setup with Dokuwiki
- https://rmm.li/wiki/doku.php?id=linux_server_manuals:dokuwiki_authentication_against_keycloak

Add a new client with following settings:
Client ID: dokuwiki
Client Protocol: openid-connect

Then edit the new adapter settings
Access Type: confidential
Valid Redirect URLS: https://example.com/* (Or wherever dokuwiki is stored)

Save and then go to the newly appeard tab “credentials”.
Set Client Authenticator to “Client id and secret” and copy the secret.

If you want dokuwiki to know about the groups keycloak assigns to the users, go to the tab “Mappers”, then click “create”.
Set following attributes:
Name: groups
Mapper Type: “group membership”
Token Claim Name: “groups”
Full group paths: off
Add to id token: off
Add to access token: off
Add to userinfo: on

- Go to extension manager page
- Install authpdo plugin by  Andreas Gohr
- Go to configuration settings page
- Add the following configurations through the ui

plugin»oauth»keycloak-key=dokuwiki
plugin»oauth»keycloak-secret=PutTheSecretFromKeycloakHere
plugin»oauth»keycloak-authurl=https://keycloak.lazz.tech/auth/realms/master/protocol/openid-connect/auth
plugin»oauth»keycloak-tokenurl=https://keycloak.lazz.tech/auth/realms/master/protocol/openid-connect/token
plugin»oauth»keycloak-userinfourl=https://keycloak.lazz.tech/auth/realms/master/protocol/openid-connect/userinfo
plugin»oauth»singleService=Keycloak

Then save.


# References
1. https://www.reddit.com/r/selfhosted/comments/dr7dan/customer_identity_and_access_management/f6hsvht?utm_source=share&utm_medium=web2x&context=3
2. https://www.reddit.com/r/selfhosted/comments/fxotbi/experiences_with_keycloak_alternatives/fn1u3p4?utm_source=share&utm_medium=web2x&context=3
3. https://www.reddit.com/r/selfhosted/comments/hzesur/keycloak_as_okta_universal_directory_alternative/fzk3kxa?utm_source=share&utm_medium=web2x&context=3
4. https://www.reddit.com/r/selfhosted/comments/hrcb66/sso_on_multiple_selfhosted_services/fy38lkx?utm_source=share&utm_medium=web2x&context=3
5. https://www.reddit.com/r/selfhosted/comments/hrcb66/sso_on_multiple_selfhosted_services/fy3tuk2?utm_source=share&utm_medium=web2x&context=3
6. https://www.reddit.com/r/selfhosted/comments/e0sfl4/seamless_login_and_accounts_across_services/fb6s3qr?utm_source=share&utm_medium=web2x&context=3
7. https://www.reddit.com/r/linuxadmin/comments/gdegxl/keycloak_freeipa_openldap_proscons/fph06mz?utm_source=share&utm_medium=web2x&context=3