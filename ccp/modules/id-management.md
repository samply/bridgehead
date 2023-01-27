# Module: Id-Management
This module provides integration with the CCP-Pseudonymiziation Service. To learn more on the backgrounds of this service, you can refer to the [CCP Data Protection Concept](https://dktk.dkfz.de/klinische-plattformen/documents-download).

## Getting Started
The following configuration variables are added to your sites-configuration repository:

```
IDMANAGER_UPLOAD_APIKEY="<random-string>"
IDMANAGER_READ_APIKEY="<random-string>"
IDMANAGER_CENTRAL_PATIENTLIST_APIKEY="<given-to-you-by-ccp-it>"
IDMANAGER_CONTROLNUMBERGENERATOR_APIKEY="<given-to-you-by-ccp-it>"
IDMANAGER_AUTH_CLIENT_ID="<given-to-you-by-ccp-it>"
IDMANAGER_AUTH_CLIENT_SECRET="<given-to-you-by-ccp-it>"

IDMANAGER_SEEDS_BK="<three-numbers>"
IDMANAGER_SEEDS_MDS="<three-numbers>"
IDMANAGER_SEEDS_DKTK000001985="<three-numbers>"
```

Once your Bridgehead is updated and restarted, you're all set!

## Additional information you may want to know
### Services

Upon configuration, the Bridgehead will spawn the following services:

- The `bridgehead-id-manager` at https://bridgehead.local/id-manager, provides a common interface for creating pseudonyms in the bridgehead.
- The `bridgehead-patientlist` at https://bridgehead.local/patientlist is a local instance of the open-source software [Mainzelliste](https://mainzelliste.de). This service's primary task is to map patients IDAT to pseudonyms identifying them along the different CCP projects.
- The `bridgehead-patientlist-db` is only accessible within the Bridgehead itself. This is a local postgresql instance storing the database for `bridgehead-patientlist`. The data is persisted as a named volume `patientlist-db-data` and backups are automatically created in `/var/cache/bridgehead/backup/bridgehead-patientlist-db`.

### How to import an existing database (e.g from Legacy Windows or from Backups)
First you must shutdown your local bridgehead instance:
```
systemctl stop bridgehead@ccp
```

Next you need to remove the current patientlist database:
```
docker volume rm patientlist-db-data;
```

Third, you need to place your postgres dump in the import directory `/tmp/bridgehead/patientlist/some-dump.sql`. This will only be imported, then the volume `patientlist-db-data` was removed previously. 
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
dktk.idmanagement.apiKey=<your-setting-for-IDMANAGER_UPLOAD_APIKEY>
```
They typically already exist, but need to be changed to the new values!
#### Sites using ADT2FHIR
@Pierre


### How to connect the legacy windows bridgehead
You need to change the configuration file "..." of your Windows Bridgehead. TODO... 
