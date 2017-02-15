
var NodeModel = function(data) {

    var self = this;

    self.isExpanded = ko.observable(true);
    self.description = ko.observable();
    self.name = ko.observable();
    self.nodes = ko.observableArray([]);

    self.toggleVisibility = function() {
        self.isExpanded(!self.isExpanded());
    };

    ko.mapping.fromJS(data, self.mapOptions, self);

};

var TreeModel = function(data) {
    var self = this;
    self.tree = new NodeModel(data);

    self.selectedValues = ko.observableArray([]);

    self.validateSelectedValues = function () {
        if (self.selectedValues().length == 0) {
            return false;
        }
        return true;
    };

    self.extraField = ko.observable();

    var checkNodes = function(nodes) {
        for (var i in nodes()) {
            if (nodes()[i].name().toLowerCase() == self.extraField().toLowerCase()) {
                return true;
            }
            if (checkNodes(nodes()[i].nodes)) {
                return true
            };
        };
        return false;
    };

    self.addTreeNode = function(parentTreeNodes) {
        if (parentTreeNodes && self.extraField() != undefined) {
            if (!checkNodes(parentTreeNodes)) {
                var newNodeModel = new NodeModel({name: self.extraField(), description: self.extraField()});
                parentTreeNodes.push(newNodeModel);
            }
        }
    };

};

NodeModel.prototype.mapOptions = {
    nodes: {
        create: function(args) {
            return new NodeModel(args.data);
        }
    }
};

ko.bindingHandlers.treeView = {
    init: function(element, valueAccessor, allBindindsAccessor, viewModel, bindingContext) {
        var accessor = valueAccessor();
        ko.renderTemplate("tree-template", accessor, {}, element, 'replaceNode');
        return { controlsDescendantBindings: true };
    },
    update: function(element, valueAccessor, allBindingsAccessor,  viewModel, bindingContext) {
    }
};

