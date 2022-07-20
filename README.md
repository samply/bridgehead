# Bridgehead

This repository contains all information and tools to deploy a bridgehead. If you have any questions about deploying a bridgehead, please [contact us](mailto:verbis-support@dkfz-heidelberg.de).

## Table of Contents

1. [About](#about)
2. [Requirements](#requirements)
    - [Hardware](#hardware)
    - [System Requirements](#system-requirements)
      - [git](#git)
      - [docker](#dockerhttpsdocsdockercomget-docker)
3. [Getting Started](#getting-started)
    - [Installation](#installation)
4. [Configuration](#configuration)
    - [Authentication](#basic-auth)
        - [systemd](#systemd)
        - [environment](#without-systemd)
    - [Testing](#testing-your-bridgehead)
    - [After the Installation](#after-the-installation)
5. [Roadmap](#roadmap-🚀)
6. [Authors](#authors)
7. [License](#license)
8. [Build With](#build-with)
9. [Acknowledgements](#acknowledgements)

---

## About

Maybe this would explain the purpose of this repository better:

The Bridgehead is a collection of Software componentens for medical informatics usecases. This repository aims to ease the deployment of those components to their users, by providing consistent configuration and software updates across the usecases. For this purpose, a minimal set of default components is integrated within this repository:

- A forward proxy, as a central point for scanning and logging outgoing network traffic of the components deployed with the bridgehead
- A reverse proxy, that distributes incoming network traffic to the components of the bridgehead.
- A landingpage, that offers a quick graphical overview of all components running in the bridgehead

Because the different use cases of the bridgehead all require different components, we provide detailed project specific documentation on these inside [Projects](docs/projects.md).

---

## Requirements

### Hardware

For running your bridgehead we recommend the follwing Hardware:

- 4 CPU cores
- At least 8 GB Ram
- 100GB Hard Drive, SSD recommended

### System Requirements

Before starting the installation process, please ensure that following software is available on your system:

#### [Git](https://git-scm.com/downloads)

Check if you have at least git 2.0 installed on the system with:

``` shell
git --version
```

#### [Docker](https://docs.docker.com/get-docker/)

To check your docker installation, you should execute the docker with --version:

``` shell
docker --version
```

The Version should be higher than "20.10.1". Otherwise you will have problems starting the bridgehead. The next step is to check ``` docker-compose```  with:

``` shell
docker-compose --version
```

The recomended version is "2.XX" and higher. If docker-compose was not installed with docker follow these [instructions](https://docs.docker.com/compose/install/#install-compose-as-standalone-binary-on-linux-systems). To futher check your docker and docker-compose installation, please run the following command. 

``` shell
docker-compose -f - up <<EOF
version: "3.7"
services:
  hello-world:
    image: hello-world
EOF
```
Docker will now download the "hello-world" docker image and try to execute it. After the download you should see a message starting with "Hello from Docker!".

> NOTE: If the download of the image fails (e.g with "connection timed out" message), ensure that you have correctly set the proxy for the docker daemon. Refer to ["Docker Daemon Proxy Configuration" in the "Pitfalls" section](#docker-daemon-proxy-configuration)

#### [systemd](https://systemd.io/)

You shouldn't need to install it yourself, If systemd is not available on your system you should get another system.
To check if systemd is available on your system, please execute

``` shell
systemctl --version
```

If systemd is not installed, you can start the bridgehead. However, for productive use we recomend using systemd.

---

## Getting Started

### Installation

If your system passed all checks from ["Requirements" section], you are now ready to download the bridgehead.

First, clone the repository to the directory "/srv/docker/bridgehead":

``` shell
sudo mkdir -p /srv/docker/;
sudo git clone https://github.com/samply/bridgehead.git /srv/docker/bridgehead;
```

It is recomended to create a user for the bridgehead service.  This should be done after clone the repository. Since not all linux distros support ```adduser```, we provide an action for the systemcall ```useradd```. You should try the first one, when the systm can't create the user you should try the second one.

``` shell
adduser --no-create-home --disabled-login --ingroup docker --gecos "" bridgehead
```

``` shell
useradd -M -g docker -N -s /sbin/nologin bridgehead
```

After adding the User you need to change the ownership of the directories to the bridgehead user.

``` shell
chown bridgehead /srv/docker/bridgehead/ -R
```

### Configuration

> NOTE: If you are part of the CCP-IT we will provide you another link for the configuration.

Next, you need to configure a set of variables, specific for your site with not so high security concerns. You can clone the configuration template at [GitHub](https://github.com/samply/bridgehead-config). The confiugration of the bridgehead should be located in /etc/bridghead.

``` shell
sudo git clone https://github.com/samply/bridgehead-config.git /etc/bridgehead;
```

After cloning or forking the repository you need to add value to the template. If you are a part of the CCP-IT you will get an already filled out config repo.

After cloning your configuration you need to change the ownership of the folder aswell.

``` shell
chown bridgehead /etc/bridgehead/ -R
```

#### Basic Auth

- [ ] TODO: Explain what will work without this

For data protection we use basic authenfication for some services. To access those services you need an username and password combination. If you start the bridgehead without basic auth, then those services are not accesbile. We provide a script to generate a basic auth login.

``` shell
lib/add_bc_user.sh
```

The result needs to be set in either in the _systemd service_ or in your environment. 

##### systemd

``` shell
sudo systemctl edit <project>
```
``` conf
[Service]
...
Environment=bc_auth_users=<hash>
```

##### without systemd

Either add the hash to the environment with an export, or add it to /etc/environment

``` shell
export bc_auth_user=<output>
```

Caution: for exporting need to escape occurring dollar signs with back slashes.

### Testing your bridgehead

We recomend to run first with the start and stop script. If you have trouble starting the bridghead have a look at the troubleshooting section.

Now you ready to run a bridgehead instance. The bridgehead scripts checks if your configuration is correct. To check if everything works, execute the following:
``` shell
/srv/docker/bridgehead/bridgehead start <Project>
```

You should now be able to access the landing page on your system, e.g "https://<your-host>/". 

To shutdown the bridgehead just run.
``` shell
/srv/docker/bridgehead/bridgehead stop <Project>
```

### After the Installation

After starting your bridgehead, visit the landing page under the hostname. If you singed your own ssl certificate, there is probable an error message. However, you can accept it as exception. 

On this page, there are all important links to each component, central and local. 

---

## Roadmap 🚀

- [ ] Securely manage secrets using the [vault warden fetcher](https://github.com/samply/bridgehead-vaultfetcher)
- [ ] Integrate the [samply/share-client](https://github.com/samply/share-client) for the [DKTK](https://dktk.dkfz.de) project with the new deployment
- [ ] Replace the multiple docker-compose files by using a template engine (e.g. [Jinja](https://jinja.palletsprojects.com/en/3.1.x/)) driven approach
- [ ] Migrate sites using [samply/bridgehead-deployment](https://github.com/samply/bridgehead-deployment)
- [ ] Integrate an OAuth Provider (e.g. [keycloak](https://www.keycloak.org/)) in the deployment package to replace basic authentication for local components

---

## Authors

- **Patrick Skowronek** - Team Member
- **Martin Lablans** - Team Member
- **Torben Brenner** - Team Member
- **David Croft** - Team Member

---

## License

Copyright 2019 - 2022 The Samply Community

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

---

## Build With

- [Git](https://git-scm.com/)
- [Docker](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [systemd](https://systemd.io/)

---

## Acknowledgements

- [samply/bridgehead-deployment](https://github.com/samply/bridgehead-deployment)
