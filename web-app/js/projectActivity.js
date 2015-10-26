var ProjectActivitiesViewModel = function (pActivities, pActivityForms, projectId, sites, user) {
    var self = this;
    self.pActivityForms = pActivityForms;
    self.sites = sites;

    self.projectId = ko.observable();
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
        self.reset();
        pActivity.current(true);
    };

    self.loadProjectActivitiesVM = function (pActivities, pActivityForms, projectId, sites) {
        self.projectId(projectId);
        self.sortBy("name");
        self.sortOrder("asc");
        $.map(pActivities, function (pActivity, i) {
            return self.projectActivities.push(new ProjectActivity(pActivity, pActivityForms, projectId, (i == 0), sites));
        });

        self.sort();
    };

    self.userCanEdit = function (pActivity) {
        return pActivity.publicAccess() || (user && Object.keys(user).length > 0 && (user.isEditor || user.isAdmin));
    };

    self.loadProjectActivitiesVM(pActivities, pActivityForms, projectId, sites);

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
    self.placeHolder = placeHolder;
    self.speciesOptions =  [{id: 'ALL_SPECIES', name:'All species'},{id:'SINGLE_SPECIES', name:'Single species'}, {id:'GROUP_OF_SPECIES',name:'A selection or group of species'}];
    self.datesOptions = [60, 90, 120, 180];
    self.formNames = ko.observableArray($.map(self.pActivityForms ? self.pActivityForms : [], function (obj, i) {
        return obj.name;
    }));

    self.addProjectActivity = function () {
        self.reset();
        self.projectActivities.push(new ProjectActivity([], self.pActivityForms, self.projectId(), true, self.sites));
        initialiseValidator();
        self.refreshSurveyStatus();
        showAlert("Successfully added.", "alert-success", self.placeHolder);
    };

    self.updateStatus = function () {
        var current = self.current();
        var jsData = current.asJSAll();

        if (jsData.published) {
            return self.unpublish();
        }
        if (jsData.name && jsData.description && jsData.startDate &&
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

    self.saveSites = function () {
        return self.genericUpdate("sites");
    };

    self.deleteProjectActivity = function () {
        bootbox.confirm("Are you sure you want to delete the survey? Any survey forms that have been submitted will also be deleted.", function (result) {
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
        } else if(caller == "info" || caller == "visibility"){
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
                    showAlert("Successfully published", "alert-success", self.placeHolder);
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

        if(isDataAvailable(pActivity)){
            return;
        }
        var url =  fcConfig.projectActivityUpdateUrl + "/" + pActivity.projectActivityId();
        $.ajax({
            url: url,
            type: 'POST',
            data: {published: false},
            contentType: 'application/json',
            success: function (data) {
                var result = data.resp;
                if (result && result.message == 'updated') {
                    var found = ko.utils.arrayFirst(self.projectActivities(), function(obj) {
                        return obj.projectActivityId() == pActivity.projectActivityId();
                    });
                    found ? found.published(false) : '';
                    showAlert("Successfully unpublished", "alert-success", self.placeHolder);
                } else {
                    showAlert(data.error ? data.error : "Error unpublished the survey", "alert-error", self.placeHolder);
                }
            },
            error: function (data) {
                showAlert("Error unpublished the survey -" + data.status, "alert-error", self.placeHolder);
            }
        });
    };

    self.genericUpdate = function (caller) {
        if (!$('#project-activities-' + caller + '-validation').validationEngine('validate')) {
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

    self.refreshSurveyStatus();
};

var ProjectActivity = function (o, pActivityForms, projectId, selected, sites) {
    if (!o) o = {};
    if (!pActivityForms) pActivityForms = [];
    if (!projectId) projectId = "";
    if (!selected) selected = false;
    if (!sites) sites = [];

    var self = $.extend(this, new pActivityInfo(o, selected));
    self.projectId = ko.observable(o.projectId ? o.projectId : projectId);
    self.restrictRecordToSites = ko.observable(o.restrictRecordToSites);
    self.pActivityFormName = ko.observable(o.pActivityFormName);
    self.species = new SpeciesConstraintViewModel(o.species);
    self.visibility = new SurveyVisibilityViewModel(o.visibility);

    self.transients = self.transients || {};
    self.transients.siteSelectUrl = ko.observable(fcConfig.siteSelectUrl);
    self.transients.siteCreateUrl = ko.observable(fcConfig.siteCreateUrl);
    self.transients.siteUploadUrl = ko.observable(fcConfig.siteUploadUrl);

    self.transients.warning = ko.computed(function () {
        return self.projectActivityId() === undefined ? true : false;
    });


    self.sites = ko.observableArray();
    self.loadSites = function (projectSites, surveySites) {
        $.map(projectSites ? projectSites : [], function (obj, i) {
            var defaultSites = [];
            surveySites && surveySites.length > 0 ? $.merge(defaultSites, surveySites) : defaultSites.push(obj.siteId);
            self.sites.push(new SiteList(obj, defaultSites));
        });
    };
    self.loadSites(sites, o.sites);

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

    self.asJSAll = function () {
        var jsData = $.extend({},
            self.asJS("info"),
            self.asJS("access"),
            self.asJS("form"),
            self.asJS("species"),
            self.asJS("visibility"),
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
    };
    self.transients.toggleShowExistingSpeciesLists = function () {
        self.transients.showExistingSpeciesLists(!self.transients.showExistingSpeciesLists());
        if (self.transients.showExistingSpeciesLists()) {
            self.allSpeciesLists.loadAllSpeciesLists();
        }
    };

    self.addSpeciesLists = function (lists) {
        lists.transients.check(true);
        self.speciesLists.push(lists);
    };
    self.removeSpeciesLists = function (lists) {
        self.speciesLists.remove(lists);
    };
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

var SurveyVisibilityViewModel = function (o) {
    var self = this;
    if (!o) o = {};
    self.constraint = ko.observable(o.constraint ? o.constraint : 'PUBLIC');   // 'PUBLIC', 'PUBLIC_WITH_SET_DATE', 'EMBARGO'
    self.setDate = ko.observable(o.setDate ? o.setDate : 60);     // 60, 90, 120 days
    self.embargoDate = ko.observable(o.embargoDate).extend({simpleDate: false});
};

function initialiseValidator() {
    var tabs = ['info', 'species', 'form', 'access', 'visibility'];
    $.each(tabs, function (index, label) {
        $('#project-activities-' + label + '-validation').validationEngine();
    });
};