var AekosViewModel = function (pActivityVM, projectViewModel, user, vocabList) {

    var self = $.extend(this, pActivityVM);

    self.projectViewModel = projectViewModel;

    if (!self.projectViewModel.name) return;

    self.user = user;

    self.submissionName = self.projectViewModel.name() + ' - ' + self.name();

    self.datasetTitle = ko.computed(function() {
        return self.projectViewModel.organisationName() + ' - ' + self.name();
    });

    self.fieldsOfResearch = [];
    self.socioEconomic = [];
    self.economicResearch = [];
    self.anthropogenic = [];
    self.conservationManagement = [];
    self.plantGroups = [];
    self.animalGroups = [];
    self.environmentalFeatures = [];
    self.samplingDesign = [];
    self.observationMeasurements = [];
    self.observedAttributes = [];
    self.identificationMethod = [];

    self.loadVocabData = function() {
        self.fieldsOfResearch = new TreeModel(vocabList.fieldsOfResearch.navTree);
        self.socioEconomic = new TreeModel(vocabList.socioEconomicObjectives.navTree);
        self.economicResearch = new TreeModel(vocabList.ecologicalResearch.navTree);
        self.anthropogenic = new TreeModel(vocabList.anthropogenic.navTree);
        self.conservationManagement = new TreeModel(vocabList.conservationManagement.navTree);
        self.plantGroups = new TreeModel(vocabList.plantGroups.navTree);
        self.animalGroups = new TreeModel(vocabList.animalGroups.navTree);
        self.environmentalFeatures = new TreeModel(vocabList.environmentalFeatures.navTree);
        self.samplingDesign = new TreeModel(vocabList.samplingDesign.navTree);
        self.observationMeasurements = new TreeModel(vocabList.observationMeasurements.navTree);
        self.observedAttributes = new TreeModel(vocabList.observedAttributes.navTree);
        self.identificationMethod = new TreeModel(vocabList.identificationMethod.navTree);
    };

    self.loadVocabData();

    self.currentDatasetVersion = ko.computed(function() {
        var res = self.projectViewModel.name().substr(0, 3) + self.name().substr(0, 3);
        //var res = self.name.substr(1, 3);

        if (self.submissionRecords && self.submissionRecords().length > 0) {
            var datasetArray = $.map(self.submissionRecords(), function (o) {
                if (o.datasetVersion().length > 0) {
                    return o.datasetVersion().substr(8, o.datasetVersion().length)
                } else {
                    return 0;
                }
            });
            //var latestDataset = self.submissionRecords()[0].datasetVersion;
            var highest = Math.max.apply(Math, datasetArray);
            highest = highest + 1;
            var i = (highest > 9) ? "" + highest: "0" + highest;

            return res + "_" + i;
        } else {
            return res + "_01";
        }
    });

    self.associatedMaterialTypes = ko.observableArray(['Algorithms', 'Database Manual', 'Database Schema',
                                    'Derived Spatial Layers', 'Field Manual', 'Mathematical Equations',
                                    'None', 'Other', 'Patent', 'Published Paper', 'Published Report']);
    self.selectedMaterialType = '';

    self.otherMaterials = ko.observable('');
    self.associatedMaterialNane = ko.observable('');

    self.materialIdentifierTypes = ko.observableArray(['Ark Persistent Identifier Scheme', 'Australian Research Council Identifier',
                                        'DOI', 'National Library Of Australia Identifier', 'None']);
    self.selectedMaterialIdentifier = ko.observable('');

    self.legalCustodianOrganisationTypeList = (['Community-based Organisation', 'Federal Agency', 'Foreign Government Agency', 'Herbarium', 'Individual Researcher', 'International Organisation', 'Museum',
                             'Non-government Organisation', 'Private Enterprise', 'Research Institution', 'State Agency', 'University']);

    self.curationStatusList = (['Active', 'Completed', 'Stalled']);
    self.curationStatus = ko.observable('');

    self.curationActivitiesOtherList = (['Data Validation', 'Not curated', 'Plausibility Review', 'Taxonomic Opinion', 'Taxonomic Determination']);
    self.curationActivitiesOther = ko.observable('');

    self.selectedTab = ko.observable('tab-1');

    self.selectTab = function(data, event) {
        if (self.isValidationValid()) {
            var tabId = event.currentTarget.id;
            $("#" + tabId).tab('show');
            var tabNumber = tabId.substr(0, 5);
            self.selectedTab(tabNumber);
        }
    };

    self.selectNextTab = function(nextTab) {
        if (self.isValidationValid()) {
            $(nextTab).tab('show');
            var nextTab = nextTab.substr(1, 5);
            self.selectedTab(nextTab);
        }
    };

    self.nextTab = ko.computed(function(){
        var currentTab = ko.utils.unwrapObservable(self.selectedTab);
        var currentTabNumber = parseInt(currentTab.charAt(4));
        var nextTabNumber = currentTabNumber + 1;
        var nextTab = currentTab.substr(0, 4) + nextTabNumber;
        return nextTab;
    });

    self.dataToggleVal = function(){
        if(self.isValidationValid()){
            return 'tab'
        } else {
            return ''
        }
    };

    self.show = ko.observable(false);
    self.hideModal = function () {
        bootbox.confirm("You will lose unsaved changes. Are you sure you want to close this window?", function(result) {
            if (result) {
               self.show(false);
                $(window).on('beforeunload', function(){
                    $('*').css("cursor", "progress");
                });
                window.location.reload();
        }});
   }

    self.showModal = function() {
        self.show(true);
    };

    self.isProjectInfoValidated = function () {
        return ko.utils.unwrapObservable(self.projectViewModel.description);
    };

    self.isDatasetInfoValidated = function () {
        return ko.utils.unwrapObservable(self.datasetTitle) &&
               ko.utils.unwrapObservable(self.description);
    };

    self.isDatasetContentValidated = function () {
        if (self.fieldsOfResearch.validateSelectedValues() &&
            self.socioEconomic.validateSelectedValues() &&
            self.economicResearch.validateSelectedValues()) {
            return false;
        };
        return true;
     };

    self.isLocationDatesValidated = function () {
        return ko.utils.unwrapObservable(self.sites);
    };

    self.isDatasetSpeciesValidated = function () {
        // nothing to validate...only display fields currently
        return true;
    };

    self.isMaterialsValidated = function () {
        // nothing to validate...only display fields currently
        return true;
    };

    self.isMethodsValidated = function () {
        return ko.utils.unwrapObservable(self.methodName) &&
            ko.utils.unwrapObservable(self.methodAbstract);
    };

    self.isContactsValidated = function () {
        return ko.utils.unwrapObservable(self.datasetContactDetails) &&
                ko.utils.unwrapObservable(self.datasetContactName) &&
                ko.utils.unwrapObservable(self.datasetContactRole) &&
                ko.utils.unwrapObservable(self.datasetContactPhone) &&
                ko.utils.unwrapObservable(self.datasetContactEmail) &&
                ko.utils.unwrapObservable(self.datasetContactAddress) &&
                ko.utils.unwrapObservable(self.authorSurname) &&
                ko.utils.unwrapObservable(self.authorAffiliation);
    };

    self.isManagementValidated = function () {
        return true;
    };

    self.isValidationValid = function () {
        switch(ko.utils.unwrapObservable(self.selectedTab)) {
            case 'tab-1':
                return self.isProjectInfoValidated();
                break;
            case 'tab-2':
                return self.isDatasetInfoValidated();
                break;
            case 'tab-3':
                return true;
                break;
            case 'tab-4':
                return self.isLocationDatesValidated();
                break;
            case 'tab-5':
                return self.isDatasetSpeciesValidated();
                break;
            case 'tab-6':
                return self.isMaterialsValidated();
                break;
            case 'tab-7':
                return self.isMethodsValidated();
                break;
            case 'tab-8':
                return self.isContactsValidated();
                break;
            case 'tab-9':
                return self.isManagementValidated();
                break;
            default:
            return true;
        }
    };

    self.isAllValidationValid = function (index) {
        if (!self.isProjectInfoValidated()) {
            self.selectNextTab('#tab-1-' + index);
            return false;
        } else if (!self.isDatasetInfoValidated()) {
            self.selectNextTab('#tab-2-' + index);
            return false;
        } else if (!self.isDatasetContentValidated()) {
            self.selectNextTab('#tab-3-' + index);
            return false;
        } else if (!self.isLocationDatesValidated()) {
            self.selectNextTab('#tab-4-' + index);
            return false;
        } else if (!self.isDatasetSpeciesValidated()) {
            self.selectNextTab('#tab-5-' + index);
            return false;
        } else if (!self.isMaterialsValidated()) {
            self.selectNextTab('#tab-6-' + index);
            return false;
        } else if (!self.isMethodsValidated()) {
            self.selectNextTab('#tab-7-' + index);
            return false;
        } else if (!self.isContactsValidated()) {
            self.selectNextTab('#tab-8-' + index);
            return false;
        } else if (!self.isManagementValidated()) {
            self.selectNextTab('#tab-9-' + index);
            return false;
        }

        return true;
    };

    self.update = function(pActivity, caller){
        var url =  fcConfig.projectActivityUpdateUrl + "/" + pActivity.projectActivityId();
        $.ajax({
            url: url,
            type: 'POST',
            data: JSON.stringify(pActivity.asJS(caller), function (key, value) {return value === undefined ? "" : value;}),
            contentType: 'application/json',
            success: function (data) {
                var result = data.resp;
                if (result && result.message == 'updated') {
                   // self.updateLogo(data);
                    showAlert("Successfully updated ", "alert-success", self.placeHolder);

                    window.location.reload();
                } else {
                    self.showAlert(data.error ? data.error : "Error updating survey dataset", "alert-error", 'div.aekosAlert');
                }
            },
            error: function (data) {
                self.showAlert("Error updating the survey -" + data.status, "alert-error", 'div.aekosAlert');
            }
        });
    };

    self.showAlert = function(message, alerttype, target) {

        $(target).append('<div class="alert ' +  alerttype + ' aekosAlertDiv"><a class="close" data-dismiss="alert">×</a><span>'+message+'</span></div>')

        setTimeout(function() { // this will automatically close the alert and remove this if the users doesnt close it in 5 secs
            $("div.alert." + alerttype + ".aekosAlertDiv").remove();
        }, 5000);
    };

    self.submit = function(index){

        if (self.isAllValidationValid(index)) {
            var current_time = Date.now();

            var submissionDate = moment(current_time).format("YYYY-MM-DDTHH:mm:ssZZ"); //moment(new Date(), 'YYYY-MM-DDThh:mm:ssZ').isValid() ? self.endDate() : "";
            //var utc = new Date().toJSON().slice(0,10);
            self.submissionRecords.push (new SubmissionRec(submissionDate, self.user, self.currentDatasetVersion(), 'Pending'));
          //  self.showAlert("Error updating the survey - error", "alert-error", 'div.aekosAlert');
            //setTimeout(function(){
              self.update (self, 'info');

            //}, 0);

        }
    };


};

var SubmissionRec = function (submitDateVal, submitterVal, datasetVersionVal, doiRef) {
    var self = this;

    self.submissionPublicationDate = ko.observable(submitDateVal);
    self.datasetSubmitter = ko.observable(submitterVal);
    self.datasetVersion = ko.observable(datasetVersionVal);
    self.submissionDoi = ko.observable(doiRef);

    self.displayDate = ko.computed (function(){
        return moment(self.submissionPublicationDate()).format("DD-MM-YYYY");
    })
}
