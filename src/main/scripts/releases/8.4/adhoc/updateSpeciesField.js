load("../../../mongo/utils/audit.js");
db.projectActivity.find({
    "$or": [{"speciesFields.config.scientificNameField": / /}, {"speciesFields.config.commonNameField": / /}],
    status: "active",
    published: true
}).forEach(function(pa) {
    var updated = false;
    pa.speciesFields && pa.speciesFields.forEach(function(speciesField) {
        if (speciesField.config.scientificNameField && speciesField.config.scientificNameField.includes(' ')) {
            speciesField.config.scientificNameField = replaceWhiteSpaceWithUnderScore(speciesField.config.scientificNameField);
            updated = true;
        }

        if (speciesField.config.commonNameField && speciesField.config.commonNameField.includes(' ')) {
            speciesField.config.commonNameField = replaceWhiteSpaceWithUnderScore(speciesField.config.commonNameField);
            updated = true;
        }
    });

    if (updated) {
        pa.lastUpdated = new ISODate();
        db.projectActivity.updateOne({projectActivityId: pa.projectActivityId}, {$set: {speciesFields: pa.speciesFields, lastUpdated: pa.lastUpdated}});
        audit(pa, pa.projectActivityId, 'au.org.ala.ecodata.ProjectActivity', 'system');
        print('Updated project activity with project id: ' + pa.projectId + 'and project activity id: ' + pa.projectActivityId + ' - ' + pa.name);
    }
});

function replaceWhiteSpaceWithUnderScore(fieldName) {
    return fieldName.replace(/ /g, '_');
}