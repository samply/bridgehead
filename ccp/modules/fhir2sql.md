# fhir2sql
fhir2sql connects to Blaze, retrieves data, and syncs it with a PostgreSQL database. The application is designed to run continuously, syncing data at regular intervals.
The Dashboard module is a optional component of the Bridgehead CCP setup. When enabled, it starts two Docker services: **fhir2sql** and **dashboard-db**. Data held in PostgreSQL is only stored temporarily and Blaze is considered to be the 'leading system' or 'source of truth'.

## Services
### fhir2sql
* Image: docker.verbis.dkfz.de/cache/samply/fhir2sql:latest
* Container name: bridgehead-ccp-dashboard-fhir2sql
* Depends on: dashboard-db
* Environment variables:
  - BLAZE_BASE_URL: The base URL of the Blaze FHIR server (set to http://blaze:8080/fhir/)
  - PG_HOST: The hostname of the PostgreSQL database (set to dashboard-db)
  - PG_USERNAME: The username for the PostgreSQL database (set to dashboard)
  - PG_PASSWORD: The password for the PostgreSQL database (set to the value of DASHBOARD_DB_PASSWORD)
  - PG_DBNAME: The name of the PostgreSQL database (set to dashboard)

### dashboard-db

* Image: docker.verbis.dkfz.de/cache/postgres:${POSTGRES_TAG}
* Container name: bridgehead-ccp-dashboard-db
* Environment variables:
  - POSTGRES_USER: The username for the PostgreSQL database (set to dashboard)
  - POSTGRES_PASSWORD: The password for the PostgreSQL database (set to the value of DASHBOARD_DB_PASSWORD)
  - POSTGRES_DB: The name of the PostgreSQL database (set to dashboard)
* Volumes:
  - /var/cache/bridgehead/ccp/dashboard-db:/var/lib/postgresql/data

The volume used by dashboard-db can be removed safely and should be restored to a working order by re-importing data from Blaze.

### Environment Variables
* DASHBOARD_DB_PASSWORD: A generated password for the PostgreSQL database, created using a salt string and the SHA1 hash function.
* POSTGRES_TAG: The tag of the PostgreSQL image to use (not set in this module, but required by the dashboard-db service).


### Setup
To enable the Dashboard module, set the ENABLE_FHIR2SQL environment variable to true. The dashboard-setup.sh script will then start the fhir2sql and dashboard-db services, using the environment variables and volumes defined above.