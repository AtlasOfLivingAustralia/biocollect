var ProjectActivitiesViewModel = function (pActivities, pActivityForms, projectId, sites){
    var self = this;
    self.pActivityForms = pActivityForms;
    self.sites = sites;

    self.projectId = ko.observable();
    self.projectActivities = ko.observableArray();

    self.sortBy = ko.observable();
    self.sortOrder = ko.observable();
    self.sortOptions = [{id: 'name', name:'Name'},{id: 'description', name:'Description'},{id:'transients.status', name:'Status'}];
    self.sortOrderOptions = [{id: 'asc', name:'Ascending'},{id:'desc', name:'Descending'}];
    self.sortBy.subscribe(function(by) {
        self.sort();
    });
    self.sortOrder.subscribe(function(order) {
        self.sort();
    });

    self.sort = function(){
        var by = self.sortBy();
        var order = self.sortOrder() == 'asc' ? '<' : '>';
        if(by && order){
            eval('self.projectActivities.sort(function(left, right) { return left.'+ by +'() == right.'+ by +'() ? 0 : (left.'+ by +'() '+ order +' right.'+ by +'() ? -1 : 1) });');
        }
    };

    self.reset = function(){
        $.each(self.projectActivities(), function(i, obj){
            obj.current(false);
        });
    };

    self.current = function (){
        var pActivity;
        $.each(self.projectActivities(), function(i, obj){
            if(obj.current()){
                pActivity = obj;
            }
        });
        return pActivity;
    };

    self.setCurrent = function(pActivity) {
        self.reset();
        pActivity.current(true);
    };

    self.loadProjectActivitiesVM = function(pActivities, pActivityForms, projectId, sites){
        self.projectId(projectId);
        self.sortBy("name");
        self.sortOrder("asc");
        $.map(pActivities, function (pActivity, i) {
            return self.projectActivities.push(new ProjectActivity(pActivity, pActivityForms, projectId, (i == 0), sites));
        });

        self.sort();
    };

    self.loadProjectActivitiesVM(pActivities, pActivityForms, projectId, sites);

};

var ProjectActivitiesListViewModel = function(pActivitiesVM){
    var self = $.extend(this, pActivitiesVM);
    self.filter = ko.observable(false);

    self.toggleFilter = function () {
        self.filter(!self.filter())
    };

    self.setCurrent = function(pActivity) {
        self.reset();
        pActivity.current(true);
    };
};

var ProjectActivitiesDataViewModel = function(pActivitiesVM){
    var self = $.extend(this, pActivitiesVM);

};

