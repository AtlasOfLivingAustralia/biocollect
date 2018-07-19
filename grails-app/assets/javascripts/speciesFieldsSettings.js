/**
 * Created by mol109 on 27/1/17.
 */

var SpeciesConstraintViewModel = function (o, fieldName) {
    var self = this;
    var defaultValues = {
        type: 'ALL_SPECIES',
        speciesDisplayFormat: 'SCIENTIFICNAME(COMMONNAME)',
        commonNameField: 'commonName',
        scientificNameField: 'matchedName'
    };

    o = $.extend(defaultValues, o);
    self.type = ko.observable(o.type);
    self.allSpeciesLists = new SpeciesListsViewModel();
    self.singleSpecies = new SpeciesViewModel(o.singleSpecies || {}, fcConfig);
    self.commonNameField = ko.observable(o.commonNameField);
    self.scientificNameField = ko.observable(o.scientificNameField);
    self.commonFields = ko.observableArray();
    self.speciesLists = ko.observableArray();
    self.speciesLists.subscribe(getCommonKeys);
    self.newSpeciesLists = new NewSpeciesListViewModel();
    self.speciesDisplayFormat = ko.observable(o.speciesDisplayFormat);
    self.speciesOptions =  [{id: 'ALL_SPECIES', name:'All species'},{id:'SINGLE_SPECIES', name:'Single species'}, {id:'GROUP_OF_SPECIES',name:'A selection or group of species'}];

    self.speciesLists($.map(o.speciesLists ? o.speciesLists : [], function (obj, i) {
        return new SpeciesList(obj);
    }));

    addDefaultCommonFields();

    self.transients = {};
    self.transients.bioProfileUrl = ko.computed(function () {
        return fcConfig.bieUrl + '/species/' + self.singleSpecies.guid();
    });

    self.transients.inputSettingsTooltip = ko.computed(function () {
        var type = self.type();

        if(type === 'SINGLE_SPECIES') {
            return 'Single species';
        } else  if(type === 'GROUP_OF_SPECIES') {
            if(self.speciesLists().length > 0) {
                var speciesListsTooltip = '<p>Lists</p>';
                for(var i =0 ; i < self.speciesLists().length; i++ ) {
                    speciesListsTooltip += '<span class="pull-left text-left">' + self.speciesLists()[i].transients.truncatedListName() + '</span> <br/>\n';
                }

                speciesListsTooltip += '<br/>';
                return speciesListsTooltip;
            } else {
                return "No lists configured yet";
            }
        } else {
            return '';
        }
    });



    self.transients.inputSettingsSummary = ko.computed(function () {
        var type = self.type();
        if(type === 'ALL_SPECIES'){
            return 'All species';

        } else if(type === 'SINGLE_SPECIES') {
            return self.singleSpecies.name();
        } else  if(type === 'GROUP_OF_SPECIES') {
            if(self.speciesLists().length > 0) {
                var moreListsMessage = (self.speciesLists().length > 1) ? ' and ' + (self.speciesLists().length - 1)  + ' more.' : '';
                return 'List ' + self.speciesLists()[0].transients.truncatedListName() + moreListsMessage;
            } else {
                return "No lists configured yet"
            }
        } else if(type === 'DEFAULT_SPECIES'){
            return 'Default species';

        } else {
            return 'Not configured';
        }
    });

    self.transients.isValid = ko.computed(function () {
        var type = self.type();
        return !!type
    });
    self.transients.fieldName = ko.observable(fieldName);
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
        // Type specific parameters
        if (self.type() == "SINGLE_SPECIES") {
            jsData.singleSpecies = ko.mapping.toJS(self.singleSpecies, {ignore: ['transients']});
        }
        else if (self.type() == "GROUP_OF_SPECIES") {
            jsData.speciesLists = ko.mapping.toJS(self.speciesLists, {ignore: ['listType', 'fullName', 'itemCount', 'description', 'listType', 'allSpecies', 'transients']});
            jsData.commonNameField = self.commonNameField();
            jsData.scientificNameField = self.scientificNameField();
        }

        // Only generate output for known types
        if ($.inArray(self.type(), ["SINGLE_SPECIES", "GROUP_OF_SPECIES", "ALL_SPECIES", "DEFAULT_SPECIES"]) >-1) {
            // Common parameters
            jsData.type = self.type();
        }

        // Display format is independent of type and derivate type fields
        jsData.speciesDisplayFormat = self.speciesDisplayFormat()

        return jsData;
    };

    self.isValid = function(){
        return ((self.type() == "ALL_SPECIES") || (self.type() == "SINGLE_SPECIES" && self.singleSpecies.guid()) ||
        (self.type() == "GROUP_OF_SPECIES" && self.speciesLists().length > 0)) || (self.type() == "DEFAULT_SPECIES")
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

    function getCommonKeys(){
        var url = fcConfig.commonKeysUrl, druids = $.map(self.speciesLists(), function (list) {
            return list.dataResourceUid();
        });

        if(druids && druids.length){
            $.get(url,{
                druid: druids.join(',')
            }, function (fields) {
                self.commonFields(fields);
            }).fail(addDefaultCommonFields);
        } else {
            addDefaultCommonFields()
        }
    }

    function addDefaultCommonFields() {
        self.commonFields(fcConfig.defaultCommonFields);
    }
};

