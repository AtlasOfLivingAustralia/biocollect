var ProjectActivitiesViewModel = function (params) {
    var self = this;
    var pActivities = params.pActivities;
    var user = params.user;

    self.organisationName = params.organisationName;
    self.pActivityForms = params.pActivityForms;
    self.sites = params.sites;
    self.projectStartDate = params.projectStartDate;
    self.project = params.project;

    self.vocabList = params.vocabList

    self.projectId = ko.observable(params.projectId);
    self.projectActivities = ko.observableArray();

    self.user = user ? user : {isEditor: false, isAdmin: false};

    self.sortBy = ko.observable();
    self.sortOrder = ko.observable();
    self.sortOptions = [{id: 'name', name: 'Name'}, {id: 'description', name: 'Description'}, {
        id: 'transients.status',
        name: 'Status'
    }];
    self.sortOrderOptions = [{id: 'asc', name: 'Ascending'}, {id: 'desc', name: 'Descending'}];

    self.sortBy.subscribe(function (by) {
        self.sort();
    });

    self.sortOrder.subscribe(function (order) {
        self.sort();
    });

    // flag to check if survey was changed by dropdown menu. it is used to decide on saving survey.
    self.isSurveySelected = ko.observable(false);

    self.sort = function () {
        var by = self.sortBy();
        var order = self.sortOrder() == 'asc' ? '<' : '>';
        if (by && order) {
            eval('self.projectActivities.sort(function(left, right) { return left.' + by + '() == right.' + by + '() ? 0 : (left.' + by + '() ' + order + ' right.' + by + '() ? -1 : 1) });');
        }
    };

    self.reset = function () {
        $.each(self.projectActivities(), function (i, obj) {
            obj.current(false);
        });
    };

    self.current = function () {
        var pActivity = null;
        $.each(self.projectActivities(), function (i, obj) {
            if (obj.current()) {
                pActivity = obj;
            }
        });
        return pActivity;
    };

    self.setCurrent = function (pActivity) {
        self.isSurveySelected(true);
        self.reset();
        pActivity.current(true);
        self.isSurveySelected(false);
    };

    self.loadProjectActivities = function (pActivities) {
        self.sortBy("name");
        self.sortOrder("asc");
        $.map(pActivities, function (pActivity, i) {
            var args = {
                pActivity: pActivity,
                pActivityForms: self.pActivityForms,
                projectId: self.projectId(),
                selected: (i == 0),
                sites: self.sites,
                organisationName: self.organisationName,
                startDate: self.projectStartDate,
                project: self.project,
                user: self.user,
                vocabList: self.vocabList
            };
            return self.projectActivities.push(new ProjectActivity(args));
        });

        self.sort();
    };

    self.userCanEdit = function (pActivity) {
        var projectActive = !pActivity.endDate() || moment(pActivity.endDate()).isAfter(moment());
        var userIsEditorOrAdmin = user && Object.keys(user).length > 0 && (user.isEditor || user.isAdmin);
        return projectActive && (pActivity.publicAccess() || userIsEditorOrAdmin) && fcConfig.version.length == 0;
    };

    self.userIsAdmin = function (pActivity) {
        if (user && Object.keys(user).length > 0 && user.isAdmin) {
            return true;
        } else {
            return false;
        }
    };

    self.loadProjectActivities(pActivities);

   /* self.aekosTestModalView = ko.observable(new AekosViewModel (pActivity, project.name, project.description, project.status));

    //self.aekosModal = ko.observable(false);

    self.showModal = function () {
        //  self.aekosModal(true);
        self.aekosTestModalView().show(true);
    };
*/
};

var ProjectActivitiesListViewModel = function (pActivitiesVM) {
    var self = $.extend(this, pActivitiesVM);
    self.filter = ko.observable(false);

    self.toggleFilter = function () {
        self.filter(!self.filter())
    };

    self.setCurrent = function (pActivity) {
        self.reset();
        pActivity.current(true);
    };
};

var ProjectActivitiesDataViewModel = function (pActivitiesVM) {
    var self = $.extend(this, pActivitiesVM);
};

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