var ProjectActivitiesSettingsViewModel =  function(pActivitiesVM) {

    var self = $.extend(this, pActivitiesVM);

    self.speciesOptions =  [{id: 'ALL_SPECIES', name:'All species'},{id:'SINGLE_SPECIES', name:'Single species'}, {id:'GROUP_OF_SPECIES',name:'A selection or group of species'}];
    self.datesOptions = [60, 90, 120];
    self.formNames = ko.observableArray($.map(self.pActivityForms ? self.pActivityForms : [], function (obj, i) {
        return obj.name;
    }));

    self.addProjectActivity = function() {
        self.reset();
        self.projectActivities.push(new ProjectActivity([], self.pActivityForms, self.projectId(), true, self.sites));
        initialiseValidator();
        showAlert("Successfully added.", "alert-success",  'project-activities-result-placeholder');
    };

    self.saveAccess = function(access){
        var caller = "access";
        return self.genericUpdate(self.current().asJSON(caller), caller);
    };

    self.saveForm = function(){
        var caller = "form";
        return self.genericUpdate(self.current().asJSON(caller), caller);
    };

    self.saveInfo = function(){
        var caller = "info";
        return self.genericUpdate(self.current().asJSON(caller), caller);
    };

    self.saveSpecies = function(){
        var caller = "species";
        return self.genericUpdate(self.current().asJSON(caller), caller);
    };

    self.saveSites = function(){
        var caller = "sites";
        return self.genericUpdate(self.current().asJSON(caller), caller);
    };
    self.saveVisibility = function(){
        var caller = "visibility";
        return self.genericUpdate(self.current().asJSON(caller), caller);
    };

    self.deleteProjectActivity = function() {
        bootbox.confirm("Are you sure you want to delete the survey?", function (result) {
            if (result) {
                var that = this;

                var pActivity;
                $.each(self.projectActivities(), function(i, obj){
                    if(obj.current()){
                        obj.status("deleted");
                        pActivity = obj;
                    }
                });

                if(pActivity.projectActivityId() === undefined){
                    self.projectActivities.remove(pActivity);
                    if(self.projectActivities().length > 0){
                        self.projectActivities()[0].current(true);
                    }
                    showAlert("Successfully deleted.", "alert-success",  'project-activities-result-placeholder');
                }
                else{
                    self.genericUpdate(self.current().asJSON("info"), "info");
                }
            }
        });

    };

    self.genericUpdate = function(model, caller, message){
        if (!$('#project-activities-'+caller+'-validation').validationEngine('validate')){
            return false;
        }

        message = typeof message !== 'undefined' ? message : 'Successfully updated';
        var pActivity = self.current();
        var url = pActivity.projectActivityId() ? fcConfig.projectActivityUpdateUrl + "&id=" +
        pActivity.projectActivityId() : fcConfig.projectActivityCreateUrl;

        var divId = 'project-activities-'+ caller +'-result-placeholder';

        if(caller != "info" && pActivity.projectActivityId() === undefined){
            showAlert("Please save 'Survey Info' details before applying other constraints.", "alert-error",  divId);
            return;
        }

        $.ajax({
            url: url,
            type: 'POST',
            data: model,
            contentType: 'application/json',
            success: function (data) {

                if (data.error) {
                    showAlert("Error :" + data.text, "alert-error", divId);
                }
                else if(data.resp && data.resp.projectActivityId) {
                    $.each(self.projectActivities(), function(i, obj){
                        if(obj.current()){
                            obj.projectActivityId(data.resp.projectActivityId);
                        }
                    });
                    showAlert(message, "alert-success",  divId);
                }
                else{
                    if(pActivity.status() == "deleted"){
                        self.projectActivities.remove(pActivity);
                        if(self.projectActivities().length > 0){
                            self.projectActivities()[0].current(true);
                        }
                        showAlert(message, "alert-success",  divId);
                    }else{
                        showAlert(message, "alert-success",  divId);
                    }
                }
            },
            error: function (data) {
                var status = data.status;
                showAlert("Error : An unhandled error occurred" + data.status, "alert-error", divId);
            }
        });
    };
}

var pActivityInfo = function(o, selected){
    var self = this;
    if(!o) o = {};

    self.projectActivityId = ko.observable(o.projectActivityId);
    self.name = ko.observable(o.name ? o.name : "Survey name");
    self.description = ko.observable(o.description);
    self.status = ko.observable(o.status ? o.status : "active");
    self.startDate = ko.observable(o.startDate).extend({simpleDate:false});
    self.endDate = ko.observable(o.endDate).extend({simpleDate:false});
    self.commentsAllowed = ko.observable(o.commentsAllowed ? o.commentsAllowed : false);
    self.published = ko.observable(o.published ? o.published : false);
    self.logoUrl = ko.observable(fcConfig.imageLocation + "/no-image-2.png");
    self.current = ko.observable(selected);

    self.addActivity = function(){
    };

    self.transients = self.transients || {};
    var isBeforeToday = function(date) {
        return moment(date) < moment().startOf('day');
    };
    var calculateDurationInDays = function(startDate, endDate) {
        var start = moment(startDate);
        var end = moment(endDate);
        var days = end.diff(start, 'days');
        return days < 0? 0: days;
    };

    self.transients.daysSince = ko.pureComputed(function() {
        var startDate = self.startDate();
        if (!startDate) return -1;
        var start = moment(startDate);
        var today = moment();
        return today.diff(start, 'days');
    });

    self.transients.daysRemaining = ko.pureComputed(function() {
        var end = self.endDate();
        return end? isBeforeToday(end)? 0: calculateDurationInDays(undefined, end) + 1: -1;
    });
    self.transients.daysTotal = ko.pureComputed(function() {
        return self.startDate()? calculateDurationInDays(self.startDate(), self.endDate()): -1;
    });
    self.transients.status = ko.pureComputed(function(){
        var status = "";
        if(self.transients.daysSince() < 0 || (self.transients.daysSince() >= 0 && self.transients.daysRemaining() > 0)){
            status = "Active, Not yet started"
        }
        else if(self.transients.daysSince() >= 0 && self.transients.daysRemaining() < 0){
            status = "Active, In progress"
        }
        else if(self.transients.daysSince() >= 0 && self.transients.daysRemaining() == 0){
            status = "Inactive, Completed"
        }
        return status;
    });

};

