/*
    Utilities for managing project representations.
 */

/**
 * A chance to make any on-the-fly changes to projects as they are opened.
 * @param project
 * @param callback optional callback for the results of any asynch saves
 * @returns updated project object
 */
function checkAndUpdateProject (project, callback, programs) {
    var propertiesToSave = {},
        isEmpty=function(x,p){for(p in x)return!1;return!0};
    // add any checks here - return true if the project representation needs to be saved
    var program = null;
    if (programs && project.associatedProgram) {
        var matchingProgram = $.grep(programs.programs, function(program, index) {
            return program.name == project.associatedProgram;
        });
        program = matchingProgram[0];
    }
    propertiesToSave = $.extend(propertiesToSave, createTimelineIfMissing(project, program));
    // check for saves
    if (!isEmpty(propertiesToSave) && fcConfig.projectUpdateUrl !== undefined) {
        $.ajax({
            url: fcConfig.projectUpdateUrl,
            type: 'POST',
            data: JSON.stringify(propertiesToSave),
            contentType: 'application/json',
            success: function (data) {
                if (callback) {
                    if (data.error) {
                        callback.call(this, 'error', data.detail + ' \n' + data.error);
                    } else {
                        callback.call(this, 'success');
                    }
                }
            },
            error: function (data) {
                if (callback) {
                    callback.call(this, 'error', data.status);
                }
            }
        });
    }
    return project;
}

/**
 * Injects a newly created timeline if none exists.
 * Clears (but can't delete) any currentStage property. This prop is
 * deprecated because current stage is calculated from the timeline and
 * the current date.
 * @param project
 * @returns updated properties
 */
function createTimelineIfMissing (project, program) {
    if (project.timeline === undefined) {
        var props = {};
        if (project.currentStage !== undefined) {
            props.currentStage = '';
        }
        if (program) {
            addTimelineBasedOnStartDate(project, program.reportingPeriod, program.reportingPeriodAlignedToCalendar || false);
        }
        else {
            addTimelineBasedOnStartDate(project);
        }
        props.timeline = project.timeline;
        return props;
    }
    return {};
}

/**
 * Creates a default timeline based on project start date.
 * Assumes 6 monthly stages with the first containing the project's
 * planned start date.
 * @param project
 */
function addTimelineBasedOnStartDate (project, reportingPeriod, alignToCalendar) {

    if (!reportingPeriod) {
        reportingPeriod = 6;
    }
    if (alignToCalendar == undefined) {
        alignToCalendar = true;
    }

    // planned start date should be an ISO8601 UTC string
    if (project.plannedStartDate === undefined || project.plannedStartDate === '') {
        // make one up so we can proceed
        project.plannedStartDate = new Date(Date.now()).toISOStringNoMillis();
    }
    if (project.plannedEndDate === undefined || project.plannedEndDate === '') {
        // make one up so we can proceed
        var endDate = new Date(Date.now());
        endDate = endDate.setUTCFullYear(endDate.getUTCFullYear()+5);
        project.plannedEndDate = new Date(endDate).toISOStringNoMillis();
    }

    var date = Date.fromISO(project.plannedStartDate),
        endDate = Date.fromISO(project.plannedEndDate),
        i = 0;

    if (alignToCalendar) {
        var month = date.getMonth();
        var numPeriods = Math.floor(month/reportingPeriod);
        var monthOfStartDate = numPeriods*reportingPeriod;
        var dayOfStartDate = 1;

        date = new Date(date.getFullYear(), monthOfStartDate, dayOfStartDate);
    }
    project.timeline = [];

    var duration = moment.duration({'months':reportingPeriod});

    var periodStart = moment(date);
    while (periodStart.isBefore(endDate)) {

        var periodEnd = moment(periodStart).add(duration);
        var period = {
            fromDate: periodStart.toISOString(),
            toDate:periodEnd.toISOString()
        };
        period.name = 'Stage ' + (i + 1);
        project.timeline.push(period);

        // add 6 months to date
        periodStart = periodEnd;
        i++;
    }
}

/**
 * Returns the from and to dates of the half year that the specified
 * date falls in.
 * @param date
 * @returns {{fromDate: string, toDate: string}}
 */
function getSixMonthPeriodContainingDate (date) {
    var year = date.getUTCFullYear(),
        midYear = new Date(Date.UTC(year, 6, 0));
    if (date.getTime() < midYear.getTime()) {
        return {
            fromDate: year + "-01-01T00:00:00Z",
            toDate: year + "-07-01T00:00:00Z"
        };
    } else {
        return {
            fromDate: year + "-07-01T00:00:00Z",
            toDate: (year + 1) + "-01-01T00:00:00Z"
        };
    }
}

/**
 * Returns the stage within the timeline that contains the specified date.
 * @param timeline
 * @param UTCDateStr date must be an ISO8601 string
 * @returns {string}
 */
function findStageFromDate (timeline, UTCDateStr) {
    var stage = 'unknown';
    // try a simple lexical comparison
    $.each(timeline, function (i, period) {
        if (UTCDateStr > period.fromDate && UTCDateStr <= period.toDate) {
            stage = period.name;
        }
    });
    return stage;
}

/**
 * Returns stage report status.
 * @param project
 * @param stage
 * @returns {boolean}
 */
