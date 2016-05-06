var ProjectActivitiesViewModel = function (params) {
    var self = this;
    var pActivities = params.pActivities;
    var user = params.user;

    self.organisationName = params.organisationName;
    self.pActivityForms = params.pActivityForms;
    self.sites = params.sites;
    self.projectStartDate = params.projectStartDate;

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

    self.setLegalCustodian = function(data) {
        self.current().legalCustodian(data);
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
                startDate: self.projectStartDate
            };
            return self.projectActivities.push(new ProjectActivity(args));
        });

        self.sort();
    };

    self.userCanEdit = function (pActivity) {
        var projectActive = !pActivity.endDate() || moment(pActivity.endDate()).isAfter(moment());
        var userIsEditorOrAdmin = user && Object.keys(user).length > 0 && (user.isEditor || user.isAdmin);
        return projectActive && (pActivity.publicAccess() || userIsEditorOrAdmin);
    };

    self.loadProjectActivities(pActivities);

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

var ProjectActivitiesSettingsViewModel = function (pActivitiesVM, placeHolder) {

    var self = $.extend(this, pActivitiesVM);
    var surveyInfoTab = '#survey-info-tab';
    self.placeHolder = placeHolder;
    self.speciesOptions =  [{id: 'ALL_SPECIES', name:'All species'},{id:'SINGLE_SPECIES', name:'Single species'}, {id:'GROUP_OF_SPECIES',name:'A selection or group of species'}];
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
            current.species.isValid() &&
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
        current.species.isValid() &&
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

    var self = $.extend(this, new pActivityInfo(pActivity, selected, startDate, organisationName));
    self.projectId = ko.observable(pActivity.projectId ? pActivity.projectId : projectId);
    self.restrictRecordToSites = ko.observable(pActivity.restrictRecordToSites);
    self.pActivityFormName = ko.observable(pActivity.pActivityFormName);
    self.species = new SpeciesConstraintViewModel(pActivity.species);
    self.visibility = new SurveyVisibilityViewModel(pActivity.visibility);
    self.alert = new AlertViewModel(pActivity.alert);

    self.usageGuide = ko.observable(pActivity.usageGuide ? pActivity.usageGuide : "");

    self.relatedDatasets = ko.observableArray (pActivity.relatedDatasets ? pActivity.relatedDatasets : []);

    self.lastUpdated = ko.observable(pActivity.lastUpdated ? pActivity.lastUpdated : "");

    var legalCustodian = pActivity.legalCustodian? pActivity.legalCustodian: "";
    self.legalCustodian = ko.observable(legalCustodian);

    self.dataSharingLicense = ko.observable(pActivity.dataSharingLicense ? pActivity.dataSharingLicense : "");

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

    if (legalCustodian != "" && organisationName != legalCustodian) {
        self.transients.custodianOptions = [organisationName, legalCustodian];
    } else {
        self.transients.custodianOptions = [organisationName];
    }

    //self.selectedCustodianOption = ko.observableArray([legalCustodian]);
    self.transients.selectedCustodianOption = [legalCustodian];

    self.sites = ko.observableArray();
    self.loadSites = function (projectSites, surveySites) {
        $.map(projectSites ? projectSites : [], function (obj, i) {
            var defaultSites = [];
            surveySites && surveySites.length > 0 ? $.merge(defaultSites, surveySites) : defaultSites.push(obj.siteId);
            self.sites.push(new SiteList(obj, defaultSites));
        });
    };
    self.loadSites(sites, pActivity.sites);

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

    self.pActivityFormName.subscribe(function (formName) {
        self.pActivityFormImages.removeAll();
        $.each(self.pActivityForms, function (index, form) {
            if (form.name == formName && form.images) {
                for (var i = 0; i < form.images.length; i++) {
                    self.pActivityFormImages.push(new ImagesViewModel(form.images[i]));
                }
            }
        });
    });

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
                'access', 'species', 'sites', 'transients', 'endDate','visibility','pActivityFormName', 'restrictRecordToSites']);
            ignore = $.grep(ignore, function (item, i) {
                return item != "documents";
            });
            jsData = ko.mapping.toJS(self, {ignore: ignore});
            jsData.endDate = moment(self.endDate(), 'YYYY-MM-DDThh:mm:ssZ').isValid() ? self.endDate() : "";
        }
        else if (by == "species") {
            jsData = {};
            jsData.species = self.species.asJson();
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
};

