
/**
 * Manages the species data type in the output model.
 * Allows species information to be searched for and displayed.
 */
var SpeciesViewModel = function(o, lists){
    var self = this;
    if(!o) o = {};
    if(!lists) lists = {};
    self.name = ko.observable(o.name);
    self.guid = ko.observable(o.guid);

    self.transients = {};
    self.transients.name = ko.observable(o.name);
    self.transients.guid = ko.observable(o.guid);
    self.transients.source = ko.observable(fcConfig.speciesSearch);

    self.transients.bioProfileUrl =  ko.computed(function (){
        return  fcConfig.bieUrl + '/species/' + self.guid();
    });

    self.focusLost = function(event) {
        self.name(self.transients.name());
        self.guid(self.transients.guid());
    };

    self.transients.guid.subscribe(function(newValue) {
        self.name(self.transients.name());
        self.guid(self.transients.guid());
    });
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