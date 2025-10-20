# Exporter and Reporter

---

## Exporter

**GitHub:** [https://github.com/samply/exporter](https://github.com/samply/exporter)

The Exporter is a **REST API** that enables the export of data from various **bridgehead databases** as **structured tables**. It currently supports only **FHIR sources** such as **Blaze**, but it is designed to be extended to **other types** of data sources. The Exporter provides multiple output formats, including **CSV, Excel, JSON, and XML**, and can also export data directly into **Opal (DataSHIELD)**.

### How it works

The **user** submits a **query** and specifies the desired **export template** and **output format**. The **query** acts like the `WHERE` clause in SQL, filtering data, while the **template** defines what data to select and how to format it, similar to the `SELECT` clause. The Exporter then processes this to generate the export files.

### Exporter Templates
[For further information](exporter-templates.md)


### Environment Variables

Below is a list of configurable environment variables used by the Exporter:

| Variable                                                  | Default                                     | Description                                                |
| --------------------------------------------------------- | ------------------------------------------- | ---------------------------------------------------------- |
| APPLICATION\_PORT                                         | 8092                                        | Port on which the application runs.                        |
| ARCHIVE\_EXPIRED\_QUERIES\_CRON\_EXPRESSION               | `0 0 2 * * *`                               | Cron expression for archiving expired queries.             |
| CLEAN\_TEMP\_FILES\_CRON\_EXPRESSION                      | `0 0 1 * * *`                               | Cron expression for cleaning temporary files.              |
| CLEAN\_WRITE\_FILES\_CRON\_EXPRESSION                     | `0 0 2 * * *`                               | Cron expression for cleaning written files.                |
| CONVERTER\_TEMPLATE\_DIRECTORY                            |                                             | Directory containing conversion templates.                 |
| CONVERTER\_XML\_APPLICATION\_CONTEXT\_PATH                |                                             | Path to the XML application context used by the converter. |
| CROSS\_ORIGINS                                            |                                             | Allowed CORS origins (comma-separated).                    |
| CSV\_SEPARATOR\_REPLACEMENT                               |                                             | Character to replace CSV separators within values.         |
| EXCEL\_WORKBOOK\_WINDOW                                   | 30000000                                    | Memory window size for Excel workbook processing.          |
| EXPORTER\_API\_KEY                                        |                                             | API key for authenticating access to the exporter.         |
| EXPORTER\_DB\_FLYWAY\_MIGRATION\_ENABLED                  | true                                        | Enable Flyway DB migrations on startup.                    |
| EXPORTER\_DB\_PASSWORD                                    |                                             | Password for exporter database.                            |
| EXPORTER\_DB\_URL                                         | `jdbc:postgresql://localhost:5432/exporter` | JDBC URL for exporter DB.                                  |
| EXPORTER\_DB\_USER                                        |                                             | Username for exporter DB.                                  |
| FHIR\_PACKAGES\_DIRECTORY                                 |                                             | Directory where FHIR packages are stored.                  |
| HAPI\_FHIR\_CLIENT\_LOG\_LEVEL                            | OFF                                         | Log level for HAPI FHIR client.                            |
| HIBERNATE\_LOG                                            | false                                       | Enable Hibernate SQL logging.                              |
| HTTP\_RELATIVE\_PATH                                      |                                             | Relative base path for HTTP endpoints.                     |
| HTTP\_SERVLET\_REQUEST\_SCHEME                            | http                                        | Default HTTP scheme.                                       |
| LOG\_FHIR\_VALIDATION                                     |                                             | Enable logging of FHIR validation results.                 |
| LOG\_LEVEL                                                | INFO                                        | Application log level.                                     |
| MAX\_NUMBER\_OF\_EXCEL\_ROWS\_IN\_A\_SHEET                | 100000                                      | Max rows per Excel sheet.                                  |
| MAX\_NUMBER\_OF\_RETRIES                                  | 10                                          | Max retry attempts.                                        |
| MERGE\_FILENAME                                           |                                             | Name of merged output file.                                |
| SITE                                                      |                                             | Site identifier for filenames/logs.                        |
| TEMP\_FILES\_LIFETIME\_IN\_DAYS                           | 1                                           | Lifetime of temporary files (days).                        |
| TEMPORAL\_FILE\_DIRECTORY                                 |                                             | Directory for temporary files.                             |
| TIMEOUT\_IN\_SECONDS                                      | 10                                          | Default timeout (seconds).                                 |
| TIMESTAMP\_FORMAT                                         |                                             | Timestamp format string.                                   |
| WEBCLIENT\_BUFFER\_SIZE\_IN\_BYTES                        | 8192                                        | Buffer size for web client.                                |
| WEBCLIENT\_CONNECTION\_TIMEOUT\_IN\_SECONDS               | 5                                           | Connection timeout (seconds).                              |
| WEBCLIENT\_MAX\_NUMBER\_OF\_RETRIES                       | 10                                          | Max retries for web client.                                |
| WEBCLIENT\_REQUEST\_TIMEOUT\_IN\_SECONDS                  | 10                                          | Request timeout (seconds).                                 |
| WEBCLIENT\_TCP\_KEEP\_CONNECTION\_NUMBER\_OF\_TRIES       | 3                                           | TCP keepalive retry attempts.                              |
| WEBCLIENT\_TCP\_KEEP\_IDLE\_IN\_SECONDS                   | 30                                          | TCP keepalive idle time (seconds).                         |
| WEBCLIENT\_TCP\_KEEP\_INTERVAL\_IN\_SECONDS               | 10                                          | TCP keepalive probe interval (seconds).                    |
| WEBCLIENT\_TIME\_IN\_SECONDS\_AFTER\_RETRY\_WITH\_FAILURE | 1                                           | Wait time after failed retry (seconds).                    |
| WRITE\_FILE\_DIRECTORY                                    |                                             | Directory for final output files.                          |
| WRITE\_FILES\_LIFETIME\_IN\_DAYS                          | 30                                          | Lifetime of written files (days).                          |
| XML\_FILE\_MERGER\_ROOT\_ELEMENT                          | Containers                                  | Root element for XML file merging.                         |
| ZIP\_FILENAME                                             | `exporter-files-${SITE}-${TIMESTAMP}.zip`   | Pattern for ZIP archive naming.                            |

---

### About Cron Expressions in Spring

Cron expressions configure scheduled tasks and consist of six space-separated fields representing second, minute, hour, day of month, month, and day of week. For example, the default `0 0 2 * * *` means “at 2:00 AM every day.” These expressions allow precise scheduling for maintenance tasks such as cleaning files or archiving data.  

---

## Exporter-DB

**GitHub:** [https://github.com/samply/exporter-db](https://github.com/samply/exporter-db) (If exists; if not, just remove or adjust accordingly)

The Exporter-DB stores queries for execution by the Exporter and tracks multiple executions of the same query, managing versioning and scheduling.

---

## Reporter

**GitHub:** [https://github.com/samply/reporter](https://github.com/samply/reporter)

The Reporter is a **plugin for the Exporter** designed for generating **complex Excel reports** based on **customizable templates**. It supports various template engines like **Groovy** and **Thymeleaf**, making it ideal for producing detailed documents such as the traditional CCP **data quality report**.

---


