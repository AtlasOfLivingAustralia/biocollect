var pActivityInfo = function(o, selected, startDate, organisationName){
    var self = $.extend(this, new Documents());
    if(!o) o = {};
    if(!selected) selected = false;
    if(!organisationName) organisationName = "";

    self.formatAttribution = function(organisationName, surveyName) {
        return organisationName + (surveyName ? (", " + surveyName) : "");
    };

    self.transients = self.transients || {};

    self.projectActivityId = ko.observable(o.projectActivityId);
    self.name = ko.observable(o.name ? o.name : "Survey name");
    self.description = ko.observable(o.description);
    self.status = ko.observable(o.status ? o.status : "active");
    self.startDate = ko.observable(o.startDate ? o.startDate :  startDate).extend({simpleDate:false});
    self.endDate = ko.observable(o.endDate).extend({simpleDate:false});
    self.commentsAllowed = ko.observable(o.commentsAllowed ? o.commentsAllowed : false);
    self.published = ko.observable(o.published ? o.published : false);
    self.publicAccess = ko.observable(o.publicAccess ? o.publicAccess : false);
    self.attribution = ko.observable(o.attribution ? o.attribution : self.formatAttribution(organisationName, self.name()));
    self.methodType = ko.observable(o.methodType || "");
    self.methodName = ko.observable(o.methodName);
    self.methodAbstract = ko.observable(o.methodAbstract);
    self.methodUrl = ko.observable(o.methodUrl);
    self.downloadFormTemplateUrl = ko.observable(o.pActivityFormName ? fcConfig.downloadTemplateFormUrl + "?type=" + o.pActivityFormName + "&expandList=true" : "")

 /*   self.datasetVersion = ko.observable(o.datasetVersion ? o.datasetVersion : "");
    self.submissionDoi = ko.observable(o.submissionDoi ? o.submissionDoi : "");
    self.submissionPublicationDate = ko.observable(o.submissionPublicationDate ? o.submissionPublicationDate : "");
    self.datasetSubmitter = ko.observable(o.datasetSubmitter ? o.datasetSubmitter : "");
*/
    self.current = ko.observable(selected);
    self.methodType.subscribe(function (newValue) {
        if (newValue === 'opportunistic') {
            self.methodName(fcConfig.opportunisticDisplayName);
        } else {
            self.methodName("");
        }
    });

    self.transients.isSystematicSurvey = ko.pureComputed(function () {
        return self.methodType() === 'systematic';
    });

    self.addActivity = function(){
        window.location.href = fcConfig.activityCreateUrl + "/" + self.projectActivityId();
    };

    self.listActivityRecords = function() {
        $('#data-tab').tab('show');
        if (!_.isUndefined(activitiesAndRecordsViewModel)) {
            activitiesAndRecordsViewModel.selectFacetTerm(self.name(), "Survey");
        }
    };

    self.showAekosDetails = function() {
        if (self.transients.showAekosDetailsState()) {
            self.transients.showAekosDetailsState(false);
            self.transients.aekosToggleText('Show Datasets in AEKOS');
        } else {
            self.transients.showAekosDetailsState(true);
            self.transients.aekosToggleText('Hide Datasets in AEKOS');
        }
    };


    self.transients.organisationName = ko.observable(organisationName);
    self.transients.oldName = ko.observable(self.name());

    self.transients.showAekosDetailsState = ko.observable(false);

    self.transients.aekosToggleText = ko.observable('Show Datasets in AEKOS');

    // Publish is allowed only when no data's are associated with the survey
    // Survey Info & visibility can be saved regardless of the existence of the data.
    self.transients.saveOrUnPublishAllowed = ko.observable(false);
    // This list will determine if a site can be removed from a survey even after removing it.
    self.transients.sitesWithData = ko.observableArray([]);
    self.transients.siteWithDataAjaxFlag = ko.observable(false);
    self.transients.imageUploadUrl  = ko.observable(fcConfig.imageUploadUrl);
    self.transients.methoddocumentUpdateUrl  = ko.observable(fcConfig.methoddocumentUpdateUrl);

    self.transients.logoUrl = ko.pureComputed(function(){
        return self.logoUrl() ? self.logoUrl() : fcConfig.imageLocation + "no-image-2.png";
    });

    self.methodDocUrl = ko.pureComputed(function(){
        var methodDocument = self.findDocumentByRole(self.documents(), 'methodDoc');
        return methodDocument ? methodDocument.url + "&role='methodDoc'" : "";
    });

    self.methodDocName = ko.pureComputed(function(){
        var methodDocument = self.findDocumentByRole(self.documents(), 'methodDoc');
        return methodDocument ? methodDocument.name: "";
    });

    self.removeMethodDoc = function() {
        self.deleteDocumentByRole('methodDoc');
    };

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
        if(self.transients.daysSince() < 0){
            status = "Active, Not yet started"
        }
        else if(self.transients.daysSince() >= 0 && (self.transients.daysRemaining() > 0 || self.transients.daysRemaining() == -1)){
            status = "Active, In progress"
        }
        else if(self.transients.daysSince() >= 0 && self.transients.daysRemaining() == 0){
            status = "Inactive, Completed"
        }
        return status;
    });

    if (o.documents !== undefined && o.documents.length > 0) {
        $.each(['logo', 'methodDoc'], function(i, role){
            var document = self.findDocumentByRole(o.documents, role);
            if (document) {
                self.documents.push(document);
            }
        });
    }

    self.isInfoValid = function () {
        return self.name() && self.description() && self.attribution() && self.startDate() && self.isEndDateAfterStartDate();
    };

    self.isEndDateAfterStartDate = function () {
        if (self.endDate()) {
            var start = moment(self.startDate());
            var end = moment(self.endDate());
            return end >= start;
        } else {
            return true;
        }
    };

    self.name.subscribe(function(newValue) {
        var initial = self.formatAttribution(self.transients.organisationName(), self.transients.oldName());
        if(initial == self.attribution()){
            self.attribution(self.formatAttribution(self.transients.organisationName(),newValue));
            self.transients.oldName(self.name());
        }
    });

    /**
     * get sites with data for a given survey/project activity
     * @param obj
     */
    self.getSitesWithData = function () {
        self.transients.sitesWithData.removeAll();
        self.transients.siteWithDataAjaxFlag(false);
        $.ajax({
            url: fcConfig.sitesWithDataForProjectActivity + "/" + self.projectActivityId(),
            type: 'GET',
            timeout: 10000,
            success: function (data) {
                if(data.sites){
                    self.transients.sitesWithData(data.sites)
                }
            },
            error: function (data) {
                console.log("Error retrieving sites with data for survey.", "alert-error");
            }
        }).done(function () {
            self.transients.siteWithDataAjaxFlag(true);
        });
    };
};
