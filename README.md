# Bridgehead

This repository contains all information and tools to deploy a bridgehead. If you have any questions about deploying a bridgehead, please [contact us](mailto:verbis-support@dkfz-heidelberg.de).

TODO: Insert comprehensive feature list of the bridgehead? Why would anyone install it?

## Requirements
Before starting the installation process, please ensure that following software is available on your system:

### [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
To check that you have a working git installation, please run
``` shell
cd ~/;
git clone https://github.com/octocat/Hello-World.git;
cat ~/Hello-World/README;
rm -rf Hello-World;
```
If you see the output "Hello World!" your installation should be working.

### [Docker](https://docs.docker.com/get-docker/)
To check your docker installation, you can try to execute dockers "Hello World" Image. The command is:
``` shell
docker run --rm --name hello-world hello-world;
```
Docker will now download the "hello-world" docker image and try to execute it. After the download you should see a message starting with "Hello from Docker!".

> NOTE: If the download of the image fails (e.g with "connection timed out" message), ensure that you have correctly set the proxy for the docker daemon. Refer to ["Docker Daemon Proxy Configuration" in the "Pitfalls" section]()

### [Docker Compose](https://docs.docker.com/compose/install/)
To check your docker-compose installation, please run the following command. It uses the "hello-world" image from the previous section:
``` shell
docker-compose -f - up <<EOF
version: "3.9"
services:
  hello-world:
    image: hello-world
EOF
```
After executing the command, you should again see the message starting with "Hello from Docker!".

### [systemd](https://systemd.io/)
You shouldn't need to install it yourself. If systemd is not available on your system you should get another system.
To check if systemd is available on your system, please execute

``` shell
systemctl --version
```

## Getting Started

If your system passed all checks from ["Requirements" section], you are now ready to download the bridgehead.

First, clone the repository to the directory "/srv/docker/bridgehead":

``` shell
sudo mkdir /srv/docker/;
sudo git clone https://github.com/samply/bridgehead.git /srv/docker/bridgehead;
```

Next, you need to download the cooperatively created site-configuration to the directory "/srv/docker/bridgehead/site-config":

``` shell
sudo git clone <link-to-sites-configuration-repository> /srv/docker/bridgehead/site-config;
```

After this, you need to install the systemd units. This is currently done with the [install-bridgehead.sh script](./install-bridgehead.sh).

You can execute it with
``` shell
sudo ./install-bridgehead.sh
```

Finally, you need to configure your sites secrets. These are places as configuration for each bridgeheads system unit. Refer to the section for your specific project:

### DKTK/C4

You can create the site specific configuration with: 

``` shell
sudo systemctl edit bridgehead@dktk.service;
```

This will open your default editor allowing you to edit the docker system units configuration. Insert the following lines in the editor and define your machines secrets. You share some of the ID-Management secrets with the central patientlist (Mainz) and controlnumbergenerator (Frankfurt). Refer to the ["Configuration" section]() for this.

``` conf
[Service]
Environment=HOSTIP=
Environment=HOST=
Environment=HTTP_PROXY_USER=
Environment=HTTP_PROXY_PASSWORD=
Environment=HTTPS_PROXY_USER=
Environment=HTTPS_PROXY_PASSWORD=
Environment=CONNECTOR_POSTGRES_PASS=
Environment=STORE_POSTGRES_PASS=
Environment=ML_DB_PASS=
Environment=MAGICPL_API_KEY=
Environment=MAGICPL_MAINZELLISTE_API_KEY=
Environment=MAGICPL_API_KEY_CONNECTOR=
Environment=MAGICPL_MAINZELLISTE_CENTRAL_API_KEY=
Environment=MAGICPL_CENTRAL_API_KEY=
Environment=MAGICPL_OIDC_CLIENT_ID=
Environment=MAGICPL_OIDC_CLIENT_SECRET=
```

For the C4 project, you need to additionally set the "LDM_URL_BASE" setting in the configuration table to null. You need to execute this after starting the bridgehead system unit for c4:

``` shell
docker exec bridgehead-c4-connector-db-1 bash -c 'psql -U $POSTGRES_USER $POSTGRES_DB -c "UPDATE samply.configuration SET setting=\'\' WHERE name=\'LDM_URL_BASE\'"';
```

To make the configuration effective, you need to tell systemd to reload the configuration and restart the docker service:

``` shell
sudo systemctl daemon-reload;
sudo systemctl restart docker;
```

### GBA/BBMRI-ERIC

You can create the site specific configuration with: 

``` shell
sudo systemctl edit bridgehead@dktk.service;
```

This will open your default editor allowing you to edit the docker system units configuration. Insert the following lines in the editor and define your machines secrets.

``` conf
[Service]
Environment=HOSTIP=
Environment=HOST=
Environment=HTTP_PROXY_USER=
Environment=HTTP_PROXY_PASSWORD=
Environment=HTTPS_PROXY_USER=
Environment=HTTPS_PROXY_PASSWORD=
Environment=CONNECTOR_POSTGRES_PASS=
```

