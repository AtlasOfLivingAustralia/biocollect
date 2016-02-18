/**
 * Manages the species data type in the output model.
 * Allows species information to be searched for and displayed.
 */
var SpeciesViewModel = function (species, lists, populate) {
    var self = this;
    if (!species) species = {};
    if (!lists) lists = {};
    if (!populate) populate = false;
    self.name = ko.observable(species.name);
    self.guid = ko.observable(species.guid);

    // Reference to output species uuid - for uniqueness retrieved from ecodata server
    self.outputSpeciesId = ko.observable();

    self.transients = {};
    self.transients.name = ko.observable(species.name);
    self.transients.guid = ko.observable(species.guid);
    self.transients.source = ko.observable(fcConfig.speciesSearch);

    self.transients.bioProfileUrl = ko.computed(function () {
        return fcConfig.bieUrl + '/species/' + self.guid();
    });

    self.focusLost = function (event) {
        self.name(self.transients.name());
        self.guid(self.transients.guid());
    };

    self.transients.guid.subscribe(function (newValue) {
        self.name(self.transients.name());
        self.guid(self.transients.guid());
    });

    self.populateSingleSpecies = function (populate) {
        if (!self.name() && !self.guid() && fcConfig.getSingleSpeciesUrl && populate) {
            $.ajax({
                url: fcConfig.getSingleSpeciesUrl,
                type: 'GET',
                contentType: 'application/json',
                success: function (data) {
                    if (data.name && data.guid) {
                        self.name(data.name);
                        self.guid(data.guid);
                        self.transients.name(data.name);
                        self.transients.guid(data.guid);
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
        self.transients.name("");
        self.transients.guid("");
    };


    self.loadOutputSpeciesId = function(species) {

        if(species.outputSpeciesId) {
            self.outputSpeciesId(species.outputSpeciesId);
        } else {
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
