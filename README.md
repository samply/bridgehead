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

We recommend to install Docker(-compose) from its official sources as described on the [Docker website](https://docs.docker.com).

Note for Ubuntu: Please note that snap versions of Docker are not supported.

### Network

Since it needs to carry sensitive patient data, Bridgeheads are intended to be deployed within your institution's secure network and behave well even in networks in strict security settings, e.g. firewall rules. The only connectivity required is an outgoing HTTPS proxy. TLS termination is supported, too (see [below](#tls-terminating-proxies))

Note for Ubuntu: Please note that the uncomplicated firewall (ufw) is known to conflict with Docker [here](https://github.com/chaifeng/ufw-docker).

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

### TLS terminating proxies

All of the Bridgehead's outgoing connections are secured by transport encryption (TLS) and a Bridgehead will refuse to connect if certificate verification fails. If your local forward proxy server performs TLS termination, please place its CA certificate in `/etc/bridgehead/trusted-ca-certs` as a `.pem` file, e.g. `/etc/bridgehead/trusted-ca-certs/mylocalca.pem`. Then, all Bridgehead components will pick up this certificate and trust it for outgoing connections.

### File structure

- `/srv/docker/bridgehead` contains this git repository with the shell scripts and *project-specific configuration*. In here, all files are identical for all sites. You should not make any changes here.
- `/etc/bridgehead` contains your *site-specific configuration* synchronized from your site-specific git repository as part of the [base installation](#base-installation). To change anything here, please consult your git repository (find out its URL via `git -C /etc/bridgehead remote -v`).
  - `/etc/bridgehead/<PROJECT>.conf` is your main site-specific configuration, all bundled into one concise config file. Do not change it here but via the central git repository.
  - `/etc/bridgehead/<PROJECT>.local.conf` contains site-specific parameters to be known to your Bridgehead only, e.g. local access credentials. The file is ignored via git, and you may edit it here via a text editor.
  - `/etc/bridgehead/traefik-tls` contains your Bridgehead's reverse proxies TLS certificates for [HTTPS access](#https-access).
  - `/etc/bridgehead/pki` contains your Bridgehead's private key (e.g., but not limited to Samply.Beam), generated as part of the [Samply.Beam enrollment](#register-with-samplybeam).
  - `/etc/bridgehead/trusted-ca-certs` contains third-party certificates to be trusted by the Bridgehead. For example, you want to place the certificates of your [TLS-terminating proxy](#network) here.
  - `/var/cache/bridgehead/backup` contains automatically created backups of the databases.

Your Bridgehead's actual data is not stored in the above directories, but in named docker volumes, see `docker volume ls` and `docker volume inspect <volume_name>`.

## Things you should know

### Auto-Updates

Your Bridgehead will automatically and regularly check for updates. Whenever something has been updates (e.g., one of the git repositories or one of the docker images), your Bridgehead is automatically restarted. This should happen automatically and does not need any configuration.

If you would like to understand what happens exactly and when, please check the systemd units deployed during the [installation](#base-installation) via `systemctl cat bridgehead-update@<PROJECT>.service` and `systemctl cat bridgehead-update@<PROJECT.timer`.

### Auto-Backups
Some of the components in the bridgehead will store persistent data. For those components, we integrated an automated backup solution in the bridgehead updates. It will automatically save the backup in multiple files

1) Last-XX, were XX represents a weekday to allow re-import of at least one version of the database for each of the past seven days.
2) Year-KW-XX, were XX represents the calendar week to allow re-import of at least one version per calendar week
3) Year-Month, to allow re-import of at least one version per month

### Monitoring

To keep all Bridgeheads up and working and detect any errors before a user does, a central monitoring 

- Your Bridgehead itself will report relevant system events, such as successful/failed updates, restarts, performance metrics or version numbers.
- Your Bridgehead is also monitored from the outside by your network's central components. For example, the federated search will regularly perform a black-box test by sending an empty query to your Bridgehead and checking if the results make sense.

In all monitoring cases, obviously no sensitive information is transmitted, in particular not any patient-related data. Aggregated data, e.g. total amount of datasets, may be transmitted for diagnostic purposes.

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
