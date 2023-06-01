# Bridgehead

The Bridgehead is a secure, low-effort solution to connect your research institution to a federated research network. It bundles interoperable, open-source software components into a turnkey package for installation on one of your secure servers. The Bridgehead is pre-configured with sane defaults, centrally monitored and with an absolute minimum of "moving parts" on your side, making it an extremely low-maintenance gateway to data sharing.

This repository is the starting point for any information and tools you will need to deploy a Bridgehead. If you have questions, please [contact us](mailto:verbis-support@dkfz-heidelberg.de).

1. [Requirements](#requirements)
    - [Hardware](#hardware)
    - [Software](#software)
    - [Network](#network)
    - [Register with a Directory](#register-with-a-directory)
2. [Deployment](#deployment)
    - [Site name](#site-name)
    - [Projects](#projects)
    - [GitLab repository](#gitlab-repository)
    - [Base Installation](#base-installation)
    - [Register with Samply.Beam](#register-with-samplybeam)
    - [Starting and stopping your Bridgehead](#starting-and-stopping-your-bridgehead)
    - [Testing your new Bridgehead](#testing-your-new-bridgehead)
    - [De-installing a Bridgehead](#de-installing-a-bridgehead)
3. [Site-specific configuration](#site-specific-configuration)
    - [HTTPS Access](#https-access)
    - [TLS terminating proxies](#tls-terminating-proxies)
    - [File structure](#file-structure)
4. [Things you should know](#things-you-should-know)
    - [Auto-Updates](#auto-updates)
    - [Auto-Backups](#auto-backups)
    - [Non-Linux OS](#non-linux-os)
5. [Troubleshooting](#troubleshooting)
    - [Docker Daemon Proxy Configuration](#docker-daemon-proxy-configuration)
    - [Monitoring](#monitoring)
6. [License](#license)

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

A running Bridgehead requires an outgoing HTTPS proxy to communicate with the central components.

Additionally, your site might use its own proxy. You should discuss this with your local systems administration. If a proxy is being used, you will need to note down the URL of the proxy. If it is a secure proxy, then you will also need to make a note of its username and password. This information will be used later on during the installation process.

Note that git and Docker may also need to be configured to use this proxy. This is a job for your systems administrators.

If there is a site firewall, this needs to be configured so that git and Docker can reach the outside world. Another job for the systems administrators.

Note for Ubuntu: Please note that the uncomplicated firewall (ufw) is known to conflict with Docker [here](https://github.com/chaifeng/ufw-docker).

### Register with a Directory

If you run a biobank, you should register with the [Directory][https://directory.bbmri-eric.eu], a BBMRI project that catalogs biobanks.

To do this, contact the BBMRI national node for the country where your biobank is based, see [the list of nodes](http://www.bbmri-eric.eu/national-nodes/).

Once you have registered, **you should choose one of your sample collections as a default collection for your biobank**. This is the collection that will be automatically used to label any samples that have not been assigned a collection ID in your ETL process. Make a note of this ID, you will need it later on in the installation process.

## Deployment

### Site name

You will need to choose a short name for your site. This is not a URL, just a simple identifying string. For the examples below, we will use "your-site-name", but you should obviously choose something that is meaningful to you and which is unique.

Site names should adhere to the following conventions:

- They should be lower-case.
- They should generally be named after the city where your site is based, e.g. ```karlsruhe```.
- If you have a multi-part name, please use a hypen ("-") as separator, e.g. ```le-havre```.
- If your site is for testing purposes, rather than production, please append "-test", e.g. ```zaragoza-test```.
- If you are a developer and you are making changes to the Bridgehead, please use your name and prepend "dev-", e.g. ```dev-joe-doe```.

### GitLab repository

In order to be able to install, you will need to have your own repository in GitLab for your site's configuration settings. This allows automated updates of the Bridgehead software.

To request a new repository, please contact your research network administration or send an email to one of the project specific addresses:

- For the bbmri project: bridgehead@helpdesk.bbmri-eric.eu.
- For the ccp project: support-ccp@dkfz-heidelberg.de

Mention:
- which project you belong to, i.e. "bbmri" or "ccp"
- site name (According to conventions listed above)
- operator name and email

We will set the repository up for you. We will then send you:

- A Repository Short Name (RSN). Beware: this is distinct from your site name.
- Repository URL containing the acces token eg. https://BH_Dummy:dummy_token@git.verbis.dkfz.de/bbmri-bridgehead-configs/dummy.git

During the installation, your Bridgehead will download your site's configuration from GitLab and you can review the details provided to us by email.


### Base Installation

First, download your site specific configuration repository:
```shell
sudo mkdir -p /etc/bridgehead/
sudo git clone <REPO_URL_FROM_EMAIL> /etc/bridgehead/
```

Review the site configuration:
```shell
sudo cat /etc/bridgehead/bbmri.conf
```

Pay special attention to:

- SITE_NAME
- SITE_ID
- OPERATOR_FIRST_NAME
- OPERATOR_LAST_NAME
- OPERATOR_EMAIL

Clone the bridgehead repository:
```shell
sudo mkdir -p /srv/docker/
sudo git clone https://github.com/samply/bridgehead.git /srv/docker/bridgehead
```

Then, run the installation script:

```shell
cd /srv/docker/bridgehead
sudo ./bridgehead install <PROJECT>
```

### Register with Samply.Beam

Many Bridgehead services rely on the secure, performant and flexible messaging middleware called [Samply.Beam](https://github.com/samply/beam). You will need to register ("enroll") with Samply.Beam by creating a cryptographic key pair for your bridgehead:

``` shell
cd /srv/docker/bridgehead
sudo ./bridgehead enroll <PROJECT>
```

... and follow the instructions on the screen. Please send your default Collection ID and the display name of your site together with the certificate request when you enroll. You should then be prompted to do the next step:

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

### Testing your new Bridgehead

After starting the Bridgehead, you can watch the initialization process with the following command:

```shell
journalctl -u bridgehead@bbmri -f
```

if this exits with something similar to the following:

```
bridgehead@bbmri.service: Main process exited, code=exited, status=1/FAILURE
```

Then you know that there was a problem with starting the Bridgehead. Scroll up the printout to find the cause of the error.

Once the Bridgehead is running, you can also view the individual Docker processes with:

```shell
docker ps
```

There should be 6 - 10 Docker proceses. If there are fewer, then you know that something has gone wrong. To see what is going on, run:

```shell
journalctl -u bridgehead@bbmri -f
```

Once the Bridgehead has passed these checks, take a look at the landing page:

```
https://localhost
```

You can either do this in a browser or with curl. If you visit the URL in the browser, you will neet to click through several warnings, because you will initially be using a self-signed certificate. With curl, you can bypass these checks:

```shell
curl -k https://localhost
```

If you get errors when you do this, you need to use ```docker logs``` to examine your landing page container in order to determine what is going wrong.

If you have chosen to take part in our monitoring program (by setting the ```MONITOR_APIKEY``` variable in the configuration), you will be informed by email when problems are detected in your Bridgehead.

### De-installing a Bridgehead

You may decide that you want to remove a Bridgehead installation from your machine, e.g. if you want to migrate it to a new location or if you want to start a fresh installation because the initial attempts did not work.

To do this, run:

```shell
sh bridgehead uninstall
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

Your Bridgehead's actual data is not stored in the above directories, but in named docker volumes, see `docker volume ls` and `docker volume inspect <volume_name>`.

### Directory sync

This is an optional feature for bbmri projects. It keeps the [BBMRI Directory](https://directory.bbmri-eric.eu/) up to date with your local data eg. number of samples. It also updates the local FHIR store with the latest contact details etc. from the Directory.  You must explicitly set your country specific directory url, username and password to enable this feature.

Full details can be found in [directory_sync_service](https://github.com/samply/directory_sync_service).

To enable it, you will need to set these variables to the ```bbmri.conf``` file of your GitLab repository. Here is an example config:

```
### Directory sync service
DS_DIRECTORY_URL=https://directory.bbmri-eric.eu
DS_DIRECTORY_USER_NAME=your_directory_username
DS_DIRECTORY_USER_PASS=qwdnqwswdvqHBVGFR9887
DS_TIMER_CRON="0 22 * * *"
```
You must contact the Directory for your national node to find the URL, and to register as a user.

Additionally, you should choose when you want Directory sync to run. In the example above, this is set to happen at 10 pm every evening. You can modify this to suit your requirements. The timer specification should follow the [cron](https://crontab.guru) convention.

Once you edited the gitlab config. The bridgehead will autoupdate the config with the values and will sync the data.

There will be a delay before the effects of Directory sync become visible. First, you will need to wait until the time you have specified in ```TIMER_CRON```. Second, the information will then be synchronized from your national node with the central European Directory. This can take up to 24 hours.

## Things you should know

### Auto-Updates

Your Bridgehead will automatically and regularly check for updates. Whenever something has been updates (e.g., one of the git repositories or one of the docker images), your Bridgehead is automatically restarted. This should happen automatically and does not need any configuration.

If you would like to understand what happens exactly and when, please check the systemd units deployed during the [installation](#base-installation) via `systemctl cat bridgehead-update@<PROJECT>.service` and `systemctl cat bridgehead-update@<PROJECT.timer`.

### Auto-Backups

Some of the components in the bridgehead will store persistent data. For those components, we integrated an automated backup solution in the bridgehead updates. It will automatically save the backup in multiple files

1) Last-XX, were XX represents a weekday to allow re-import of at least one version of the database for each of the past seven days.
2) Year-KW-XX, were XX represents the calendar week to allow re-import of at least one version per calendar week
3) Year-Month, to allow re-import of at least one version per month

To enable the Auto-Backup feature, please set the Variable `BACKUP_DIRECTORY` in your sites configuration.

### Development Installation

By using `./bridgehead dev-install <projectname>` instead of `install`, you can install a developer bridgehead. The difference is, that you can provide an arbitrary configuration repository during the installation, meaning that it does not have to adhere to the usual naming scheme. This allows for better decoupling between development and production configurations.

### Non-Linux OS

The installation procedures described above have only been tested under Linux.

Below are some suggestions for getting the installation to work on other operating systems. Note that we are not able to provide support for these routes!

We believe that it is likely that installation would also work with FreeBSD and MacOS.

Under Windows, you have 2 options:

- Virtual machine
- WSL

We have tested the installation procedure with an Ubuntu 22.04 guest system running on a VMware virtual machine. That worked flawlessly.

Installation under WSL ought to work, but we have not tested this.

## Troubleshooting

### Docker Daemon Proxy Configuration

Docker has a background daemon, responsible for downloading images and starting them. Sometimes, proxy configuration from your system won't carry over and it will fail to download images. In that case, configure the proxy for this daemon as described in the [official documentation](https://docs.docker.com).


### Monitoring

To keep all Bridgeheads up and working and detect any errors before a user does, a central monitoring 

- Your Bridgehead itself will report relevant system events, such as successful/failed updates, restarts, performance metrics or version numbers.
- Your Bridgehead is also monitored from the outside by your network's central components. For example, the federated search will regularly perform a black-box test by sending an empty query to your Bridgehead and checking if the results make sense.

In all monitoring cases, obviously no sensitive information is transmitted, in particular not any patient-related data. Aggregated data, e.g. total amount of datasets, may be transmitted for diagnostic purposes.

## License

Copyright 2019 - 2022 The Samply Community

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
