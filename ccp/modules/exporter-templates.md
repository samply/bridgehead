# Exporter Templates

An exporter template describes the **structure** and **content** of the **export output**.

## Main Elements

* **converter**: Defines the **export job**, specifying **output** filenames and **data sources**.
* **container**: Represents a logical grouping of data rows (like a **table**).
* **attribute**: Defines individual data fields/**columns** extracted from the data source.

## Other Elements

* **cql**: Contains Clinical Quality Language metadata used to enrich or filter data.
* **fhir-rev-include**: Defines FHIR reverse includes to fetch related resources.
* **fhir-package**: Defines a FHIR package to be included in the FHIR query.
* **fhir-terminology-server**: FHIR terminology server for validation support.

## Example Snippet

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

## 1. **Converter**

Main tag of an exporter template. The Exporter functions as a flexible system of converters. Given a specific input format and desired output, the exporter determines the optimal chain of converters to transform the input into the required output.

Each converter template provides essential details that help the exporter build the correct conversion chain and produce the final export. The template includes the following components:

- **Source**: The data source from which information is read. Sources are defined in converter.xml, and each template refers to a source by its ID.

- **Information to Export**: Specifies which elements from the source should be included in the output.

- **Metadata**: Defines output structure elements such as header names, column titles, sheet names, etc.

- **Additional Query Information**: Contains any extra data needed to complete and refine the user's query.

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

## 2. **Container**

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

### Note
The following attributes can be used to define the name of the output file:

- **default-name**: Used as a fallback name if no specific filename is provided for the selected output format.

- **csv-filename**: Specifies the filename for CSV output.

- **xml-filename**: Specifies the filename for XML output.

... and so on for other supported formats.

If the user selects an output format that does not have a specifically defined filename, the default-name will be used as the base, with the appropriate file extension automatically appended.
If neither a format-specific filename nor a default-name is provided, a filename will be automatically generated using a UUID and the correct extension.
---

## 3. **Attribute**

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

    * **Direct:** main resource points to secondary resource in a **parent to child** relationship.
    * **Indirect:** secondary resource points back to main resource (path begins with `/`) in a **child to parent** relationship.
* Joins can chain multiple resources, e.g., `R1 -> R2 -> R3`, with commas separating joins.
* It is even possible to combine direct and indirect references: `R1 -> R2 <- R3`: `<fhir path reference R1 -> R2>,/<fhir path reference R3 -> R2>`


*Examples*:

* Example of a **direct relationship**:
```xml
<container id="Histology">
  <attribute id="Histology-ID" default-name="HistologyID" val-fhir-path="Observation.where(code.coding.code = '59847-4').id" anonym="His" op="EXTRACT_RELATIVE_ID"/>
  <attribute default-name="ICDOMorphologyCode" val-fhir-path="Observation.where(code.coding.code = '59847-4').value.coding.code.value"/>
  ...
  <attribute default-name="Grading" val-fhir-path="Observation.where(code.coding.code = '59542-1').value.coding.code.value" join-fhir-path="Observation.where(code.coding.code = '59847-4').hasMember.reference.value"/>
</container>
```
Here, the main observation Observation.where(code.coding.code = '59847-4') contains a reference to the secondary observation Observation.where(code.coding.code = '59542-1'), where we can find the value that we are looking for.

* Example of an **indirect relationship**:
```xml
<container id="Radiation-Therapy" ...>
  <attribute id="Radiation-Therapy-ID" default-name="RadiationTherapyID" val-fhir-path="Procedure.where(category.coding.code = 'ST').id" anonym="Rad" op="EXTRACT_RELATIVE_ID"/>
  <attribute default-name="RadiationTherapyRelationToSurgery" val-fhir-path="Procedure.extension('http://dktk.dkfz.de/fhir/StructureDefinition/onco-core-Extension-StellungZurOp').value.coding.code.value"/>
  ...
  <attribute default-name="Nebenwirkung Grad" val-fhir-path="AdverseEvent.severity.coding.code.value" join-fhir-path="/AdverseEvent.suspectEntity.instance.reference.where(value.startsWith('Procedure')).value" />
</container>
```

---

### Note
The following attributes define the name of a column or field in the output:

- **default-name**: A general fallback name used when no format-specific name is provided.

- **csv-column**: Name used for the CSV output.

- **excel-column**: Name used for Excel output.

- **json-key**: Name used for JSON output.

- **xml-element**: Name used for XML output.

If a format-specific name is not defined for a given output, the default-name will be used.
If default-name is also missing, a UUID will be generated and used as the name.

---

## 4. **CQL**

Contains metadata and details important for handling CQL queries.

| Tag     | Description                                                      |
| ------- | ---------------------------------------------------------------- |
| `<cql>` | Container for CQL query metadata including tokens and parameters |

**Allowed child elements:**

* `<token>`, `<measure-parameters>`, `<default-fhir-search-query>`

---

## 5. **Token (CQL)**

Replaces keys in CQL queries with specific values (commonly used for stratifiers).

| Tag       | Description                           |
| --------- | ------------------------------------- |
| `<token>` | Contains `key` and `value` attributes |

| Attribute | Description                        | Example                                                                                                                       |
| --------- | ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| key       | Key to replace in CQL              | `key="DKTK_STRAT_MEDICATION_STRATIFIER"`                                                                                      |
| value     | CQL code snippet that replaces key | `value="define MedicationStatement: if InInitialPopulation then [MedicationStatement] else {} as List <MedicationStatement>"` |

---

## 6. **Measure Parameters (CQL)**

Parameters for a CQL measure query, typically in JSON format.

| Tag                    | Description                                                 |
| ---------------------- | ----------------------------------------------------------- |
| `<measure-parameters>` | Parameters such as `periodStart`, `periodEnd`, `reportType` |

*Example*:
```xml
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
```
  
---

## 7. **Default FHIR Search Query (CQL)**

FHIR search query applied after obtaining measure reports from CQL.

| Tag                           | Description                                           | Example   |
| ----------------------------- | ----------------------------------------------------- | --------- |
| `<default-fhir-search-query>` | Defines a FHIR resource type to query (e.g., Patient) | `Patient` |

CQL (Clinical Quality Language) queries are primarily used to generate MeasureReports. However, in some cases, it is more useful to extract the underlying data used to build those MeasureReports.

In this context, the CQL query acts as a filtering mechanism—more expressive and powerful than a standard FHIR search query. When the Exporter processes a CQL input, it sends the query to the FHIR server along with the relevant MeasureReport request. The FHIR server responds with a reference to a subset of resources, typically a list of patient IDs. This subset serves as a filter for subsequent data extraction.

The behavior depends on the selected input format:

- **CQL**: The Exporter returns the MeasureReports resulting from the execution of the CQL query.

- **CQL_DATA**: After obtaining the list of matching resource references from the FHIR server, the Exporter performs a second request—a standard FHIR search query—on that filtered list to retrieve the actual data resources (e.g., Patients, Observations, etc.).

The default FHIR search query is applied to get the resources from the FHIR server after getting the list of patients.

---

## 8. **FHIR Reverse Include**

Defines which resources should be reverse-included when using FHIR search as input or CQL\_DATA.

| Tag                  | Description                                                  |
| -------------------- | ------------------------------------------------------------ |
| `<fhir-rev-include>` | Specifies reverse include resources to simplify FHIR queries |

This tag allows users to simplify the FHIR search query by only specifying the search criteria. The specific FHIR resources to be retrieved are defined in the template, not in the user’s query.

This design shifts responsibility:
- The user focuses on defining what to filter (e.g., patients with a certain condition).
- The template defines what information will be extracted from each matching FHIR resource (e.g., which fields from Patient, Observation, etc.).

By separating concerns in this way, the template ensures consistent and controlled data extraction while keeping the user's input simple.

*Example*:
```xml
<fhir-rev-include>Observation:patient</fhir-rev-include>
<fhir-rev-include>Condition:patient</fhir-rev-include>
<fhir-rev-include>ClinicalImpression:patient</fhir-rev-include>
<fhir-rev-include>MedicationStatement:patient</fhir-rev-include>
<fhir-rev-include>Procedure:patient</fhir-rev-include>
<fhir-rev-include>Specimen:patient</fhir-rev-include>
<fhir-rev-include>AdverseEvent:subject</fhir-rev-include>
<fhir-rev-include>CarePlan:patient</fhir-rev-include>
```
