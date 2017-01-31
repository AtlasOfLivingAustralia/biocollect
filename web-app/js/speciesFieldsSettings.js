/**
 * Created by mol109 on 27/1/17.
 */

var SpeciesConstraintViewModel = function (o) {
    var self = this;
    if (!o) o = {};

    self.type = ko.observable(o.type);
    self.allSpeciesLists = new SpeciesListsViewModel();
    self.singleSpecies = new SpeciesViewModel(o.singleSpecies);
    self.speciesLists = ko.observableArray($.map(o.speciesLists ? o.speciesLists : [], function (obj, i) {
        return new SpeciesList(obj);
    }));
    self.newSpeciesLists = new NewSpeciesListViewModel();
    self.speciesDisplayFormat = ko.observable(o.speciesDisplayFormat ||'SCIENTIFICNAME(COMMONNAME)')

    self.speciesOptions =  [{id: 'ALL_SPECIES', name:'All species'},{id:'SINGLE_SPECIES', name:'Single species'}, {id:'GROUP_OF_SPECIES',name:'A selection or group of species'}];

    self.transients = {};
    self.transients.bioProfileUrl = ko.computed(function () {
        return fcConfig.bieUrl + '/species/' + self.singleSpecies.guid();
    });

    self.transients.bioSearch = ko.observable(fcConfig.speciesSearchUrl);
    self.transients.allowedListTypes = [
        {id: 'SPECIES_CHARACTERS', name: 'SPECIES_CHARACTERS'},
        {id: 'CONSERVATION_LIST', name: 'CONSERVATION_LIST'},
        {id: 'SENSITIVE_LIST', name: 'SENSITIVE_LIST'},
        {id: 'LOCAL_LIST', name: 'LOCAL_LIST'},
        {id: 'COMMON_TRAIT', name: 'COMMON_TRAIT'},
        {id: 'COMMON_HABITAT', name: 'COMMON_HABITAT'},
        {id: 'TEST', name: 'TEST'},
        {id: 'OTHER', name: 'OTHER'}];

    self.transients.showAddSpeciesLists = ko.observable(false);
    self.transients.showExistingSpeciesLists = ko.observable(false);

    self.transients.toggleShowAddSpeciesLists = function () {
        self.transients.showAddSpeciesLists(!self.transients.showAddSpeciesLists());
        if (self.transients.showAddSpeciesLists()) {
            self.transients.showExistingSpeciesLists(false);
        }
    };

    self.transients.toggleShowExistingSpeciesLists = function () {
        self.allSpeciesLists.transients.loading(true);
        self.transients.showExistingSpeciesLists(!self.transients.showExistingSpeciesLists());
        if (self.transients.showExistingSpeciesLists()) {
            self.allSpeciesLists.setDefault();
            self.transients.showAddSpeciesLists(false);
        }
    };

    self.addSpeciesLists = function (list) {
        if(!self.containsList(list)) {
            self.speciesLists.push(list);
            list.transients.check(true);
        }
    };

    self.containsList = function(list) {
        var result = false;
        ko.utils.arrayForEach(self.speciesLists(), function(existingList) {
            if(existingList.dataResourceUid() == list.dataResourceUid()) {
                result = existingList;
            }
        });

        return result;
    }

    self.removeSpeciesLists = function (list) {
        list.transients.check(false);
        self.speciesLists.remove(list);
    };

    self.allSpeciesInfoVisible = ko.computed(function () {
        return (self.type() == "ALL_SPECIES");
    });

    self.groupInfoVisible = ko.computed(function () {
        return (self.type() == "GROUP_OF_SPECIES");
    });

    self.singleInfoVisible = ko.computed(function () {
        return (self.type() == "SINGLE_SPECIES");
    });

    self.type.subscribe(function (type) {
        if (self.type() == "SINGLE_SPECIES") {
        } else if (self.type() == "GROUP_OF_SPECIES") {
        }
    });

    self.asJson = function () {
        var jsData = {};
        if (self.type() == "ALL_SPECIES") {
            jsData.type = self.type();
            jsData.speciesDisplayFormat = self.speciesDisplayFormat()
        }
        else if (self.type() == "SINGLE_SPECIES") {
            jsData.type = self.type();
            jsData.singleSpecies = ko.mapping.toJS(self.singleSpecies, {ignore: ['transients']});
            jsData.speciesDisplayFormat = self.speciesDisplayFormat()
        }
        else if (self.type() == "GROUP_OF_SPECIES") {
            jsData.type = self.type();
            jsData.speciesLists = ko.mapping.toJS(self.speciesLists, {ignore: ['listType', 'fullName', 'itemCount', 'description', 'listType', 'allSpecies', 'transients']});
            jsData.speciesDisplayFormat = self.speciesDisplayFormat()
        }

        return jsData;
    };

    self.isValid = function(){
        return ((self.type() == "ALL_SPECIES") || (self.type() == "SINGLE_SPECIES" && self.singleSpecies.guid()) ||
        (self.type() == "GROUP_OF_SPECIES" && self.speciesLists().length > 0))
    };

    self.hasErrors = function() {
        if(!self.type()) {
            return "You must select an option from the list";
        } else if(self.type() == "SINGLE_SPECIES" && !self.singleSpecies.guid()) {
            return "You must type and select a species name"
        } else if(self.type() == "GROUP_OF_SPECIES" && self.speciesLists().length == 0) {
            return "You must either select existing species lists or create a new one"
        }
    }



    self.saveNewSpeciesName = function () {
        if (!$('#project-activities-species-validation').validationEngine('validate')) {
            return;
        }

        var jsData = {};
        jsData.listName = self.newSpeciesLists.listName();
        jsData.listType = self.newSpeciesLists.listType();
        jsData.description = self.newSpeciesLists.description();
        jsData.listItems = "";

        var lists = ko.mapping.toJS(self.newSpeciesLists);
        $.each(lists.allSpecies, function (index, species) {
            var UNMATCHED_TAXON = " (Unmatched taxon)";

            var name = (species.guid) ? // Matched Taxon ?
                species.name :
                species.name.substr(0, species.name.indexOf(UNMATCHED_TAXON));
            if (index == 0) {
                jsData.listItems = name;
            } else {
                jsData.listItems = jsData.listItems + "," + name;
            }
        });

        var model = JSON.stringify(jsData, function (key, value) {
            return value === undefined ? "" : value;
        });
        var divId = 'species-dialog-alert-placeholder';
        $("#addNewSpecies-status").show();

        $.ajax({
            url: fcConfig.addNewSpeciesListsUrl,
            type: 'POST',
            data: model,
            contentType: 'application/json',
            success: function (data) {
                if (data.error) {
                    showAlert("Error :" + data.error, "alert-error", divId);
                }
                else {
                    showAlert("Successfully added the new species list - " + self.newSpeciesLists.listName() + " (" + data.id + ")", "alert-success", divId);
                    self.newSpeciesLists.dataResourceUid(data.id);
                    self.speciesLists.push(new SpeciesList(ko.mapping.toJS(self.newSpeciesLists)));
                    self.newSpeciesLists = new NewSpeciesListViewModel();
                    self.transients.toggleShowAddSpeciesLists();
                }
                $("#addNewSpecies-status").hide();
            },
            error: function (data) {
                showAlert("Error : An unhandled error occurred" + data.status, "alert-error", divId);
                $("#addNewSpecies-status").hide();
            }
        });
    };

};




