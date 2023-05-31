// todo: Delete?
var projectPromise = entities.getProject();
var paPromise = entities.getProjectActivity();
$.when(projectPromise, paPromise).done(function (projectResult, paResult) {
    var project = projectResult.data,
        pa = paResult.data,
        paViewModel = new pActivityInfo(pa),
        actvitiesViewModel = new ActivitiesViewModel(),
        paID = "pActivity",
        activitiesID = "activities";

    ko.applyBindings(paViewModel, document.getElementById(paID));
    ko.applyBindings(actvitiesViewModel, document.getElementById(activitiesID));

    entities.getActivitiesForProjectActivity().then(function (result) {
        actvitiesViewModel.transients.load(result.data.activities);
    });
})

function ActivitiesViewModel() {
    var self = this;

    self.activities = ko.observableArray();

    self.transients = {
        load: function (activities) {
            var models = []
            activities && activities.forEach(function (activity) {
                if (activity instanceof ActivityViewModel) {
                    models.push(activity);
                }
                else {
                    models.push(new ActivityViewModel(activity));
                }
            });

            self.activities(models);
        }
    }
}

function ActivityViewModel(activity) {
    var self = this;
    self.rawData = activity;
    self.activityId = activity.activityId;
    self.showCrud = ko.observable(activity.showCrud);
    self.userCanModerate = activity.userCanModerate;
    self.projectActivityId = activity.projectActivityId;
    self.name = activity.name;
    self.type = activity.type;
    self.lastUpdated = ko.observable(activity.lastUpdated).extend({simpleDate: true});
    self.ownerName = activity.activityOwnerName;
    self.userId = activity.userId;
    self.siteId = ko.observable(activity.siteId);
    self.embargoed = activity.embargoed;
    self.embargoUntil = ko.observable(activity.embargoUntil).extend({simpleDate: false});
    self.projectName = activity.projectName;
    self.projectId = activity.projectId;
    self.projectType = activity.projectType;
    self.records = ko.observableArray();
    self.isWorksProject = ko.pureComputed(function () {
        return self.projectType === "works"
    });

    self.transients = {
        viewUrl: ko.observable((self.isWorksProject() ? fcConfig.worksActivityViewUrl : fcConfig.activityViewUrl) + "&activityId=" + self.activityId).extend({returnTo: fcConfig.returnTo, dataVersion: fcConfig.version}),
        editUrl: ko.observable((self.isWorksProject() ? fcConfig.worksActivityEditUrl : fcConfig.activityEditUrl) + "&activityId=" + self.activityId).extend({returnTo: fcConfig.returnTo}),
        addUrl: ko.observable(fcConfig.activityAddUrl + "?projectActivityId=" + self.projectActivityId).extend({returnTo: fcConfig.returnTo}),
        thumbnailUrl: ko.observable(activity.thumbnailUrl ||  fcConfig.imageLocation + "font-awesome/5.15.4/svgs/regular/image.svg"),
        loadRecords: function (records) {
            var allRecords = $.map(activity.records ? activity.records : [], function (record, index) {
                record.parent = self;
                record.thumbnailUrl = self.transients.thumbnailUrl();
                return new RecordViewModel(record);
            });

            self.records(allRecords);
        }
    }

    self.transients.loadRecords(activity.records);
}

function RecordViewModel (record) {
    var self = this;
    if (!record) record = {};
    self.rawData = record;
    self.parent = record.parent;
    self.occurrenceID = record.occurrenceID;
    self.guid = ko.observable(record.guid);
    self.name = ko.observable(record.name);
    self.commonName = record.commonName;
    self.coordinates = record.coordinates;
    self.multimedia = record.multimedia || [];
    self.eventTime = record.eventTime;
    self.individualCount = record.individualCount;
    self.eventDate =  ko.observable(record.eventDate).extend({simpleDate: false});
    self.thumbnailUrl = record.thumbnailUrl;
};