function isStageReportable (project, stage) {

    //is current stage a last stage?
    if(project.timeline && project.timeline.length > 0 &&
        project.timeline[project.timeline.length-1].name == stage.name){
       return project.plannedEndDate < new Date().toISOStringNoMillis();
    }
    else{
        return stage.toDate < new Date().toISOStringNoMillis();
    }
}
/**
 * Returns the activities associated with the stage.
 * @param activities
 * @param timeline
 * @param stage stage name
 * @returns {[]}
 */
function findActivitiesForStage (activities, timeline, stage) {
	var stageFromDate = '';
	var stageToDate = '';

	$.each(timeline, function (i, period) {
		if(period.name == stage){
			stageFromDate = period.fromDate;
			stageToDate = period.toDate;
		}
	});

    stageActivities = $.map(activities, function(act, i) {
    	var endDate = act.endDate ? act.endDate : act.plannedEndDate;
    	var startDate = act.startDate ? act.startDate : act.plannedStartDate;
        if(startDate >= stageFromDate && endDate <= stageToDate){
        	return act;
        }
    });
    return stageActivities;
}

/**
 * Is it a current or past stage
 * @param timeline
 * @param stage current stage name
 * @param period stage period
 * @returns true if past stage.
 */
function isPastStage(timeline, currentStage, period) {

	var stageFromDate = '';
	var stageToDate = '';
	$.each(timeline, function (i, period) {
		if(period.name == currentStage){
			stageFromDate = period.fromDate;
			stageToDate = period.toDate;
		}
	});
	return period.toDate <= stageToDate;
}

