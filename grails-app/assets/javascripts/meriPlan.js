/*
 Script for handling Project MERI Plan
 */

function MERIPlan(project, themes, key) {
    var self = this;
    if(!project.custom){ project.custom = {};}
    if(!project.custom.details){project.custom.details = {};}

    if (key) {
        var savedProjectCustomDetails = amplify.store(key);
        if (savedProjectCustomDetails) {
            var restored = JSON.parse(savedProjectCustomDetails);
            if (restored.custom) {
                $('#restoredData').show();
                project.custom.details = restored.custom.details;
            }
        }
    }

    self.details = new DetailsViewModel(project.custom.details, getBudgetHeaders(project));
    self.detailsLastUpdated = ko.observable(project.custom.details.lastUpdated).extend({simpleDate: true});
    self.detailsLastUpdatedDisplayName = ko.observable(project.custom.details.lastUpdatedDisplayName || '');
    self.isProjectDetailsSaved = ko.computed (function (){
        return (project['custom']['details'].status == 'active');
    });
    self.isProjectDetailsLocked = ko.computed (function (){
        return false; // Always editable, at least for now.
    });

    self.projectThemes =  $.map(themes, function(theme, i) { return theme.name; });
    self.projectThemes.push("Milestone");
    self.projectThemes.push("Variation");
    self.projectThemes.push("MERI & Admin");
    self.projectThemes.push("Others");

    self.likelihoodOptions = ['Almost Certain', 'Likely', 'Possible', 'Unlikely', 'Remote'];
    self.consequenceOptions = ['Insignificant', 'Minor', 'Moderate', 'Major', 'Extreme'];
    self.ratingOptions = ['High', 'Significant', 'Medium', 'Low'];
    self.obligationOptions = ['Yes', 'No'];
    self.threatOptions = ['Blow-out in cost of project materials', 'Changes to regional boundaries affecting the project area', 'Co-investor withdrawal / investment reduction',
        'Lack of delivery partner capacity', 'Lack of delivery partner / landholder interest in project activities', 'Organisational restructure / loss of corporate knowledge', 'Organisational risk (strategic, operational, resourcing and project levels)',
        'Seasonal conditions (eg. drought, flood, etc.)', 'Timeliness of project approvals processes',
        'Workplace health & safety (eg. Project staff and / or delivery partner injury or death)', 'Land use Conflict'];
    self.organisations =['Academic/research institution', 'Australian Government Department', 'Commercial entity', 'Community group',
        'Farm/Fishing Business', 'If other, enter type', 'Indigenous Organisation', 'Individual', 'Local Government', 'Other', 'Primary Industry group',
        'School', 'State Government Organisation', 'Trust'];
    self.protectedNaturalAssests =[ 'Natural/Cultural assets managed','Threatened Species', 'Threatened Ecological Communities',
        'Migratory Species', 'Ramsar Wetland', 'World Heritage area', 'Community awareness/participation in NRM', 'Indigenous Cultural Values',
        'Indigenous Ecological Knowledge', 'Remnant Vegetation', 'Aquatic and Coastal systems including wetlands', 'Not Applicable'];

    self.addBudget = function(){
        self.details.budget.rows.push (new BudgetRowViewModel({},getBudgetHeaders(project)));
    };
    self.removeBudget = function(budget){
        self.details.budget.rows.remove(budget);
    };

    self.addObjectives = function(){
        self.details.objectives.rows.push(new GenericRowViewModel());
    };
    self.addOutcome = function(){
        self.details.objectives.rows1.push(new OutcomeRowViewModel());
    };
    self.removeObjectives = function(row){
        self.details.objectives.rows.remove(row);
    };
    self.removeObjectivesOutcome = function(row){
        self.details.objectives.rows1.remove(row);
    };
    self.addNationalAndRegionalPriorities = function(){
        self.details.priorities.rows.push(new GenericRowViewModel());
    };
    self.removeNationalAndRegionalPriorities = function(row){
        self.details.priorities.rows.remove(row);
    };

    self.addKEQ = function(){
        self.details.keq.rows.push(new GenericRowViewModel());
    };
    self.removeKEQ = function(keq){
        self.details.keq.rows.remove(keq);
    };

    self.mediaOptions = [{id:"yes",name:"Yes"},{id:"no",name:"No"}];

    self.addEvents = function(){
        self.details.events.push(new EventsRowViewModel());
    };
    self.removeEvents = function(event){
        self.details.events.remove(event);
    };

    self.addPartnership = function(){
        self.details.partnership.rows.push (new GenericRowViewModel());
    };
    self.removePartnership = function(partnership){
        self.details.partnership.rows.remove(partnership);
    };

    self.addOutcomeProgress = function(outcomeProgress) {
        self.details.outcomeProgress.push(new OutcomeProgressViewModel(outcomeProgress));
    };
    self.removeOutcomeProgress = function(outcomeProgress) {
        self.details.outcomeProgress.remove(outcomeProgress);
    };
};

