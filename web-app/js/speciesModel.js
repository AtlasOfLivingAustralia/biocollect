/**
 * Manages the species data type in the output model.
 * Allows species information to be searched for and displayed.
 * @param species If provided, populate SpeciesViewModel name, guid, scientificName, commonName and their transients from this object
 * @param populate If true populate species information from fcConfig.getSingleSpeciesUrl
 * @param output Identity of field for specific configuration.
 * @param dataFieldName Identity of field for specific configuration.
 */
var SpeciesViewModel = function (species, populate, output, dataFieldName) {
    var self = this;
    if (!species) species = {};
    if (!populate) populate = false;
    if(!output) output = "";
    if(!dataFieldName) dataFieldName = "";
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
    self.transients.source = ko.observable(fcConfig.speciesSearch +
        '&output=' + output+ '&dataFieldName=' + dataFieldName);
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

    self.populateSingleSpecies = function (populate) {
        if (!self.name() && !self.guid() && fcConfig.getSingleSpeciesUrl && populate) {
            $.ajax({
                url: fcConfig.getSingleSpeciesUrl + '?output=' + output+ '&dataFieldName=' + dataFieldName ,
                type: 'GET',
                contentType: 'application/json',
                success: function (data) {
                    if (data.name && data.guid) {
                        self.name(data.name);
                        self.guid(data.guid);
                        self.scientificName(data.scientificName);
                        self.commonName(data.commonName);
                        self.transients.name(data.name);
                        self.transients.guid(data.guid);
                        self.transients.scientificName(data.scientificName);
                        self.transients.commonName(data.commonName);
                        self.transients.speciesFieldIsReadOnly(true)
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


    self.loadOutputSpeciesId = function(species) {
        var idRequired = fcConfig.getOutputSpeciesIdUrl;
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

        } else if (idRequired) {
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

    self.loadOutputSpeciesId(species);
    self.populateSingleSpecies(populate);
};

function validateSpeciesLookup(element) {

}
