//= require EmailViewModel.js
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

/**
 * Get parameter of the current page's URL
 * @param parameter to look for
 * @returns String | Boolean
 * source - http://stackoverflow.com/a/21903119
 */
function getUrlParameterValue(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};

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



function FundingViewModel(funding){
    var self = this;
    self.fundingSource=ko.observable(funding.fundingSource)
    self.fundingType=ko.observable(funding.fundingType)
    self.fundingSourceAmount=ko.observable(funding.fundingSourceAmount).extend({currency:{currencySymbol:"AUD $ "}})

}

function ProjectViewModel(project, isUserEditor) {
    var self = $.extend(this, new Documents());

    if (isUserEditor === undefined) {
        isUserEditor = false;
    }

    self.name = ko.observable(project.name);
    self.aim = ko.observable(project.aim);
    self.description = ko.observable(project.description).extend({markdown:true});
    self.externalId = ko.observable(project.externalId);
    self.grantId = ko.observable(project.grantId);
    self.manager = ko.observable(project.manager);
    self.managerEmail = ko.observable(project.managerEmail);
    self.plannedStartDate = ko.observable(project.plannedStartDate).extend({simpleDate: false});
    self.plannedEndDate = ko.observable(project.plannedEndDate).extend({simpleDate: false});
    var fundings = $.map(project.fundings || [], function(funding){
        return new FundingViewModel(funding)})
    self.fundings = ko.observableArray(fundings);

    self.fundingTypes = ["Public - commonwealth", "Public - state", "Public - local", "Public - in-kind", "Private - in-kind", "Private - industry", "Private - philanthropic", "Private - bequeath/other", "Private - NGO"];
    self.funding = ko.computed(function(){
        var total = 0;
        ko.utils.arrayForEach(self.fundings() ,function(funding){
            total += parseInt(funding.fundingSourceAmount());
        })
        return total;
    }).extend({currency:{currencySymbol:"AUD $ "}})

    self.removeFunding = function(){
        self.fundings.remove(this);
    }
    self.addFunding = function(){
        self.fundings.push(new FundingViewModel({fundingSournce : "",fundingType : "", fundingSourceAmount : 0}))
    }


    var initialCountries = project.countries && $.isArray(project.countries) && project.countries.length > 0 ? project.countries : ['Australia']
    self.countries = ko.observableArray(initialCountries)
    var initialUNRegions = project.uNRegions && $.isArray(project.uNRegions) && project.uNRegions.length > 0 ? project.uNRegions : ['Oceania']
    self.uNRegions = ko.observableArray(initialUNRegions)
    self.origin = ko.observable(project.origin)

    self.facets = ko.observableArray();

    self.coverage = project.coverage

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
    self.organisationName = ko.observable(project.organisationName ? project.organisationName : '');

    self.collectoryInstitutionId = ko.computed(function() {
            var org;
            if(self.organisationId() && self.organisationSearch) {
                if (self.organisationSearch.selectedOrganisation['organisationId'] === self.organisationId()) {
                    org = self.organisationSearch.selectedOrganisation;
                }
            }
            return  org && org.collectoryInstitutionId ? org.collectoryInstitutionId: "";
    });

    self.transients.truncatedOrganisationName = ko.computed(function () {
        return truncate(self.organisationName(), 50);
    });

    self.transients.truncatedAim = ko.computed(function () {
        return truncate(self.aim(), 80);
    });

    self.transients.truncatedName = ko.computed(function () {
        return truncate(self.name(), 50);
    });
    
    

    var legalCustodianVal = project.legalCustodianOrganisation? project.legalCustodianOrganisation: ko.utils.unwrapObservable(self.organisationName);
    self.legalCustodianOrganisation = ko.observable(legalCustodianVal);


    self.transients = self.transients || {};
    self.transients.checkVisibility = function (checkElementId, visibleElementId) {
        function check() {
            if($(checkElementId).val() == '') {
                $(visibleElementId).hide();
            }
        }

        setTimeout(check, 0);
        return true;
    };

    var legalCustodianOrganisationTypeVal = project.legalCustodianOrganisationType? project.legalCustodianOrganisationType: "";
    self.legalCustodianOrganisationType = ko.observable(legalCustodianOrganisationTypeVal);


    self.orgIdGrantee = ko.observable(project.orgIdGrantee);
    self.orgIdSponsor = ko.observable(project.orgIdSponsor);
    self.orgGrantee = ko.observable(project.orgGrantee ? project.orgGrantee : '');
    self.orgSponsor = ko.observable(project.orgSponsor ? project.orgSponsor : '');
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
    self.noCost = ko.observable(project.noCost);
    self.hasTeachingMaterials = ko.observable($.inArray("hasTeachingMaterials", project.tags) >= 0);
    self.isCitizenScience = ko.observable(project.isCitizenScience);
    self.isDIY = ko.observable($.inArray("isDIY", project.tags) >= 0);
    self.isHome = ko.observable($.inArray("isHome", project.tags) >= 0);
    self.mobileApp = ko.observable(project.mobileApp);
    self.isWorks = ko.observable(project.isWorks);
    self.isEcoScience = ko.observable(project.isEcoScience);
    self.isExternal = ko.observable(project.isExternal);
    self.isSciStarter = ko.observable(project.isSciStarter);
    self.isMERIT = ko.observable(project.isMERIT);
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
    self.baseLayer = ko.observable(project.baseLayer || '');
    self.termsOfUseAccepted = ko.observable(project.termsOfUseAccepted || false);
    self.alaHarvest = ko.observable(project.alaHarvest ? true : false);
    self.industries = ko.observableArray(project.industries);
    self.transients.notification = new EmailViewModel(fcConfig);
    self.transients.yesNoOptions = ["Yes","No"];
    self.transients.alaHarvest = ko.computed({
        read: function () {
            return self.alaHarvest() ? 'Yes' : 'No';
        },
        write: function (newValue) {
            if (newValue === 'Yes') {
                self.alaHarvest(true);
            } else if (newValue === 'No') {
                self.alaHarvest(false);
            }
        }
    });

    self.updateProject = function(jsonData){
        return $.ajax({
            url: fcConfig.projectUpdateUrl,
            type: 'POST',
            data: JSON.stringify(jsonData),
            contentType: 'application/json',
            success: function (data) {
                if (data.error) {
                    console.error(data)
                    bootbox.alert("Error "+ data.error);
                }
                else {
                    bootbox.alert("Successfully updated");
                }
            },
            error: function (data) {
                console.error(data)
                bootbox.alert("Error updating, try again later");

            }
        });
    };

    self.alaHarvest.subscribe(function(newValue) {
        var data = {alaHarvest: newValue };
        self.updateProject(data);
    });

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
    self.transients.dataCollectionWhiteList = []
    self.transients.uNRegions = ko.observableArray();
    self.transients.countries = ko.observableArray();
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
            if(types[i] == value){
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

    self.transients.getCountries = function () {
        var url = fcConfig.countriesUrl
        if(url){
            $.ajax(url, {
                success: function (data) {
                    self.transients.countries ( data );
                }
            })
        }
    }

    self.transients.getUNRegions = function () {
        var url = fcConfig.uNRegionsUrl
        if(url){
            $.ajax(url, {
                success: function (data) {
                    self.transients.uNRegions ( data );
                }
            })
        }
    }

    self.transients.getDataCollectionWhiteList = function () {
        var url = fcConfig.dataCollectionWhiteListUrl
        if(url){
            $.ajax(url, {
                success: function (data) {
                    self.transients.dataCollectionWhiteList.push.apply(self.transients.dataCollectionWhiteList, data );
                }
            })
        }
    }

    /**
     * Remove a selected UN region
     * @param data
     * @param event
     */
    self.transients.removeUNRegion = function (data, event) {
        self.uNRegions.remove(data)
    }

    /**
     * Remove a selected country
     * @param data
     * @param event
     */
    self.transients.removeCountry = function (data, event) {
        self.countries.remove(data)
    }

    /**
     * Select a UN Region
     * @param data
     * @param event
     */
    self.transients.selectUNRegion = function (model , event) {
        var region =  event.target.value
        var valid = false
        self.transients.uNRegions().forEach(function(item){
            if(item == region){
                valid = true
            }
        })

        valid && $.inArray(region, self.uNRegions()) == -1 && self.uNRegions.push (region)
    }

    /**
     * Select a country
     * @param data
     * @param event
     */
    self.transients.selectCountry = function (model, event) {
        var country = event.target.value
        if(country != "---------"){
            var valid = false
            self.transients.countries().forEach(function(item){
                if(item == country){
                    valid = true
                }
            })

            valid && $.inArray(country, self.countries()) == -1 && self.countries.push (country)
        }
    }


    self.transients.validateCountries = function() {
        if(self.countries().length < 1) {
            return "Countries field is required"
        }
    }

    self.transients.validateUNRegions = function () {
        if(self.uNRegions().length < 1) {
            return "UN Regions field is required"
        }
    }

    self.transients.validateSiteViewModel  = function () {
        if(!self.transients.siteViewModel.isValid(true)) {
            return "You must define the spatial extent of the project area"
        }
    }

    /**
     * Validates project fields that are not covered by jQuery Vaiidation Engine
     * @returns an HTML string with the list of errors if the validation fails
     */
    self.transients.projectHasErrors  = function () {
        var errors = []

        // Countries and uNRegions could easily be managed as jQuery validation engine callFunc functions
        // however it is buggy and won't display error messages unless accompained by required which stuff the logic.
        // hence the overcomplicated approach.
        var countriesError = self.transients.validateCountries()
        countriesError && errors.push(countriesError)

        var uNRegionsError = self.transients.validateUNRegions()
        uNRegionsError && errors.push(uNRegionsError)

        var siteError = self.transients.validateSiteViewModel()
        siteError && errors.push(siteError)

        if(errors.length > 0) {
            var result = "<ul>"

            errors.forEach(function(item){
                result += "<li>" + item + "</li>"

                })
            result += "</ul>"
            return result
        }
    }

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
            switch (value){
                case 'citizenScience':
                case 'survey':
                    self.isCitizenScience(true);
                    self.isWorks(false);
                    self.isEcoScience(false);
                    self.projectType('survey');
                    break;
                case 'works':
                    self.isWorks(true);
                    self.isCitizenScience(false);
                    self.isEcoScience(false);
                    self.projectType(value);
                    break;
                case 'ecoScience':
                    self.isEcoScience(true);
                    self.isWorks(false);
                    self.isCitizenScience(false);
                    self.projectType(value);
                    break;
            }
        }
    });

    self.transients.index = ko.observable();
    self.transients.industries = ['Bananas','Cropping','Grazing','Sugarcane'];

    self.loadPrograms = function (programsModel) {
        $.each(programsModel.programs, function (i, program) {
            if (program.readOnly && project.associatedProgram != program.name) {
                return;
            }
            self.transients.programs.push(program.name);
            self.transients.subprograms[program.name] = $.map(program.subprograms,function (obj, i){return obj.name});
        });
        self.associatedProgram(project.associatedProgram); // to trigger the computation of sub-programs
    };

    self.toJS = function() {
        var toIgnore = self.ignore; // document properties to ignore.
        toIgnore = toIgnore.concat(['transients', 'daysStatus', 'projectDatesChanged', 'collectoryInstitutionId', 'ignore', 'projectStatus','fundingTypes']);
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

    self.updateMethodDocs = function(doc) {
        $.each (self.documents(), function (i, obj) {
            if (obj.projectActivityId === doc.projectActivityId && obj.role() === 'methodDoc') {
                self.documents.remove(obj);
            }
        });
        self.addDocument(doc);
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
                                window.location.href = fcConfig.homePagePath;
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

    self.transients.getCountries()
    self.transients.getUNRegions()
    self.transients.getDataCollectionWhiteList()
};

/**
 * View model for use by the project create and edit pages.  Extends the ProjectViewModel to provide support
 * for organisation search and selection as well as saving project information.
 * @param project pre-populated or existing project data.
 * @param isUserEditor true if the user can edit the project.
 * @constructor
 */
function CreateEditProjectViewModel(project, isUserEditor, options) {
    ProjectViewModel.apply(this, [project, isUserEditor]);

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
        var oldValue = self.transients.siteViewModel.site().name();
        var prefix = "Project area for ";
        if (oldValue.indexOf(prefix) >= 0 || !oldValue) {
            self.transients.siteViewModel.site().name(prefix + projectName);
        }
    });

    self.organisationSearch = new OrganisationSelectionViewModel(project.organisationId, project.organisationName);

    self.associatedOrganisationSearch = new OrganisationSelectionViewModel();
    self.transients.associatedOrgNotInList = ko.observable(false);
    self.transients.associatedOrgUrl = ko.observable();
    self.transients.associatedOrgLogoUrl = ko.observable();

    self.granteeOrganisation = new OrganisationSelectionViewModel(project.orgIdGrantee, project.orgGrantee);
    self.sponsorOrganisation = new OrganisationSelectionViewModel(project.orgIdSponsor, project.orgSponsor);

    self.transients.termsOfUseClicked = ko.observable(false);
    
    self.transients.isDataEntryValid = function () {
        if(!fcConfig.hideProjectEditScienceTypes) {
            if (!self.isExternal()) {
                var types = self.scienceType();
                for( var index = 0; index < types.length; index++){
                    var type = types[index];
                    for(var j = 0; j < self.transients.dataCollectionWhiteList.length; j++){
                        if(type == self.transients.dataCollectionWhiteList[j]){
                            return true
                        }
                    }
                }

                return false
            }

            return true
        }

        return true
    };

    self.clickTermsOfUse = function() {
        self.transients.termsOfUseClicked(true);
        return true;
    };

    self.createOrganisation = function() {
        var projectData = self.modelAsJSON();
        amplify.store(config.storageKey, projectData);
        var here = document.location.href;
        document.location.href = config.organisationCreateUrl+'?returnTo='+here+'&returning=true';
    };

    self.organisationSearch.selectedOrganisation.subscribe(function(newSelection) {
        if (! $.isEmptyObject( newSelection)) {
            self.organisationId(newSelection.organisationId);
            self.organisationName(newSelection.name());
        } else {
            self.organisationId('');
            self.organisationName('');
        }
    });

    self.granteeOrganisation.selectedOrganisation.subscribe(function(newSelection) {
        if (! $.isEmptyObject( newSelection)) {
            self.orgIdGrantee(newSelection.organisationId);
            self.orgGrantee(newSelection.name());
        } else {
            self.orgIdGrantee('');
            self.orgGrantee('');
        }
    });

    self.sponsorOrganisation.selectedOrganisation.subscribe(function(newSelection) {
        if (! $.isEmptyObject( newSelection)) {
            self.orgIdSponsor(newSelection.organisationId);
            self.orgSponsor(newSelection.name());
        } else {
            self.orgIdSponsor('');
            self.orgSponsor('');
        }
    });

    self.hasOrgAlreadyBeenAdded = function(newOrganisation) {
        for(var i = 0; i<self.associatedOrgs().length; i++) {
            var existingOrganisation=self.associatedOrgs()[i];
            if(existingOrganisation.name === newOrganisation.name) {
                return true;
            }
        }
        return false;
    }

    self.associatedOrganisationSearch.addSelectedOrganisation = function() {
        var org = { id: self.associatedOrgs().length };
        if (self.transients.associatedOrgNotInList()) {

            if($('#associatedOrgLogo').validationEngine('validate')) {
                //Invalid content, let validation engine pop up the error and we just stop processing
                return;
            }
            org.name = self.associatedOrganisationSearch.searchTerm();
            org.url = self.transients.associatedOrgUrl() || null;
            org.logo = self.transients.associatedOrgLogoUrl() || null;

        } else {
            var selectedOrganisation = self.associatedOrganisationSearch.selectedOrganisation();

            org.organisationId = selectedOrganisation.organisationId || "";
            org.name = selectedOrganisation.name();
            org.url = selectedOrganisation.url() || "";
            org.logo = selectedOrganisation.logoUrl() || "";
        }

        if(!self.hasOrgAlreadyBeenAdded(org)) {
            self.associatedOrgs.push(org);
            self.associatedOrganisationSearch.clearSelection();
            self.transients.associatedOrgLogoUrl(false);
            self.transients.associatedOrgUrl(null);
            self.transients.associatedOrgLogoUrl(null);
        } else {
            showAlert("This organisation has already been added",  "alert-error", "orgAlreadyAddedMessage")
        }

    };


    self.removeAssociatedOrganisation = function(org, event) {
        self.associatedOrgs.remove(org);
    };


    self.ignore = self.ignore.concat(['organisationSearch', 'associatedOrganisationSearch', 'granteeOrganisation', 'sponsorOrganisation']);
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

    var selectedOrg = organisationSelectionViewModel.selectedOrganisation();
    if (!selectedOrg || selectedOrg == null || _.isUndefined(selectedOrg) || $.isEmptyObject(selectedOrg)) {
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
        types:['News and Events', 'Project Stories'],
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
        $.post(url).always(function() {
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