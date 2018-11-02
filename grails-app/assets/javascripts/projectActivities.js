var ProjectActivitiesViewModel = function (params, projectViewModel) {
    var self = this;
    var pActivities = params.pActivities;
    var user = params.user;

    self.projectViewModel = projectViewModel;

    self.organisationName = params.organisationName;
    self.pActivityForms = params.pActivityForms;
    self.sites = params.sites;
    self.projectStartDate = params.projectStartDate;
    self.project = params.project;

    self.projectId = ko.observable(params.projectId);

    /**
     * Differentiate a site for project from sites for survey
     */
    self.markProjectAreaSite = function(){
        var ps_Id = self.project.projectSiteId;
        _.each(self.sites, function(site){
            if (site.siteId == ps_Id){
                site.isProjectArea = true;
            }else{
                site.isProjectArea = false;
            }
        })
    };

    self.markProjectAreaSite();

    self.projectActivities = ko.observableArray();

    self.currentUser = user;
    self.vocabList = params.vocabList;
    self.projectArea = params.projectArea;
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
        var by = self.sortBy() || '';
        by = by.split('.');
        var order = self.sortOrder() == 'asc';
        if (by != '' && order != undefined) {
            self.projectActivities.sort(function(left, right) {
                for (var i=0; i < by.length; i++) {
                    left = left[by[i]];
                    right = right[by[i]];
                }

                if( order ) {
                    return left() > right();
                } else {
                    return left() <= right();
                }
            });
        }
    };

    self.reset = function () {
        $.each(self.projectActivities(), function (i, obj) {
            obj.current(false);
            obj.transients.subscribeOrDisposePActivityFormName(false);
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
        pActivity.transients.subscribeOrDisposePActivityFormName(true);
        self.isSurveySelected(false);
    };

    self.loadProjectActivities = function (pActivities) {
        self.sortBy("name");
        self.sortOrder("asc");
        $.map(pActivities, function (pActivity, i) {
            var args = {
                pActivity: pActivity,
                projectId: self.projectId(),
                selected: (i == 0),
                sites: self.sites,
                organisationName: self.organisationName,
                startDate: self.projectStartDate,
                project: self.project,
                user: self.user/*,
                 vocabList: params.vocabList,
                 projectArea: params.projectArea*/
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
        pActivity.transients.subscribeOrDisposePActivityFormName(true);
    };
};

var ProjectActivitiesDataViewModel = function (pActivitiesVM) {
    var self = $.extend(this, pActivitiesVM);
};


var ProjectActivitiesSettingsViewModel = function (pActivitiesVM, placeHolder) {

    var self = $.extend(this, pActivitiesVM);
    var surveyInfoTab = '#survey-info-tab';
    var project = pActivitiesVM.project;
    var errorMsgSurveyInfo = "Failed to save survey. Are you sure all mandatory fields in 'Survey Info' tab is filled?";
    self.placeHolder = placeHolder;
    self.datesOptions = [60, 90, 120, 180];
    self.formNames = ko.observableArray($.map(self.pActivityForms ? self.pActivityForms : [], function (obj, i) {
        return obj.name;
    }));

    self.addProjectActivity = function () {
        self.reset();
        var args = {
            pActivity: [],
            projectId: self.projectId(),
            selected: true,
            sites: self.sites,
            organisationName: self.organisationName,
            project: project,
            startDate: self.projectStartDate
        };
        var survey = new ProjectActivity(args)
        self.projectActivities.push(survey);
        survey.transients.subscribeOrDisposePActivityFormName(true);
        initialiseValidator();
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
        if(self.current().areSpeciesValid()) {
            self.genericUpdate("species");
        } else {
            showAlert("All species field(s) must be configured before saving.", "alert-error", self.placeHolder);
        }
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
                    self.remove();
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
        } else {
            return true;
        }
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

    self.updateProjectResources = function (data) {
        var doc = data.methodDoc;
        if (doc && doc.content && doc.content.documentId && doc.content.url) {
            $.each(self.projectActivities(), function (i, obj) {
                if (obj.current()) {
                    var methodDocument = obj.findDocumentByRole(obj.documents(), 'methodDoc');
                    if (methodDocument) {
                        methodDocument.documentId = doc.content.documentId;
                        methodDocument.url = doc.content.url;
                        self.projectViewModel.updateMethodDocs(methodDocument);
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
                    showAlert(errorMsgSurveyInfo, "alert-error", self.placeHolder);
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
                    self.updateProjectResources(data);
                    showAlert("Successfully updated ", "alert-success", self.placeHolder);
                } else {
                    showAlert(errorMsgSurveyInfo, "alert-error", self.placeHolder);
                }
            },
            error: function (data) {
                showAlert("Error updating the survey -" + data.status, "alert-error", self.placeHolder);
            }
        });
    };

    self.remove = function(){
        var pActivity = self.current();
        var url =  fcConfig.projectActivityDeleteUrl + "/" + pActivity.projectActivityId();
        $.ajax({
            url: url,
            type: 'DELETE',
            success: function (data) {
                if (data.error) {
                    showAlert("An error happened while deleting the survey. The error might have happened " +
                        "because some mandatory fields in 'Survey Info' tab are empty. Please fill them and " +
                        "save the survey before trying to delete again.", "alert-error", self.placeHolder);
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
                    showAlert("Successfully published, reloading page now.", "alert-success", self.placeHolder);
                    setTimeout(function() {
                        saveTabSelection('ul-main-project', 'activities-tab');
                        window.location.reload(true);
                    }, 1000);
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

        bootbox.confirm("Are you sure you want to unpublish this survey?", function (result) {
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
                            showAlert (
                                "An error happened while un-publishing the survey. The error might have happened " +
                                "because some mandatory fields in 'Survey Info' tab are empty. Please fill them and " +
                                "save the survey before trying to un-publish again.", "alert-error", self.placeHolder
                            );
                        }
                    },
                    error: function (data) {
                        showAlert(errorMsgSurveyInfo, "alert-error", self.placeHolder);
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

    /**
     * get sites with data for all project activities in this project.
     */
    self.getSitesWithDataForProjectActivitiesInProject = function() {
        $.each(self.projectActivities(), function (i, obj) {
            obj.getSitesWithData();
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

    self.getSitesWithDataForProjectActivitiesInProject();
};

