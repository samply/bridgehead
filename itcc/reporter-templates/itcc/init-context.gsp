<%@ page import="de.samply.reporter.context.Context" %>
<% Context context %> <!--@ignore-->
<%
    def patientsProAttributeValueKey = "Patients pro attribute-value"
    def patientsProAttributeKey = "Patients pro attribute"
    def validationKey = "Validation"
    // Key names are read by the shared ccp sheet scripts of the dktk-reporter image
    def patientIdLocalIdMapKey = "Patient Id - DKTK-ID Map"
    def attributeMetaInfoKey = "Attribute Meta Info"
    def totalNumberOfPatientsKey = "total number of patients"
    def existsValidationKey = "Exists Validation for Attribute"
    def emptyValue = ""
    def idSuffix = "-id"
%>
<!-- Attribute Meta Info: same index layout as ccp/init-context.gsp, because the ccp sheet scripts read it.
4. FHIR element, 6. Data type, 7. Data element, 8. Allowed values (null: no value list)
Source: ITCC Datamodel_updated_20260907.xlsx (CDE-FHIR_Mapping)
-->
<%
    def meta = { fhirElement, dataType, dataElement, allowedValues = null -> ["", "", "", "", fhirElement, "", dataType, dataElement, allowedValues] }
    def attributeMetaInfo = [
            "PatientIdentifier"  : meta("Patient.identifier", "String", "Identifier of the patient"),
            "Gender"             : meta("Patient.gender", "List", "Biological sex of the patient", ["male", "female", "unknown"]),
            "VitalStatus"        : meta("Observation(VitalStatus).valueCodeableConcept", "List", "Vital status", ["alive", "deceased", "unknown"]),
            "DeathDetail"        : meta("Observation(VitalStatus).component.valueCodeableConcept", "List", "Deceased detail", ["dead-from-cancer", "dead-from-other-cause", "unknown"]),
            "AgeAtVitalStatus"   : meta("Observation(VitalStatus).component.valueQuantity", "Float", "Age in months at latest status"),
            "ConditionType"      : meta("Condition.category", "List", "Condition type", ["primary", "relapse", "progression", "secondary-malignancy", "refractory"]),
            "Diagnosis"          : meta("Condition.code.coding (itcc-core-clinical-diagnosis-cs)", "List", "Code of the diagnosis", ["ALL", "AML", "DSRCT", "EPN", "EWS", "HL", "HGG", "LGG", "MB", "NBL", "NHL", "Osteo", "Other", "Rhabdoid", "STS", "WT"]),
            "DiagnosisWHO"       : meta("Condition.code.coding (itcc-core-clinical-diagnosis-who-cs)", "String", "WHO list"),
            "AgeAtOnset"         : meta("Condition.onsetAge", "Float", "Age in months"),
            "AgeAtOnsetPrecision": meta("Condition.onsetAge.extension (itcc-core-age-precision-ext)", "String", "Precision of the age"),
            "HadEvent"           : meta("Condition.extension (itcc-core-had-event-ext)", "List", "Event flag", ["true", "false"]),
            "DiseaseExtent"      : meta("Observation(DiseaseExtent).valueCodeableConcept", "List", "Disease extent", ["Unknown", "Local", "Metastatic", "LocalAndMetastatic"]),
            "DiseaseExtentDetail": meta("Observation(DiseaseExtent).component.valueCodeableConcept", "List", "Disease extent detail", ["leptomeningeal", "distant-lymph-nodes", "bone-marrow", "lung", "liver", "skin", "cutaneous", "subcutaneous", "soft-tissue", "kidney", "bone", "other", "unknown"]),
            "SampleIdentifier"   : meta("Specimen.identifier", "String", "Identifier of the sample (Link to WP3)"),
            "SampleType"         : meta("Specimen.type (itcc-core-specimen-type-cs)", "List", "Type of the sample", ["tumor", "csf", "plasma", "bone-marrow-aspirate", "DNA", "RNA", "skin-biopsy", "other"]),
            "SampleTypeSNOMED"   : meta("Specimen.type (SNOMED CT)", "String", "Type of the sample (SNOMED CT)"),
            "AgeAtSampling"      : meta("Specimen.extension (itcc-core-specimen-age-ext)", "Float", "Age in months when sample was extracted"),
            "TumorContext"       : meta("Specimen.extension (itcc-core-specimen-tumor-context-ext)", "List", "Origin (primary or metastasis)", ["primary-cancer", "metastatic-cancer", "cell-free-dna"])
    ]
    context.putElement(attributeMetaInfo, attributeMetaInfoKey)
%>
<%
    def validatedAttributes = attributeMetaInfo.findAll { attribute, info -> info[8] != null || info[6] == "Float" }.keySet()
    def fetchValidationError = { attribute, value ->
        def info = attributeMetaInfo[attribute]
        if (info == null || value == emptyValue) return null
        if (info[8] != null && !info[8].contains(value)) return "allowed: " + info[8].join("|")
        if (info[6] == "Float" && !value.isNumber()) return "not a number"
        return null
    }
    // putElement does not overwrite, so the stored set is the one to fill
    def fetchPatients = { String... keys ->
        def patients = context.getElement(keys)
        if (patients == null) {
            patients = [] as Set
            context.putElement(patients, keys)
        }
        return patients
    }
    def patientIdLocalIdMap = [:]
    context.getSourcePaths().forEach(path -> {
        if (context.hasOnlyHeaders(path)) {
            context.fetchHeaders(path).forEach { attribute ->
                if (attribute != null && attribute.trim().size() > 0) {
                    fetchPatients(patientsProAttributeValueKey, attribute, emptyValue)
                    fetchPatients(patientsProAttributeKey, attribute, emptyValue)
                }
            }
        } else {
            context.applyToRecords(path, csvRecord -> {
                def patientId = csvRecord.get("Patient-ID")
                if (path.getFileName().toString().contains("Patient")) {
                    def localId = csvRecord.get("PatientIdentifier")
                    if (localId != null && localId.trim().size() > 0) {
                        patientIdLocalIdMap.put(patientId, localId)
                    }
                }
                csvRecord.getParser().getHeaderMap().keySet().findAll { header -> !header.toLowerCase().endsWith(idSuffix) }.forEach { header ->
                    def value = csvRecord.get(header)
                    if (value == null || value.trim().size() == 0) {
                        value = emptyValue
                    }
                    def patientsForValue = fetchPatients(patientsProAttributeValueKey, header, value)
                    def patientsForAttribute = fetchPatients(patientsProAttributeKey, header)
                    if (value != emptyValue) {
                        patientsForValue.add(patientId)
                        patientsForAttribute.add(patientId)
                    }

                    def validationError = fetchValidationError(header, value)
                    if (validationError != null) {
                        def error = context.getElement(validationKey, header, value)
                        if (error == null) {
                            error = [validationError, [] as Set]
                            context.putElement(error, validationKey, header, value)
                        }
                        error[1].add(patientId)
                    }
                }
            })
        }
    })
    context.putElement(patientIdLocalIdMap, patientIdLocalIdMapKey)
    context.putElement(validatedAttributes, existsValidationKey)
%>
<%
    def patientIds = [] as Set
    context.getAllElement(patientsProAttributeKey).forEach { tempPatientIds -> patientIds.addAll(tempPatientIds) }
    context.putElement(Integer.valueOf(patientIds.size()), totalNumberOfPatientsKey)
%>