var ProjectActivitiesSettingsViewModel = function (pActivitiesVM, placeHolder) {

    var self = $.extend(this, pActivitiesVM);
    var surveyInfoTab = '#survey-info-tab';
    self.placeHolder = placeHolder;
    self.datesOptions = [60, 90, 120, 180];
    self.formNames = ko.observableArray($.map(self.pActivityForms ? self.pActivityForms : [], function (obj, i) {
        return obj.name;
    }));

    self.addProjectActivity = function () {
        self.reset();
        var args = {
            pActivity: [],
            pActivityForms: self.pActivityForms,
            projectId: self.projectId(),
            selected: true,
            sites: self.sites,
            organisationName: self.organisationName,
            startDate: self.projectStartDate
        };
        self.projectActivities.push(new ProjectActivity(args));
        initialiseValidator();
        self.refreshSurveyStatus();
        $(surveyInfoTab).tab('show');
        showAlert("Successfully added.", "alert-success", self.placeHolder);
    };

    self.updateStatus = function () {
        var current = self.current();
        var jsData = current.asJSAll();

        if (jsData.published) {
            return self.unpublish();
        }

        if(!current.isEndDateAfterStartDate()) {
            showAlert("Survey end date must be after start date", "alert-error", self.placeHolder);
            $('#survey-info-tab').tab('show');
        } else if (current.isInfoValid() &&
            current.areSpeciesValid() &&
            jsData.pActivityFormName &&
            (jsData.sites && jsData.sites.length > 0)
        ) {
            jsData.published = true;
            return self.publish(jsData);
        } else {
            showAlert("Mandatory fields in 'Survey Info', 'Species', 'Survey Form' and 'Locations' tab must be completed before publishing the survey.", "alert-error", self.placeHolder);
        }
    };

    self.saveInfo = function () {
        return self.genericUpdate("info");
    };

    self.saveVisibility = function () {
        return self.genericUpdate("visibility");
    };

    self.saveForm = function () {
        return self.genericUpdate("form");
    };

    self.saveSpecies = function () {
        return self.genericUpdate("species");
    };

    self.saveAlert = function () {
        return self.genericUpdate("alert");
    };

    self.saveSites = function () {
        var jsData = self.current().asJS("sites");
        if (jsData.sites && jsData.sites.length > 0) {
            self.genericUpdate("sites");
        } else {
            showAlert("No site associated with this survey", "alert-error", self.placeHolder);
        }
    };

    self.saveSitesBeforeRedirect = function(redirectUrl) {
        var jsData = self.current().asJS("sites");
        if (jsData.sites && jsData.sites.length > 0) {
            self.genericUpdate("sites");
        }
        window.location.href = redirectUrl;
    };

    self.redirectToCreate = function(){
        var pActivity = self.current();
        self.saveSitesBeforeRedirect(fcConfig.siteCreateUrl + '&pActivityId=' + pActivity.projectActivityId());
    };

    self.redirectToSelect = function(){
        self.saveSitesBeforeRedirect(fcConfig.siteSelectUrl);
    };

    self.redirectToUpload = function(){
        self.saveSitesBeforeRedirect(fcConfig.siteUploadUrl);
    };

    self.deleteProjectActivity = function () {
        bootbox.confirm("Are you sure you want to delete this survey? Any survey forms that have been submitted will also be deleted.", function (result) {
            if (result) {
                var that = this;

                var pActivity;
                $.each(self.projectActivities(), function (i, obj) {
                    if (obj.current()) {
                        obj.status("deleted");
                        pActivity = obj;
                    }
                });

                if (pActivity.projectActivityId() === undefined) {
                    self.projectActivities.remove(pActivity);
                    if (self.projectActivities().length > 0) {
                        self.projectActivities()[0].current(true);
                    }
                    showAlert("Successfully deleted.", "alert-success", self.placeHolder);
                }
                else {
                    self.delete();
                }
            }
        });
    };

    // Once records are created, only info and visibility can be updated.
    var canSave = function (pActivity, caller){
        if (caller != "info" && pActivity.projectActivityId() === undefined) {
            showAlert("Please save 'Survey Info' details before applying other constraints.", "alert-error", self.placeHolder);
            return false;
        } else if (caller == "info" && !pActivity.isEndDateAfterStartDate()){
            showAlert("Survey end date must be after start date", "alert-error", self.placeHolder);
            return false;
        } else if(caller == "info" || caller == "visibility" || caller == "alert"){
            return true;
        }

        return !isDataAvailable(pActivity);
    };

    var isDataAvailable = function(pActivity){
        var result = true;
        $.ajax({
            url: fcConfig.activiyCountUrl + "/" + pActivity.projectActivityId(),
            type: 'GET',
            async: false,
            timeout: 10000,
            success: function (data) {
                if(data.total == 0){
                    result = false;
                } else {
                    showAlert("Error: Survey cannot be edited because records exist - to edit the survey, delete all records.", "alert-error", self.placeHolder);
                }
            },
            error: function (data) {
                showAlert("Un handled error, please try again later.", "alert-error", self.placeHolder);
            }
        });
        return result;
    };

    self.updateLogo = function (data){
        var doc = data.doc;
        if (doc && doc.content && doc.content.documentId && doc.content.url) {
            $.each(self.projectActivities(), function (i, obj) {
                if (obj.current()) {
                    var logoDocument = obj.findDocumentByRole(obj.documents(), 'logo');
                    if (logoDocument) {
                        obj.removeLogoImage();
                        logoDocument.documentId = doc.content.documentId;
                        logoDocument.url = doc.content.url;
                        obj.documents.push(logoDocument);
                    }
                }
            });
        }
    };

    self.create = function (pActivity, caller){
        var pActivity = self.current();
        var url = fcConfig.projectActivityCreateUrl;
        $.ajax({
            url: url,
            type: 'POST',
            data: JSON.stringify(pActivity.asJS(caller), function (key, value) {return value === undefined ? "" : value;}),
            contentType: 'application/json',
            success: function (data) {
                var result = data.resp;
                if (result && result.message == 'created') {
                    $.each(self.projectActivities(), function (i, obj) {
                        if (obj.current() && !obj.projectActivityId()) {
                            obj.projectActivityId(result.projectActivityId);
                        }
                    });
                    self.updateLogo(data);
                    showAlert("Successfully created", "alert-success", self.placeHolder);
                } else {
                    showAlert(data.error ? data.error : "Error creating the survey", "alert-error", self.placeHolder);
                }
            },
            error: function (data) {
                showAlert("Error creating the survey -" + data.status, "alert-error", self.placeHolder);
            }
        });
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
                    self.updateLogo(data);
                    showAlert("Successfully updated ", "alert-success", self.placeHolder);
                } else {
                    showAlert(data.error ? data.error : "Error updating the survey", "alert-error", self.placeHolder);
                }
            },
            error: function (data) {
                showAlert("Error updating the survey -" + data.status, "alert-error", self.placeHolder);
            }
        });
    };

    self.delete = function(){
        var pActivity = self.current();
        var url =  fcConfig.projectActivityDeleteUrl + "/" + pActivity.projectActivityId();
        $.ajax({
            url: url,
            type: 'DELETE',
            success: function (data) {
                if (data.error) {
                    showAlert("Error deleting the survey, please try again later.", "alert-error", self.placeHolder);
                } else {
                    self.projectActivities.remove(pActivity);
                    if (self.projectActivities().length > 0) {
                        self.projectActivities()[0].current(true);
                    }
                    showAlert("Successfully deleted.", "alert-success", self.placeHolder);
                }
            },
            error: function (data) {
                showAlert("Error deleting the survey -" + data.status, "alert-error", self.placeHolder);
            }
        });
    };

    self.publish = function(jsData){

        var url =  jsData.projectActivityId ? fcConfig.projectActivityUpdateUrl + "/" + jsData.projectActivityId : fcConfig.projectActivityCreateUrl;
        $.ajax({
            url: url,
            type: 'POST',
            data: JSON.stringify(jsData, function (key, value) {return value === undefined ? "" : value;}),
            contentType: 'application/json',
            success: function (data) {
                var result = data.resp;
                if (result && result.message) {
                    var pActivityId = jsData.projectActivityId ? jsData.projectActivityId : result.projectActivityId;
                    var found = ko.utils.arrayFirst(self.projectActivities(), function(obj) {
                        return obj.projectActivityId() == pActivityId;
                    });
                    found ? found.published(true) : '';
                    showAlert("Successfully published, redirecting to survey list page.", "alert-success", self.placeHolder);
                    setTimeout(function() {
                        $('#activities-tab').tab('show');
                    }, 3000);

                } else{
                    showAlert(data.error ? data.error : "Error publishing the survey", "alert-error", self.placeHolder);
                }
            },
            error: function (data) {
                showAlert("Error publishing the survey -" + data.status, "alert-error", self.placeHolder);
            }
        });
    };


    self.unpublish = function(){
        var pActivity = self.current();

        var url =  fcConfig.projectActivityUnpublishUrl + "/" + pActivity.projectActivityId();

        bootbox.confirm("Are you sure you want to unpublish this survey? All data associated with this survey will be lost.", function (result) {
            if (result) {
                blockUIWithMessage("Unpublishing the survey");
                $.ajax({
                    url: url,
                    type: 'POST',
                    data: {published: false},
                    contentType: 'application/json',
                    success: function (data) {
                        var result = data.resp;
                        if (result && result.message == 'updated') {
                            location.reload();
                        } else {
                            showAlert(data.error ? data.error : "Error unpublishing the survey", "alert-error", self.placeHolder);
                        }
                    },
                    error: function (data) {
                        showAlert("Error unpublishing the survey -" + data.status, "alert-error", self.placeHolder);
                    },
                    complete: function(){
                        $.unblockUI();
                    }
                });
            }
        });
    };

    self.genericUpdate = function (caller) {
        if (caller != 'alert' && !$('#project-activities-' + caller + '-validation').validationEngine('validate')) {
            return false;
        }
        var pActivity = self.current();
        if (!canSave(pActivity, caller)) {
            return;
        }
        pActivity.projectActivityId() ? self.update(pActivity, caller) : self.create(pActivity, caller);
    };

    self.refreshSurveyStatus = function() {
        $.each(self.projectActivities(), function (i, obj) {
            var allowed = false;
            $.ajax({
                url: fcConfig.activiyCountUrl + "/" + obj.projectActivityId(),
                type: 'GET',
                async: false,
                timeout: 10000,
                success: function (data) {
                    if(data.total == 0){
                        allowed = true;
                    }
                },
                error: function (data) {
                    console.log("Error retrieving survey status.", "alert-error", self.placeHolder);
                }
            });
            obj.transients.saveOrUnPublishAllowed(allowed);
        });

    };

    /**
     * checks if selected survey has survey info tab filled.
     * @returns {boolean}
     */
    self.isSurveyInfoFormFilled = ko.computed(function(){
        return !!(self.current() && self.current().isInfoValid())
    })

    /**
     * This function checks if the survey info tab is valid and returns an appropriate string to fill data-toggle
     * attribute on the anchor tag. This logic is used to disable all tabs except survey info tab. It helps to force
     * users to fill the survey info tab before moving to other tabs.
     * @returns {string} 'tab' or ''
     */
    self.dataToggleVal = function(){
        if(self.isSurveyInfoFormFilled()){
            return 'tab'
        } else {
            return ''
        }
    }

    /**
     * Checks if all mandatory survey fields are filled for survey to be published.
     * @returns {boolean}
     */
    self.isSurveyPublishable = function(){
        var current = self.current();
        var sites = current.sites();

        return (current.isInfoValid() &&
        current.areSpeciesValid() &&
        current.pActivityFormName() &&
        (sites && sites.length > 0))
    }

    /**
     * Checks if survey data entry template is selected
     * @returns {boolean}
     */
    self.isPActivityFormNameFilled = function(){
        var current = self.current();
        return !!current.pActivityFormName();
    }

    /**
     * Checks if one or more sites are added to the survey
     * @returns {boolean}
     */
    self.isSiteSelected = function(){
        var sites = self.current().sites();
        return sites && sites.length > 0
    }

    /**
     * Auto save when all mandatory survey info fields are filled
     */
    self.isSurveyInfoFormFilled.subscribe(function(){
        if(self.isSurveyInfoFormFilled() && !self.isSurveySelected()){
            self.saveInfo();
        }
    })

    self.refreshSurveyStatus();
};

