# Bridgehead

This repository contains all information and tools to deploy a bridgehead. If you have any questions about deploying a bridgehead, please [contact us](mailto:verbis-support@dkfz-heidelberg.de).


# Table of Contents

1. [About](#about)
    - [Projects](#projects)
        - [GBA/BBMRI-ERIC](#gbabbmri-eric)
        - [CCP(DKTK/C4)](#ccpdktkc4)
        - [NNGM](#nngm)
    - [Bridgehead Components](#bridgehead-components)
        - [Blaze Server](#blaze-serverhttpsgithubcomsamplyblaze)  
        - [Connector](#connector) 
1. [Requirements](#requirements)
    - [Hardware](#hardware)
    - [System](#system-requirements)
      - [git](#git)
      - [docker](#dockerhttpsdocsdockercomget-docker)
      - [systemd](#systemd)
2. [Getting Started](#getting-started)
    - [DKTK](#dktkc4)
    - [C4](#c4)
    - [GBA/BBMRI-ERIC](#gbabbmri-eric)
3. [Configuration](#configuration)
4. [Managing your Bridgehead](#managing-your-bridgehead)
    - [Systemd](#on-a-server)
    - [Without Systemd](#on-developers-machine)
4. [Pitfalls](#pitfalls)
5. [Migration-guide](#migration-guide)
7. [License](#license)


---

## About

TODO: Insert comprehensive feature list of the bridgehead? Why would anyone install it?

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

After adding the User you need to change the ownership of the directory to the bridgehead user.

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

#### Basic Auth

- [ ] TODO: Explain what will work without this

For Data protection we use basic authenfication for some services. To access those services you need an username and password combination. If you start the bridgehead without basic auth, then those services are not accesbile. We provide a script which set the needed config for you, just run the script and follow the instructions.

``` shell
add_user.sh
```

The result needs to be set in either in the _systemd service_ or in your console.

When just running the bridgehead you need to export the auth variable. Be aware that this export is only for the current session in the environment and after exit it will not be accessible anymore.

``` shell
export bc_auth_user=<output>
```

Cation: you need to escape occurring dollar signs.

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

## Roadmap

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
