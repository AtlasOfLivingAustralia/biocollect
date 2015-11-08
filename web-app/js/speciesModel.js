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

    self.populateSingleSpecies(populate);
};

function validateSpeciesLookup(element) {

    // Only perform the validation if there is data in the field
    if (element.val()) {
        var speciesModel = ko.dataFor(element[0]);
        if (!speciesModel.guid()) {
            return 'Unable to find a matching species for this name'
        }
    }

}