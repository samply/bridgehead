# Exporter and Reporter

---

## Exporter

**GitHub:** [https://github.com/samply/exporter](https://github.com/samply/exporter)

The Exporter is a **REST API** that enables the export of data from various **bridgehead databases** as **structured tables**. It currently supports only **FHIR sources** such as **Blaze**, but it is designed to be extended to **other types** of data sources. The Exporter provides multiple output formats, including **CSV, Excel, JSON, and XML**, and can also export data directly into **Opal (DataSHIELD)**.

### How it works

The **user** submits a **query** and specifies the desired **export template** and **output format**. The **query** acts like the `WHERE` clause in SQL, filtering data, while the **template** defines what data to select and how to format it, similar to the `SELECT` clause. The Exporter then processes this to generate the export files.

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

## Exporter Templates

An exporter template describes the **structure** and **content** of the **export output**.

### Main Elements

* **converter**: Defines the export job, specifying output files and data sources.
* **container**: Represents a logical grouping of data rows (like a table).
* **attribute**: Defines individual data fields/columns extracted from the data source.

### Other Elements

* **cql**: Contains Clinical Quality Language metadata used to enrich or filter data.
* **fhir-rev-include**: Defines FHIR reverse includes to fetch related resources.
* **fhir-package**: (To be detailed)
* **fhir-terminology-server**: (To be detailed)

### Example Snippet

```xml
<converter id="ccp" excel-filename="Export-${SITE}-${TIMESTAMP}.xlsx" source-id="blaze-store" >
  <container id="Patient" csv-filename="Patient-${SITE}-${TIMESTAMP}.csv" excel-sheet="Patient" xml-filename="Patient-${SITE}-${TIMESTAMP}.xml" xml-root-element="Patients" xml-element="Patient" json-filename="Patient-${SITE}-${TIMESTAMP}.json" json-key="Patients" >
    <attribute id="Patient-ID" default-name="PatientID" val-fhir-path="Patient.id.value" anonym="Pat" op="EXTRACT_RELATIVE_ID"/>

    <attribute default-name="DKTKIDGlobal" val-fhir-path="Patient.identifier.where(type.coding.code = 'Global').value.value"/>
    <attribute default-name="DKTKIDLokal" val-fhir-path="Patient.identifier.where(type.coding.code = 'Lokal').value.value" />
    <attribute default-name="DateOfBirth" val-fhir-path="Patient.birthDate.value.toString().substring(0, 4) + '-01-01'"/>
    <attribute default-name="Gender" val-fhir-path="Patient.gender.value" />
  </container>

  <container id="Diagnosis" csv-filename="Diagnosis-${SITE}-${TIMESTAMP}.csv" excel-sheet="Diagnosis" xml-filename="Diagnosis-${SITE}-${TIMESTAMP}.xml" xml-root-element="Diagnoses" xml-element="Diagnosis" json-filename="Diagnosis-${SITE}-${TIMESTAMP}.json" json-key="Diagnoses">
    <attribute id="Diagnosis-ID" default-name="DiagnosisID" val-fhir-path="Condition.id.value" anonym="Dia" op="EXTRACT_RELATIVE_ID"/>
    <attribute id="Patient-ID" link="Patient.Patient-ID" default-name="PatientID" val-fhir-path="Condition.subject.reference.value" anonym="Pat"/>

    <attribute default-name="ICD10Code" val-fhir-path="Condition.code.coding.code.value"/>
    <attribute default-name="ICDOTopographyCode" val-fhir-path="Condition.bodySite.coding.where(system = 'urn:oid:2.16.840.1.113883.6.43.1').code.value"/>
    <attribute default-name="LocalizationSide" val-fhir-path="Condition.bodySite.coding.where(system = 'http://dktk.dkfz.de/fhir/onco/core/CodeSystem/SeitenlokalisationCS').code.value"/>
  </container>

  <container id="Histology" csv-filename="Histology-${SITE}-${TIMESTAMP}.csv" excel-sheet="Histology" xml-filename="Histology-${SITE}-${TIMESTAMP}.xml" xml-root-element="Histologies" xml-element="Histology" json-filename="Histology-${SITE}-${TIMESTAMP}.json" json-key="Histologies" >
    <attribute id="Histology-ID" default-name="HistologyID" val-fhir-path="Observation.where(code.coding.code = '59847-4').id" anonym="His" op="EXTRACT_RELATIVE_ID"/>
    <attribute id="Diagnosis-ID" link="Diagnosis.Diagnosis-ID" default-name="DiagnosisID" val-fhir-path="Observation.where(code.coding.code = '59847-4').focus.reference.value" anonym="Dia"/>
    <attribute id="Patient-ID" link="Patient.Patient-ID" default-name="PatientID" val-fhir-path="Observation.where(code.coding.code = '59847-4').subject.reference.value" anonym="Pat" />

    <attribute default-name="ICDOMorphologyCode" val-fhir-path="Observation.where(code.coding.code = '59847-4').value.coding.code.value"/>
    <attribute default-name="Grading" val-fhir-path="Observation.where(code.coding.code = '59542-1').value.coding.code.value" join-fhir-path="Observation.where(code.coding.code = '59847-4').hasMember.reference.value"/>
  </container>

  <container id="Radiation-Therapy" csv-filename="RadiationTherapy-${SITE}-${TIMESTAMP}.csv" excel-sheet="RadiationTherapy" xml-filename="RadiationTherapy-${SITE}-${TIMESTAMP}.xml" xml-root-element="Radiation-Therapies" xml-element="Radiation-Therapy" json-filename="RadiationTherapy-${SITE}-${TIMESTAMP}.json" json-key="Radiation Therapies">
    <attribute id="Radiation-Therapy-ID" default-name="RadiationTherapyID" val-fhir-path="Procedure.where(category.coding.code = 'ST').id" anonym="Rad" op="EXTRACT_RELATIVE_ID"/>
    <attribute id="Diagnosis-ID" link="Diagnosis.Diagnosis-ID" default-name="DiagnosisID" val-fhir-path="Procedure.where(category.coding.code = 'ST').reasonReference.reference.value" anonym="Dia"/>
    <attribute id="Patient-ID" link="Patient.Patient-ID" default-name="PatientID" val-fhir-path="Procedure.where(category.coding.code = 'ST').subject.reference.value" anonym="Pat" />

    <attribute default-name="RadiationTherapyRelationToSurgery" val-fhir-path="Procedure.extension('http://dktk.dkfz.de/fhir/StructureDefinition/onco-core-Extension-StellungZurOp').value.coding.code.value"/>
    <attribute default-name="RadiationTherapyIntention" val-fhir-path="Procedure.extension('http://dktk.dkfz.de/fhir/StructureDefinition/onco-core-Extension-SYSTIntention').value.coding.code.value" />
    <attribute default-name="RadiationTherapyStart" val-fhir-path="Procedure.where(category.coding.code = 'ST').performed.start.value"/>
    <attribute default-name="RadiationTherapyEnd" val-fhir-path="Procedure.where(category.coding.code = 'ST').performed.end.value"/>
    <attribute default-name="Nebenwirkung Grad" val-fhir-path="AdverseEvent.severity.coding.code.value" join-fhir-path="/AdverseEvent.suspectEntity.instance.reference.where(value.startsWith('Procedure')).value" />
  </container>


  <cql>
    <default-fhir-search-query>Patient</default-fhir-search-query>

    <token key="DKTK_STRAT_MEDICATION_STRATIFIER" value="define MedicationStatement:&#10;if InInitialPopulation then [MedicationStatement] else {} as List &lt;MedicationStatement&gt; &#10;" />
    <token key="DKTK_STRAT_PRIMARY_DIAGNOSIS_NO_SORT_STRATIFIER" value="define PrimaryDiagnosis:&#10;First(&#10;from [Condition] C&#10;where C.extension.where(url=&apos;http://hl7.org/fhir/StructureDefinition/condition-related&apos;).empty()) &#10;" />

    <measure-parameters>
      {
      "resourceType": "Parameters",
      "parameter": [
      {
      "name": "periodStart",
      "valueDate": "2000"
      },
      {
      "name": "periodEnd",
      "valueDate": "2030"
      },
      {
      "name": "reportType",
      "valueCode": "subject-list"
      }
      ]
      }
    </measure-parameters>
  </cql>



  <fhir-rev-include>Observation:patient</fhir-rev-include>
  <fhir-rev-include>Condition:patient</fhir-rev-include>
  <fhir-rev-include>ClinicalImpression:patient</fhir-rev-include>
  <fhir-rev-include>MedicationStatement:patient</fhir-rev-include>
  <fhir-rev-include>Procedure:patient</fhir-rev-include>
  <fhir-rev-include>Specimen:patient</fhir-rev-include>
  <fhir-rev-include>AdverseEvent:subject</fhir-rev-include>
  <fhir-rev-include>CarePlan:patient</fhir-rev-include>

</converter>
```

---

### 1. **Converter**

Main tag of an exporter template grouping converters to find the best chain for data conversion.

| Tag           | Description                                                                                   |
| ------------- | --------------------------------------------------------------------------------------------- |
| `<converter>` | Main tag for exporter template containing sources, metadata, and additional query information |

| Attribute                | Description                                                                             | Example                                             | Default |
| ------------------------ | --------------------------------------------------------------------------------------- | --------------------------------------------------- | ------- |
| id                       | ID to reference a template                                                              | `id="ccp-opal"`                                     | —       |
| default-name             | Default name when output is in a single file format (no extension; added automatically) | —                                                   | —       |
| ignore                   | Deactivate template but keep accessible                                                 | `ignore="true"`                                     | false   |
| excel-filename           | Name of the Excel output file (supports variables `${SITE}`, `${TIMESTAMP}`)            | `excel-filename="Export-${SITE}-${TIMESTAMP}.xlsx"` | —       |
| csv-separator            | CSV separator character                                                                 | —                                                   | `"\t"`  |
| source-id                | ID of the data source                                                                   | `source-id="blaze-store"`                           | —       |
| target-id                | ID of a target server for file transfer (e.g., Opal for DataSHIELD)                     | `target-id="opal"`                                  | —       |
| opal-project             | Opal-specific: name of project                                                          | —                                                   | —       |
| opal-permission-type     | Opal permission type (`user` or `group`)                                                | —                                                   | —       |
| opal-permission-subjects | Opal permission subjects                                                                | —                                                   | —       |
| opal-permission          | Opal permission (`administrate` or `use`)                                               | —                                                   | —       |

**Notes:**
* You can use variables such as `${SITE}`, `${TIMESTAMP}`, and other environment variables within tags.
* To define environment variables for a specific export, use the HTTP parameter **`CONTEXT`**.
  The value must be a Base64-encoded string containing comma-separated key-value pairs.
* **Example:**
  Plain: `KEY1=VALUE1,KEY2=VALUE2`
  Base64: `S0VZMT1WQUxVRTEsS0VZMj1WQUxVRTI=`

**Allowed child elements:**

* `<container>`, `<cql>`, `<fhir-rev-include>`, `<fhir-package>`, `<fhir-terminology-server>`

---

### 2. **Container**

Represents a data table with columns (attributes).

| Tag           | Description                                         |
| ------------- | --------------------------------------------------- |
| `<container>` | Defines a container/table with attributes (columns) |

| Attribute        | Description                                                  | Example                                       | Default |
| ---------------- | ------------------------------------------------------------ | --------------------------------------------- | ------- |
| id               | Container ID to reference                                    | —                                             | —       |
| default-name     | Name of Excel sheet/file (no extension, added automatically) | —                                             | —       |
| csv-filename     | Name of CSV file                                             | `csv-filename="Diagnosis-${TIMESTAMP}.csv"`   | —       |
| json-filename    | Name of JSON file                                            | `json-filename="diagnosis-${TIMESTAMP}.json"` | —       |
| xml-filename     | Name of XML file                                             | `xml-filename="diagnosis-${TIMESTAMP}.xml"`   | —       |
| xml-root-element | Root element name in XML                                     | `xml-root-element="diagnoses"`                | —       |
| xml-element      | Element name for each entry in XML                           | `xml-element="diagnosis"`                     | —       |
| excel-sheet      | Excel sheet name                                             | `excel-sheet="diagnosis-${TIMESTAMP}.xlsx"`   | —       |
| opal-table       | Opal table name                                              | `opal-name="Diagnosis"`                       | —       |
| opal-entity-type | Opal entity type                                             | —                                             | —       |

---

### 3. **Attribute**

Represents a column in a container/table.

| Tag           | Description                 |
| ------------- | --------------------------- |
| `<attribute>` | Defines an attribute/column |

| Attribute                 | Description                                                                                    | Example                                                                                                      | Default |
| ------------------------- | ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ | ------- |
| id                        | Attribute ID                                                                                   | `id="Patient-ID"`                                                                                            | —       |
| default-name              | Default name of the attribute (used if no output-specific name provided)                       | —                                                                                                            | —       |
| link                      | Reference to an attribute of another container (format: `<container-name>.<attribute-id>`)     | `link="Patient.Patient-ID"`                                                                                  | —       |
| csv-column                | Name of the CSV column                                                                         | —                                                                                                            | —       |
| excel-column              | Name of the Excel column                                                                       | —                                                                                                            | —       |
| json-key                  | JSON key                                                                                       | —                                                                                                            | —       |
| xml-element               | XML element name                                                                               | —                                                                                                            | —       |
| opal-value-type           | Opal-specific value type                                                                       | —                                                                                                            | —       |
| opal-script               | Script to be applied to the field in Opal                                                      | —                                                                                                            | —       |
| primary-key               | Marks attribute as primary key                                                                 | `primary-key="true"`                                                                                         | false   |
| validation                | Marks attribute as syntactic validation field (ends with `-Validation` in DKTK/BBMRI reporter) | `validation="true"`                                                                                          | false   |
| val-fhir-path             | FHIR path to extract value (if source is a FHIR server)                                        | `val-fhir-path="Patient.gender.value"`                                                                       | —       |
| join-fhir-path            | FHIR path for joining secondary resources to main resource                                     | `join-fhir-path="/AdverseEvent.suspectEntity.instance.reference.where(value.startsWith('Procedure')).value"` | —       |
| condition-value-fhir-path | Condition filtering for complex value extraction (FHIR path syntax)                            | `condition-value-fhir-path="Patient.birthDate <= today() - 18 'years'"`                                      | —       |
| anonym                    | Anonymization prefix; replaces real value with `anonym` + number                               | `anonym="Pat"`                                                                                               | —       |
| mdr                       | Metadata repository ID in DKTK context                                                         | `mdr="dktk:dataelement:20:3"`                                                                                | —       |
| op                        | Operation applied on value (e.g., `EXTRACT_RELATIVE_ID`)                                       | `op="EXTRACT_RELATIVE_ID"`                                                                                   | —       |

---

### Notes on **join-fhir-path**

* Used to join resources in FHIR queries when container references multiple resources.
* Two join types:

    * **Direct:** main resource points to secondary resource.
    * **Indirect:** secondary resource points back to main resource (path begins with `/`).
* Joins can chain multiple resources, e.g., `R1 -> R2 -> R3`, with commas separating joins.

---

### 4. **CQL**

Contains metadata and details important for handling CQL queries.

| Tag     | Description                                                      |
| ------- | ---------------------------------------------------------------- |
| `<cql>` | Container for CQL query metadata including tokens and parameters |

---

### 5. **Token (CQL)**

Replaces keys in CQL queries with specific values (commonly used for stratifiers).

| Tag       | Description                           |
| --------- | ------------------------------------- |
| `<token>` | Contains `key` and `value` attributes |

| Attribute | Description                        | Example                                                                                                                       |
| --------- | ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| key       | Key to replace in CQL              | `key="DKTK_STRAT_MEDICATION_STRATIFIER"`                                                                                      |
| value     | CQL code snippet that replaces key | `value="define MedicationStatement: if InInitialPopulation then [MedicationStatement] else {} as List <MedicationStatement>"` |

---

### 6. **Measure Parameters (CQL)**

Parameters for a CQL measure query, typically in JSON format.

| Tag                    | Description                                                 |
| ---------------------- | ----------------------------------------------------------- |
| `<measure-parameters>` | Parameters such as `periodStart`, `periodEnd`, `reportType` |

---

### 7. **Default FHIR Search Query (CQL)**

FHIR search query applied after obtaining measure reports from CQL.

| Tag                           | Description                                           | Example   |
| ----------------------------- | ----------------------------------------------------- | --------- |
| `<default-fhir-search-query>` | Defines a FHIR resource type to query (e.g., Patient) | `Patient` |

---

### 8. **FHIR Reverse Include**

Defines which resources should be reverse-included when using FHIR search as input or CQL\_DATA.

| Tag                  | Description                                                  |
| -------------------- | ------------------------------------------------------------ |
| `<fhir-rev-include>` | Specifies reverse include resources to simplify FHIR queries |

---

