# Bridgehead

A Bridgehead is a set of components that must be installed locally, in order to connect your clinic or research centre to a federated search system. This repository contains the information and tools that you will need to deploy a Bridgehead. If you have questions, please [contact us](mailto:verbis-support@dkfz-heidelberg.de).


TOC

1. [Requirements](#requirements)
    - [Hardware](#hardware)
    - [System](#system)
      - [Git](#git)
      - [Docker](#docker)
2. [Deployment](#deployment)
    - [Installation](#installation)
    - [Register with Beam](#register-with-beam)
    - [Starting and stopping your Bridgehead](#starting-and-stopping-your-bridgehead)
    - [Systemd service configuration](#systemd-service-configuration)
3. [Additional Services](#additional-Services)
    - [Monitoring](#monitoring)
    - [Register with a Directory](#register-with-a-Directory)
4. [Configuration](#configuration)
    - [HTTPS Access](#https-access)
    - [Locally Managed Secrets](#locally-managed-secrets)
    - [Git Proxy Configuration](#git-proxy-configuration)
    - [Docker Daemon Proxy Configuration](#docker-daemon-proxy-configuration)
5. [License](#license)

## Requirements

### Hardware

For running your Bridgehead we recommend the follwing Hardware:

- 4 CPU cores
- At least 8 GB Ram
- 100GB Hard Drive, SSD recommended

### System

Before starting the installation process, please ensure that following software is available on your system:

#### Git

Check if you have at leat git 2.0 installed on the system with:

``` shell
git --version
```

#### Docker

To check your Docker installation, you should execute the docker with --version:

``` shell
docker --version
```

The Version should ideally be higher than "20.10.1". The next step is to check ``` docker-compose```  with:

``` shell
docker-compose --version
```
The recomended version is "2.XX" and higher.

If docker or docker-compose are not installed, please refer to the [Docker website](https://docs.docker.com).

## Deployment

### Installation

First, clone the repository to the directory "/srv/docker/bridgehead":

``` shell
sudo mkdir -p /srv/docker/;
sudo git clone https://github.com/samply/bridgehead.git /srv/docker/bridgehead;
```

Now create a user for the Bridgehead service:

``` shell
sudo useradd -M -g docker -N -s /sbin/nologin bridgehead
```

After adding the user you will need to change the ownership of the directory to the Bridgehead user.

``` shell
sudo chown bridgehead /srv/docker/bridgehead/ -R
```
Download the configuration repository:

``` shell
sudo git clone https://github.com/samply/bridgehead-config.git -b fix/bbmri-config /etc/bridgehead;
```
Change ownership:
``` shell
sudo chown bridgehead /etc/bridgehead/ -R
```
Edit /etc/bridgehead/bbmri.conf and modify SITE_ID and SITE_NAME to be relevant to your biobank. SITE_ID should not contains spaces. By convention, it is lower-case. E.g.:
```
SITE_ID="toulouse-prod"
SITE_NAME="Toulouse"
```

### Register with Beam

You will need to register with Beam in order to be able to start your Bridgehead. Please send an email to: bridgehead@helpdesk.bbmri-eric.eu, mentioning the SITE_ID that you chose above.

The response will contain your private key for Beam.

Create a file for this private key:

``` shell
/etc/bridgehead/pki/$SITE_ID.priv.pem
```

### Starting and stopping your Bridgehead
To start your new Bridgehead, type:

```shell
sudo /srv/docker/bridgehead/bridgehead start bbmri
```
The script may break, because Spot tries to connect to Blaze, but Blaze is not yet ready, causing Spot to terminate. Try to start and stop the script a few times.

To shut down the Bridgehead, type:
```shell
sudo /srv/docker/bridgehead/bridgehead stop bbmri
```

### Systemd service configuration

The Linux "systemctl" command enables you to autostart processes whenever your server is booted. Note that some Linux distributions do not support this command.

In this repository you will find tools that allow you to take advantage of "systemctl" to automatically start the Bridgehead whenever your server gets restarted. You can set this up by executing the [bridgehead](./bridgehead) script:
``` shell
sudo /srv/docker/bridgehead/bridgehead install bbmri
```

This will install the systemd units to run and update the bridghead.

If your site operates with a proxy, you will need to set it up with ```systemctl edit``` as follows:

``` shell
sudo systemctl edit bridgehead@bbmri.service;
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

To make the configuration active, you need to tell systemd to reload the configuration and restart the docker service:

``` shell
sudo systemctl daemon-reload;
sudo systemctl bridgehead@bbmri.service;
```

## Additional Services

### Monitoring

We provide a central monitoring service, which checks the health of your Bridgehead 24/7. Using this service is optional but recommended.

You can register for it by sending a request to: bridgehead@helpdesk.bbmri-eric.eu.

The confirmation of your registration will contain a monitoring API key.

You need to add the key to the "/etc/bridgehead/bbmri.conf" file:
``` conf
MONITOR_APIKEY=1b9e5e21-8b34-5382-8590-7eae98a4f6d3
```
(your key will be different to the one shown above, obviously).

It should now show up in the monitoring with grey (updates) and green (query) messages at the next full hour.

### Register with a Directory

The [Directory][directory] is a BBMRI project that aims to catalog all biobanks in Europe and beyond. Each biobank is given its own unique ID and the Directory maintains counts of the number of donors and the number of samples held at each biobank. You are strongly encouraged to register with the Directory, because this opens the door to further services, such as the [Negotiator][negotiator].

Generally, you should register with the BBMRI national node for the country where your biobank is based. You can find a list of contacts for the national nodes [here](http://www.bbmri-eric.eu/national-nodes/). If your country is not in this list, or you have any questions, please contact the [BBMRI helpdesk](mailto:directory@helpdesk.bbmri-eric.eu). If your biobank is for COVID samples, you can also take advantage of an accelerated registration process [here](https://docs.google.com/forms/d/e/1FAIpQLSdIFfxADikGUf1GA0M16J0HQfc2NHJ55M_E47TXahju5BlFIQ).

Your national node will give you detailed instructions for registering, but for your information, here are the basic steps:

* Log in to the Directory for your country.
* Add your biobank and enter its details, including contact information for a person involved in running the biobank.
* You will need to create at least one collection.

## Configuration

### HTTPS Access

We advise to use https for all service of your Bridgehead. HTTPS is enabled on default. For starting the bridghead you need a ssl certificate. You can either create it yourself or get a signed one. You need to drop the certificates in /certs.

The Bridgehead create one autotmatic on the first start. However, it will be unsigned and we recomend to get a signed one.


### Locally Managed Secrets

This section describes the secrets you need to configure locally through the configuration

| Name                                 | Recommended Value                                                                                 | Description |  
|--------------------------------------|---------------------------------------------------------------------------------------------------| ----------- |  
| HTTP_PROXY_USER                      |                                                                                                   | Your local http proxy user |
| HOSTIP                               | Compute with: `docker run --rm --add-host=host.docker.internal:host-gateway ubuntu cat /etc/hosts | grep 'host.docker.internal' | awk '{print $1}'` | The ip from which docker containers can reach your host system. |
| HOST                                 | Compute with: `hostname`                                                                          |The hostname from which all components will eventually be available|
| HTTP_PROXY_PASSWORD                  |                                                                                                   |Your local http proxy user's password|
| HTTPS_PROXY_USER                     |                                                                                                   |Your local https proxy user|
| HTTPS_PROXY_PASSWORD                 || Your local https proxy user's password                                                            |
| CONNECTOR_POSTGRES_PASS              | Random String                                                                                     |The password for your project specific connector.|
| STORE_POSTGRES_PASS                  | Random String                                                                                     |The password for your local datamanagements database (only relevant in c4)|
| ML_DB_PASS                           | Random String                                                                                     |The password for your local patientlist database|
| MAGICPL_API_KEY                      | Random String                                                                                     |The apiKey used by the local datamanagement to create pseudonymes.|
| MAGICPL_MAINZELLISTE_API_KEY         | Random String                                                                                     |The apiKey used by the local id-manager to communicate with the local patientlist|
| MAGICPL_API_KEY_CONNECTOR            | Random String                                                                                     |The apiKey used by the connector to communicate with the local patientlist|
| MAGICPL_MAINZELLISTE_CENTRAL_API_KEY | You need to ask the central patientlists admin for this.                                          |The apiKey for your machine to communicate with the central patientlist|
| MAGICPL_CENTRAL_API_KEY              | You need to ask the central controlnumbergenerator admin for this.                                |The apiKey for your machine to communicate with the central controlnumbergenerator|
| MAGICPL_OIDC_CLIENT_ID               || The client id used for your machine, to connect with the central authentication service           |
| MAGICPL_OIDC_CLIENT_SECRET           || The client secret used for your machine, to connect with the central authentication service       |

### Git Proxy Configuration

Unlike most other tools, git doesn't use the default proxy variables "http_proxy" and "https_proxy". To make git use a proxy, you will need to adjust the global git configuration:

``` shell
sudo git config --global http.proxy http://<your-proxy-host>:<your-proxy-port>;
sudo git config --global https.proxy http://<your-proxy-host>:<your-proxy-port>;
```
> NOTE: Some proxies may require user and password authentication. You can adjust the settings like this: "http://<your-proxy-user>:<your-proxy-user-password>@<your-proxy-host>:<your-proxy-port>".
> NOTE: It is also possible that a proxy requires https protocol, so you can replace this to.

You can check that the updated configuration with

``` shell
sudo git config --global --list;
```

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

## License

Copyright 2019 - 2022 The Samply Community

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