var SiteList = function (o, surveySites) {
    var self = this;
    if (!o) o = {};
    if (!surveySites) surveySites = {};

    self.siteId = ko.observable(o.siteId);
    self.name = ko.observable(o.name);
    self.added = ko.observable(false);
    self.siteUrl = ko.observable(fcConfig.siteViewUrl + "/" + self.siteId());

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

var SpeciesConstraintViewModel = function (o) {
    var self = this;
    if (!o) o = {};

    self.type = ko.observable(o.type);
    self.allSpeciesLists = new SpeciesListsViewModel();
    self.singleSpecies = new SpeciesViewModel(o.singleSpecies);
    self.speciesLists = ko.observableArray($.map(o.speciesLists ? o.speciesLists : [], function (obj, i) {
        return new SpeciesList(obj);
    }));
    self.newSpeciesLists = new SpeciesList();

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
        self.transients.showExistingSpeciesLists(!self.transients.showExistingSpeciesLists());
        if (self.transients.showExistingSpeciesLists()) {
            self.allSpeciesLists.loadAllSpeciesLists();
            self.transients.showAddSpeciesLists(false);
        }
    };

    self.addSpeciesLists = function (lists) {
        lists.transients.check(true);
        self.speciesLists.push(lists);
    };

    self.removeSpeciesLists = function (lists) {
        self.speciesLists.remove(lists);
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
        }
        else if (self.type() == "SINGLE_SPECIES") {
            jsData.type = self.type();
            jsData.singleSpecies = ko.mapping.toJS(self.singleSpecies, {ignore: ['transients']});
        }
        else if (self.type() == "GROUP_OF_SPECIES") {
            jsData.type = self.type();
            jsData.speciesLists = ko.mapping.toJS(self.speciesLists, {ignore: ['listType', 'fullName', 'itemCount', 'description', 'listType', 'allSpecies', 'transients']});
        }
        return jsData;
    };

    self.isValid = function(){
        return ((self.type() == "ALL_SPECIES") || (self.type() == "SINGLE_SPECIES" && self.singleSpecies.guid()) ||
        (self.type() == "GROUP_OF_SPECIES" && self.speciesLists().length > 0))
    };

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
            if (index == 0) {
                jsData.listItems = species.name;
            } else {
                jsData.listItems = jsData.listItems + "," + species.name;
            }
        });
        // Add bulk species names.
        if (jsData.listItems == "") {
            jsData.listItems = self.newSpeciesLists.transients.bulkSpeciesNames();
        } else {
            jsData.listItems = jsData.listItems + "," + self.newSpeciesLists.transients.bulkSpeciesNames();
        }

        var model = JSON.stringify(jsData, function (key, value) {
            return value === undefined ? "" : value;
        });
        var divId = 'project-activities-result-placeholder';
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
                    self.newSpeciesLists = new SpeciesList();
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

var SpeciesListsViewModel = function (o) {
    var self = this;
    if (!o) o = {};

    self.searchGuid = ko.observable();
    self.searchName = ko.observable();

    self.allSpeciesListsToSelect = ko.observableArray();
    self.offset = ko.observable(0);
    self.max = ko.observable(100);
    self.listCount = ko.observable();
    self.isNext = ko.computed(function () {
        var status = false;
        if (self.listCount() > 0) {
            var maxOffset = self.listCount() / self.max();
            if (self.offset() < Math.ceil(maxOffset) - 1) {
                status = true;
            }
        }
        return status;
    });

    self.isPrevious = ko.computed(function () {
        return (self.offset() > 0);
    });

    self.next = function () {
        if (self.listCount() > 0) {
            var maxOffset = self.listCount() / self.max();
            if (self.offset() < Math.ceil(maxOffset) - 1) {
                self.offset(self.offset() + 1);
                self.loadAllSpeciesLists();
            }
        }
    };

    self.previous = function () {
        if (self.offset() > 0) {
            var newOffset = self.offset() - 1;
            self.offset(newOffset);
            self.loadAllSpeciesLists();
        }
    };

    self.loadAllSpeciesLists = function () {
        var url = fcConfig.speciesListUrl + "?sort=listName&offset=" + self.offset() + "&max=" + self.max();
        if (self.searchGuid()) {
            url += "&guid=" + self.searchGuid();
        }

        var divId = 'project-activities-result-placeholder';
        $.ajax({
            url: url,
            type: 'GET',
            contentType: 'application/json',
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
                }
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

        self.loadAllSpeciesLists();
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

    // Only used for new species.
    self.description = ko.observable(o.description);
    self.listType = ko.observable(o.listType);
    self.allSpecies = ko.observableArray();
    self.addNewSpeciesName = function () {
        self.allSpecies.push(new SpeciesViewModel());
    };
    self.removeNewSpeciesName = function (species) {
        self.allSpecies.remove(species);
    };

    self.transients = {};
    self.transients.bulkSpeciesNames = ko.observable(o.bulkSpeciesNames);
    self.transients.url = ko.observable(fcConfig.speciesListsServerUrl + "/speciesListItem/list/" + o.dataResourceUid);
    self.transients.check = ko.observable(false);
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
