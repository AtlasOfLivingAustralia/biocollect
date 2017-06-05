/**
 * Manages the species data type in the output model.
 * Allows species information to be searched for and displayed.
 * output, dataFieldName and survey are optional parameters and
 * if present will be used to pinpoint either the projectActivity or project configuration to restrict the species values
 * available for this field
 *
 * @param species If provided, populate SpeciesViewModel name, guid, scientificName, commonName and their transients from this object
 * @param populate If true populate species information from fcConfig.getSingleSpeciesUrl
 * @param output Identity of field for specific configuration.
 * @param dataFieldName Identity of field for specific configuration.
 * @param survey The survey where this field belongs for  specific configuration.
 */
var SpeciesViewModel = function (species, populate, output, dataFieldName, surveyName) {
    var self = this;
    if (!species) species = {};
    if (!populate) populate = false;
    if(!output) output = "";
    if(!dataFieldName) dataFieldName = "";
    if(!surveyName) surveyName = "";

    self.name = ko.observable(species.name);
    self.guid = ko.observable(species.guid);
    self.scientificName = ko.observable(species.scientificName);
    self.commonName = ko.observable(species.commonName);

    // Reference to output species uuid - for uniqueness retrieved from ecodata server
    self.outputSpeciesId = ko.observable();

    self.transients = {};
    self.transients.name = ko.observable(species.name);
    self.transients.guid = ko.observable(species.guid);
    self.transients.scientificName = ko.observable(species.scientificName);
    self.transients.speciesFieldIsReadOnly = ko.observable(false);
    self.transients.commonName = ko.observable(species.commonName);
    self.transients.image = ko.observable(species.image || '');
    self.transients.source = ko.observable(fcConfig.speciesSearch +
        '&output=' + output+ '&dataFieldName=' + dataFieldName + '&surveyName=' + surveyName);
    self.transients.bieUrl = ko.observable();

    self.transients.bioProfileUrl = ko.computed(function () {
        return self.transients.bieUrl();
    });

    self.focusLost = function (event) {
        self.name(self.transients.name());
        self.guid(self.transients.guid());
        self.scientificName(self.transients.scientificName());
        self.commonName(self.transients.commonName());
        self.transients.bieUrl(fcConfig.bieUrl + '/species/' + self.guid());
    };

    self.transients.guid.subscribe(function (newValue) {
        self.name(self.transients.name());
        self.guid(self.transients.guid());
        self.scientificName(self.transients.scientificName());
        self.commonName(self.transients.commonName());
        self.transients.bieUrl(fcConfig.bieUrl + '/species/' + self.guid());
    });

    self.name.subscribe(function (newName) {
        if (!self.outputSpeciesId() && newName != species.name) {
            self.assignOutputSpeciesId();
        }
    });

    self.populateSingleSpecies = function (populate) {
        if (!self.name() && !self.guid() && fcConfig.getSingleSpeciesUrl && populate) {
            $.ajax({
                url: fcConfig.getSingleSpeciesUrl + '?output=' + output+ '&dataFieldName=' + dataFieldName
                +'&surveyName=' + surveyName,
                type: 'GET',
                contentType: 'application/json',
                success: function (data) {
                    if (data.name && data.guid) {
                        self.transients.name(data.name);
                        self.transients.scientificName(data.scientificName);
                        self.transients.commonName(data.commonName);
                        self.transients.speciesFieldIsReadOnly(true);
                        self.transients.guid(data.guid); // This will update the non-transient data.
                    }
                },
                error: function (data) {
                    console.log('Error retrieving single species')
                }
            });
        }
    };

    self.reset = function () {
        self.name("");
        self.guid("");
        self.scientificName("");
        self.commonName("");
        self.transients.name("");
        self.transients.guid("");
        self.transients.scientificName("");
        self.transients.commonName("");
    };

    self.guidFromOutputSpeciesId = function(species) {
        if (species.outputSpeciesId) {
            self.outputSpeciesId(species.outputSpeciesId);
            $.ajax({
                url: fcConfig.getGuidForOutputSpeciesUrl+ "/" + species.outputSpeciesId,
                type: 'GET',
                contentType: 'application/json',
                success: function (data) {
                    self.transients.bieUrl(data.guid ? fcConfig.bieUrl + '/species/' + data.guid : fcConfig.bieUrl);
                },
                error: function (data) {
                    bootbox.alert("Error retrieving species data, please try again later.");
                }
            });

        }
    };

    /**
     * Obtain a unique id for this species to correlate the form data with occurance
     * records produced for export to the ALA
     */
    self.assignOutputSpeciesId = function() {
        var idRequired = fcConfig.getOutputSpeciesIdUrl;
        if (idRequired && !self.outputSpeciesId() && self.guid()) {
            self.transients.bieUrl(fcConfig.bieUrl + '/species/' + self.guid());
            $.ajax({
                url: fcConfig.getOutputSpeciesIdUrl,
                type: 'GET',
                contentType: 'application/json',
                success: function (data) {
                    if (data.outputSpeciesId) {
                        self.outputSpeciesId(data.outputSpeciesId);
                    }
                },
                error: function (data) {
                    bootbox.alert("Error retrieving species data, please try again later.");
                }
            });
        }
    };

    self.guidFromOutputSpeciesId(species);
    self.populateSingleSpecies(populate);
    if (species.name && !self.outputSpeciesId()) {
        self.assignOutputSpeciesId(); // This will result in the data being marked as dirty.
    }
};

function validateSpeciesLookup(element) {

}