function DetailsViewModel(projectDetails, period) {
    var self = this;
    self.status = ko.observable(projectDetails.status);
    self.obligations = ko.observable(projectDetails.obligations);
    self.policies = ko.observable(projectDetails.policies);
    self.caseStudy = ko.observable(projectDetails.caseStudy ? projectDetails.caseStudy : false);
    self.keq = new GenericViewModel(projectDetails.keq);
    self.objectives = new ObjectiveViewModel(projectDetails.objectives);
    self.priorities = new GenericViewModel(projectDetails.priorities);
    self.implementation = new ImplementationViewModel(projectDetails.implementation);
    self.partnership = new GenericViewModel(projectDetails.partnership);
    self.lastUpdated = ko.observable(projectDetails.lastUpdated ? projectDetails.lastUpdated : moment().format());
    self.budget = new BudgetViewModel(projectDetails.budget, period);
    self.outcomeProgress = ko.observableArray($.map(projectDetails.outcomeProgress || [], function(outcomeProgress) { return new OutcomeProgressViewModel(outcomeProgress); }));
    $.extend(self, new Risks(projectDetails.risks));
    self.issues = new IssuesViewModel(projectDetails.issues);

    var row = [];
    projectDetails.events ? row = projectDetails.events : row.push(ko.mapping.toJS(new EventsRowViewModel()));
    self.events = ko.observableArray($.map(row, function (obj, i) {
        return new EventsRowViewModel(obj);
    }));

    self.modelAsJSON = function() {
        var tmp = {};
        tmp['details'] =  ko.mapping.toJS(self);
        var jsData = {"custom": tmp};
        var json = JSON.stringify(jsData, function (key, value) {
            return value === undefined ? "" : value;
        });
        return json;
    };
};

function GenericViewModel(o) {
    var self = this;
    if(!o) o = {};
    self.description = ko.observable(o.description);
    var row = [];
    o.rows ? row = o.rows : row.push(ko.mapping.toJS(new GenericRowViewModel()));
    self.rows = ko.observableArray($.map(row, function (obj,i) {
        return new GenericRowViewModel(obj);
    }));
};

function GenericRowViewModel(o) {
    var self = this;
    if(!o) o = {};
    self.data1 = ko.observable(o.data1);
    self.data2 = ko.observable(o.data2);
    self.data3 = ko.observable(o.data3);
};

function ObjectiveViewModel(o) {
    var self = this;
    if(!o) o = {};

    var row = [];
    o.rows ? row = o.rows : row.push(ko.mapping.toJS(new GenericRowViewModel()));
    self.rows = ko.observableArray($.map(row, function (obj, i) {
        return new GenericRowViewModel(obj);
    }));

    var row1 = [];
    o.rows1 ? row1 = o.rows1 : row1.push(ko.mapping.toJS(new OutcomeRowViewModel()));
    self.rows1 = ko.observableArray($.map(row1, function (obj, i) {
        return new OutcomeRowViewModel(obj);
    }));
};


function ImplementationViewModel(o) {
    var self = this;
    if(!o) o = {};
    self.description = ko.observable(o.description);
};

