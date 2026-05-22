print("scientificNameField,commonNameField,dataResourceUid,listName");
db.projectActivity.find({published: true, status: 'active'}).forEach(function(pa) {
    pa.speciesFields && pa.speciesFields.forEach(function(speciesField) {
        if (speciesField.config && speciesField.config.type === 'GROUP_OF_SPECIES') {
            speciesField.config.speciesLists && speciesField.config.speciesLists.forEach(function(speciesList) {
                print(speciesField.config.scientificNameField + "," + speciesField.config.commonNameField + "," + speciesList.dataResourceUid + "," + speciesList.listName);
            });
        }
    });
});