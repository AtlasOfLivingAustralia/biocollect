load("../../../mongo/utils/audit.js");

const commonNameMapping = {
    "vernacular name": "VernacularName",
    "Supplied common name":	"Supplied_common_name",
    "Other Name": "Other_Name",
    "common name": "CommonNames",
    "undefined": "commonName",
    "suppliedCommonName": "Supplied_common_name",
    "commonName": "commonName",
    "rawScientificName": "rawScientificName",
    "matchedName": "matchedName",
    "vernacularName": "vernacularName",
    "commonNameAndBionetCode": "commonNameAndBionetCode",
    "commName": "commName"
};

const scientificNameMapping = {
    "Display name":	"Display_Name",
    "Full name": "Full_name",
    "supplied species name": "supplied species name",
    "undefined": "matchedName",
    "commonName": "commonName",
    "rawScientificName": "rawScientificName",
    "matchedName": "matchedName",
    "Supplied Name": "rawSupplied_Name",
};

db.projectActivity.find({
    "speciesFields.config.type": "GROUP_OF_SPECIES",
    status: "active",
    published: true
}).forEach(function(pa) {
    var updated = false;
    pa.speciesFields && pa.speciesFields.forEach(function(speciesField) {
        if (speciesField.config.type != 'GROUP_OF_SPECIES') {
            return;
        }

        if (speciesField.config.commonNameField && commonNameMapping[speciesField.config.commonNameField]) {
            speciesField.config.commonNameField = commonNameMapping[speciesField.config.commonNameField];
            updated = true;
        }
        else if (!speciesField.config.commonNameField) {
            speciesField.config.commonNameField = commonNameMapping['undefined'];
            updated = true;
        }
        else {
            print('No mapping found for commonNameField: ' + speciesField.config.commonNameField + ' in project activity with project id: ' + pa.projectId + 'and project activity id: ' + pa.projectActivityId + ' - ' + pa.name);
        }

        if (speciesField.config.scientificNameField && scientificNameMapping[speciesField.config.scientificNameField]) {
            speciesField.config.scientificNameField = scientificNameMapping[speciesField.config.scientificNameField];
            updated = true;
        }
        else if (!speciesField.config.scientificNameField) {
            speciesField.config.scientificNameField = scientificNameMapping['undefined'];
            updated = true;
        }
        else {
            print('No mapping found for scientificNameField: ' + speciesField.config.scientificNameField + ' in project activity with project id: ' + pa.projectId + 'and project activity id: ' + pa.projectActivityId + ' - ' + pa.name);
        }
    });

    if (updated) {
        pa.lastUpdated = new ISODate();
        db.projectActivity.updateOne({projectActivityId: pa.projectActivityId}, {$set: {speciesFields: pa.speciesFields, lastUpdated: pa.lastUpdated}});
        audit(pa, pa.projectActivityId, 'au.org.ala.ecodata.ProjectActivity', 'system');
        print('Updated project activity with project id: ' + pa.projectId + 'and project activity id: ' + pa.projectActivityId + ' - ' + pa.name);
    }
});