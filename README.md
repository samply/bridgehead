# Bridgehead

The Bridgehead is a secure, low-effort solution to connect your research institution to a federated research network. It bundles interoperable, open-source software components into a turnkey package for installation on one of your secure servers. The Bridgehead is pre-configured with sane defaults, centrally monitored and with an absolute minimum of "moving parts" on your side, making it an extremely low-maintenance gateway to data sharing.

This repository is the starting point for any information and tools you will need to deploy a Bridgehead. If you have questions, please [contact us](mailto:verbis-support@dkfz-heidelberg.de).

1. [Requirements](#requirements)
    - [Hardware](#hardware)
    - [Software](#software)
    - [Network](#network)
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
    - [BBMRI-ERIC Directory entry needed](#bbmri-eric-directory-entry-needed)
    - [Directory sync tool](#directory-sync-tool)
    - [Loading data](#loading-data)
    - [Teiler (Frontend)](#teiler-frontend)
    - [Data Exporter Service](#data-exporter-service)
      - [Data Quality Report](#data-quality-report)
4. [Things you should know](#things-you-should-know)
    - [Auto-Updates](#auto-updates)
    - [Auto-Backups](#auto-backups)
    - [Non-Linux OS](#non-linux-os)
    - [FAQ](#faq)
5. [Troubleshooting](#troubleshooting)
    - [Docker Daemon Proxy Configuration](#docker-daemon-proxy-configuration)
    - [Monitoring](#monitoring)
6. [License](#license)

## Requirements

The data protection officer at your site will probably want to know exactly what our software does with patient data, and you may need to get their approval before you are allowed to install a Bridgehead. To help you with this, we have provided some data protection concepts:

- [Germany](https://www.bbmri.de/biobanking/it/infrastruktur/datenschutzkonzept/)

### Hardware

Hardware requirements strongly depend on the specific use-cases of your network as well as on the data it is going to serve. Most use-cases are well-served with the following configuration:

- 4 CPU cores
- 32 GB RAM
- 160GB Hard Drive, SSD recommended

We recommend using a dedicated VM for the Bridgehead, with no other applications running on it. While the Bridgehead can, in principle, run on a shared VM, you might run into surprising problems such as resource conflicts (e.g., two apps using tcp port 443).

### Software

You are strongly recommended to install the Bridgehead under a Linux operating system (but see the section [Non-Linux OS](#non-linux-os)). You will need root (administrator) priveleges on this machine in order to perform the deployment. We recommend the newest Ubuntu LTS server release.

Ensure the following software (or newer) is installed:

- git >= 2.0
- docker >= 20.10.1
- docker-compose >= 2.xx (`docker-compose` and `docker compose` are both supported).
- systemd
- curl

We recommend to install Docker(-compose) from its official sources as described on the [Docker website](https://docs.docker.com).

> 📝 Note for Ubuntu: Snap versions of Docker are not supported.

### Network

A Bridgehead communicates to all central components via outgoing HTTPS connections.

Your site might require an outgoing proxy (i.e. HTTPS forward proxy) to connect to external servers; you should discuss this with your local systems administration. In that case, you will need to note down the URL of the proxy. If the proxy requires authentication, you will also need to make a note of its username and password. This information will be used later on during the installation process. TLS terminating proxies are also supported, see [here](#tls-terminating-proxies). Apart from the Bridgehead itself, you may also need to configure the proxy server in [git](https://gist.github.com/evantoli/f8c23a37eb3558ab8765) and [docker](https://docs.docker.com/network/proxy/).

The following URLs need to be accessible (prefix with `https://`):
* To fetch code and configuration from git repositories
  * github.com
  * git.verbis.dkfz.de
* To fetch docker images
  * docker.verbis.dkfz.de
  * Official Docker, Inc. URLs (subject to change, see [official list](https://docs.docker.com/desktop/setup/allow-list/))
    * hub.docker.com
    * registry-1.docker.io
    * production.cloudflare.docker.com
* To report bridgeheads operational status
  * healthchecks.verbis.dkfz.de
* only for DKTK/CCP
  * broker.ccp-it.dktk.dkfz.de
* only for BBMRI-ERIC
  * broker.bbmri.samply.de
  * gitlab.bbmri-eric.eu
* only for German Biobank Node
  * broker.bbmri.de

> 📝 This URL list is subject to change. Instead of the individual names, we highly recommend whitelisting wildcard domains: *.dkfz.de, github.com, *.docker.com, *.docker.io, *.samply.de, *.bbmri.de.

> 📝 Ubuntu's pre-installed uncomplicated firewall (ufw) is known to conflict with Docker, more info [here](https://github.com/chaifeng/ufw-docker).

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
- Repository URL containing the acces token eg. https://BH_Dummy:dummy_token@git.verbis.dkfz.de/<project>-bridgehead-configs/dummy.git

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
sudo git clone -b main https://github.com/samply/bridgehead.git /srv/docker/bridgehead
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
/srv/docker/bridgehead/bridgehead logs <project> -f
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
/srv/docker/bridgehead/bridgehead logs <Project> -f
```
This translates to a journalctl command so all the regular journalctl flags can be used.

Once the Bridgehead has passed these checks, take a look at the landing page:

```
https://localhost
```

You can either do this in a browser or with curl. If you visit the URL in the browser, you will neet to click through several warnings, because you will initially be using a self-signed certificate. With curl, you can bypass these checks:

```shell
curl -k https://localhost
```

Should the landing page not show anything, you can inspect the logs of the containers to determine what is going wrong. To do this you can use `./bridgehead docker-logs <Project> -f` to follow the logs of the container. This transaltes to a docker compose logs command meaning all the ususal docker logs flags work.

If you have chosen to take part in our monitoring program (by setting the ```MONITOR_APIKEY``` variable in the configuration), you will be informed by email when problems are detected in your Bridgehead.

### De-installing a Bridgehead

You may decide that you want to remove a Bridgehead installation from your machine, e.g. if you want to migrate it to a new location or if you want to start a fresh installation because the initial attempts did not work.

To do this, run:

```shell
sh bridgehead uninstall
```

## Site-specific configuration

[How to Change Config Access Token](docs/update-access-token.md)

### HTTPS Access

Even within your internal network, the Bridgehead enforces HTTPS for all services. During the installation, a self-signed, long-lived certificate was created for you. To increase security, you can simply replace the files under `/etc/bridgehead/traefik-tls` with ones from established certification authorities such as [Let's Encrypt](https://letsencrypt.org) or [DFN-AAI](https://www.aai.dfn.de).

### TLS terminating proxies

All of the Bridgehead's outgoing connections are secured by transport encryption (TLS) and a Bridgehead will refuse to connect if certificate verification fails. If your local forward proxy server performs TLS termination, please place its CA certificate in `/etc/bridgehead/trusted-ca-certs` as a `.pem` file, e.g. `/etc/bridgehead/trusted-ca-certs/mylocalca.pem`. Then, all Bridgehead components will pick up this certificate and trust it for outgoing connections.

To find the certificate file, first run the following:

```
curl -v https://broker.bbmri.samply.de/v1/health
```

In the output, look out for the line:


```
successfully set certificate verify locations:
```

Here a file will be mentioned, perhaps in the directory /etc/ssl/certs. The exact location  will depend on your operating system. This is the file that you need to copy.

### File structure

- `/srv/docker/bridgehead` contains this git repository with the shell scripts and *project-specific configuration*. In here, all files are identical for all sites. You should not make any changes here.
- `/etc/bridgehead` contains your *site-specific configuration* synchronized from your site-specific git repository as part of the [base installation](#base-installation). To change anything here, please consult your git repository (find out its URL via `git -C /etc/bridgehead remote -v`).
  - `/etc/bridgehead/<PROJECT>.conf` is your main site-specific configuration, all bundled into one concise config file. Do not change it here but via the central git repository.
  - `/etc/bridgehead/<PROJECT>.local.conf` contains site-specific parameters to be known to your Bridgehead only, e.g. local access credentials. The file is ignored via git, and you may edit it here via a text editor.
  - `/etc/bridgehead/traefik-tls` contains your Bridgehead's reverse proxies TLS certificates for [HTTPS access](#https-access).
  - `/etc/bridgehead/pki` contains your Bridgehead's private key (e.g., but not limited to Samply.Beam), generated as part of the [Samply.Beam enrollment](#register-with-samplybeam).
  - `/etc/bridgehead/trusted-ca-certs` contains third-party certificates to be trusted by the Bridgehead. For example, you want to place the certificates of your [TLS-terminating proxy](#network) here.

Your Bridgehead's actual data is not stored in the above directories, but in named docker volumes, see `docker volume ls` and `docker volume inspect <volume_name>`.

### BBMRI-ERIC Directory entry needed

If you run a biobank, you should be listed together with your collections with in the [Directory](https://directory.bbmri-eric.eu), a BBMRI-ERIC project that catalogs biobanks.

To do this, contact the BBMRI-ERIC national node for the country where your biobank is based, see [the list of nodes](http://www.bbmri-eric.eu/national-nodes/).

Once you have added your biobank to the Directory you got persistent identifier (PID) for your biobank and unique identifiers (IDs) for your collections. The collection IDs are necessary for the biospecimens assigning to the collections and later in the data flows between BBMRI-ERIC tools. In case you cannot distribute all your biospecimens within collections via assigning the collection IDs, **you should choose one of your sample collections as a default collection for your biobank**. This collection will be automatically used to label any samples that have not been assigned a collection ID in your ETL process. Make a note of this default collection ID, you will need it later on in the installation process.

### Directory sync tool

The Bridgehead's **Directory Sync** is an optional feature that keeps the BBMRI-ERIC Directory up to date with your local data, e.g. number of samples. Conversely, it can also update the local FHIR store with the latest contact details etc. from the  BBMRI-ERIC Directory.

You should talk with your local data protection group regarding the information that is published by Directory sync.

To enable it, you will need to explicitly set the username and password variables for BBMRI-ERIC Directory login in the configuration file of your GitLab repository (e.g. ```bbmri.conf```). Here is an example minimal config:

```
DS_DIRECTORY_USER_NAME=your_directory_username
DS_DIRECTORY_USER_PASS=your_directory_password
```
Please contact your National Node or Directory support (directory-dev@helpdesk.bbmri-eric.eu) to obtain these credentials.

The following environment variables can be used from within your config file to control the behavior of Directory sync:

| Variable                           | Purpose                                                                                                                                                              | Default if not specified               |
|:-----------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------------------------|
| DS_DIRECTORY_URL                   | Base URL of the Directory                                                                                                                                            | https://directory-backend.molgenis.net |
| DS_DIRECTORY_USER_NAME             | User name for logging in to Directory **Mandatory**                                                                                                                  |                                        |
| DS_DIRECTORY_USER_PASS             | Password for logging in to Directory **Mandatory**                                                                                                                   |                                        |
| DS_DIRECTORY_DEFAULT_COLLECTION_ID | ID of collection to be used if not in samples                                                                                                                        |                                        |
| DS_DIRECTORY_ALLOW_STAR_MODEL      | Set to 'True' to send star model info to Directory                                                                                                                   | True                                  |
| DS_FHIR_STORE_URL                  | URL for FHIR store                                                                                                                                                   | http://bridgehead-bbmri-blaze:8080     |
| DS_TIMER_CRON                      | Execution interval for Directory sync, [cron](https://crontab.guru) format                                                                                           | 0 22 * * *                             |
| DS_IMPORT_BIOBANKS                 | Set to 'True' to import biobank metadata from Directory                                                                                                              | True                                  |
| DS_IMPORT_COLLECTIONS              | Set to 'True' to import collection metadata from Directory                                                                                                           | True                                  |

Once you have finished editing the config, the Bridgehead will autoupdate the config with the values and will sync data at regular intervals, using the time specified in DS_TIMER_CRON.

There will be a delay before the effects of Directory sync become visible. First, you will need to wait until the time you have specified in ```TIMER_CRON```. Second, the information will then be synchronized from your national node with the central European Directory. This can take up to 24 hours.

More details of Directory sync can be found in [directory_sync_service](https://github.com/samply/directory_sync_service).

### Loading data

The data accessed by the federated search is held in the Bridgehead in a FHIR store (we use Blaze).

You can load data into this store by using its FHIR API:

```
https://<Name of your server>/bbmri-localdatamanagement/fhir
```
The name of your server will generally be the full name of the VM that the Bridgehead runs on. You can alternatively supply an IP address.

The FHIR API uses basic auth. You can find the credentials in `/etc/bridgehead/<project>.local.conf`.

Note that if you don't have a DNS certificate for the Bridgehead, you will need to allow an insecure connection. E.g. with curl, use the `-k` flag.

The storage space on your hard drive will depend on the number of FHIR resources that you intend to generate. This will be the sum of the number of patients/subjects, the number of samples, the number of conditions/diseases and the number of observations. As a general rule of thumb, you can assume that each resource will consume about 2 kilobytes of disk space.

For more information on Blaze performance, please refer to [import performance](https://github.com/samply/blaze/blob/master/docs/performance/import.md).

### Clearing data

The Bridgehead's FHIR store, Blaze, saves its data in a Docker volume. This means that the data will persist even if you stop the Bridgehead. You can clear existing data from the FHIR store by deleting the relevant Docker volume.

First, stop the Bridgehead:
```shell
sudo systemctl stop bridgehead@<PROJECT>.service
```
Now remove the volume:
```shell
docker volume rm <PROJECT>_blaze-data
```
Finally, restart the Bridgehead:
```shell
sudo systemctl start bridgehead@<PROJECT>.service
```
You will need to do this for example if you are using a VM as a test environment and you subsequently want to use the same VM for production.

#### ETL for BBMRI and GBA

Normally, you will need to build your own ETL to feed the Bridgehead. However, there is one case where a short cut might be available:
- If you are using CentraXX as a BIMS and you have a FHIR-Export License, then you can employ standard mapping scripts that access the CentraXX-internal data structures and map the data onto the BBMRI FHIR profile. It may be necessary to adjust a few parameters, but this is nonetheless significantly easier than writing your own ETL.

You can find the profiles for generating FHIR in [Simplifier](https://simplifier.net/bbmri.de/~resources?category=Profile).

### Teiler (Frontend)

Teiler is the web-based frontend of the Bridgehead, providing access to its various internal, and external services and components.   
To learn how to integrate your custom module into Teiler, please refer to https://github.com/samply/teiler-dashboard.
- To activate Teiler, set the following environment variable in your `<PROJECT>.conf` file:  

```bash
ENABLE_TEILER=true
```

### Data Exporter Service

The Exporter is a dedicated service for extracting and exporting Bridgehead data in (tabular) formats such as Excel, CSV, Opal, JSON, XML, ...  
- To enable the Exporter service, set the following environment variable in your `<PROJECT>.conf` file:  

```bash
ENABLE_EXPORTER=true

#### Data Quality Report
To assess the quality and plausibility of your imported data, the Reporter component is pre-configured to generate Excel reports with data quality metrics and statistical analyses. Reporter is part of the Exporter and can be enabled by setting the same environment variable in your `<PROJECT>.conf` file:
```bash
ENABLE_EXPORTER=true
```

For convenience, it's recommended to enable the Teiler web frontend alongside the Exporter to access export and quality control features via a web interface: set the following environment varibles in your `<PROJECT>.conf` file:
```bash
ENABLE_TEILER=true
ENABLE_EXPORTER=true
```


## Things you should know

### Auto-Updates

Your Bridgehead will automatically and regularly check for updates. Whenever something has been updates (e.g., one of the git repositories or one of the docker images), your Bridgehead is automatically restarted. This should happen automatically and does not need any configuration.

If you would like to understand what happens exactly and when, please check the systemd units deployed during the [installation](#base-installation) via `systemctl cat bridgehead-update@<PROJECT>.service` and `systemctl cat bridgehead-update@<PROJECT>.timer`.

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

### FAQ

**Q: How is the security of GitHub pulls, volumes/containers, and image signing ensured?**

A: Changes to Git branches that could be delivered to sites (main and develop) must be accepted via a pull request with at least two positive reviews.
Containers/images are not built manually, but rather automatically through a CI/CD pipeline, so that an image can be rolled back to a defined code version at any time without changes.
**Note:** If firewall access for (outgoing) connections to GitHub and/or Docker Hub is problematic at the site, mirrors for both services are available, operated by the DKFZ.

**Q: How is authentication between users and components regulated?**

A: When setting up a Bridgehead, a private key and a so-called Certificate Sign Request (CSR) are generated locally. This CSR is manually signed by the broker operator, which allows the Bridgehead access to the network infrastructure.
All communication runs via Samply.Beam and is therefore end-to-end encrypted, but also signed. This allows the integrity and authenticity of the sender to be technically verified (which happens automatically both in the broker and at the recipients).
The connection to the broker is additionally secured using traditional TLS (transport encryption over https).

**Q: Are there any statistics on incoming traffic from the Bridgehead (what goes in and what goes out)?**

A: Incoming and outgoing traffic can only enter/leave the Bridgehead via a forward or reverse proxy, respectively. These components log all connections.
Statistical analysis is not currently being conducted, but is on the roadmap for some projects. We are also working on a dashboard for all tasks/responses delivered via Samply.Beam.

**Q: How is container access controlled, and what permission level is used?**

A: Currently, it is not possible to run the Bridgehead "out-of-the-box" as a rootless Docker Compose stack. The main reason is the operation of the reverse proxy (Traefik), which binds to the privileged ports 80 (HTTP) and 443 (HTTPS).
Otherwise, there are no known technical obstacles, although we don't have concrete experience implementing this.
At the file system level, a "bridgehead" user is created during installation, which manages the configuration and Bridgehead folders.

**Q: Is a cloud installation (not a company-owned one, but an external service provider) possible?**

A: Technically, yes. This is primarily a data protection issue between the participant and their cloud provider.
The Bridgehead contains a data storage system that, during use, contains sensitive patient and sample data.
There are cloud providers with whom appropriately worded contracts can be concluded to make this possible.
Of course, the details must be discussed with the responsible data protection officer.

**Q: What needs to be considered regarding the Docker distribution/registry, and how is it used here?**

A: The Bridgehead images are located both in Docker Hub and mirrored in a registry operated by the DKFZ.
The latter is used by default, avoiding potential issues with Docker Hub URL activation or rate limits.
When using automatic updates (highly recommended), an daily check is performed for:
- site configuration updates
- Bridgehead software updates
- container image updates

If updates are found, they are downloaded and applied.
See the first question for the control mechanism.

**Q: Is data only transferred one-way (Bridgehead/FHIR Store → Central/Locator), or is two-way access necessary?**

A: By using Samply.Beam, only one outgoing connection to the broker is required at the network level (i.e., Bridgehead → Broker).

## Troubleshooting

### Docker Daemon Proxy Configuration

Docker has a background daemon, responsible for downloading images and starting them. Sometimes, proxy configuration from your system won't carry over and it will fail to download images. In that case, you'll need to configure the proxy inside the system unit of docker by creating the file `/etc/systemd/system/docker.service.d/proxy.conf` with the following content:

``` ini
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:3128"
Environment="HTTPS_PROXY=https://proxy.example.com:3128"
Environment="NO_PROXY=localhost,127.0.0.1,some-local-docker-registry.example.com,.corp"
```

After saving the configuration file, you'll need to reload the system daemon for the changes to take effect:

``` shell
sudo systemctl daemon-reload
```

and restart the docker daemon:

``` shell
sudo systemctl restart docker
```

For more information, please consult the [official documentation](https://docs.docker.com/config/daemon/systemd/#httphttps-proxy).

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
