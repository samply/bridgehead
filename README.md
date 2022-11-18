# Bridgehead

The Bridgehead is a secure, low-effort solution to connect your research institution to a federated research network. It bundles interoperable, open-source software components into a turnkey package for installation on one of your secure servers. The Bridgehead is pre-configured with sane defaults, centrally monitored and with an absolute minimum of "moving parts" on your side, making it an extremely low-maintenance gateway to data sharing.

This repository is the starting point for any information and tools you will need to deploy a Bridgehead. If you have questions, please [contact us](mailto:verbis-support@dkfz-heidelberg.de).

1. [Requirements](#requirements)
    - [Hardware](#hardware)
    - [System](#system)
      - [Git](#git)
      - [Docker](#docker)
2. [Deployment](#deployment)
    - [Installation](#installation)
    - [Register with Samply.Beam](#register-with-samplybeam)
    - [Starting and stopping your Bridgehead](#starting-and-stopping-your-bridgehead)
    - [Auto-starting your Bridgehead when the server starts](#auto-starting-your-bridgehead-when-the-server-starts)
3. [Additional Services](#additional-Services)
    - [Monitoring](#monitoring)
    - [Register with a Directory](#register-with-a-Directory)
4. [Site-specific configuration](#site-specific-configuration)
    - [HTTPS Access](#https-access)
    - [Locally Managed Secrets](#locally-managed-secrets)
    - [Git Proxy Configuration](#git-proxy-configuration)
    - [Docker Daemon Proxy Configuration](#docker-daemon-proxy-configuration)
    - [Non-Linux OS](#non-linux-os)
5. [License](#license)

## Requirements

### Hardware

Hardware requirements strongly depend on the specific use-cases of your network as well as on the data it is going to serve. Most use-cases are well-served with the following configuration:

- 4 CPU cores
- 32 GB RAM
- 160GB Hard Drive, SSD recommended

### Software

You are strongly recommended to install the Bridgehead under a Linux operating system (but see the section [Non-Linux OS](#non-linux-os)). You will need root (administrator) priveleges on this machine in order to perform the deployment. We recommend the newest Ubuntu LTS server release.

Ensure the following software (or newer) is installed:

- git >= 2.0
- docker >= 20.10.1
- docker-compose >= 2.xx (`docker-compose` and `docker compose` are both supported).
- systemd

We recommend to install Docker(-compose) from its official sources as described on the [Docker website](https://docs.docker.com). Note for Ubuntu: Please note that snap versions of Docker are not supported.

## Deployment

### Base Installation

First, clone the repository to the directory `/srv/docker/bridgehead`:

```shell
sudo mkdir -p /srv/docker/
sudo git clone https://github.com/samply/bridgehead.git /srv/docker/bridgehead
```

Then, run the installation script:

```shell
cd /srv/docker/bridgehead
sudo ./bridgehead install <PROJECT>
```

... and follow the instructions on the screen. You should then be prompted to do the next step:

### Register with Samply.Beam

Many Bridgehead services rely on the secure, performant and flexible messaging middleware called [Samply.Beam](https://github.com/samply/beam). You will need to register ("enroll") with Samply.Beam by creating a cryptographic key pair for your bridgehead:

``` shell
cd /srv/docker/bridgehead
sudo ./bridgehead enroll <PROJECT>
```

... and follow the instructions on the screen. You should then be prompted to do the next step:

### Starting and stopping your Bridgehead

If you followed the above steps, your Bridgehead should already be configured to autostart (via systemd). If you would like to start/stop manually:

To start, run

```shell
sudo systemctl start bridgehead@<PROJECT>.service
```

To stop, run

```shell
sudo systemctl stop bridgehead@<PROJECT>.service
```

To enable/disable autostart, run

```shell
sudo systemctl [enable|disable] bridgehead@<PROJECT>.service
```

## Site-specific configuration

### HTTPS Access

Even within your internal network, the Bridgehead enforces HTTPS for all services. During the installation, a self-signed, long-lived certificate was created for you. To increase security, you can simply replace the files under `/etc/bridgehead/traefik-tls` with ones from established certification authorities such as [Let's Encrypt](https://letsencrypt.org) or [DFN-AAI](https://www.aai.dfn.de).

## Troubleshooting

### Docker Daemon Proxy Configuration

Docker has a background daemon, responsible for downloading images and starting them. Sometimes, proxy configuration from your system won't carry over and it will fail to download images. In that case, configure the proxy for this daemon as described in the [official documentation](https://docs.docker.com).

### Non-Linux OS

The installation procedures described above have only been tested under Linux.

Below are some suggestions for getting the installation to work on other operating systems. Note that we are not able to provide support for these routes!

We believe that it is likely that installation would also work with FreeBSD and MacOS.

Under Windows, you have 2 options:

- Virtual machine
- WSL

We have tested the installation procedure with an Ubuntu 22.04 guest system running on a VMware virtual machine. That worked flawlessly.

Installation under WSL ought to work, but we have not tested this.

## License

Copyright 2019 - 2022 The Samply Community

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
