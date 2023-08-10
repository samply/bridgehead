# Login
The login component is a local Keycloak instance. In the future will be replaced by the central keycloak instance
or maybe can be used to add local identity providers to the bridgehead or just to simplify the configuration of
the central keycloak instance for the integration of every new bridgehead.
The basic configuration of our Keycloak instance is contained in a small json file.

### Teiler User
Currently, the local keycloak is used by the teiler. There is a basic admin user in the basic configuration of keycloak.
The user can be configured with the environment variables TEILER_ADMIN_XXX.

## Login-DB
Keycloak requires a local database for its configuration. However, as we use an initial json configuration file, if no
local identity provider is configured nor any local user, theoretically we don't need a volume for the login.