var ProjectActivity = function (o, pActivityForms, projectId, selected, sites){
    if(!o) o = {};
    if(!pActivityForms) pActivityForms = [];
    if(!projectId) projectId = "";
    if(!selected) selected = false;
    if(!sites) sites = [];

    var self = $.extend(this, new pActivityInfo(o, selected));
    self.projectId = ko.observable(o.projectId ? o.projectId  : projectId);
    self.restrictRecordToSites = ko.observable(o.restrictRecordToSites);
    self.pActivityFormName = ko.observable(o.pActivityFormName);
    self.species = new SpeciesConstraintViewModel(o.species);
    self.visibility = new SurveyVisibilityViewModel(o.visibility);

    self.transients = self.transients || {};
    self.transients.siteSelectUrl = ko.observable(fcConfig.siteSelectUrl);
    self.transients.siteCreateUrl = ko.observable(fcConfig.siteCreateUrl);
    self.transients.siteUploadUrl = ko.observable(fcConfig.siteUploadUrl);

    self.transients.warning = ko.computed(function(){
        return self.projectActivityId() === undefined ? true : false;
    });
    self.sites = ko.observableArray($.map(sites ? sites : [], function (obj, i) {
        return new SiteList(obj, o.sites);
    }));

    var images = [];
    $.each(pActivityForms, function(index, form){
        if(form.name == self.pActivityFormName()){
            images = form.images ? form.images : [];
        }
    });

    self.pActivityFormImages =  ko.observableArray($.map(images, function (obj, i) {
        return new ImagesViewModel(obj);
    }));

    self.pActivityForms = pActivityForms;

    self.pActivityFormName.subscribe(function(formName) {
        self.pActivityFormImages.removeAll();
        $.each(self.pActivityForms, function(index, form){
            if(form.name == formName && form.images){
                for(var i =0; i < form.images.length; i++){
                    self.pActivityFormImages.push(new ImagesViewModel(form.images[i]));
                }
            }
        });
    });

    self.asJSON = function(by){
        var jsData;
        if(by == "access"){
            jsData = {};
            jsData.access =  ko.mapping.toJS(self.access, {ignore:[]});
        }
        else if(by == "form"){
            jsData = {};
            jsData.pActivityFormName = self.pActivityFormName();
        }
        else if(by == "info"){
            jsData = ko.mapping.toJS(self, {ignore:['current','pActivityForms','pActivityFormImages', 'access', 'species','sites','transients','endDate']});
            jsData.endDate = moment(self.endDate(), 'YYYY-MM-DDThh:mm:ssZ').isValid() ? self.endDate() : "";
        }
        else if(by == "species"){
            jsData = {};
            jsData.species = self.species.asJson();
        }
        else if(by == "sites"){
            jsData = {};
            var sites = [];
            $.each(self.sites(), function(index, site){
                if(site.added()){
                    sites.push(site.siteId());
                }
            });
            jsData.sites = sites;
            jsData.restrictRecordToSites = self.restrictRecordToSites();
        }
        else if(by == "visibility"){
            jsData = {};
            jsData.visibility = ko.mapping.toJS(self.visibility, {ignore:['transients']});
        }

        return JSON.stringify(jsData, function (key, value) { return value === undefined ? "" : value; });
    }
};

var SiteList = function(o, surveySites){
    var self = this;
    if(!o) o = {};
    if(!surveySites) surveySites = {};

    self.siteId = ko.observable(o.siteId);
    self.name = ko.observable(o.name);
    self.added = ko.observable(false);
    self.siteUrl = ko.observable(fcConfig.siteViewUrl + "/" + self.siteId())

    self.addSite = function(){
        self.added(true);
    };
    self.removeSite = function(){
        self.added(false);
    };

    self.load = function(surveySites){
        $.each(surveySites, function( index, siteId ) {
            if(siteId == self.siteId()){
                self.added(true);
            }
        });
    };
    self.load(surveySites);

};

