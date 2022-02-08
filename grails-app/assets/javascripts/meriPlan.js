/*
 Script for handling Project MERI Plan
 */

function MERIPlan(project, key) {
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

    self.details = new DetailsViewModel(project.custom.details, project.plannedStartDate, project.plannedEndDate);
    self.detailsLastUpdated = ko.observable(project.custom.details.lastUpdated)
        .extend({simpleDate: true});
    self.detailsLastUpdatedDisplayName = ko.observable(project.custom.details.lastUpdatedDisplayName || '');
    self.isProjectDetailsSaved = ko.computed(function () {
        return project.custom.details.status === 'active';
    });
    self.isProjectDetailsLocked = ko.computed (function (){
        return false; // Always editable, at least for now.
    });

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
}

function DetailsViewModel(projectDetails, projectStartDate, projectEndDate) {
    const self = this;
    if (!projectDetails) projectDetails = {};
    self.transients = self.transients || {};

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
    self.dateCurrent = ko.observable(projectDetails.dateCurrent).extend({simpleDate: false});
    self.dateCurrentFundingBudget = ko.observable(projectDetails.dateCurrentFundingBudget).extend({simpleDate: false});

    self.budget = new BudgetViewModel(projectDetails.budget, projectStartDate, projectEndDate);
    self.budgetCommentary = ko.observable(projectDetails.budgetCommentary).extend({markdown: true});
    self.transients.editBudgetCommentary = function () {
        editWithMarkdown('Edit Content', self.budgetCommentary);
    };

    self.outcomeProgress = ko.observableArray($.map(projectDetails.outcomeProgress || [], function(outcomeProgress) { return new OutcomeProgressViewModel(outcomeProgress); }));
    $.extend(self, new Risks(projectDetails.risks));
    self.issues = new IssuesViewModel(projectDetails.issues);

    var row = [];
    projectDetails.events ? row = projectDetails.events : row.push(ko.mapping.toJS(new EventsRowViewModel()));
    self.events = ko.observableArray($.map(row, function (obj, i) {
        return new EventsRowViewModel(obj);
    }));

    self.toJS = function toJS() {
        const detailsObject = ko.mapping.toJS(self, {"ignore": ["transients"]});
        return {"custom": {"details": detailsObject}};
    };

    self.modelAsJSON = function modelAsJSON() {
        const jsData = self.toJS();
        return JSON.stringify(jsData, function (key, value) {
            return value === undefined ? "" : value;
        });
    };
}

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
}

function limitText(field, maxChar){
    $(field).attr('maxlength',maxChar);
}

