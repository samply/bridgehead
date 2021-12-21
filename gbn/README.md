# Bridgehead Deployment


## Goal
Allow the Sample Locator to search for patients and samples in your biobanks, giving researchers easy access to your resources.


## Quick start
If you simply want to set up a test installation, without exploring all of the possibilities offered by the Bridgehead, then the sections you need to look at are:
* [Starting a Bridgehead](#starting-a-bridgehead)
* [Register with a Sample Locator](#register-with-a-sample-locator)
* [Checking your newly installed Bridgehead](#checking-your-newly-installed-bridgehead)


## Background
The **Sample Locator** is a tool that allows researchers to make searches for samples over a large number of geographically distributed biobanks. Each biobank runs a so-called **Bridgehead** at its site, which makes it visible to the Sample Locator.  The Bridgehead is designed to give a high degree of protection to patient data. Additionally, a tool called the [Negotiator][negotiator] puts you in complete control over which samples and which data are delivered to which researcher.

You will most likely want to make your biobanks visible via the [publicly accessible Sample Locator][sl], but the possibility also exists to install your own Sample Locator for your site or organization, see the GitHub pages for [the server][sl-server-src] and [the GUI][sl-ui-src].

The Bridgehead has two primary components:
* The **Blaze Store**. This is a highly responsive FHIR data store, which you will need to fill with your data via an ETL chain.
* The **Connector**. This is the communication portal to the Sample Locator, with specially designed features that make it possible to run it behind a corporate firewall without making any compromises on security.

This document will show you how to:
* Install the components making up the Bridgehead.
* Register your Bridgehead with the Sample Locator, so that researchers can start searching your resources.


## Requirements
For data protection concept, server requirements, validation or import instructions, see [the list of general requirements][requirements].


## Starting a Bridgehead
The file `docker-compose.yml` contains the the minimum settings needed for installing and starting a Bridgehead on your computer. This Bridgehead should run straight out of the box. However, you may wish to modify this file, e.g. in order to:
* Enable a corporate proxy (see below).
* Set an alternative Sample Locator URL.
* Change the admin credentials for the Connector.

To start a Bridgehead on your computer, you will need to follow the following steps:

* [Install Docker][docker] and [git][git]and test with:

```sh
docker run hello-world
git --version
```

* Download this repository:

```sh
git clone https://github.com/samply/bridgehead-deployment
cd bridgehead-deployment
```

* Launch the Bridgehead with the following command:

```sh
docker-compose up -d
```

* First test of the installation: check to see if there is a Connector running on port 8082:

```sh
curl localhost:8082 | grep Welcome 
```

* If you need to stop the Bridgehead, from within this directory:

```sh
docker-compose down
```  

## Port usage
Once you have started the Bridgehead, the following components will be visible to you via ports on localhost:
* Blaze Store: port 8080
* Connector admin: port 8082

## Connector Administration
The Connector administration panel allows you to set many of the parameters regulating your Bridgehead. Most especially, it is the place where you can register your site with the Sample Locator. To access this page, proceed as follows:

* Open the Connector page: http://localhost:8082
* In the "Local components" box, click the "Samply Share" button.
* A new page will be opened, where you will need to log in using the administrator credentials (admin/adminpass by default).
* After log in, you will be taken to the administration dashboard, allowing you to configure the Connector.
* If this is the first time you have logged in as an administrator, you are strongly recommended to set a more secure password! You can use the "Users" button on the dashboard to do this.

Note: your browser must be running on the same machine as the Connector for "localhost" URLs to work.

### Register with a Directory
The [Directory][directory] is a BBMRI project that aims to catalog all biobanks in Europe and beyond. Each biobank is given its own unique ID and the Directory maintains counts of the number of donors and the number of samples held at each biobank. You are strongly encouraged to register with the Directory, because this opens the door to further services, such as the [Negotiator][negotiator].

Generally, you should register with the BBMRI national node for the country where your biobank is based. You can find a list of contacts for the national nodes [here](http://www.bbmri-eric.eu/national-nodes/). If your country is not in this list, or you have any questions, please contact the [BBMRI helpdesk](mailto:directory@helpdesk.bbmri-eric.eu). If your biobank is for COVID samples, you can also take advantage of an accelerated registration process [here](https://docs.google.com/forms/d/e/1FAIpQLSdIFfxADikGUf1GA0M16J0HQfc2NHJ55M_E47TXahju5BlFIQ).

Your national node will give you detailed instructions for registering, but for your information, here are the basic steps:

* Log in to the Directory for your country.
* Add your biobank and enter its details, including contact information for a person involved in running the biobank.
* You will need to create at least one collection.
* Note the biobank ID and the collection ID that you have created - these will be needed when you register with the Locator (see below).

### Register with a Locator
* Go to the registration page http://localhost:8082/admin/broker_list.xhtml.
* To register with a Locator, enter the following values in the three fields under "Join new Searchbroker":
  * "Address": Depends on which Locator you want to register with:
    * `https://locator.bbmri-eric.eu/broker/`: BBMRI Locator production service (European).
    * `http://147.251.124.125:8088/broker/`: BBMRI Locator test service (European).
    * `https://samplelocator.bbmri.de/broker/`: GBA Sample Locator production service (German).
    * `https://samplelocator.test.bbmri.de/broker/`: GBA Sample Locator test service (German).
  * "Your email address": this is the email to which the registration token will be returned.
  * "Automatic reply": Set this to be `Total Size`
* Click "Join" to start the registration process.
* You should now have a list containing exactly one broker. You will notice that the "Status" box is empty.
* Send an email to `feedback@germanbiobanknode.de` and let us know which of our Sample Locators you would like to register to. Please include the biobank ID and the collection ID from your Directory registration, if you have these available.
* We will send you a registration token per email.
* You will then re-open the Connector and enter the token into the "Status" box.
* You should send us an email to let us know that you have done this.
* We will then complete the registration process
* We will email you to let you know that your biobank is now visible in the Sample Locator.

If you are a Sample Locator administrator, you will need to understand the [registration process](./SampleLocatorRegistration.md). Normal bridgehead admins do not need to worry about this.

### Monitoring
You are strongly encouraged to set up an automated monitoring of your new Bridgehead. This will periodically test the Bridgehead in various ways, and (if you wish) will also send you emails if problems are detected. It helps you to become aware of problems before users do, and also gives you the information you need to track down the source of the problems. To activate monitoring, perform the following steps:

* Open the Connector administration dashboard in your browser, see [Admin](#connector-administration) for details.
* Click the "Configuration" button. 
* ![grafik](https://user-images.githubusercontent.com/86475306/142425285-977e5649-7f2e-44db-8da0-ee5e28b5e91b.png)
* Scroll to the section "Reporting to central services". 
* Click on all of the services in this section so that they have the status "ON".
* ![grafik](https://user-images.githubusercontent.com/86475306/142425378-e1b68f13-df7a-4f23-978e-121184611586.png)
* **Important:** Scroll to the bottom of the page and click the "Save" button.
* ![grafik](https://user-images.githubusercontent.com/86475306/142425417-68a28059-37e0-48a3-bb1e-1bf29a39ccfc.png)
* Return to the dashboard, and click the button "Scheduled Tasks".
* ![grafik](https://user-images.githubusercontent.com/86475306/142425447-a662257a-d556-4795-aa0b-89f7699ba1e4.png)
* Scroll down to the box labelled "ReportToMonitoringJob". For newer Versions of the bridgehead there this job is separated into "ReportToMonitoringJobShortFrequence" and "ReportToMonitoringJobLongFrequence".
* Click the button "Run now". This switches the monitoring on. If you have the newer Version of the bridgeheads please run both jobs.
* ![grafik](https://user-images.githubusercontent.com/86475306/142425487-6d297779-28c1-44b7-b2c4-dcf2ede24eb9.png)
* If you want to receive emails when the monitoring service detects problems with your Bridgehead, please send a list of email addresses for the people to be notified to: `feedback@germanbiobanknode.de`.

You are now done!

### Troubleshooting
To get detailled information about Connector problems, you need to use the Docker logging facility:

* Log into the server where the Connector is running. You need a command line login.
* Discover the container ID of the Connector. First run "docker ps". Look in the list of results. The relevant line contains the image name "samply/share-client".
* Execute the following command: "docker logs \<Container-ID\>"
* The last 100 lines of the log are relevant. Maybe you will see the problem there right away. Otherwise, send the log-selection to us.
 
### User
* To enable a user to access the connector, a new user can be created under http://localhost:8082/admin/user_list.xhtml.
This user has the possibility to view incoming queries

### Jobs
* The connector uses [Quartz Jobs](http://www.quartz-scheduler.org/) to do things like collect the queries from the searchbroker or execute the queries.
The full list of jobs can be viewed under the job page http://localhost:8082/admin/job_list.xhtml.

### Tests
* The Connector connectivity checks can be found under the test page http://localhost:8082/admin/tests.xhtml.

## Checking your newly installed Bridgehead
We will load some test data and then run a query to see if it shows up.

First, install [bbmri-fhir-gen][bbmri-fhir-gen]. Run the following command:

```sh
mkdir TestData
bbmri-fhir-gen TestData -n 10
```

This will generate test data for 10 patients, and place it in the directory `TestData`.

Next, install [blazectl][blazectl]. Run the following commands:

```sh
blazectl --server http://localhost:8080/fhir upload TestData
blazectl --server http://localhost:8080/fhir count-resources
```

If both of them complete successfully, it means that the test data has successfully been uploaded to the Blaze Store.

Open the [Sample Locator][sl] and hit the "SEND" button. You may need to wait for a minute before all results are returned. Click the "Login" link to log in via the academic institution where you work (AAI). You should now see a list of the biobanks known to the Sample Locator.

If your biobank is present, and it contains non-zero counts of patients and samples, then your installation was successful.

If you wish to remove the test data, you can do so by simply deleting the Docker volume for the Blaze Store database:

```sh
docker-compose down
docker volume rm store-db-data
```

## Manual installation
The installation described here uses Docker, meaning that you don't have to worry about configuring or installing the Bridgehead components - Docker does it all for you. If you do not wish to use Docker, you can install all of the software directly on your machine, as follows:

* Install the [Blaze Store][man-store]
* Install the [Connector][man-connector]
* Register with the Sample Locator (see above)


Source code for components deployed by `docker-compose.yml`:

* [Store][store-src]
* [Connector][connector-src]


## Optional configuration:

#### Proxy example
Add environments variables in `docker-compose.yml` (remove user and password environments if not available):
"http://proxy.example.de:8080", user "testUser", password "testPassword"
      
      version: '3.4'
      services:
        store:
          container_name: "store"
          image: "samply/blaze:0.11"
          environment:
            BASE_URL: "http://store:8080"
            JAVA_TOOL_OPTIONS: "-Xmx4g"
            PROXY_HOST: "http://proxy.example.de"
            PROXY_PORT: "8080"
            PROXY_USER: "testUser"
            PROXY_PASSWORD: "testPassword"
          networks:
            - "samply"
            
      .......
      
      connector:
          container_name: "connector"
          image: "samply/connector:7.0.0"
          environment:
            POSTGRES_HOST: "connector-db"
            POSTGRES_DB: "samply.connector"
            POSTGRES_USER: "samply"
            POSTGRES_PASS: "samply"
            STORE_URL: "http://store:8080/fhir"
            QUERY_LANGUAGE: "CQL"
            MDR_URL: "https://mdr.germanbiobanknode.de/v3/api/mdr"
            HTTP_PROXY: "http://proxy.example.de:8080"
            PROXY_USER: "testUser"
            PROXY_PASS: "testPassword
          networks:
            - "samply"
            
      .......
      


#### General information on Docker environment variables used in the Bridgehead

* [Store][env-store]
* [Connector][env-connector]


## Notes
* If you see database connection errors of Store or Connector, open a second terminal and run `docker-compose stop` followed by `docker-compose start`. Database connection problems should only occur at the first start because the store and the connector doesn't wait for the databases to be ready. Both try to connect at startup which might be to early.

* If one needs only one of the the Bridgehead components, they can be started individually:

```sh
docker-compose up store -d
docker-compose up connector -d
```

* To shut down all services (but keep databases):

```sh
docker-compose down
```  

* To delete databases as well (destroy before):

```sh
docker volume rm store-db-data
docker volume rm connector-db-data
```

* To see all executed queries, create a [new user][connector-user], logout and login with this normal user.

* To set Store-Basic-Auth-credentials in Connector (as default `Lokales Datenmanagement` with dummy values was generated)
    * Login at [Connector-UI][connector-login] (default usr=admin, pwd=adminpass)
    * Open [credentials page][connector-credentials]
        - Delete all instances of`Lokales Datenmanagement`
        - for "Ziel" select `Lokales Datenmanagement`, provide decrypted CREDENTIALS in "Benutzername" and "Passwort", select "Zugangsdaten hinzufügen"

* If you would like to read about the experiences of a  team in Brno who have installed the Bridgehead and a local Sample Locator instance, take a look at [SL-BH_deploy](SL-BH_deploy).

## Useful Links
* [FHIR Quality Reporting Authoring UI][quality-ui-github]
* [How to join Sample Locator][join-sl]
* [Samply code repositories][samply]

## License

Copyright 2019 - 2021 The Samply Community

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

[sl]: <https://samplelocator.bbmri.de>
[sl-ui-src]: <https://github.com/samply/sample-locator>
[sl-server-src]: <https://github.com/samply/share-broker-rest>
[negotiator]: <https://negotiator.bbmri-eric.eu/login.xhtml>
[directory]: <https://directory.bbmri-eric.eu>
[bbmri]: <http://www.bbmri-eric.eu>
[docker]: <https://docs.docker.com/install>
[git]: <https://www.atlassian.com/git/tutorials/install-git>

[connector-user]:<http://localhost:8082/admin/user_list.xhtml>
[connector-login]:<http://localhost:8082/admin/login.xhtml>
[connector-credentials]:<http://localhost:8082/admin/credentials_list.xhtml>

[requirements]: <https://samply.github.io/bbmri-fhir-ig/howtoJoin.html#general-requirements>

[man-store]: <https://github.com/samply/blaze/blob/master/docs/deployment/manual-deployment.md>
[env-store]: <https://github.com/samply/blaze/blob/master/docs/deployment/environment-variables.md>
[env-connector]: <https://github.com/samply/share-client/blob/master/docs/deployment/docker-deployment.md>

[bbmri-fhir-gen]: <https://github.com/samply/bbmri-fhir-gen>
[blazectl]: <https://github.com/samply/blazectl>

[man-connector]: <Connector.md>

[store-src]: <https://github.com/samply/blaze>
[connector-src]: <https://github.com/samply/share-client>

[quality-ui-github]:<https://github.com/samply/blaze-quality-reporting-ui>
[join-sl]: <https://samply.github.io/bbmri-fhir-ig/howtoJoin.html>
[samply]: <https://github.com/samply>