var SpeciesConstraintViewModel = function (o){
    var self = this;
    if(!o) o = {};

    self.type = ko.observable(o.type);
    self.allSpeciesLists  = new SpeciesListsViewModel();
    self.singleSpecies = new Species(o.singleSpecies);
    self.speciesLists = ko.observableArray($.map(o.speciesLists ? o.speciesLists : [], function (obj, i) {
        return new SpeciesList(obj);
    }));
    self.newSpeciesLists = new SpeciesList();

    self.transients = {};
    self.transients.bioProfileUrl =  ko.computed(function (){
        return  fcConfig.bieUrl + '/species/' + self.singleSpecies.guid();
    });

    self.transients.bioSearch = ko.observable(fcConfig.speciesSearchUrl);
    self.transients.allowedListTypes = [
    {id:'SPECIES_CHARACTERS', name:'SPECIES_CHARACTERS'},
    {id:'CONSERVATION_LIST', name:'CONSERVATION_LIST'},
    {id:'SENSITIVE_LIST', name:'SENSITIVE_LIST'},
    {id:'LOCAL_LIST', name:'LOCAL_LIST'},
    {id:'COMMON_TRAIT', name:'COMMON_TRAIT'},
    {id:'COMMON_HABITAT', name:'COMMON_HABITAT'},
    {id:'TEST', name:'TEST'},
    {id:'OTHER', name:'OTHER'}];

    self.transients.showAddSpeciesLists = ko.observable(false);
    self.transients.showExistingSpeciesLists = ko.observable(false);
    self.transients.toggleShowAddSpeciesLists = function (){
        self.transients.showAddSpeciesLists(!self.transients.showAddSpeciesLists());
    };
    self.transients.toggleShowExistingSpeciesLists = function (){
        self.transients.showExistingSpeciesLists(!self.transients.showExistingSpeciesLists());
        if(self.transients.showExistingSpeciesLists()){
            self.allSpeciesLists.loadAllSpeciesLists();
        }
    };

    self.addSpeciesLists = function (lists){
        lists.transients.check(true);
        self.speciesLists.push(lists);
    };
    self.removeSpeciesLists = function (lists){
        self.speciesLists.remove(lists);
    };
    self.groupInfoVisible = ko.computed(function() {
        return (self.type() == "GROUP_OF_SPECIES");
    });
    self.singleInfoVisible = ko.computed(function() {
        return (self.type() == "SINGLE_SPECIES");
    });
    self.type.subscribe(function(type) {
        if(self.type() == "SINGLE_SPECIES"){
        }else if(self.type() == "GROUP_OF_SPECIES"){
        }
    });

    self.asJson = function(){
        var jsData = {};
        if(self.type() == "ALL_SPECIES"){
            jsData.type = self.type();
        }
        else if(self.type() == "SINGLE_SPECIES"){
            jsData.type = self.type();
            jsData.singleSpecies = ko.mapping.toJS(self.singleSpecies, {ignore:['transients']});
        }
        else if(self.type() == "GROUP_OF_SPECIES"){
            jsData.type = self.type();
            jsData.speciesLists = ko.mapping.toJS(self.speciesLists, {ignore:['listType','fullName','itemCount', 'description', 'listType','allSpecies','transients']});
        }
        return jsData;
    };

    self.saveNewSpeciesName = function(){
        if (!$('#project-activities-species-validation').validationEngine('validate')){
            return;
        }

        var jsData = {};
        jsData.listName = self.newSpeciesLists.listName();
        jsData.listType = self.newSpeciesLists.listType();
        jsData.description = self.newSpeciesLists.description();
        jsData.listItems = "";

        var lists = ko.mapping.toJS(self.newSpeciesLists);
        $.each(lists.allSpecies, function( index, species ) {
            if(index == 0){
                jsData.listItems = species.name;
            }else{
                jsData.listItems =  jsData.listItems + "," + species.name;
            }
        });
        // Add bulk species names.
        if(jsData.listItems == "") {
            jsData.listItems = self.newSpeciesLists.transients.bulkSpeciesNames();
        }else{
            jsData.listItems = jsData.listItems + "," + self.newSpeciesLists.transients.bulkSpeciesNames();
        }

        var model = JSON.stringify(jsData, function (key, value) { return value === undefined ? "" : value; });
        var divId = 'project-activities-species-result-placeholder';
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
                    showAlert("Successfully added the new species list - "+self.newSpeciesLists.listName() +" ("+ data.id+")", "alert-success", divId);
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

var SpeciesListsViewModel = function(o){
    var self = this;
    if(!o) o = {};

    self.allSpeciesListsToSelect = ko.observableArray();
    self.offset = ko.observable(0);
    self.max = ko.observable(100);
    self.listCount = ko.observable();
    self.isNext = ko.computed(function() {
        var status = false;
        if(self.listCount() > 0){
            var maxOffset = self.listCount() / self.max();
            if(self.offset() < Math.ceil(maxOffset)-1) {
                status = true;
            }
        }
        return status;
    });

    self.isPrevious = ko.computed(function() {
        return (self.offset() > 0);
    });

    self.next = function(){
        if(self.listCount() > 0){
            var maxOffset = self.listCount() / self.max();
            if(self.offset() < Math.ceil(maxOffset)-1) {
                self.offset(self.offset()+1);
                self.loadAllSpeciesLists();
            }
        }
    };

    self.previous = function(){
        if(self.offset() > 0){
            var newOffset = self.offset() - 1;
            self.offset(newOffset);
            self.loadAllSpeciesLists();
        }
    };

    self.loadAllSpeciesLists = function (){
        var url = fcConfig.speciesListUrl + "?sort=listName&offset="+self.offset()+"&max="+self.max();
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

var SpeciesList = function(o){
    var self = this;
    if(!o) o = {};

    self.listName = ko.observable(o.listName);
    self.dataResourceUid = ko.observable(o.dataResourceUid);

    self.listType = ko.observable(o.listType);
    self.fullName = ko.observable(o.fullName);
    self.itemCount = ko.observable(o.itemCount);

    // Only used for new species.
    self.description = ko.observable(o.description);
    self.listType = ko.observable(o.listType);
    self.allSpecies = ko.observableArray();
    self.addNewSpeciesName = function(){
        self.allSpecies.push(new Species());
    };
    self.removeNewSpeciesName = function(species){
        self.allSpecies.remove(species);
    };

    self.transients = {};
    self.transients.bulkSpeciesNames = ko.observable(o.bulkSpeciesNames);
    self.transients.url  = ko.observable(fcConfig.speciesListsServerUrl + "/speciesListItem/list/" + o.dataResourceUid);
    self.transients.check = ko.observable(false);
};

var Species = function(o){
    var self = this;
    if(!o) o = {};
    self.name = ko.observable(o.name);
    self.guid = ko.observable(o.guid);

    self.transients = {};
    self.transients.name = ko.observable(o.name);
    self.transients.guid = ko.observable(o.guid);

    self.focusLost = function(event) {
        self.name(self.transients.name());
        self.guid(self.transients.guid());
    };

    self.transients.guid.subscribe(function(newValue) {
        self.name(self.transients.name());
        self.guid(self.transients.guid());
    });
};

var ImagesViewModel = function(image){
    var self = this;
    if(!image) image = {};

    self.thumbnail = ko.observable(image.thumbnail);
    self.url = ko.observable(image.url);
};

var SurveyVisibilityViewModel = function(o){
    var self = this;
    if(!o) o = {};
    self.constraint = ko.observable(o.constraint ? o.constraint : 'PUBLIC');   // 'PUBLIC', 'PUBLIC_WITH_SET_DATE', 'EMBARGO'
    self.setDate = ko.observable(o.setDate ? o.setDate : 60);     // 60, 90, 120 days
    self.embargoDate = ko.observable(o.embargoDate).extend({simpleDate:false});
};

function initialiseValidator() {
    var tabs = ['info','species','form', 'access','visibility'];
    $.each(tabs, function( index, label ) {
        $('#project-activities-'+ label +'-validation').validationEngine();
    });
};
