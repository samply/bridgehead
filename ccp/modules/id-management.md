# Module: Id-Management
This module provides integration with the CCP-Pseudonymiziation Service. To learn more on the backgrounds of this service, you can refer to the [CCP-DSK](https://dktk.dkfz.de/application/files/5016/2030/2474/20_11_23_Datenschutzkonzept_CCP-IT_inkl_Anlagen.pdf).

## Getting Started
You must add following configuration variables to your sites-configuration repository:

```
IDMANAGER_CENTRAXX_APIKEY="<random-string>"
IDMANAGER_CONNECTOR_APIKEY="<random-string>"
IDMANAGER_CENTRAL_PATIENTLIST_APIKEY="<given-to-you-by-ccp-it>"
IDMANAGER_CONTROLNUMBERGENERATOR_APIKEY="<given-to-you-by-ccp-it>"
IDMANAGER_AUTH_CLIENT_ID="<given-to-you-by-ccp-it>"
IDMANAGER_AUTH_CLIENT_SECRET="<given-to-you-by-ccp-it>"
```

Additionally, the ccp-it needs to add a new file "patientlist-id-generators.env" to your site configuration. This file will hold the seeds for the different id-generators used in all projects.

After adding the configuration, you simply need to update your bridgehead and 3 new services will run on your server:

- `bridgehead-id-manager`, accessible by "https://<your-host>/id-manager". This component adds a common interface for creating pseudonymes in the bridgehead.
- `bridgehead-patientlist`, accessible by "https://<your-host/patientlist". It's a local instance of the open-source software [Mainzelliste](https://mainzelliste.de). This service primary task is to map patients IDAT to pseudonymes identifying them along the different CCP projects.
- `bridgehead-patientlist-db`, not accessible outside of docker. This is a local instance of postgres storing the database of `bridgehead-patientlist`. The data is persisted in `/var/data/bridgehead/patientlist` and backups are automatically created in `/var/data/bridgehead/backups/bridgehead-patientlist-db`.

## Things you need to know
### How to import an existing database (e.g from Legacy Windows or from Backups)
First you must shutdown your local bridgehead instance:
```
systemctl stop bridgehead@ccp
```

Next you need to remove the current patientlist database:
```
rm -rf /var/data/bridgehead/patientlist
```

Third, you need to place your postgres dump in the import directory `/tmp/bridgehead/patientlist/some-dump.sql`. This will only be imported, then /var/data/bridgehead/patientlist is empty. 
> NOTE: Please create the postgres dump with the options "--no-owner" and "--no-privileges". Additionally ensure the dump is created in the plain format (SQL).

After this, you can restart your bridgehead and the dump will be imported:
```
systemctl start bridgehead@ccp
```

### How to connect your local data-management
Typically, the sites connect their local data-management for the pseudonym creation with the id-management in the bridgehead. In the following two sections, you can read where you can change the configuration:
#### Sites using CentraXX
On your CentraXX Server, you need to change following settings in the "centraxx-dev.properties" file.
```
dktk.idmanagement.url=https://<your-linux-bk-host>/id-manager/translator/getId
dktk.idmanagement.apiKey=<your-setting-for-IDMANAGER_CENTRAXX_APIKEY>
```
They typically already exist, but need to be changed to the new values!
#### Sites using ADT2FHIR
@Pierre


### How to connect the legacy windows bridgehead
You need to change the configuration file "..." of your Windows Bridgehead. TODO... 