/**
 * Creates a bootstrap modal from the supplied UI element to collect a species field configuration and returns a
 * jquery Deferred promise to access it.
  * @param speciesFieldConfigViewModel default model for the document.  can be used to populate role, etc.
 * @param modalSelector a selector identifying the ui element that contains the markup for the bootstrap modal dialog.
 * @param templateSelector a selector identifying the element that calls the ko template and where data binding will be applied
 * @returns an instance of jQuery.Deferred - the uploaded document will be supplied to a chained 'done' function.
 */
function showSpeciesFieldConfigInModal(speciesFieldConfigViewModel, modalSelector, templateSelector) {
    // Get the native object (index 0) rather than jquery wrapper, ko needs it.
    var template = $(templateSelector)[0];


    // Used to communicate the result back to the calling process.
    var result = $.Deferred();




    // Decorate the model so it can handle the button presses and close the modal window.
    speciesFieldConfigViewModel.cancel = function() {
        //TODO reject validation engine result
        result.reject();
        closeModal();
    };


    speciesFieldConfigViewModel.accept = function() {
        var error =  speciesFieldConfigViewModel.hasErrors();
        $modal.find('form').validationEngine('validate');

        if(!error){
            result.resolve(speciesFieldConfigViewModel.asJson());
            // Clean the template before we reuse it
            speciesFieldConfigViewModel.speciesLists.removeAll();
            closeModal();
        } else {
            showAlert(error, 'alert-error', 'species-dialog-alert-placeholder')
        }
    };


    // Close the modal and tidy up the bindings.
    var closeModal = function() {
        $modal.modal('hide');
        $modal.find('form').validationEngine('detach');
        ko.cleanNode(template);
    };

    ko.applyBindings(speciesFieldConfigViewModel, template);

    //Modal selector won't exist until ko 'instantiates' the template hence we wait for it before trying to
    // get the element
    var $modal = $(modalSelector);

    // Don't allow ESC to close dialog, it will bypass the cancel function and hence mess the KO binding/unbinding
    // mechanism
    $modal.modal({
            backdrop:'static',
            keyboard: false
        });
    $modal.modal('show');

    $modal.on('shown', function() {
        $modal.find('form').validationEngine();
    });

    return result;
}