var ProjectActivity = function (params) {
    if(!params) params = {};
    var pActivity = params.pActivity ? params.pActivity : {};
    var pActivityForms = params.pActivityForms ? params.pActivityForms : [];
    var projectId = params.projectId ? params.projectId : "";
    var selected = params.selected ? params.selected : false;
    var sites = params.sites ? params.sites : [];
    var startDate = params.startDate ? params.startDate : "";
    var organisationName = params.organisationName ? params.organisationName : "";
    var project = params.project ? params.project : {};
    var user = params.user ? params.user : {};
    var vocabList = params.vocabList ? params.vocabList : {};

    var self = $.extend(this, new pActivityInfo(pActivity, selected, startDate, organisationName));

    self.project = project;

    self.projectId = ko.observable(pActivity.projectId ? pActivity.projectId : projectId);
    self.restrictRecordToSites = ko.observable(pActivity.restrictRecordToSites);
    self.allowAdditionalSurveySites = ko.observable(pActivity.allowAdditionalSurveySites);
    self.baseLayersName = ko.observable(pActivity.baseLayersName);

    var speciesFields = pActivity.speciesFields || [];
    self.transients.speciesFields = ko.observableArray($.map(speciesFields, function (obj, i) {
        return new SpeciesFieldViewModel(obj);
    }));

    self.pActivityFormName = ko.observable(pActivity.pActivityFormName);
    self.pActivityFormName.extend({rateLimit: 100});

    var images = [];
    $.each(pActivityForms, function (index, form) {
        if (form.name == self.pActivityFormName()) {
            images = form.images ? form.images : [];
        }
    });

    self.pActivityFormImages = ko.observableArray($.map(images, function (obj, i) {
        return new ImagesViewModel(obj);
    }));

    self.pActivityForms = pActivityForms;

    self.updateFormImages = function (formName) {
        self.pActivityFormImages.removeAll();
        $.each(self.pActivityForms, function (index, form) {
            if (form.name == formName && form.images) {
                for (var i = 0; i < form.images.length; i++) {
                    self.pActivityFormImages.push(new ImagesViewModel(form.images[i]));
                }
            }
        });
    }

    self.transients.oldFormName = self.pActivityFormName();
    self.transients.allowFormNameChange = false;

    // 1. There is no straightforward way to prevent/cancel a KO change in a beforeChange subscription
    // 2. bootbox.confirm is totally asynchronous so by the time a user confirms or rejects a change, the change has already happened.
    // 2a. There is no good reason to call standard confirm which would block the thread.
    // 3. Trying to use jQuery to prevent event propagation might turn a pain as it would potentially get on the way with ko observables
    // Hence the approach taken is to mimic a user rejection by reverting the old value.
    // We can't prevent the value of the select to be changed from bootbox.confirm but we can update dependable properties
    // only when a user has accepted the change.

    self.pActivityFormName.subscribe(function(oldValue) {
        console.log("Updating oldName to  " + oldValue);
        self.transients.oldFormName = oldValue;
    }, null, "beforeChange");

    // Flag to prevent infinite event firing.
    // self.pActivityFormName is changed within a subscription to it
    self.transients.revertFormNameChange = false;

    self.pActivityFormName.subscribe(function(newValue) {
        console.log("New form name is " + self.pActivityFormName());

        if(!self.transients.revertFormNameChange) { // Normal interaction of user with  UI select control
            if(self.transients.speciesFields().length > 0) {
                bootbox.confirm("There is specific fields configuration for this survey in the Species tab. Changing the form will override existing settings. Do you want to continue?", function (result) {
                    // Asynchronous call, too late to prevent change but depending on the user response we either:
                    // a) Restore the previous value in the select or
                    // b) Let dependent pActivityFormName fields to be updated, ko already updated the pActivityFormName
                    self.transients.allowFormNameChange = result
                    if (result) {
                        self.retrieveSpeciesFieldsForFormName(self.pActivityFormName());
                        self.updateFormImages(self.pActivityFormName());
                    } else {
                        console.log("reverting form to previous value" + self.transients.oldFormName);
                        self.pActivityFormName(self.transients.oldFormName);
                        // Stop infinite loop propagation.
                        self.transients.revertFormNameChange = true;
                    }
                });
            } else { // No need of user confirmation, let's update pActivityFormName dependent properties
                self.retrieveSpeciesFieldsForFormName(self.pActivityFormName());
                self.updateFormImages(self.pActivityFormName());
            }
        } else {
            // User chose to cancel change to pActivityFormName, self.pActivityFormName already had the old value
            // let's just re-enable the normal event propagation behavior
            self.transients.revertFormNameChange = false;
        }
    });


    /**
     * Retrieves the species fields and overrides self.transients.speciesFields with them
     * If the species fields for this form is 0 or 1 only then  self.transients.speciesFields will be set to an empty array
     * @param formName The new form name
     */
    self.retrieveSpeciesFieldsForFormName = function(formName) {
        var divId = 'project-activities-result-placeholder';
        $.ajax({
            url: fcConfig.getSpeciesFieldsForSurveyUrl+'/' + formName,
            type: 'GET',
            // data: model,
            // contentType: 'application/json',
            success: function (data) {
                if (data.error) {
                    showAlert("Error :" + data.error, "alert-error", divId);
                }
                else {
                    self.transients.speciesFields.removeAll();

                    // Only one species field in the form, don't bother with its configuration
                    if(data.result && data.result.length > 1) {
                        $.map(data.result ? data.result : [], function (obj, i) {
                            self.transients.speciesFields.push(new SpeciesFieldViewModel(obj));
                        });
                    }
                }
            },
            error: function (data) {
                showAlert("Error : An unhandled error occurred" + data.status, "alert-error", divId);
            }
        });
    }


    self.species = ko.observable(new SpeciesConstraintViewModel(pActivity.species));

    self.showSpeciesConfiguration = function(speciesConstraintVM, fieldName, index) {
        // Create a copy to bind to the field config dialog otherwise we may change the main screen values inadvertenly
        speciesConstraintVM = new SpeciesConstraintViewModel(speciesConstraintVM.asJson(), fieldName);
        if(index) {
            speciesConstraintVM.speciesOptions.push({id: 'DEFAULT_SPECIES', name:'Use default configuration'});
        }

        showSpeciesFieldConfigInModal(speciesConstraintVM, '#configureSpeciesFieldModal', '#speciesFieldDialog')
            .done(function(result){
                    if(index) { //Update a particular species field configuration
                        var newSpeciesConstraintVM = new SpeciesConstraintViewModel(result)
                         newSpeciesConstraintVM.speciesOptions.push({id: 'DEFAULT_SPECIES', name:'Use default configuration'});
                        self.transients.speciesFields()[index()].config(newSpeciesConstraintVM);
                    } else { // Update species default configuration
                        self.species(new SpeciesConstraintViewModel(result));
                    }
                }
            );
    }
    /**
     * Determine if each species defined in this survey are valid in order for the Survey to be Publishable
     * This is an agregation of the SpeciesConstraintViewModel#isValid as now we have, potentially, more than
     * one species configuration
     */
    self.areSpeciesValid = function() {

        // As soon as a field is not valid we stop

        if(!self.species().isValid()){
            return false;
        }

        var speciesFields = self.transients.speciesFields();

        for (var i = 0; i < speciesFields.length; i++) {
            if(!speciesFields[i].config().isValid()) {
                return false;
            }
        }
        return true;
    }

    self.visibility = new SurveyVisibilityViewModel(pActivity.visibility);
    self.alert = new AlertViewModel(pActivity.alert);

    self.usageGuide = ko.observable(pActivity.usageGuide ? pActivity.usageGuide : "");

    self.relatedDatasets = ko.observableArray (pActivity.relatedDatasets ? pActivity.relatedDatasets : []);

    self.typeFor = ko.observableArray(pActivity.typeFor ? pActivity.typeFor : [])
    self.typeSeo = ko.observableArray(pActivity.typeSeo ? pActivity.typeSeo : [])
    self.typeResearch = ko.observableArray(pActivity.typeResearch ? pActivity.typeResearch : [])
    self.typeThreat = ko.observableArray(pActivity.typeThreat ? pActivity.typeThreat : [])
    self.typeConservation = ko.observableArray(pActivity.typeConservation ? pActivity.typeConservation : [])

    self.lastUpdated = ko.observable(pActivity.lastUpdated ? pActivity.lastUpdated : "");

    self.dataSharingLicense = ko.observable(pActivity.dataSharingLicense ? pActivity.dataSharingLicense : "CC BY");

    self.transients = self.transients || {};
    self.transients.warning = ko.computed(function () {
        return self.projectActivityId() === undefined ? true : false;
    });
    self.transients.disableEmbargoUntil = ko.computed(function () {
        if(self.visibility.embargoOption() != 'DATE'){
            return true;
        }

        return false;
    });

    self.transients.availableSpeciesDisplayFormat = ko.observableArray([{
        id:'SCIENTIFICNAME(COMMONNAME)',
        name: 'Scientific name (Common name)'
    },{
        id:'COMMONNAME(SCIENTIFICNAME)',
        name: 'Common name (Scientific name)'
    },{
        id:'COMMONNAME',
        name: 'Common name'
    },{
        id:'SCIENTIFICNAME',
        name: 'Scientific name'
    }])

    var legalCustodianVal = ko.utils.unwrapObservable(project.legalCustodianOrganisation);

    if (legalCustodianVal != "" && organisationName != legalCustodianVal) {
        self.transients.custodianOptions = [organisationName, legalCustodianVal];
    } else {
        self.transients.custodianOptions = [organisationName];
    }

    self.transients.selectedCustodianOption = legalCustodianVal;

    self.sites = ko.observableArray();
    self.loadSites = function (projectSites, surveySites) {
        $.map(projectSites ? projectSites : [], function (obj, i) {
            var defaultSites = [];
            surveySites && surveySites.length > 0 ? $.merge(defaultSites, surveySites) : defaultSites.push(obj.siteId);
            self.sites.push(new SiteList(obj, defaultSites));
        });
    };
    self.loadSites(sites, pActivity.sites);

    // AEKOS submission records
    var submissionRecs = pActivity.submissionRecords ? pActivity.submissionRecords : [];

    submissionRecs.sort(function(b, a) {
        var v1 = parseInt(a.datasetVersion.substr(7, 8))
        var v2 = parseInt(b.datasetVersion.substr(7, 8))
        if (v1 < v2) {
            return -1;
        }
        if (v1 > v2) {
            return 1;
        }

        // names must be equal
        return 0;
    });

    var sortedSubmissionRecs = submissionRecs.sort();

    self.submissionRecords = ko.observableArray();

    self.loadSubmissionRecords = function (submissionRecs) {
        $.map(submissionRecs ? submissionRecs : [], function (obj, i) {
            self.submissionRecords.push(new SubmissionRec(obj.submissionPublicationDate, obj.datasetSubmitter, obj.datasetVersion, obj.submissionDoi));
        });
    };
    self.loadSubmissionRecords(sortedSubmissionRecs);

    var methodName = pActivity.methodName? pActivity.methodName : "";

    if ((pActivity.sites ? pActivity.sites.length : 0) > 0 && methodName != "") {
        self.transients.isAekosData = ko.observable(true);
    } else {
        self.transients.isAekosData = ko.observable(false);
    }

    /*   self.showModal = function (pActivity) {
     self.modal = ko.observable(new AekosWorkflowViewModel(pActivity));

     } */

    // New fields for Aekos Submission
    self.environmentalFeatures = ko.observableArray();
    self.environmentalFeaturesSuggest = ko.observable();

    self.transients.titleOptions = ['Assoc Prof', 'Dr', 'Miss', 'Mr', 'Mrs', 'Miss', 'Prof'];

    self.datasetContactRole = ko.observable('');
    self.datasetContactDetails = ko.observable('');
    self.datasetContactEmail = ko.observable('');
    self.datasetContactName = ko.observable('');
    self.datasetContactPhone = ko.observable('');
    self.datasetContactAddress = ko.observable('');

    self.authorGivenNames = ko.observable('');
    self.authorSurname = ko.observable('');
    self.authorAffiliation = ko.observable('');

   /* self.showModal = function () {
        //  self.aekosModal(true);
        self.aekosModalView().show(true);
        $('.modal')[0].style.width = '90%'
        $('.modal')[0].style.height = '80%'
    };
*/

    /**
     * get number of sites selected for a survey
     * @returns {number}
     */
    self.getNumberOfSitesForSurvey = function () {
        var count = 0;
        var sites = self.sites();
        sites.forEach(function(site){
            if(site.added()){
                count ++;
            }
        });
        return count;
    }

    self.asJSAll = function () {
        var jsData = $.extend({},
            self.asJS("info"),
            self.asJS("access"),
            self.asJS("form"),
            self.asJS("species"),
            self.asJS("visibility"),
            self.asJS("alert"),
            self.asJS("sites"));
        return jsData;
    };

    self.asJS = function (by) {
        var jsData;

        if (by == "form") {
            jsData = {};
            jsData.pActivityFormName = self.pActivityFormName();
        }
        else if (by == "info") {
            var ignore = self.ignore.concat(['current', 'pActivityForms', 'pActivityFormImages',
                'access', 'species', 'sites', 'transients', 'endDate','visibility','pActivityFormName', 'restrictRecordToSites',
                'allowAdditionalSurveySites', 'baseLayersName', 'aekosModalView', 'project']);
            ignore = $.grep(ignore, function (item, i) {
                return item != "documents";
            });
            jsData = ko.mapping.toJS(self, {ignore: ignore});
            jsData.endDate = moment(self.endDate(), 'YYYY-MM-DDThh:mm:ssZ').isValid() ? self.endDate() : "";
        }
        else if (by == "species") {
            jsData = {};
            jsData.species = self.species().asJson();

            jsData.speciesFields = $.map(self.transients.speciesFields(), function (obj, i) {
                return obj.asJson();
            });
        }
        else if (by == "sites") {
            jsData = {};
            var sites = [];
            $.each(self.sites(), function (index, site) {
                if (site.added()) {
                    sites.push(site.siteId());
                }
            });
            jsData.sites = sites;
            jsData.restrictRecordToSites = self.restrictRecordToSites();
            jsData.allowAdditionalSurveySites = self.allowAdditionalSurveySites();
            jsData.baseLayersName = self.baseLayersName();
        }
        else if (by == "visibility") {
            jsData = {};
            var ignore = self.ignore.concat(['transients']);
            jsData.visibility = ko.mapping.toJS(self.visibility, {ignore: ignore});
        }
        else if (by == "alert") {
            jsData = {};
            var ignore = self.ignore.concat(['transients']);
            jsData.alert = ko.mapping.toJS(self.alert, {ignore: ignore});
        }

        return jsData;
    }

    self.aekosModalView = ko.observable(new AekosViewModel (self, project, user, vocabList));

    //self.aekosModal = ko.observable(false);

    self.showModal = function () {
        //  self.aekosModal(true);
        self.aekosModalView().show(true);
    };

};


