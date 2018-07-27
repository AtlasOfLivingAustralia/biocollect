
function ActivityViewModel (act, site, project, metaModel, themes) {
    var self = this;
    self.activityId = act.activityId;
    self.description = ko.observable(act.description);
    self.notes = ko.observable(act.notes);
    self.startDate = ko.observable(act.startDate || act.plannedStartDate).extend({simpleDate: false});
    self.endDate = ko.observable(act.endDate || act.plannedEndDate).extend({simpleDate: false});
    self.eventPurpose = ko.observable(act.eventPurpose);
    self.fieldNotes = ko.observable(act.fieldNotes);
    self.associatedProgram = ko.observable(act.associatedProgram);
    self.associatedSubProgram = ko.observable(act.associatedSubProgram);
    self.projectStage = ko.observable(act.projectStage || "");
    self.progress = ko.observable(act.progress || 'started');
    self.mainTheme = ko.observable(act.mainTheme);
    self.type = ko.observable(act.type);
    self.siteId = ko.observable(act.siteId);
    self.projectId = act.projectId;
    self.transients = {};
    self.transients.site = site;
    self.transients.project = project;
    self.transients.metaModel = metaModel || {};
    self.transients.activityProgressValues = ['planned','started','finished'];
    self.transients.themes = $.map(themes || [], function (obj, i) { return obj.name });
    self.goToProject = function () {
        if (self.projectId) {
            document.location.href = fcConfig.projectViewUrl + self.projectId;
        }
    };
    self.goToSite = function () {
        if (self.siteId()) {
            var url = fcConfig.siteViewUrl + self.siteId();
            if (self.projectId) {
                url += '?projectId='+self.projectId;
            }
            document.location.href = url;
        }
    };
    if (metaModel.supportsPhotoPoints) {
        self.transients.photoPointModel = ko.observable(new PhotoPointViewModel(site, act));
    }
};

function sortActivities(activities) {
    activities.sort(function (a,b) {

        if (a.stageOrder !== undefined && b.stageOrder !== undefined && a.stageOrder != b.stageOrder) {
            return a.stageOrder - b.stageOrder;
        }
        if (a.sequence !== undefined && b.sequence !== undefined) {
            return a.sequence - b.sequence;
        }

        if (a.plannedStartDate != b.plannedStartDate) {
            return a.plannedStartDate < b.plannedStartDate ? -1 : (a.plannedStartDate > b.plannedStartDate ? 1 : 0);
        }
        var numericActivity = /[Aa]ctivity (\d+)(\w)?.*/;
        var first = numericActivity.exec(a.description);
        var second = numericActivity.exec(b.description);
        if (first && second) {
            var firstNum = Number(first[1]);
            var secondNum = Number(second[1]);
            if (firstNum == secondNum) {
                // This is to catch activities of the form Activity 1a, Activity 1b etc.
                if (first.length == 3 && second.length == 3) {
                    return first[2] > second[2] ? 1 : (first[2] < second[2] ? -1 : 0);
                }
            }
            return  firstNum - secondNum;
        }
        else {
            if (a.dateCreated !== undefined && b.dateCreated !== undefined && a.dateCreated != b.dateCreated) {
                return a.dateCreated < b.dateCreated ? 1 : -1;
            }
            return a.description > b.description ? 1 : (a.description < b.description ? -1 : 0);
        }

    });
}

var ActivityNavigationViewModel = function(navigationMode, projectId, activityId, siteId, config) {
    var self = this;

    self.stayOnPage = (navigationMode == 'stayOnPage');

    self.activities = ko.observableArray();

    self.stages = ko.observableArray();
    self.selectedStage = ko.observable();
    self.selectedActivity = ko.observable();
    self.stageActivities = ko.observableArray();

    self.selectedStage.subscribe(function (newStage) {
        self.stageActivities( _.filter(self.activities(), function (activity) { return activity.stage == newStage  }));
        self.selectedActivity(self.nextActivity());
    });
    self.hasNext = function() {
        return self.nextActivity().activityId !== undefined;
    };
    self.hasPrevious = function() {
        return self.previousActivity().activityId !== undefined;
    };
    self.nextActivityUrl = function() {
        if (self.hasNext()) {
            return config.activityUrl + '/' + self.nextActivity().activityId + (config.returnTo ? '?returnTo=' + encodeURIComponent(config.returnTo) : '');
        }
        return '#';

    };
    self.previousActivityUrl = function() {
        if (self.hasPrevious()) {
            return config.activityUrl + '/' + self.previousActivity().activityId + (config.returnTo ? '?returnTo=' + encodeURIComponent(config.returnTo) : '');
        }
        return '#';

    };
    self.nextActivity = function() {
        return self.activities()[currentActivityIndex()+1] || {};
    };
    self.previousActivity = function() {
        return self.activities()[currentActivityIndex()-1] || {};
    };
    self.returnText = ko.pureComputed(function() {
        if (config.navContext == 'project') {
            return 'Return to project';
        }
        else if (config.navContext == 'site') {
            return 'Return to site';
        }
        else {
            return 'Return';
        }
    });

    self.navigateUrl = ko.computed(function() {
        if (self.selectedActivity()) {
            return config.activityUrl + '/' +self.selectedActivity().activityId + (config.returnTo ? '?returnTo=' + encodeURIComponent(config.returnTo) : '');
        }
        return '#';

    });

    self.returnUrl = config.returnTo;

    function currentActivityIndex() {
        return _.findIndex(self.activities(), function (activity) {
            return activity.activityId == activityId;
        });
    }

    self.cancel = function() {
        self.return();
    };

    self.return = function() {
        document.location.href = self.returnUrl;
    };

    self.activities.subscribe(function(activities) {

        self.stages(_.uniq(_.pluck(activities, 'stage')));

        if (self.hasNext()) {
            var next = self.nextActivity();
            self.selectedStage(next.stage);
        }

    });

    self.afterSave = function(valid, saveResponse) {
        if (valid) {

            if (self.stayOnPage) {
                showAlert("Your data has been saved.  Please select one of the the navigation options below to continue.", "alert-info", 'saved-nav-message-holder');
                $("html, body").animate({
                    scrollTop: $(config.savedNavMessageSelector).offset().top + 'px'
                });
                var $nav = $(config.activityNavSelector);

                var oldBorder = $nav.css('border');
                $nav.css('border', '2px solid black');
                setTimeout(function () {
                    $nav.css('border', oldBorder);
                }, 5000);
            }
            else {
                self.return();
            }
        }
    };

    if (self.stayOnPage) {
        var navActivitiesUrl = config.navigationUrl;
        if (config.navContext == 'site' && siteId) {
            navActivitiesUrl += '?siteId='+siteId;
        }
        $.get(navActivitiesUrl).done(function (activities) {
            sortActivities(activities);
            self.activities(activities);
        });
    }

};