function EventsRowViewModel(o) {
    var self = this;
    if(!o) o = {};
    self.name = ko.observable(o.name);
    self.description = ko.observable(o.description);
    self.media = ko.observable(o.media);
    self.type = ko.observable(o.type || '');
    self.funding = ko.observable(o.funding).extend({numericString:0}).extend({currency:true});
    self.scheduledDate = ko.observable(o.scheduledDate).extend({simpleDate: false});
    self.grantAnnouncementDate = ko.observable(o.grantAnnouncementDate);
};

function OutcomeRowViewModel(o) {
    var self = this;
    if(!o) o = {};
    self.baseline = ko.observable(o.baseline);
    self.target = ko.observable(o.target);
    if(!o.assets) o.assets = [];
    self.assets = ko.observableArray(o.assets);
};

function OutcomeProgressViewModel(o) {
    var self = this;
    if(!o) o = {};
    self.progress = ko.observable(o.progress);
    self.date = ko.observable(o.date).extend({simpleDate:false});
    self.type = ko.observable(o.type);
    self.type.options = ['Progress Report', 'Interim', 'Final'];
};

function BudgetViewModel(o, period){
    var self = this;
    if(!o) o = {};

    self.overallTotal = ko.observable(0.0);

    var headerArr = [];
    for(i = 0; i < period.length; i++){
        headerArr.push({"data":period[i]});
    }
    self.headers = ko.observableArray(headerArr);

    var row = [];
    o.rows ? row = o.rows : row.push(ko.mapping.toJS(new BudgetRowViewModel({},period)));
    self.rows = ko.observableArray($.map(row, function (obj, i) {
        // Headers don't match with previously stored headers, adjust rows accordingly.
        if(o.headers && period && o.headers.length != period.length) {
            var updatedRow = [];
            for(i = 0; i < period.length; i++) {
                var index = -1;

                for(j = 0; j < o.headers.length; j++) {
                    if(period[i] == o.headers[j].data) {
                        index = j;
                        break;
                    }
                }
                updatedRow.push(index != -1 ? obj.costs[index] : 0.0)
                index = -1;
            }
            obj.costs = updatedRow;
        }

        return new BudgetRowViewModel(obj,period);
    }));

    self.overallTotal = ko.computed(function (){
        var total = 0.0;
        ko.utils.arrayForEach(this.rows(), function(row) {
            if(row.rowTotal()){
                total += parseFloat(row.rowTotal());
            }
        });
        return total;
    },this).extend({currency:{}});

    var allBudgetTotal = [];
    for(i = 0; i < period.length; i++){
        allBudgetTotal.push(new BudgetTotalViewModel(this.rows, i));
    }
    self.columnTotal = ko.observableArray(allBudgetTotal);
};

function BudgetTotalViewModel (rows, index){
    var self = this;
    self.data =  ko.computed(function (){
        var total = 0.0;
        ko.utils.arrayForEach(rows(), function(row) {
            if(row.costs()[index]){
                total += parseFloat(row.costs()[index].dollar());
            }
        });
        return total;
    },this).extend({currency:{}});
};


function BudgetRowViewModel(o,period) {
    var self = this;
    if(!o) o = {};
    self.shortLabel = ko.observable(o.shortLabel);
    self.description = ko.observable(o.description);
    self.dueDate = ko.observable(o.dueDate).extend({simpleDate:false});
    self.paymentStatus = ko.observable(o.paymentStatus);
    self.paymentStatus.options = ['', "P", "C"];
    self.paymentNumber = ko.observable(o.paymentNumber);
    self.fundingSource = ko.observable(o.fundingSource);


    var arr = [];
    for(i = 0 ; i < period.length; i++)
        arr.push(ko.mapping.toJS(new FloatViewModel()));

    //Incase if timeline is generated.
    if(o.costs && o.costs.length != arr.length) {
        o.costs = arr;
    }
    o.costs ? arr = o.costs : arr;
    self.costs = ko.observableArray($.map(arr, function (obj, i) {
        return new FloatViewModel(obj);
    }));

    self.rowTotal = ko.computed(function (){
        var total = 0.0;
        ko.utils.arrayForEach(this.costs(), function(cost) {
            if(cost.dollar())
                total += parseFloat(cost.dollar());
        });
        return total;
    },this).extend({currency:{}});
};