var NewSpeciesListViewModel = function (o) {
    var self = this;
    if (!o) o = {};

    self.listName = ko.observable(o.listName);
    self.dataResourceUid = ko.observable(o.dataResourceUid);
    self.description = ko.observable(o.description);
    self.listType = ko.observable(o.listType);
    self.allSpecies = ko.observableArray();

    self.inputSpeciesViewModel = new SpeciesViewModel({}, fcConfig);
    self.inputSpeciesViewModel.transients.searchValue = ko.observable("");

    self.inputSpeciesViewModel.transients.name.subscribe(function (newName) {
        if(newName) {
            var newSpecies = new SpeciesViewModel({}, fcConfig);
            newSpecies.name(newName);
            newSpecies.guid(self.inputSpeciesViewModel.transients.guid());
            if(self.inputSpeciesViewModel.transients.guid()) {
                newSpecies.transients.bieUrl(self.inputSpeciesViewModel.transients.bieUrl());
            }
            self.allSpecies.push(newSpecies);
        }

        self.clearSearchValue();
    });

    self.clearSearchValue  = function () {
        self.inputSpeciesViewModel.transients.searchValue("");
    };

    self.removeNewSpeciesName = function (species) {
        self.allSpecies.remove(species);
    };

    self.transients = {};
    self.transients.url = ko.observable(fcConfig.speciesListsServerUrl + "/speciesListItem/list/" + o.dataResourceUid);

};


/**
 * Creates a bootstrap modal from the supplied UI element to collect a species field configuration and returns a
 * jquery Deferred promise to access it.
  * @param speciesFieldConfigViewModel default model for the document.  can be used to populate role, etc.
 * @param templateSelector a selector identifying the element that calls the ko template and where data binding will be applied
 * @returns an instance of jQuery.Deferred - the uploaded document will be supplied to a chained 'done' function.
 */
function showSpeciesFieldConfigInModal(speciesFieldConfigViewModel, templateSelector) {

    var modalSelector = '#configureSpeciesFieldModal';
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
            closeModal();
        } else {
            showAlert(error, 'alert-error', 'species-dialog-alert-placeholder')
        }
    };


    // Close the modal and tidy up the bindings.
    var closeModal = function() {
        $modal.modal('hide');
        $modal.removeClass("modal-open");
        $("body").removeClass("modal-open");
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
    $modal.addClass("modal-open");
    $("body").addClass("modal-open");
    $modal.modal('show');

    $modal.on('shown', function() {
        $modal.find('form').validationEngine();
    });

    return result;
}


var SpeciesFieldViewModel = function (o) {

    var self = this;
    if (!o) o = {};

    self.label = o.label || "";
    self.dataFieldName = o.dataFieldName || "";
    self.context = o.context || "";
    self.output = o.output || "";

    self.transients = {};
    self.transients.fieldName = self.output + ' - ' + self.label;
    self.config = ko.observable(new SpeciesConstraintViewModel(o.config));

    self.asJson = function () {
        var jsData = {};

        jsData.label = self.label;
        jsData.dataFieldName = self.dataFieldName;
        jsData.context = self.context;
        jsData.output = self.output;
        jsData.config = self.config().asJson();
        return jsData;
    };

    self.load = function (data) {
        if (data) {
            self.label = data.label;
            self.dataFieldName = data.dataFieldName;
            self.context = data.context;
            self.output = data.output;
            self.transients.fieldName = self.output + ' - ' + self.label;
            self.config(new SpeciesConstraintViewModel(data.config));
        }
    };
};


