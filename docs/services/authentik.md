## Authentik

## Matrix
- https://goauthentik.io/integrations/services/matrix-synapse/

```yaml
oidc_providers:
  - idp_id: authentik
    idp_name: authentik
    discover: true
    issuer: "https://authentik.company/application/o/app-slug/"
    client_id: "*client id*"
    client_secret: "*client secret*"
    scopes:
      - "openid"
      - "profile"
      - "email"
    user_mapping_provider:
      config:
        localpart_template: "{{ user.name }}"
        display_name_template: "{{ user.name }}"
```