function FloatViewModel(o){
    var self = this;
    if(!o) o = {};
    self.dollar = ko.observable(o.dollar ? o.dollar : 0.0).extend({numericString:2}).extend({currency:{}});
};

function limitText(field, maxChar){
    $(field).attr('maxlength',maxChar);
}

function getBudgetHeaders(project) {
    var headers = [];
    var startYr = moment(project.plannedStartDate).format('YYYY');
    var endYr = moment(project.plannedEndDate).format('YYYY');;
    var startMonth = moment(project.plannedStartDate).format('M');
    var endMonth = moment(project.plannedEndDate).format('M');

    //Is startYr is between jan to june?
    if(startMonth >= 1 &&  startMonth <= 6 ){
        startYr--;
    }

    //Is the end year is between july to dec?
    if(endMonth >= 7 &&  endMonth <= 12 ){
        endYr++;
    }

    var count = endYr - startYr;
    for (i = 0; i < count; i++){
        headers.push(startYr + '/' + ++startYr);
    }
    return headers;

}

function WorksProjectViewModel(project, isEditor, organisations, options) {
    var self = this;

    var defaults = {
        saveUrl: fcConfig.saveMeriPlanUrl,
        meriPlanSelector: '#edit-meri-plan',
        saveToolbarSelector: '#project-details-save',
        floatingSaveSelector: '#floating-save',
        storageKey: 'meri-plan-'+project.projectId,
        autoSaveIntervalInSeconds:60,
        restoredDataWarningSelector:'#restoredData',
        resultsMessageId:'save-details-result-placeholder',
        timeoutMessageSelector:'#timeoutMessage',
        errorMessage:"Failed to save Project Plan: ",
        successMessage: 'Project Plan saved',
        preventNavigationIfDirty:true,
        defaultDirtyFlag:ko.dirtyFlag
    };
    var config = $.extend(defaults, options);

    $.extend(self, new ProjectViewModel(project, isEditor, organisations));
    self.mapConfiguration = new MapConfiguration(project.mapConfiguration, project);
    var themes = [];
    $.extend(self, new MERIPlan(project, themes, config.storageKey));

    $(config.meriPlanSelector).validationEngine();

    autoSaveModel(self.details, config.saveUrl, config);
    configureFloatingSave(self.details.dirtyFlag, {floatingSaveSelector:config.floatingSaveSelector, saveButtonSelector:config.saveToolbarSelector});

    // Save MERI plan
    self.saveMeriPlan = function(){
        if ($(config.meriPlanSelector).validationEngine('validate', {
                'showPrompts':true
            })) {
            self.details.status('active');
            var now = moment().toDate().toISOStringNoMillis();
            self.details.lastUpdated(now);
            self.detailsLastUpdated(now);
            self.details.saveWithErrorDetection(function(result) {
                self.detailsLastUpdatedDisplayName((result.resp && result.resp.lastUpdatedByDisplayName) || '');
            }, function(result) {
                bootbox.alert("An error occurred while updating the plan.");
            });
        } 
    };

    self.saveMapConfig = function () {
        var data = {
            mapConfiguration: self.mapConfiguration.toJS()
        };

        self.mapConfiguration.transients.loading(true);
        return $.ajax({
            url: fcConfig.projectUpdateUrl,
            method: 'post',
            data: JSON.stringify(data),
            contentType: 'application/json'
        }).done(function () {
            self.mapConfiguration.transients.loading(false);
        })
    };

    self.cancelMeriPlanEdits = function() {
        self.details.cancelAutosave();

        document.location.reload(true);
    };

    self.saveSitesBeforeRedirect = function (redirectUrl) {
        var promise = self.saveMapConfig();
        window.location.href = redirectUrl;
    };

    self.redirectToCreate = function () {
        self.saveSitesBeforeRedirect(fcConfig.siteCreateUrl);
    };

    self.redirectToSelect = function () {
        self.saveSitesBeforeRedirect(fcConfig.siteSelectUrl);
    };

    self.redirectToUpload = function () {
        self.saveSitesBeforeRedirect(fcConfig.siteUploadUrl);
    };
}