var SpeciesListsViewModel = function (o) {
    var self = this;
    if (!o) o = {};

    self.ascIconClass = "icon-chevron-up";
    self.descIconClass = "icon-chevron-down";

    self.searchGuid = ko.observable();
    self.searchName = ko.observable();

    self.pagination = new PaginationViewModel({}, self);
    self.pagination.rppOptions = [10, 20, 30];

    self.allSpeciesListsToSelect = ko.observableArray();
    self.offset = ko.observable(0);
    // self.max = ko.observable(100);
    self.listCount = ko.observable();

    self.transients = {};
    self.transients.loading = ko.observable(false);
    self.transients.sortCol = ko.observable("listName");
    self.transients.sortOrder = ko.observable("asc");

    self.sort = function(column, order) {
        if (!self.transients.loading()) {
            if (column == self.transients.sortCol()) {
                //toggle the order
                if (order == "asc") {
                    self.transients.sortOrder("desc");
                } else {
                    self.transients.sortOrder("asc");
                }
            } else {
                self.transients.sortCol(column)
                self.transients.sortOrder("asc");
            }
            self.loadAllSpeciesLists(self.transients.sortCol(), self.transients.sortOrder())
        }
    }

    self.loadAllSpeciesLists = function (sortCol, order) {
        self.transients.loading(true);
        var url = fcConfig.speciesListUrl + "?sort=" + sortCol + "&offset=" + self.offset() + "&max=" + self.pagination.resultsPerPage() + "&order=" + order;
        if (self.searchGuid()) {
            url += "&guid=" + self.searchGuid();
        }

        if (self.searchName() && self.searchName().trim() != ""){
            url += "&searchTerm=" + self.searchName().trim();
        }

        var divId = 'project-activities-result-placeholder';
        $.ajax({
            url: url,
            type: 'GET',
            contentType: 'application/json',
            beforeSend: function () {
                self.transients.loading(true);
            },
            success: function (data) {
                if (data.error) {
                    showAlert("Error :" + data.text, "alert-error", divId);
                }
                else {
                    self.listCount(data.listCount);
                    self.allSpeciesListsToSelect($.map(data.lists ? data.lists : [], function (obj, i) {
                            return new SpeciesList(obj);
                        })
                    );

                    if (self.offset() == 0) {
                        self.pagination.loadPagination(0, data.listCount);
                    }
                }
            },
            complete: function () {
                self.transients.loading(false);
            },
            error: function (data) {
                var status = data.status;
                showAlert("Error : An unhandled error occurred" + data.status, "alert-error", divId);
            }
        });
    };

    self.clearSearch = function() {
        self.searchGuid(null);
        self.searchName(null);
        self.setDefault()
    }

    self.setDefault = function() {
        self.transients.sortCol("listName");
        self.transients.sortOrder("asc");
        self.transients.loading(true);
        self.refreshPage(0);
    }

    self.refreshPage = function(offset) {
        self.offset( offset || 0);
        self.loadAllSpeciesLists(self.transients.sortCol(), self.transients.sortOrder());
    }
};

var SpeciesList = function (o) {
    var self = this;
    if (!o) o = {};

    self.listName = ko.observable(o.listName);
    self.dataResourceUid = ko.observable(o.dataResourceUid);

    self.listType = ko.observable(o.listType);
    self.fullName = ko.observable(o.fullName);
    self.itemCount = ko.observable(o.itemCount);


    self.transients = {};
    self.transients.url = ko.observable(fcConfig.speciesListsServerUrl + "/speciesListItem/list/" + o.dataResourceUid);
    self.transients.check = ko.observable(false);
    self.transients.truncatedListName = ko.computed(function () {
        return truncate(self.listName(), 45);
    });
};