function WorksProjectViewModel(project, isEditor, organisations, options) {
    var self = this;

    var defaults = {
        saveUrl: fcConfig.saveMeriPlanUrl,
        meriPlanSelector: '#edit-meri-plan',
        mapConfigurationSelector: "#mapConfiguration",
        outcomesProgressSelector: "#outcomes-progress",
        fundingBudgetSelector: "#edit-funding-budget",
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

    const projectVm = new ProjectViewModel(project, isEditor, organisations);
    $.extend(true, self, projectVm);

    self.mapConfiguration = new MapConfiguration(project.mapConfiguration, project);

    const meriPlanVm = new MERIPlan(project, config.storageKey);
    $.extend(true, self, meriPlanVm);

    self.transients.fundingBudgetComparison = new ProjectFundingBudgetCompareViewModel(self);

    /**
     * Produces the js object representation of the model.
     * @return {*}
     */
    self.toJS = function toJS() {
        // serialise the 'top-level' project data
        const projectObject = projectVm.toJS();

        // serialise the meri plan details data
        const detailsObject = meriPlanVm.details.toJS();

        // add the 'details' data to the 'top-level' data
        projectObject.custom = detailsObject.custom;

        return projectObject;
    };

    /**
     * Produces the JSON string representation of the model.
     * @return {string}
     */
    self.modelAsJSON = function () {
        const projectObject = self.toJS();

        // stringify the object
        return JSON.stringify(projectObject, function (key, value) {
            return value === undefined ? "" : value;
        });
    };

    const saveMeriPlanSelectors = [
        config.meriPlanSelector,
        config.mapConfigurationSelector,
        // config.outcomesProgressSelector,
        config.fundingBudgetSelector,
    ].join(',')

    $(saveMeriPlanSelectors).validationEngine('attach', {showPrompts: true,validateNonVisibleFields: true,scroll: true});

    autoSaveModel(self, config.saveUrl, config);
    configureFloatingSave({changeFlag:self.dirtyFlag});

    /**
     * Get validation error title and the value that caused the error.
     *
     * There is no easy way to provide the label or text of which field has the error.
     * This approach looks at the current item and the item's siblings
     * to find particular tags that are usually used for field titles.
     *
     * It then uses the text of the first element found.
     * @return {*|jQuery}
     */
    self.getMeriPlanValidationErrors = function getMeriPlanValidationErrors() {
        const titleTagTypes = ['label', 'b', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'];
        return $('.formError').map(function () {
            const errorContainer = $(this);

            let fieldTitle = null;
            let currentItem = errorContainer;

            while (fieldTitle === null && currentItem !== null) {
                const currentTagType = currentItem.prop("tagName");

                if (titleTagTypes.some(function (el) {
                    return el.toUpperCase() === currentTagType;
                })) {
                    fieldTitle = currentItem.text();
                } else {

                    const text = titleTagTypes.reduce(function (prev, el) {
                        const siblingsText = currentItem.siblings(el).text();
                        const result = siblingsText ? (prev ? prev + ', ' + siblingsText : siblingsText) : prev;
                        return result.trim();
                    }, '');
                    if (text) {
                        fieldTitle = text;
                    } else {
                        currentItem = currentItem.parent() || null;
                    }
                }

                if (currentTagType === 'HTML') {
                    // try to prevent infinite while loop
                    currentItem = null;
                }
            }

            return {
                'title': (fieldTitle.replace('*', '') || '(title not found)').trim(),
                'value': errorContainer.text().replace('*', '').trim()
            };
        }).get();
    };

    // Save MERI plan
    self.saveMeriPlan = function () {
        const isMeriPlanValid = $(saveMeriPlanSelectors).validationEngine('validate', {
            showPrompts: true, validateNonVisibleFields: true, validateAttribute: "data-validation-engine"
        });
        if (isMeriPlanValid) {
            self.details.status('active');
            var now = moment().toDate().toISOStringNoMillis();
            self.details.lastUpdated(now);
            self.detailsLastUpdated(now);
            self.details.saveWithErrorDetection(function (result) {
                console.info('[MeriPlan] Successfully saved project.', result);
                self.detailsLastUpdatedDisplayName((result.resp && result.resp.lastUpdatedByDisplayName) || '');
            }, function (result) {
                console.error('[MeriPlan] Failed to save project.', result);
                bootbox.alert("An error occurred while updating the plan.");
            });
        } else {
            // gather the validation errors to show in alertbox
            const validationErrors = self.getMeriPlanValidationErrors();
            console.error('[MeriPlan] The project had validation errors.', validationErrors);

            let errorUniqueCount = 0;
            const errorText = validationErrors.reduce(function (prev, element) {
                const newItem = '<b>' + element.title + '</b>: ' + element.value;
                if (prev.indexOf(newItem) === -1) {
                    errorUniqueCount += 1;
                    return prev + "<li>" + errorUniqueCount.toString() + ') ' + newItem + "</li>";
                } else {
                    return prev;
                }
            }, '');
            bootbox.alert("<h4>The project could not be saved.</h4>" +
                "<p>Please check that all fields are filled as required.</p>" +
                "<p>Some of the field validation errors may be listed below, " +
                "along with an approximate title or section name to help you find and fix the field content:</p>" +
                "<br><ul>" + errorText + "</ul><br>"
            );
        }
    };

    self.saveMapConfig = function () {
        if (!$(config.mapConfigurationSelector).validationEngine('validate')) {
            return;
        }

        var data = {
            mapConfiguration: self.mapConfiguration.toJS(),
            mapLayersConfig: ko.toJS(self.mapLayersConfig)
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

function ProjectFundingBudgetCompareViewModel(workProjectViewModel) {
    const self = this;

    self.fundingTotal = ko.computed(function () {
        const raw = workProjectViewModel.funding();
        const fundingTotal = Math.round(raw * 100) / 100;
        return fundingTotal;
    }).extend({currency: {}});
    self.budgetTotal = ko.computed(function () {
        const raw = workProjectViewModel.details.budget.overallTotal();
        const budgetTotal = Math.round(raw * 100) / 100;
        return budgetTotal;
    }).extend({currency: {}});
    self.diff = ko.computed(function () {
        const f = self.fundingTotal();
        const b = self.budgetTotal();
        const diff = Math.abs(f - b);
        return diff;
    }).extend({currency: {}});
    self.outcome = ko.computed(function () {
        const d = self.diff();
        const precision = 0.001;
        const outcome = d <= precision;
        return outcome;
    });
}