To make the configuration effective, you need to tell systemd to reload the configuration and restart the docker service:

``` shell
sudo systemctl daemon-reload;
sudo systemctl restart docker;
```

### Developers
Because some developers machines doesn't support system units (e.g Windows Subsystem for Linux), we provide a dev environment [configuration script](./init-dev-environment.sh).
It is not recommended to use this script in production!

## Configuration

### Locally Managed Secrets
This section describes the secrets you need to configure locally through the configuration
|Name|Recommended Value|Description|
|HOSTIP|Compute with: `docker run --rm --add-host=host.docker.internal:host-gateway ubuntu cat /etc/hosts | grep 'host.docker.internal' | awk '{print $1}'`|The ip from which docker containers can reach your host system.|
|HOST|Compute with: `hostname`|The hostname from which all components will eventually be available|
|HTTP_PROXY_USER||Your local http proxy user|
|HTTP_PROXY_PASSWORD||Your local http proxy user's password|
|HTTPS_PROXY_USER||Your local https proxy user|
|HTTPS_PROXY_PASSWORD||Your local https proxy user's password|
|CONNECTOR_POSTGRES_PASS|Random String|The password for your project specific connector.|
|STORE_POSTGRES_PASS|Random String|The password for your local datamanagements database (only relevant in c4)|
|ML_DB_PASS|Random String|The password for your local patientlist database|
|MAGICPL_API_KEY|Random String|The apiKey used by the local datamanagement to create pseudonymes.|
|MAGICPL_MAINZELLISTE_API_KEY|Random String|The apiKey used by the local id-manager to communicate with the local patientlist|
|MAGICPL_API_KEY_CONNECTOR|Random String|The apiKey used by the connector to communicate with the local patientlist|
|MAGICPL_MAINZELLISTE_CENTRAL_API_KEY|You need to ask the central patientlists admin for this.|The apiKey for your machine to communicate with the central patientlist|
|MAGICPL_CENTRAL_API_KEY|You need to ask the central controlnumbergenerator admin for this.|The apiKey for your machine to communicate with the central controlnumbergenerator|
|MAGICPL_OIDC_CLIENT_ID||The client id used for your machine, to connect with the central authentication service|
|MAGICPL_OIDC_CLIENT_SECRET||The client secret used for your machine, to connect with the central authentication service|

### Cooperatively Managed Secrets
> TODO: Describe secrets from site-config 

## Managing your Bridgehead

> TODO: Rewrite this section (restart, stop, uninstall, manual updates)
There two methods to start the bridgehead. For Windows, Linux and Mac OS you can use the start-bridgehead.sh to deploy it wit docker-compose. If will also check some other setting of your system.

The second methods is using the systemd management tool you start, stop and update your bridgehead.

Just run the install-bridgehead and thats it.

## Migration Guide
> TODO: How to transfer from windows/gbn

## Pitfalls
### [Git Proxy Configuration](https://gist.github.com/evantoli/f8c23a37eb3558ab8765)
Unlike most other tools, git doesn't use the default proxy variables "http_proxy" and "https_proxy". To make git use a proxy, you will need to adjust the global git configuration:

``` shell
git config --global http.proxy http://<your-proxy-host>:<your-proxy-port>;
git config --global https.proxy http://<your-proxy-host>:<your-proxy-port>;
```
> NOTE: Some proxies may require user and password authentication. You can adjust the settings like this: "http://<your-proxy-user>:<your-proxy-user-password>@<your-proxy-host>:<your-proxy-port>".
> NOTE: It is also possible that a proxy requires https protocol, so you can replace this to.

You can check that the updated configuration with

``` shell
git config --global --list;
```

Please repeat this configuration for the root user to. Otherwise the update service won't be able to properly update the git repository.

### Docker Daemon Proxy Configuration
Docker has a background daemon, responsible for downloading images and starting them. To configure the proxy for this daemon, use the systemctl command:

``` shell
sudo systemctl edit docker
```

This will open your default editor allowing you to edit the docker system units configuration. Insert the following lines in the editor, replace <your-proxy-host> and <your-proxy-port> with the corresponding values for your machine and save the file:
``` conf
[Service]
Environment=HTTP_PROXY=http://<your-proxy-host>:<your-proxy-port>
Environment=HTTPS_PROXY=http://<your-proxy-host>:<your-proxy-port>
Environment=FTP_PROXY=http://<your-proxy-host>:<your-proxy-port>
```
> NOTE: Some proxies may require user and password authentication. You can adjust the settings like this: "http://<your-proxy-user>:<your-proxy-user-password>@<your-proxy-host>:<your-proxy-port>".
> NOTE: It is also possible that a proxy requires https protocol, so you can replace this to.

The file should now be at the location "/etc/systemd/system/docker.service.d/override.conf". You can proof check with
``` shell
cat /etc/systemd/system/docker.service.d/override.conf;
```

To make the configuration effective, you need to tell systemd to reload the configuration and restart the docker service:

``` shell
sudo systemctl daemon-reload;
sudo systemctl restart docker;
```