function getBugetHeaders(timeline) {
	var headers = [];
    var startYr = moment(timeline[0].fromDate).format('YYYY');
    var endYr = moment(timeline[timeline.length-1].toDate).format('YYYY');;
    var startMonth = moment(timeline[0].fromDate).format('M');
    var endMonth = moment(timeline[timeline.length-1].toDate).format('M');

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

function isValid(p, a) {
	 a = a.split(".");
	 for (i in a) {
		var key = a[i];
		if (p[key] == null || p[key] == undefined){
			return '';
		}
		p = p[key];
	 }
	 return p;
}

function ProjectViewModel(project, isUserEditor, organisations) {
    var self = $.extend(this, new Documents());

    if (isUserEditor === undefined) {
        isUserEditor = false;
    }
    if (!organisations) {
        organisations = [];
    }
    var organisationsMap = {}, organisationsRMap = {};
    $.map(organisations, function(org) {
        organisationsMap[org.organisationId] = org;
        organisationsRMap[org.name] = org.organisationId;
    });

    self.name = ko.observable(project.name);
    self.aim = ko.observable(project.aim);
    self.description = ko.observable(project.description).extend({markdown:true});
    self.externalId = ko.observable(project.externalId);
    self.grantId = ko.observable(project.grantId);
    self.manager = ko.observable(project.manager);
    self.managerEmail = ko.observable(project.managerEmail);
    self.plannedStartDate = ko.observable(project.plannedStartDate).extend({simpleDate: false});
    self.plannedEndDate = ko.observable(project.plannedEndDate).extend({simpleDate: false});
    self.funding = ko.observable(project.funding).extend({currency:{}});

    self.regenerateProjectTimeline = ko.observable(false);
    self.projectDatesChanged = ko.computed(function() {
        return project.plannedStartDate != self.plannedStartDate() ||
            project.plannedEndDate != self.plannedEndDate();
    });
    var projectDefault = "active";
    if(project.status){
        projectDefault = project.status;
    }
    self.status = ko.observable(projectDefault.toLowerCase());
    self.projectStatus = [{id: 'active', name:'Active'},{id:'completed',name:'Completed'},{id:'deleted', name:'Deleted'}];

    self.organisationId = ko.observable(project.organisationId);
    self.collectoryInstitutionId = ko.computed(function() {
        var org = self.organisationId() && organisationsMap[self.organisationId()];
        return org? org.collectoryInstitutionId: "";
    });
    self.organisationName = ko.computed(function() {
        var org = self.organisationId() && organisationsMap[self.organisationId()];
        return org? org.name: project.organisationName;
    });

    var legalCustodianVal = project.legalCustodianOrganisation? project.legalCustodianOrganisation: ko.utils.unwrapObservable(self.organisationName);
    self.legalCustodianOrganisation = ko.observable(legalCustodianVal);

    self.setLegalCustodian = function (data, event) {
        if (event.originalEvent) { //user changed
            self.current().legalCustodianOrganisation(data.transients.selectedCustodianOption);
        }
    };

    var legalCustodianOrganisationTypeVal = project.legalCustodianOrganisationType? project.legalCustodianOrganisationType: "";
    self.legalCustodianOrganisationType = ko.observable(legalCustodianOrganisationTypeVal);


    self.orgIdGrantee = ko.observable(project.orgIdGrantee);
    self.orgIdSponsor = ko.observable(project.orgIdSponsor);
    self.orgIdSvcProvider = ko.observable(project.orgIdSvcProvider);

    self.serviceProviderName = ko.observable(project.serviceProviderName);
    self.associatedProgram = ko.observable(); // don't initialise yet - we want the change to trigger dependents
    self.associatedSubProgram = ko.observable(project.associatedSubProgram);
    self.newsAndEvents = ko.observable(project.newsAndEvents).extend({markdown:true});
    self.projectStories = ko.observable(project.projectStories).extend({markdown:true});
    self.difficulty = ko.observable(project.difficulty);
    self.gear = ko.observable(project.gear);
    self.getInvolved = ko.observable(project.getInvolved).extend({markdown:true});
    self.hasParticipantCost = ko.observable(project.hasParticipantCost);
    self.hasTeachingMaterials = ko.observable(project.hasTeachingMaterials);
    self.isCitizenScience = ko.observable(project.isCitizenScience);
    self.isDIY = ko.observable(project.isDIY);
    self.isWorks = ko.observable(project.isWorks);
    self.isEcoScience = ko.observable(project.isEcoScience);
    self.isExternal = ko.observable(project.isExternal);
    self.isSciStarter = ko.observable(project.isSciStarter)
    self.isMERIT = ko.observable(project.isMERIT);
    self.isMetadataSharing = ko.observable(project.isMetadataSharing);
    self.isContributingDataToAla = ko.observable(project.isContributingDataToAla);
    self.isSuitableForChildren = ko.observable(project.isSuitableForChildren);
    self.keywords = ko.observable(project.keywords);
    self.projectSiteId = project.projectSiteId;
    self.projectType = ko.observable(project.projectType);
    self.scienceType = ko.observableArray(project.scienceType);
    self.ecoScienceType = ko.observableArray(project.ecoScienceType);
    self.task = ko.observable(project.task);
    self.urlWeb = ko.observable(project.urlWeb).extend({url:true});
    self.contractStartDate = ko.observable(project.contractStartDate).extend({simpleDate: false});
    self.contractEndDate = ko.observable(project.contractEndDate).extend({simpleDate: false});
    self.imageUrl = ko.observable(project.urlImage);
    self.termsOfUseAccepted = ko.observable(project.termsOfUseAccepted || false);
    
    self.associatedProgram = ko.observable(project.associatedProgram ? project.associatedProgram : '');
    self.associatedSubProgram = ko.observable(project.associatedSubProgram ? project.associatedSubProgram : '');
    self.orgGrantee = ko.observable(project.orgGrantee ? project.orgGrantee : '');
    self.orgSponsor = ko.observable(project.orgSponsor ? project.orgSponsor : '');

    self.associatedOrgs = ko.observableArray();
    ko.utils.arrayMap(project.associatedOrgs || [], function(org) {
        var tmpOrg = org || {};
        self.associatedOrgs.push({
            id: tmpOrg.id,
            organisationId: tmpOrg.organisationId || null,
            logo: tmpOrg.logo || null,
            name: tmpOrg.name || null,
            url: tmpOrg.url || null
        });
    });

    self.isExternal.subscribe(function (newVal) {
        if (!newVal) {
            self.isContributingDataToAla(true)
        }
    });

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
    var calculateDuration = function(startDate, endDate) {
        if (!startDate || !endDate) {
            return '';
        }
        return Math.ceil(calculateDurationInDays(startDate, endDate)/7);
    };
    var calculateEndDate = function(startDate, duration) {
        var start =  moment(startDate);
        var end = start.add(duration*7, 'days');
        return end.toDate().toISOStringNoMillis();
    };

    var contractDatesFixed = function() {
        var programs = self.transients.programs;
        for (var i=0; i<programs.length; i++) {
            if (programs[i].name === self.associatedProgram()) {
                return programs[i].projectDatesContracted;
            }
        }
        return true;
    };

    self.transients.daysRemaining = ko.pureComputed(function() {
        var end = self.plannedEndDate();
        return end? isBeforeToday(end)? 0: calculateDurationInDays(undefined, end) + 1: -1;
    });
    self.transients.daysSince = ko.pureComputed(function() {
        var startDate = self.plannedStartDate();
        if (!startDate) return -1;
        var start = moment(startDate);
        var today = moment();
        return today.diff(start, 'days');
    });
    self.transients.daysTotal = ko.pureComputed(function() {
        return self.plannedEndDate()? calculateDurationInDays(self.plannedStartDate(), self.plannedEndDate()): -1;
    });
    self.daysStatus = ko.pureComputed(function(){
        return self.transients.daysRemaining()? "active": "ended";
    });
    self.transients.since = ko.pureComputed(function(){
        var daysSince = self.transients.daysSince();
        if (daysSince < 0) {
            daysSince = -daysSince;
            if (daysSince === 1) return "tomorrow";
            if (daysSince < 30) return "in " + daysSince + " days";
            if (daysSince < 32) return "in about a month";
            if (daysSince < 365) return "in " + (daysSince / 30).toFixed(1) + " months";
            if (daysSince === 365) return "in one year";
            return "in " + (daysSince / 365).toFixed(1) + " years";
        }
        if (daysSince === 0) return "today";
        if (daysSince === 1) return "yesterday";
        if (daysSince < 30) return daysSince + " days ago";
        if (daysSince < 32) return "about a month ago";
        if (daysSince < 365) return (daysSince / 30).toFixed(1) + " months ago";
        if (daysSince === 365) return "one year ago";
        return (daysSince / 365).toFixed(1) + " years ago";
    });
    var updatingDurations = false; // Flag to prevent endless loops during change of end date / duration.
    self.transients.plannedDuration = ko.observable(calculateDuration(self.plannedStartDate(), self.plannedEndDate()));

    self.transients.plannedDuration.subscribe(function(newDuration) {
        if (updatingDurations) {
            return;
        }
        try {
            updatingDurations = true;
            self.plannedEndDate(calculateEndDate(self.plannedStartDate(), newDuration));
        }
        finally {
            updatingDurations = false;
        }
    });

    self.plannedEndDate.subscribe(function(newEndDate) {
        if (updatingDurations) {
            return;
        }
        try {
            updatingDurations = true;
            self.transients.plannedDuration(calculateDuration(self.plannedStartDate(), newEndDate));
        }
        finally {
            updatingDurations = false;
        }
    });

    self.plannedStartDate.subscribe(function(newStartDate) {
        if (updatingDurations) {
            return;
        }
        if (contractDatesFixed()) {
            if (!self.plannedEndDate()) {
                return;
            }
            try {
                updatingDurations = true;
                self.transients.plannedDuration(calculateDuration(newStartDate, self.plannedEndDate()));
            }
            finally {
                updatingDurations = false;
            }
        }
        else {
            if (!self.transients.plannedDuration()) {
                return;
            }
            try {
                updatingDurations = true;
                self.plannedEndDate(calculateEndDate(newStartDate, self.transients.plannedDuration()));
            }
            finally {
                updatingDurations = false;
            }
        }
    });

    self.transients.contractDuration = ko.observable(calculateDuration(self.contractStartDate(), self.contractEndDate()));
    self.transients.contractDuration.subscribe(function(newDuration) {
        if (updatingDurations) {
            return;
        }
        if (!self.contractStartDate()) {
            return;
        }
        try {
            updatingDurations = true;
            self.contractEndDate(calculateEndDate(self.contractStartDate(), newDuration));
        }
        finally {
            updatingDurations = false;
        }
    });


    self.contractEndDate.subscribe(function(newEndDate) {
        if (updatingDurations) {
            return;
        }
        if (!self.contractStartDate()) {
            return;
        }
        try {
            updatingDurations = true;
            self.transients.contractDuration(calculateDuration(self.contractStartDate(), newEndDate));
        }
        finally {
            updatingDurations = false;
        }
    });

    self.contractStartDate.subscribe(function(newStartDate) {
        if (updatingDurations) {
            return;
        }
        if (contractDatesFixed()) {
            if (!self.contractEndDate()) {
                return;
            }
            try {
                updatingDurations = true;
                self.transients.contractDuration(calculateDuration(newStartDate, self.contractEndDate()));
            }
            finally {
                updatingDurations = false;
            }
        }
        else {
            if (!self.transients.contractDuration()) {
                return;
            }
            try {
                updatingDurations = true;
                self.contractEndDate(calculateEndDate(newStartDate, self.transients.contractDuration()));
            }
            finally {
                updatingDurations = false;
            }
        }
    });

    self.transients.projectId = project.projectId;
    self.transients.programs = [];
    self.transients.subprograms = {};
    self.transients.subprogramsToDisplay = ko.computed(function () {
        return self.transients.subprograms[self.associatedProgram()];
    });
    self.transients.organisations = organisations;

    self.transients.difficultyLevels = [ "Easy", "Medium", "Hard" ];

    var scienceTypesList = [
        {name:'Biodiversity', value:'biodiversity'},
        {name:'Ecology', value:'ecology'},
        {name:'Natural resource management', value:'nrm'}
    ];
    var ecoScienceTypesList = [
        {name:'Biodiversity', value:'biodiversity'},
        {name:'Ecology', value:'ecology'},
        {name:'Natural resource management', value:'nrm'}
    ];
    self.transients.availableScienceTypes = fcConfig.scienceTypes;
    self.transients.availableEcoScienceTypes = fcConfig.ecoScienceTypes;
    self.transients.scienceTypeDisplay = ko.pureComputed(function () {
        for (var st = self.scienceType(), i = 0; i < scienceTypesList.length; i++)
            if (st === scienceTypesList[i].value)
                return scienceTypesList[i].name;
    });
    self.transients.ecoScienceTypeDisplay = ko.pureComputed(function () {
        for (var st = self.ecoScienceType(), i = 0; i < ecoScienceTypesList.length; i++)
            if (st === ecoScienceTypesList[i].value)
                return ecoScienceTypesList[i].name;
    });

    self.transients.isScienceTypeChecked = function(value){
        var types = self.scienceType()
        for(var i=0; i<types.length; i++){
            if(types[i] == value.toLowerCase()){
                return true
            }
        }

        return false;
    };

    self.transients.isEcoScienceTypeChecked = function(value){
        var types = self.ecoScienceType()
        for(var i=0; i<types.length; i++){
            if(types[i] == value.toLowerCase()){
                return true
            }
        }

        return false;
    };

    self.transients.addScienceType = function(data, event){
        var elem = event.target
        if(elem.checked){
            self.scienceType.push(elem.value)
        } else {
            self.scienceType.remove(elem.value)
        }
    }

    self.transients.addEcoScienceType = function(data, event){
        var elem = event.target
        if(elem.checked){
            self.ecoScienceType.push(elem.value)
        } else {
            self.ecoScienceType.remove(elem.value)
        }
    };

    var availableProjectTypes = [
        {name:'Citizen Science Project', display:'Citizen\nScience', value:'citizenScience'},
        {name:'Ecological or biological survey / assessment (not citizen science)', display:'Biological\nScience', value:'ecoScience'},
        {name:'Natural resource management works project', display:'Works\nProject', value:'works'}
    ];
    self.transients.availableProjectTypes = availableProjectTypes;
    self.transients.kindOfProjectDisplay = ko.pureComputed(function () {
        for (var pt = self.transients.kindOfProject(), i = 0; i < availableProjectTypes.length; i++)
            if (pt === availableProjectTypes[i].value)
                return availableProjectTypes[i].display;
    });
    /** Map between the available selection of project types and how the data is stored */
    self.transients.kindOfProject = ko.pureComputed({
        read: function() {
            if (self.isCitizenScience()) {
                return 'citizenScience';
            }
            if (self.isWorks()) {
                return 'works';
            }
            if (self.isEcoScience()) {
                return 'ecoScience';
            }
            if (self.projectType()) {
                return self.projectType() == 'survey' ? 'survey' : (self.projectType() == 'works' ? 'works' : 'ecoScience');
            }
        },
        write: function(value) {
            if (value === 'citizenScience') {
                self.isCitizenScience(true);
                self.projectType('survey');
            }
            else {
                self.isCitizenScience(false);
                self.projectType(value);
            }
        }
    });

    self.loadPrograms = function (programsModel) {
        $.each(programsModel.programs, function (i, program) {
            if (program.readOnly && self.associatedProgram() != program.name) {
                return;
            }
            self.transients.programs.push(program.name);
            self.transients.subprograms[program.name] = $.map(program.subprograms,function (obj, i){return obj.name});
        });
        self.associatedProgram(project.associatedProgram); // to trigger the computation of sub-programs
    };

    self.toJS = function() {
        var toIgnore = self.ignore; // document properties to ignore.
        toIgnore.concat(['transients', 'daysStatus', 'projectDatesChanged', 'collectoryInstitutionId', 'ignore', 'projectStatus']);
        return ko.mapping.toJS(self, {ignore:toIgnore});
    };

    self.modelAsJSON = function() {
        return JSON.stringify(self.toJS());
    };

    // documents
    var maxStages = project.timeline ? project.timeline.length : 0 ;
    self.addDocument = function(doc) {
        // check permissions
        if ((isUserEditor && doc.role !== 'approval') ||  doc.public) {
            doc.maxStages = maxStages;
            self.documents.push(new DocumentViewModel(doc));
        }
    };
    self.attachDocument = function() {
        showDocumentAttachInModal(fcConfig.documentUpdateUrl, new DocumentViewModel({role:'information', maxStages: maxStages},{key:'projectId', value:project.projectId}), '#attachDocument')
            .done(function(result){
                    window.location.href = here;
                }
            );
    };
    self.editDocumentMetadata = function(document) {
        var url = fcConfig.documentUpdateUrl + "/" + document.documentId;
        showDocumentAttachInModal( url, document, '#attachDocument')
            .done(function(result){
                window.location.href = here; // The display doesn't update properly otherwise.
            });
    };
    self.deleteDocument = function(document) {
        var url = fcConfig.documentDeleteUrl+'/'+document.documentId;
        $.post(url, {}, function() {self.documents.remove(document);});

    };

    if (project.documents) {
        $.each(project.documents, function(i, doc) {
            if (doc.role === "logo") doc.public = true; // for backward compatibility
            self.addDocument(doc);
        });
    }
    self.mainImageAttribution = ko.observable(self.mainImageAttributionText());
    self.logoAttribution = ko.observable(self.logoAttributionText());

    // links
    if (project.links) {
        $.each(project.links, function(i, link) {
            self.addLink(link.role, link.url);
        });
    }

    self.editProject = function() {
        window.location.href = fcConfig.projectEditUrl;
    };

    self.deleteProject = function () {
        var message = "<span class='label label-important'>Important</span><p><b>This cannot be undone</b></p><p>Are you sure you want to delete this project? All associated data will also be deleted.</p>";
        bootbox.confirm(message, function (result) {
            if (result) {
                $.ajax({
                    url: fcConfig.projectDeleteUrl,
                    type: 'DELETE',
                    success: function (data) {
                        if (data.error) {
                            showAlert(data.error, "alert-error", self.transients.resultsHolder);
                        } else {
                            showAlert("Successfully deleted. Indexing is in process, search result will be updated in few minutes. Redirecting to search page...", "alert-success", self.transients.resultsHolder);
                            setTimeout(function () {
                                window.location.href = fcConfig.serverUrl;
                            }, 3000);
                        }
                    },
                    error: function (data) {
                        showAlert("Error: Unhandled error", "alert-error", self.transients.resultsHolder);
                    }
                });
            }
        });
    };
};

/**
 * View model for use by the citizen science project finder page.
 * @param props array of project attributes
 * @constructor
 */
function CitizenScienceFinderProjectViewModel(props) {
    ProjectViewModel.apply(this, [{
        projectId: props[0],
        aim: props[1],
        description: props[3],
        difficulty: props[4],
        plannedEndDate: props[5] && new Date(props[5]),
        hasParticipantCost: props[6],
        hasTeachingMaterials: props[7],
        isDIY: props[8],
        isExternal: props[9],
        isSuitableForChildren: props[10],
        keywords: props[11],
        links: props[12],
        name: props[13],
        organisationId: props[14],
        organisationName: props[15],
        scienceType: props[16],
        plannedStartDate: props[17] && new Date(props[17]),
        documents: [
            {
                public: true,
                role: 'logo',
                url: props[18]
            }
        ],
        urlWeb: props[19]
    }, false, []]);

    var self = this;
    self.transients.locality = props[2] && props[2].locality;
    self.transients.state = props[2] && props[2].state;
}

/**
 * View model for use by the project create and edit pages.  Extends the ProjectViewModel to provide support
 * for organisation search and selection as well as saving project information.
 * @param project pre-populated or existing project data.
 * @param isUserEditor true if the user can edit the project.
 * @param userOrganisations the list of organisations for which the user is a member.
 * @param organisations the list of organisations for which the user is not a member.
 * @constructor
 */
function CreateEditProjectViewModel(project, isUserEditor, userOrganisations, organisations, options) {
    ProjectViewModel.apply(this, [project, isUserEditor, userOrganisations.concat(organisations)]);

    var defaults = {
        projectSaveUrl: fcConfig.projectUpdateUrl + '/' + (project.projectId || ''),
        organisationCreateUrl: fcConfig.organisationCreateUrl,
        blockUIOnSave:true,
        storageKey:project.projectId?project.projectId+'.savedData':'projectData'
    };
    var config = $.extend(defaults, options);

    var self = this;

    self.transients.siteViewModel = initSiteViewModel(false);

    self.name.subscribe(function(projectName) {
        checkProjectName(projectName);

        var oldValue = self.transients.siteViewModel.site().name();
        var prefix = "Project area for ";
        if (oldValue.indexOf(prefix) >= 0 || !oldValue) {
            self.transients.siteViewModel.site().name(prefix + projectName);
        }
    });

    self.organisationSearch = new OrganisationSelectionViewModel(organisations, userOrganisations, project.organisationId);
    self.associatedOrganisationSearch = new OrganisationSelectionViewModel(organisations, userOrganisations);
    self.transients.associatedOrgNotInList = ko.observable(false);
    self.transients.associatedOrgUrl = ko.observable();
    self.transients.associatedOrgLogoUrl = ko.observable();

    self.transients.termsOfUseClicked = ko.observable(false);

    self.transients.validProjectName = ko.observable(true);

    function checkProjectName(projectName) {
        if (!_.isUndefined(projectName) && projectName) {
            $.ajax({
                url: fcConfig.checkProjectNameUrl,
                type: 'GET',
                data: {projectName: projectName, id: project.projectId},
                contentType: 'application/json',
                success: function (data) {
                    self.transients.validProjectName(data.validName);
                }
            });
        }
    }

    self.clickTermsOfUse = function() {
        self.transients.termsOfUseClicked(true);
        return true;
    };

    self.organisationSearch.createOrganisation = function() {
        var projectData = self.modelAsJSON();
        amplify.store(config.storageKey, projectData);
        var here = document.location.href;
        document.location.href = config.organisationCreateUrl+'?returnTo='+here+'&returning=true';
    };

    self.organisationSearch.selection.subscribe(function(newSelection) {
        if (newSelection) {
            self.organisationId(newSelection.organisationId);
        }
    });

    self.associatedOrganisationSearch.addSelectedOrganisation = function() {
        var org = { id: self.associatedOrgs().length };

        if (self.transients.associatedOrgNotInList()) {

            if($('#associatedOrgLogo').validationEngine('validate')) {
                //Invalid content, let validation engine pop up the error and we just stop processing
                return;
            }
            org.name = self.associatedOrganisationSearch.term();
            org.url = self.transients.associatedOrgUrl() || null;
            org.logo = self.transients.associatedOrgLogoUrl() || null;

        } else {
            var logoDocument = ko.utils.arrayFirst(self.associatedOrganisationSearch.selection().documents, function(document) {
                return document.role === "logo"
            });

            org.organisationId = self.associatedOrganisationSearch.selection().organisationId || "";
            org.name = self.associatedOrganisationSearch.selection().name;
            org.url = self.associatedOrganisationSearch.selection().url || "";
            org.logo = logoDocument && logoDocument.thumbnailUrl ? logoDocument.thumbnailUrl : "";
        }

        self.associatedOrgs.push(org);
        self.associatedOrganisationSearch.clearSelection();
        self.transients.associatedOrgLogoUrl(false);
        self.transients.associatedOrgUrl(null);
        self.transients.associatedOrgLogoUrl(null);
    };

    self.removeAssociatedOrganisation = function(org, event) {
        self.associatedOrgs.remove(org);
    };

    self.ignore = self.ignore.concat(['organisationSearch', 'associatedOrganisationSearch']);
    self.transients.existingLinks = project.links;

    self.modelAsJSON = function() {
        var projectData = self.toJS();

        var siteData = self.transients.siteViewModel.toJS();
        var documents = ko.mapping.toJS(self.documents());
        self.fixLinkDocumentIds(self.transients.existingLinks);
        var links = ko.mapping.toJS(self.links());

        // Assemble the data into the package expected by the service.
        projectData.projectSite = siteData;
        projectData.documents = documents;
        projectData.links = links;

        return JSON.stringify(projectData);
    };

    autoSaveModel(self, config.projectSaveUrl, {blockUIOnSave:config.blockUIOnSave, blockUISaveMessage:"Saving project...", storageKey:config.storageKey});
};

/**
 * Used by the validation engine jquery plugin to validate the selection of an organisation from a picklist.
 */
function validateOrganisationSelection(field, rules, i, options) {
    var organisationSelectionViewModel = ko.dataFor(field[0]);

    var selectedOrg = organisationSelectionViewModel.selection();
    if (!selectedOrg || selectedOrg == null || _.isUndefined(selectedOrg)) {
        // there is a bug with the funcCall option in JQuery Validation Engine where the rule is triggered but the
        // message is not raised unless the 'required' rule is also present.
        // The work-around for this is to manually add the 'required' rule when the message is raised.
        // http://stackoverflow.com/questions/16182395/jquery-validation-engine-funccall-not-working-if-only-rule
        rules.push('required');
        return "You must select an organisation from the list"
    }
}



var EditableBlogEntryViewModel = function(blogEntry, options) {

    var defaults = {
        validationElementSelector:'.validationEngineContainer',
        types:['News and Events', 'Project Stories', 'Photo'],
        returnTo:fcConfig.returnTo,
        blogUpdateUrl:fcConfig.blogUpdateUrl
    };
    var config = $.extend(defaults, options);
    var self = this;
    var now = convertToSimpleDate(new Date());
    self.blogEntryId = ko.observable(blogEntry.blogEntryId);
    self.projectId = ko.observable(blogEntry.projectId || undefined);
    self.title = ko.observable(blogEntry.title || '');
    self.date = ko.observable(blogEntry.date || now).extend({simpleDate:false});
    self.content = ko.observable(blogEntry.content);
    self.stockIcon = ko.observable(blogEntry.stockImageName);
    self.documents = ko.observableArray();
    self.image = ko.observable();
    self.type = ko.observable(blogEntry.type);
    self.viewMoreUrl = ko.observable(blogEntry.viewMoreUrl).extend({url:true});

    self.imageUrl = ko.computed(function() {
        if (self.image()) {
            return self.image().url;
        }
    });
    self.imageId = ko.computed(function() {
        if (self.image()) {
            return self.image().documentId;
        }
    });
    self.documents.subscribe(function() {
        if (self.documents()[0]) {
            self.image(new DocumentViewModel(self.documents()[0]));
        }
        else {
            self.image(undefined);
        }
    });
    self.removeBlogImage = function() {
        self.documents([]);
    };

    self.modelAsJSON = function() {
        var js = ko.mapping.toJS(self, {ignore:['transients', 'documents', 'image', 'imageUrl']});
        if (self.image()) {
            js.image = self.image().modelForSaving();
        }
        return JSON.stringify(js);
    };

    self.editContent = function() {
        editWithMarkdown('Blog content', self.content);
    };

    self.save = function() {
        if ($(config.validationElementSelector).validationEngine('validate')) {
            self.saveWithErrorDetection(
                function() {document.location.href = config.returnTo},
                function(data) {bootbox.alert("Error: "+data.responseText);}
            );
        }
    };

    self.cancel = function() {
        document.location.href = config.returnTo;
    };

    self.transients = {};
    self.transients.blogEntryTypes = config.types;

    if (blogEntry.documents && blogEntry.documents[0]) {
        self.documents.push(blogEntry.documents[0]);
    }
    $(config.validationElementSelector).validationEngine();
    autoSaveModel(self, config.blogUpdateUrl, {blockUIOnSave:true});
};

var BlogEntryViewModel = function(blogEntry) {
    var self = this;
    var now = convertToSimpleDate(new Date());
    self.blogEntryId = ko.observable(blogEntry.blogEntryId);
    self.projectId = ko.observable(blogEntry.projectId);
    self.title = ko.observable(blogEntry.title || '');
    self.date = ko.observable(blogEntry.date || now).extend({simpleDate:false});
    self.content = ko.observable(blogEntry.content).extend({markdown:true});
    self.stockIcon = ko.observable(blogEntry.stockIcon);
    self.documents = ko.observableArray(blogEntry.documents || []);
    self.viewMoreUrl = ko.observable(blogEntry.viewMoreUrl);
    self.image = ko.computed(function() {
        return self.documents()[0];
    });
    self.type = ko.observable();
    self.formattedDate = ko.computed(function() {
        return moment(self.date()).format('Do MMM')
    });
    self.shortContent = ko.computed(function() {
        var content = self.content() || '';
        if (content.length > 60) {
            content = content.substring(0, 100)+'...';
        }
        return content;
    });
    self.imageUrl = ko.computed(function() {
        if (self.image()) {
            return self.image().url;
        }
    });
};


var BlogSummary = function(blogEntries) {
    var self = this;
    self.entries = ko.observableArray();

    self.load = function(entries) {
        self.entries($.map(entries, function(blogEntry) {
            return new BlogEntryViewModel(blogEntry);
        }));
    };

    self.newBlogEntry = function() {
        document.location.href = fcConfig.createBlogEntryUrl;
    };
    self.deleteBlogEntry = function(entry) {
        var url = fcConfig.deleteBlogEntryUrl+'&id='+entry.blogEntryId();
        $.post(url).done(function() {
            document.location.reload();
        });
    };
    self.editBlogEntry = function(entry) {
        document.location.href = fcConfig.editBlogEntryUrl+'&id='+entry.blogEntryId();
    };
    self.load(blogEntries);
};

var BlogViewModel = function(entries, type) {
    var self = this;
    self.entries = ko.observableArray();

    for (var i=0; i<entries.length; i++) {
        if (!type || entries[i].type == type) {
            self.entries.push(new BlogEntryViewModel(entries[i]));
        }
    }
};

var SiteViewModel = function (site, feature) {
    var self = $.extend(this, new Documents());

    self.siteId = site.siteId;
    self.name = ko.observable(site.name);
    self.externalId = ko.observable(site.externalId);
    self.context = ko.observable(site.context);
    self.type = ko.observable(site.type);
    self.area = ko.observable(site.area);
    self.description = ko.observable(site.description);
    self.notes = ko.observable(site.notes);
    self.extent = ko.observable(new EmptyLocation());
    self.state = ko.observable('');
    self.nrm = ko.observable('');
    self.address = ko.observable("");
    self.feature = feature;
    self.projects = site.projects || [];
    self.extentSource = ko.pureComputed({
        read: function() {
            if (self.extent()) {
                return self.extent().source();
            }
            return 'none'
        },
        write: function(value) {
            self.updateExtent(value);
        }
    });

    self.setAddress = function (address) {
        if (address.indexOf(', Australia') === address.length - 11) {
            address = address.substr(0, address.length - 11);
        }
        self.address(address);
    };
    self.poi = ko.observableArray();

    self.addPOI = function(poi) {
        self.poi.push(poi);

    };
    self.removePOI = function(poi){
        if (poi.hasPhotoPointDocuments) {
            return;
        }
        self.poi.remove(poi);
    };
    self.toJS = function(){
        var js = ko.mapping.toJS(self, {ignore:self.ignore});
        js.extent = self.extent().toJS();
        delete js.extentSource;
        delete js.extentGeometryWatcher;
        delete js.isValid;
        return js;
    };

    self.modelAsJSON = function() {
        var js = self.toJS();
        return JSON.stringify(js);
    }
    /** Check if the supplied POI has any photos attached to it */
    self.hasPhotoPointDocuments = function(poi) {
        if (!site.documents) {
            return;
        }
        var hasDoc = false;
        $.each(site.documents, function(i, doc) {
            if (doc.poiId === poi.poiId) {
                hasDoc = true;
                return false;
            }
        });
        return hasDoc;
    };
    self.saved = function(){
        return self.siteId;
    };
    self.loadPOI = function (pois) {
        if (!pois) {
            return;
        }
        $.each(pois, function (i, poi) {
            self.poi.push(new POI(poi, self.hasPhotoPointDocuments(poi)));
        });
    };
    self.loadExtent = function(){
        if(site && site.extent) {
            var extent = site.extent;
            switch (extent.source) {
                case 'point':   self.extent(new PointLocation(extent.geometry)); break;
                case 'pid':     self.extent(new PidLocation(extent.geometry)); break;
                case 'upload':  self.extent(new UploadLocation()); break;
                case 'drawn':   self.extent(new DrawnLocation(extent.geometry)); break;
            }
        } else {
            self.extent(new EmptyLocation());
        }
    };


    self.updateExtent = function(source){
        switch (source) {
            case 'point':
                if(site && site.extent) {
                    self.extent(new PointLocation(site.extent.geometry));
                } else {
                    self.extent(new PointLocation({}));
                }
                break;
            case 'pid':
                if(site && site.extent) {
                    self.extent(new PidLocation(site.extent.geometry));
                } else {
                    self.extent(new PidLocation({}));
                }
                break;
            case 'upload': self.extent(new UploadLocation({})); break;
            case 'drawn':
                //breaks the edits....
                self.extent(new DrawnLocation({}));
                break;
            default: self.extent(new EmptyLocation());
        }
    };

    self.refreshGazInfo = function() {

        var geom = self.extent().geometry();
        var lat, lng;
        if (geom.type === 'Point') {
            lat = self.extent().geometry().decimalLatitude();
            lng = self.extent().geometry().decimalLongitude();
        }
        else if (geom.centre !== undefined) {
            lat = self.extent().geometry().centre()[1];
            lng = self.extent().geometry().centre()[0];
        }
        else {
            // No coordinates we can use for the lookup.
            return;
        }

        $.ajax({
            url: fcConfig.siteMetaDataUrl,
            method:"POST",
            contentType: 'application/json',
            data:self.modelAsJSON()
        })
            .done(function (data) {
                var geom = self.extent().geometry();
                for (var name in data) {
                    if (data.hasOwnProperty(name) && geom.hasOwnProperty(name)) {
                        geom[name](data[name]);
                    }
                }
            });

        //do the google geocode lookup
        $.ajax({
            url: fcConfig.geocodeUrl + lat + "," + lng
        }).done(function (data) {
            if (data.results.length > 0) {
                self.extent().geometry().locality(data.results[0].formatted_address);
            }
        });
    };
    self.isValid = ko.pureComputed(function() {
        return self.extent() && self.extent().isValid();
    });
    self.loadPOI(site.poi);
    self.loadExtent(site.extent);


    // Watch for changes to the extent content and notify subscribers when they do.
    self.extentGeometryWatcher = ko.pureComputed(function() {
        // We care about changes to either the geometry coordinates or the PID in the case of known shape.
        var result = {};
        if (self.extent()) {
            var geom = self.extent().geometry();
            if (geom) {
                if (geom.decimalLatitude) result.decimalLatitude = ko.utils.unwrapObservable(geom.decimalLatitude);
                if (geom.decimalLongitude) result.decimalLongitude = ko.utils.unwrapObservable(geom.decimalLongitude);
                if (geom.coordinates) result.coordinates = ko.utils.unwrapObservable(geom.coordinates);
                if (geom.pid) result.pid = ko.utils.unwrapObservable(geom.pid);
                if (geom.fid) result.fid = ko.utils.unwrapObservable(geom.fid);
            }

        }
        return result;

    });
};