# Authentication

There are many technologies that exist to fulfill authentication, user access management and the like. It can be difficult to parse through all the options and technologies. There's SAML(Security Assertion Markup Language), OAuth(open-standard authorization protocol), LDAP(Lightweight Directory Access Protocol), AD(Active Directory), SSO(Single Sign On), OIDC(OpenID Connect), MFA(Multi Factor Authentication) and many others. Then there are services that implement these technologies to put it all together into a cohesive system. There's Azure AD, Okta, JumpCloud, Auth0, Keycloak, Authelia, FreeIPA, Gluu, Anvil and many others.

This document seeks to address and work through the challenge of setting up a manageable system to provision user accounts and user access groups in a free, open source & self hostable way. Additionally I'd like to touch on implementing support for this authentication and user account management infrastructure into newly developed services.

This document will likely change and evolve as time goes on and the setup evolves though, it should be used as the starting point of reference to dive deeper into the setup and reasoning behind the technologies selected to make this happen.

# Open Source/Self Hostable VS. Paid Solutions

The Paid/Closed source solutions can be seen as the state of the art and generally offer the greatest support and ease of use though we've already stated that our desire is to go with self hostable & open source solution to limit cost and maintain ownership of the solution. The paid/closed source solutions are however a helpful point of reference for what can be achieved.

Paid/Closed Source:
- Microsoft Active Directory(And it's many implementations such as Azure AD)
- JumpCloud
- Okta
- Auth0

Open Source/Self Hostable:
- Keycloak
- Authelia
- FreeIPA
- Gluu
- Anvil