// Custom binding for modal dialog
ko.bindingHandlers.bootstrapShowModal = {
    init: function (element, valueAccessor) {
    },
    update: function (element, valueAccessor) {
        var value = valueAccessor();

        if (ko.utils.unwrapObservable(value)) {
            $(element).modal('show');
            // this is to focus input field inside dialog
            $("input", element).focus();
        }
        else {
            $(element).modal('hide');
        }
    }
};

var SiteList = function (o, surveySites) {
    var self = this;
    if (!o) o = {};
    if (!surveySites) surveySites = {};

    self.siteId = ko.observable(o.siteId);
    self.name = ko.observable(o.name);
    self.added = ko.observable(false);
    self.siteUrl = ko.observable(fcConfig.siteViewUrl + "/" + self.siteId());
    self.ibra = ko.observable(o.extent.geometry.ibra)

    self.addSite = function () {
        self.added(true);
    };
    self.removeSite = function () {
        self.added(false);
    };

    self.load = function (surveySites) {
        $.each(surveySites, function (index, siteId) {
            if (siteId == self.siteId()) {
                self.added(true);
            }
        });
    };
    self.load(surveySites);

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


var NewSpeciesListViewModel = function (o) {
    var self = this;
    if (!o) o = {};

    self.listName = ko.observable(o.listName);
    self.dataResourceUid = ko.observable(o.dataResourceUid);
    self.description = ko.observable(o.description);
    self.listType = ko.observable(o.listType);
    self.allSpecies = ko.observableArray();

    self.inputSpeciesViewModel = new SpeciesViewModel();
    self.inputSpeciesViewModel.transients.searchValue = ko.observable("");

    self.inputSpeciesViewModel.transients.name.subscribe(function (newName) {
        if(newName) {
            var newSpecies = new SpeciesViewModel();
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

var ImagesViewModel = function (image) {
    var self = this;
    if (!image) image = {};

    self.thumbnail = ko.observable(image.thumbnail);
    self.url = ko.observable(image.url);
};

var SurveyVisibilityViewModel = function (visibility) {
    var self = this;
    if (!visibility) {
        visibility = {};
    }

    self.embargoOption = ko.observable(visibility.embargoOption ? visibility.embargoOption : 'NONE');   // 'NONE', 'DAYS', 'DATE' -> See au.org.ala.ecodata.EmbargoOptions in Ecodata

    self.embargoForDays = ko.observable(visibility.embargoForDays ? visibility.embargoForDays : 10).extend({numeric:0});     // 1 - 180 days
    self.embargoUntil = ko.observable(visibility.embargoUntil).extend({simpleDate: true});
};

var AlertViewModel = function (alert) {
    var self = this;
    if (!alert) alert = {};
    self.allSpecies = ko.observableArray();
    self.emailAddresses = ko.observableArray();

    self.add = function () {
        if (!$('#project-activities-alert-validation').validationEngine('validate')) {
            return;
        }
        var species = {};
        species.name = self.transients.species.name();
        species.guid = self.transients.species.guid();

        var match = ko.utils.arrayFirst(self.allSpecies(), function(item) {
            return species.guid === item.guid();
        });

        if (!match) {
            self.allSpecies.push(new SpeciesViewModel(species));
        }
        self.transients.species.reset();
    };
    self.delete = function (species) {
        self.allSpecies.remove(species);
    };

    self.addEmail = function () {
        var emails = [];
        emails = self.transients.emailAddress().split(",");
        var invalidEmail = false;
        var message = "";
        $.each(emails, function (index, email) {
            if (!self.validateEmail(email)) {
                invalidEmail = true;
                message = email;
                return false;
            }
        });

        if (invalidEmail) {
            showAlert("Invalid email address (" + message + ")", "alert-error", "project-activities-result-placeholder");
        } else {
            $.each(emails, function (index, email) {
                if (self.emailAddresses.indexOf(email) < 0) {
                    self.emailAddresses.push(email);
                }
            });
            self.transients.emailAddress('');
        }
    };

    self.deleteEmail = function (email) {
        self.emailAddresses.remove(email);
    };

    self.transients = {};
    self.transients.species = new SpeciesViewModel();
    self.transients.emailAddress = ko.observable();
    self.transients.disableSpeciesAdd  = ko.observable(true);
    self.transients.disableAddEmail  = ko.observable(true);
    self.transients.emailAddress.subscribe(function(email) {
        return email ? self.transients.disableAddEmail(false): self.transients.disableAddEmail(true);
    });
    self.transients.species.guid.subscribe(function(guid) {
        return guid ? self.transients.disableSpeciesAdd(false) : self.transients.disableSpeciesAdd(true);
    });

    self.validateEmail = function(email){
        var expression = /^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i;
        return expression.test(email);
    };

    self.transients.bioProfileUrl = fcConfig.bieUrl + '/species/';
    self.transients.bioSearch = ko.observable(fcConfig.speciesSearchUrl);
    self.loadAlert = function (alert) {
        self.allSpecies($.map(alert.allSpecies ? alert.allSpecies : [], function (obj, i) {
                return new SpeciesViewModel(obj);
            })
        );

        self.emailAddresses($.map(alert.emailAddresses ? alert.emailAddresses : [], function (obj, i) {
                return obj;
            })
        );
    };

    self.loadAlert(alert);
};

/**
 * Custom validation function (used by the jquery-validation-engine), defined on the embargoUntil date field on the
 * survey admin visibility form
 */
function isEmbargoDateRequired(field, rules, i, options) {
    if ($('#embargoOptionDate:checked').val()) {
        if ($('#embargoUntilDate').val() == "") {
            rules.push('required');
        } else {
            var date = convertToIsoDate($('#embargoUntilDate').val(), 'dd-MM-yyyy');
            if (moment(date).isBefore(moment())) {
                return "The date must be in the future";
            } else if (moment(date).isAfter(new Date().setMonth(new Date().getMonth() + 12))) {
                return "The date cannot be more than 12 months in the future";
            }
        }
    }
}

function initialiseValidator() {
    var tabs = ['info', 'species', 'form', 'access', 'visibility', 'alert'];
    $.each(tabs, function (index, label) {
        $('#project-activities-' + label + '-validation').validationEngine();
    });
};

