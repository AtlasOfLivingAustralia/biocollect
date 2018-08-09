var ProjectActivity = function (params) {
    if(!params) params = {};
    var pActivity = params.pActivity ? params.pActivity : {};
    var projectId = params.projectId ? params.projectId : "";
    var selected = params.selected ? params.selected : false;
    var sites = params.sites ? params.sites : [];
    var startDate = params.startDate ? params.startDate : "";
    var organisationName = params.organisationName ? params.organisationName : "";
    var project = params.project ? params.project : {};
    var user = params.user ? params.user : {};

    var self = $.extend(this, new pActivityInfo(pActivity, selected, startDate, organisationName));
    self.project = project;
    self.projectId = ko.observable(pActivity.projectId ? pActivity.projectId : projectId);
    self.restrictRecordToSites = ko.observable(pActivity.restrictRecordToSites);
    self.allowAdditionalSurveySites = ko.observable(pActivity.allowAdditionalSurveySites);
    self.selectFromSitesOnly = ko.observable(pActivity.selectFromSitesOnly);
    self.legalCustodianOrganisation = ko.utils.unwrapObservable(pActivity.legalCustodianOrganisation || organisationName);
    self.sites = ko.observableArray();
    self.allowPolygons = ko.observable(('allowPolygons' in pActivity)? pActivity.allowPolygons : false);
    self.allowPoints = ko.observable(('allowPoints' in pActivity)? pActivity.allowPoints : true);
    self.defaultZoomArea = ko.observable(('defaultZoomArea' in pActivity)? pActivity.defaultZoomArea : project?project.projectSiteId:'');
    self.baseLayersName = ko.observable(pActivity.baseLayersName);
    self.pActivityFormName = ko.observable(pActivity.pActivityFormName);
    self.usageGuide = ko.observable(pActivity.usageGuide || "");
    self.relatedDatasets = ko.observableArray (pActivity.relatedDatasets || []);
    self.dataSharingLicense = ko.observable(pActivity.dataSharingLicense || "");
    self.spatialAccuracy = ko.observable(pActivity.spatialAccuracy || "");
    self.speciesIdentification = ko.observable(pActivity.speciesIdentification || "");
    self.temporalAccuracy = ko.observable(pActivity.temporalAccuracy || "");
    self.nonTaxonomicAccuracy = ko.observable(pActivity.nonTaxonomicAccuracy || "");
    self.dataQualityAssuranceMethod = ko.observable(pActivity.dataQualityAssuranceMethod || "");
    self.dataAccessMethod = ko.observable(pActivity.dataAccessMethod || "");
    self.dataAccessExternalURL = ko.observable(pActivity.dataAccessExternalURL || "");
    self.isDataManagementPolicyDocumented = ko.observable(pActivity.isDataManagementPolicyDocumented || false);
    self.dataQualityAssuranceDescription = ko.observable(pActivity.dataQualityAssuranceDescription || "");
    self.dataManagementPolicyDescription = ko.observable(pActivity.dataManagementPolicyDescription || "");
    self.dataManagementPolicyURL = ko.observable(pActivity.dataManagementPolicyURL || "");
    self.dataManagementPolicyDocument = ko.observable(pActivity.dataManagementPolicyDocument || "");
    self.transients.publicAccess = pActivity.publicAccess? "True" : "False";
    self.transients.activityLastUpdated = pActivity.activityLastUpdated;
    self.transients.speciesRecorded = pActivity.speciesRecorded;
    self.transients.activityCount = pActivity.activityCount;
    self.transients.isDataManagementPolicyDocumented = pActivity.isDataManagementPolicyDocumented? "True" : "False";

    self.selectFromSitesOnly.subscribe(function(checked){
        if(checked){
            self.allowAdditionalSurveySites(false);
        }
    }.bind(self));

    self.allowAdditionalSurveySites.subscribe(function(checked){
        if(checked){
            self.selectFromSitesOnly(false);
        }
    }.bind(self));

    self.previewUrl = ko.observable('');

    self.previewActivity = function (link, pActivityFormName) {

        if (pActivityFormName) {

            var formName = encodeURIComponent(pActivityFormName);

            self.previewUrl(link + "?formName=" + formName + "&projectId=" + projectId);

            $("#previewModal").modal({
                // Clicking the backdrop, or pressing Escape, shouldn't automatically close the modal by default.
                // The view model should remain in control of when to close.
                backdrop: "static",
                keyboard: false
            });
        } else {
            bootbox.alert("Please select a survey form to preview");
        }

    };

    self.hideModal = function() {
        $("#previewModal").modal('hide');
    };

    /**
     * Retrieves the species fields and overrides self.speciesFields with them
     * only if formName is not empty
     * @param formName The new form name
     * @param sync should the call be synchronous (default false)
     */
    self.retrieveSpeciesFieldsForFormName = function(formName, sync) {
        sync = sync || false
        if(formName) {
            var divId = 'project-activities-result-placeholder';
            $.ajax({
                async: !sync,
                url: fcConfig.getSpeciesFieldsForSurveyUrl + '/' + formName,
                type: 'GET',
                // data: model,
                // contentType: 'application/json',
                success: function (data) {
                    if (data.error) {
                        showAlert("Error :" + data.error, "alert-error", divId);
                    }
                    else {
                        self.speciesFields.removeAll();

                        // Only one species field in the form, don't bother with its configuration
                        if (data.result) {
                            $.map(data.result ? data.result : [], function (obj, i) {
                                self.speciesFields.push(new SpeciesFieldViewModel(obj));
                            });
                        }
                    }
                },
                error: function (data) {
                    showAlert("Error : An unhandled error occurred" + data.status, "alert-error", divId);
                }
            });
        }
    };


    // 1. There is no straightforward way to prevent/cancel a KO change in a beforeChange subscription
    // 2. bootbox.confirm is totally asynchronous so by the time a user confirms or rejects a change, the change has already happened.
    // 2a. There is no good reason to call standard confirm which would block the thread.
    // 3. Trying to use jQuery to prevent event propagation might turn a pain as it would potentially get on the way with ko observables
    // Hence the approach taken is to mimic a user rejection by reverting the old value.
    // We can't prevent the value of the select to be changed from bootbox.confirm but we can update dependable properties
    // only when a user has accepted the change.

    self.transients.beforePActivityFormNameUpdate = function(oldValue) {
        console.log("pActivityFormName about to change old form: " + oldValue);
        // console.log("Survey: " + self.name());
        self.transients.oldFormName = oldValue;
    };

    self.transients.isDataAvailable = function (){
        return $.ajax({
            url: fcConfig.activiyCountUrl + "/" + self.projectActivityId(),
            type: 'GET'
        });
    };

    self.transients.deleteAllData = function () {
        return $.ajax({
            url: fcConfig.deleteAllDataForProjectActivityUrl + "/" + self.projectActivityId(),
            type: 'GET'
        });
    };

    /**
     * Seeks confirmation from user when form template was changed. The conditions checked are
     * 1. does data exists current survey? seek confirmation
     * 2. is/are species field(s) configured? seek confirmation
     * @param amountOfDataToBeCleared - Total number of records currently existing for this survey
     * @param speciesFieldConfigured - True if species field has been configured
     */
    self.transients.seekConfirmationForChangeOfFormName = function (amountOfDataToBeCleared, speciesFieldConfigured) {
        var message = "";
        if(amountOfDataToBeCleared && speciesFieldConfigured){
            message = "This survey has " + amountOfDataToBeCleared + " record(s). And, there is specific fields configuration for this" +
            " survey in the Species tab. Changing the form template will delete the existing data and override species settings. Do you want to continue?"
        } else if (amountOfDataToBeCleared){
            message =  "This survey has " + amountOfDataToBeCleared + "record(s). Changing the form template will delete the existing data. Do you want to continue?"
        } else if( speciesFieldConfigured ){
            message = "There is specific fields configuration for this survey in the Species tab. Changing the form will override existing settings. Do you want to continue?";
        }

        bootbox.confirm(message, function (result) {
            // Asynchronous call, too late to prevent change but depending on the user response we either:
            // a) Let dependent pActivityFormName fields to be updated, ko already updated the pActivityFormName or
            // b) Restore the previous value in the select
            if (result) {
                // delete records in survey
                var deletePromise = self.transients.deleteAllData();
                deletePromise.then(function () {
                    console.log('Successfully submitted deletion of records.');
                    self.retrieveSpeciesFieldsForFormName(self.pActivityFormName());
                }, function () {
                    self.transients.revertFormNameToPreviousSelection();
                    bootbox.alert("Failed to delete records. Are you authorized to do this operation? Reverting form template selection.");
                });
            } else {
                self.transients.revertFormNameToPreviousSelection();
            }
        });
    };

    /**
     * Reverts the current form selection to previous selection.
     */
    self.transients.revertFormNameToPreviousSelection = function () {
        // Prevent infinite loop, let' dispose self subscription before making any changes.
        self.transients.afterPActivityFormNameSubscription.dispose();
        console.log("Reverting form name to: " + self.transients.oldFormName + " For survey: " + self.name());

        self.pActivityFormName(self.transients.oldFormName);

        // Restore subscription for future UI events.
        self.transients.afterPActivityFormNameSubscription = self.pActivityFormName.subscribe(self.transients.afterPActivityFormNameUpdate);
    };

    /**
     * triggered after form template selector has changed.
     * It checks a series of rules to confirm the change in form template. The details are commented with code.
     * @param newValue
     */
    self.transients.afterPActivityFormNameUpdate = function(newValue) {
        console.log("pActivityFormName changed to: " + newValue +  " from: " + self.transients.oldFormName +
        "for Survey: " + self.name());

        // check if survey has been newly added.
        if(self.projectActivityId()){
            blockUIWithMessage("Checking! Please wait...");
            // check if survey has data in it
            var ajax = self.transients.isDataAvailable();
            ajax.done($.unblockUI).then(function (data) {
                var speciesFieldConfigured = self.areSpeciesFieldsConfigured();
                // if has data or has species field configured, ask user to confirm form name change.
                if( data.total > 0 || speciesFieldConfigured){
                    self.transients.seekConfirmationForChangeOfFormName(data.total, speciesFieldConfigured);
                } else {
                    // if no data or species field not configured, get species fields for form name
                    self.retrieveSpeciesFieldsForFormName(self.pActivityFormName());
                }
            }, function () {
                bootbox.alert("Reverting form template selection since an error occurred when checking existence of data in current survey.");
                self.transients.revertFormNameToPreviousSelection();
            });
        } else {
            // if new survey, get species fields for form name
            self.retrieveSpeciesFieldsForFormName(self.pActivityFormName());
        }
    };


    self.transients.subscribeOrDisposePActivityFormName = function (selected) {
        if(selected) {
            self.transients.beforePActivityFormNameSubscription = self.pActivityFormName.subscribe(self.transients.beforePActivityFormNameUpdate, null, "beforeChange");
            self.transients.afterPActivityFormNameSubscription = self.pActivityFormName.subscribe(self.transients.afterPActivityFormNameUpdate);
        } else {
            self.transients.beforePActivityFormNameSubscription && self.transients.beforePActivityFormNameSubscription.dispose();
            self.transients.afterPActivityFormNameSubscription && self.transients.afterPActivityFormNameSubscription.dispose();
        }
    }

    /**
     * Initialises new speciesField configuration, possibly from legacy species configuration
     * If no pActivity.speciesField exist then retrieve the species fields list from the current form and then
     * use the existing pActivity.species to populate defaults for each speciesField.
     *
     * self.species field then can be cleared.
     * @param pActivity the project activity object model, it should not be null
     * @param selected Is this the current displayed activity?
     */
    self.transients.initSpeciesConfig = function (pActivity, selected) {
        self.transients.oldFormName = self.pActivityFormName();

        // New configuration in place, use new speciesFields to do initialisation
        if($.isArray(pActivity.speciesFields) && pActivity.speciesFields.length > 0 ) {
            self.speciesFields = ko.observableArray($.map(pActivity.speciesFields, function (obj, i) {
                return new SpeciesFieldViewModel(obj);
            }));
        } else {
            // Legacy functionality, revert to initialising from existing pActivity.species field
            self.speciesFields = ko.observableArray([]);
            self.retrieveSpeciesFieldsForFormName(self.pActivityFormName(), true);
            for(var i = 0; i< self.speciesFields().length; i++) {
                self.speciesFields()[i].config(new SpeciesConstraintViewModel(pActivity.species));
            }
        }
    }

    self.transients.initSpeciesConfig(pActivity, selected);


    self.areSpeciesFieldsConfigured = function () {
        // As soon as a field is valid, we stop
        var speciesFields = self.speciesFields();

        for (var i = 0; i < speciesFields.length; i++) {
            if(speciesFields[i].config().isValid()) {
                return true;
            }
        }
        return false;
    }


    self.showSpeciesConfiguration = function(speciesConstraintVM, fieldName, index) {
        // Create a copy to bind to the field config dialog otherwise we may change the main screen values inadvertenly
        speciesConstraintVM = new SpeciesConstraintViewModel(speciesConstraintVM.asJson(), fieldName);

        // if(index) {
        //     speciesConstraintVM.speciesOptions.push({id: 'DEFAULT_SPECIES', name:'Use default configuration'});
        // }

        showSpeciesFieldConfigInModal(speciesConstraintVM, '#speciesFieldDialog')
            .done(function(result){
                    if(index) { //Update a particular species field configuration
                        var newSpeciesConstraintVM = new SpeciesConstraintViewModel(result)
                         // newSpeciesConstraintVM.speciesOptions.push({id: 'DEFAULT_SPECIES', name:'Use default configuration'});
                        self.speciesFields()[index()].config(newSpeciesConstraintVM);
                     }
                     // else { // Update species default configuration
                    //     self.species(new SpeciesConstraintViewModel(result));
                    // }
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

        var speciesFields = self.speciesFields();

        for (var i = 0; i < speciesFields.length; i++) {
            if(!speciesFields[i].config().isValid()) {
                return false;
            }
        }
        return true;
    }

    self.visibility = new SurveyVisibilityViewModel(pActivity.visibility);
    self.alert = new AlertViewModel(pActivity.alert);

    self.displaySelectedLicence = ko.computed(function(){
          return _.where(self.transients.alaSupportedLicences,{url:self.dataSharingLicense()});

    });



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
    }]);

    self.loadSites = function (projectSites, surveySites) {
        $.map(projectSites ? projectSites : [], function (obj, i) {
            var defaultSites = [];
            surveySites && surveySites.length > 0 ? $.merge(defaultSites, surveySites) : (obj.isProjectArea?defaultSites.push(obj.siteId):defaultSites);
            self.sites.push(new SiteList(obj, defaultSites, self));
        });
    };
    self.loadSites(sites, pActivity.sites);

    self.submissionRecords = ko.observableArray();

    self.loadSubmissionRecords = function (pActvitySubmissionRecs) {
        if (!pActvitySubmissionRecs || pActvitySubmissionRecs.length == 0) {
            return;
        }

        var submissionRecs = pActvitySubmissionRecs;

        if (pActvitySubmissionRecs.length > 1) {

            submissionRecs.sort(function (b, a) {
                if (a && b) {
                    var v1 = parseInt(a.datasetVersion.substr(7, 8))
                    var v2 = parseInt(b.datasetVersion.substr(7, 8))
                    if (v1 < v2) {
                        return -1;
                    }
                    if (v1 > v2) {
                        return 1;
                    }
                }
                // names must be equal
                return 0;

            });

            var sortedSubmissionRecs = submissionRecs.sort();
            submissionRecs = sortedSubmissionRecs;
        }

        if (ko.utils.unwrapObservable(self.submissionRecords)) {
            ko.utils.unwrapObservable(self.submissionRecords).splice (0);
        }

        $.map(submissionRecs ? submissionRecs : [], function (obj, i) {
            var submissionRec = new SubmissionRec(obj);
            ko.utils.unwrapObservable(self.submissionRecords).push(submissionRec);
         });
    };

    if (pActivity.submissionRecords && pActivity.submissionRecords.length > 0) {
        self.loadSubmissionRecords(pActivity.submissionRecords);
    }

    var methodName = pActivity.methodName? pActivity.methodName : "";

    if ((pActivity.sites ? pActivity.sites.length : 0) > 0 && methodName != "") {
        self.transients.isAekosData = ko.observable(true);
    } else {
        self.transients.isAekosData = ko.observable(false);
    }

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
            var ignore = self.ignore.concat(['current',
                'access', 'species', 'sites', 'transients', 'endDate','visibility','pActivityFormName', 'restrictRecordToSites',
                'allowAdditionalSurveySites', 'baseLayersName', 'project']);
            ignore = $.grep(ignore, function (item, i) {
                return item != "documents";
            });
            jsData = ko.mapping.toJS(self, {ignore: ignore});
            jsData.endDate = moment(self.endDate(), 'YYYY-MM-DDThh:mm:ssZ').isValid() ? self.endDate() : "";
        }
        else if (by == "species") {
            jsData = {};

            jsData.speciesFields = $.map(self.speciesFields(), function (obj, i) {
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
            jsData.selectFromSitesOnly = self.selectFromSitesOnly();
            jsData.baseLayersName = self.baseLayersName();
            jsData.allowPolygons = self.allowPolygons();
            jsData.allowPoints = self.allowPoints();
            jsData.defaultZoomArea = self.defaultZoomArea();
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

    self.showAekosModal = function (projectActivities, currentUser, vocabList, projectArea) {

        var url = fcConfig.getRecordsForMapping + '&max=10000' +'&view=project' ;

        if(fcConfig.projectId){
            url += '&projectId=' + fcConfig.projectId + "&fq=projectActivityNameFacet:" + self.name();
        }

        $.getJSON(url, function(data) {

            var inValidDataset = false;
            var promptToSubmitDataset = false;
            var filteredActivities = [];

            if (data && data.activities && data.activities instanceof Array && data.activities.length > 0) {

                //Array.prototype.push.apply(filteredActivities, data);

                // filter off those activities which doesn't have records
                var filteredActivities = data.activities.filter (function (a) {
                    return ((a.records != null) || (a.records && a.records.length >= 0))
                });


                var invalidActivity = [];

                // filter of invalid records from the remaining activity records
                for (len = filteredActivities.length, i=0; i<len; ++i) {
                    var activity = filteredActivities[i];
                    var filteredRecords = [];
                    // Obtain valid records and remove invalid records
                    var filteredRecords = activity.records.filter(function(e) {
                        return (e.guid != null || (e.name && e.name.toLowerCase().indexOf('unmatched taxon') < 0));
                    });

                    // none of the record is valid, flag this activity as invalid
                    if (filteredRecords.length == 0) {
                        invalidActivity.push (activity.activityId)
                    } else if (filteredRecords.length < activity.records.length) {
                        // some record is invalid, still can submitted but only those that are valid
                        promptToSubmitDataset = true;
                    }

                    activity.records = filteredRecords;

                }

                // if all records in activity is invalid, remove the activity
                filteredActivities = filteredActivities.filter (function (a) {
                    return invalidActivity.indexOf(a.activityId) < 0 ;
                });

                if (promptToSubmitDataset) {
                    bootbox.confirm("Warning! This dataset contains some invalid records with unMatched Taxon or invalid names. These invalid records will be ignored. Click OK to proceed or Cancel to fix the records.", function (result) {
                        if (result) {
                            data.activities = filteredActivities;
                            AEKOS.Utility.openModal({
                                template: "aekosWorkflowModal",
                                viewModel: new AEKOS.AekosViewModel(self, pActivity, project, projectActivities, currentUser, vocabList, projectArea, data),
                                context: self // Set context so we don't need to bind the callback function
                            })
                        }
                    });
                } else if (filteredActivities.length == 0) {
                    bootbox.alert("This dataset does not contain any records or records that are invalid. There is nothing to submit.");
                    //inValidDataset = true;
                } else if (filteredActivities.length < data.activities.length) {
                     bootbox.confirm("Warning! There are some activities with empty records. These will be ignored. Click OK if you wish to proceed.", function (result) {
                         if (result) {
                             data.activities = filteredActivities;
                             AEKOS.Utility.openModal({
                                 template: "aekosWorkflowModal",
                                 viewModel: new AEKOS.AekosViewModel(self, pActivity, project, projectActivities, currentUser, vocabList, projectArea, data),
                                 context: self // Set context so we don't need to bind the callback function
                             })
                         }
                     });
                } else if (filteredActivities.length == data.activities.length) {
                    data.activities = filteredActivities;
                    AEKOS.Utility.openModal({
                        template: "aekosWorkflowModal",
                        viewModel: new AEKOS.AekosViewModel(self, pActivity, project, projectActivities, currentUser, vocabList, projectArea, data),
                        context: self // Set context so we don't need to bind the callback function
                    })
                }

            } else {
                bootbox.alert("There are no records for this dataset or records cannot be retrieved.");
            }

        }).error(function (request, status, error) {
            bootbox.alert("Something went wrong when retrieving activity records.");
        });

    };

};

var SiteList = function (o, surveySites, pActivity) {
    var self = this;
    if (!o) o = {};
    if (!surveySites) surveySites = {};

    self.siteId = ko.observable(o.siteId);
    self.name = ko.observable(o.name);
    self.added = ko.observable(false);
    self.siteUrl = ko.observable(fcConfig.siteViewUrl + "/" + self.siteId());
    self.ibra = ko.observable(o.extent.geometry.ibra);
    self.isProjectArea = ko.observable(o.isProjectArea||false);

    self.addSite = function () {
        self.added(true);
    };
    self.removeSite = function () {
        if(!self.transients.isDataForSite()) {
            self.added(false);
        }
    };

    self.load = function (surveySites) {
        $.each(surveySites, function (index, siteId) {
            if (siteId == self.siteId()) {
                self.added(true);
            }
        });
    };
    self.load(surveySites);

    self.transients = {};

    /**
     * checks if this site has data associated for the provided project activity.
     */
    self.transients.isDataForSite = ko.computed(function(){
        // if ajax call is not complete return has data so that the button is disabled
        if(!pActivity.transients.siteWithDataAjaxFlag()){
            return true
        }

        var sitesWithData = pActivity.transients.sitesWithData() || [];
        var results = $.grep(sitesWithData,function (siteId) {
            return siteId == self.siteId()
        });

        return results && results.length > 0
    });
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
            self.allSpecies.push(new SpeciesViewModel(species, fcConfig));
        }
        self.transients.species.reset();
    };

    self.remove = function (species) {
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
    self.transients.species = new SpeciesViewModel({}, fcConfig);
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
                return new SpeciesViewModel(obj, fcConfig);
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
