var ActivityListsViewModel = function(placeHolder){
    var self = this;
    self.activities = ko.observableArray();
    self.pagination = new PaginationViewModel({},self);
    self.transients = {};
    self.transients.loading = ko.observable(true);
    self.transients.placeHolder = placeHolder;

    self.load = function(activities, page, total){
        self.activities([]);

        var activities = $.map(activities ? activities : [] , function(activity, index){
            return new ActivityViewModel(activity);
        });
        self.activities(activities);

        // only initialise the pagination if we are on the first page load
        if (page == 0) {
            self.pagination.loadPagination(page, total);
        }
    };

    self.delete = function(activity){
        bootbox.confirm("Are you sure you want to delete the survey and records?", function (result) {
            if (result) {
                var url = fcConfig.activityDeleteUrl + "/" + activity.activityId();
                $.ajax({
                    url: url,
                    type: 'DELETE',
                    contentType: 'application/json',
                    success: function (data) {
                        if (data.text == 'deleted') {
                            showAlert("Successfully deleted.", "alert-success", self.transients.placeHolder);
                            self.refreshPage(0);
                        } else {
                            showAlert("Error deleting the survey, please try again later.", "alert-error", self.transients.placeHolder);
                        }
                    },
                    error: function (data) {
                        if (data.status == 401) {
                            var message = $.parseJSON(data.responseText);
                            bootbox.alert(message.error);
                        } else {
                            alert('An unhandled error occurred: ' + data);
                        }
                    }
                });
            }
        });
    };

    self.refreshPage = function(offset){
        if (!offset) {
            offset = 0;
        }
        var params = { max: self.pagination.resultsPerPage(), offset: offset,  sort:'lastUpdated', order:'desc'};

        var url = fcConfig.activityListUrl + ((fcConfig.activityListUrl.indexOf('?') > -1) ? '&' : '?') + $.param( params );
        $.ajax({
            url: url,
            type: 'GET',
            contentType: 'application/json',
            success: function (data) {
                self.load(data.activities, Math.ceil(offset / self.pagination.resultsPerPage()), data.total);
            },
            error: function (data) {
                alert('An unhandled error occurred: ' + data);
            },
            complete: function(){
                self.transients.loading(false);
            }
        });
    };

    self.refreshPage(0);
};

var ActivityViewModel = function(activity){
    var self = this;
    if(!activity) activity = {};

    self.activityId = ko.observable(activity.activityId);
    self.showCrud = ko.observable(activity.showCrud);
    var projectActivityOpen = true;
    if (activity.pActivity.endDate) {
        projectActivityOpen = moment(activity.pActivity.endDate).isAfter(moment());
    }
    self.showAdd = ko.observable(projectActivityOpen);
    self.projectActivityId = ko.observable(activity.projectActivityId);
    self.name = ko.observable();
    self.type = ko.observable(activity.type);
    self.lastUpdated = ko.observable(activity.lastUpdated).extend({simpleDate: false});
    self.transients = {};
    self.transients.viewUrl = ko.observable(fcConfig.activityViewUrl + "/" + self.activityId()).extend({returnTo:fcConfig.returnTo});
    self.transients.editUrl = ko.observable(fcConfig.activityEditUrl + "/" + self.activityId()).extend({returnTo:fcConfig.returnTo});
    self.transients.addUrl = ko.observable(fcConfig.activityAddUrl + "/" + self.projectActivityId()).extend({returnTo:fcConfig.returnTo});
    self.transients.pActivity = new pActivityInfo(activity.pActivity);
};