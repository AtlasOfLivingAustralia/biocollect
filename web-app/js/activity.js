var ActivityListsViewModel = function(){
    var self = this;
    self.activities = ko.observableArray();
    self.showCrud = ko.observable(false);
    self.pagination = new PaginationViewModel({},self);
    self.transients = {};
    self.transients.loading = ko.observable(true);

    self.load = function(activities, rp, total, showCrud){
        self.activities([]);
        self.showCrud(showCrud);
        var activities = $.map(activities ? activities : [] , function(activity, index){
            return new ActivityViewModel(activity);
        });
        self.activities(activities);
        self.pagination.loadPagination(rp, total);
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
                            location.reload(true);
                        } else {
                            bootbox.alert("Error deleting the survey, please try again later.");
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

    self.refreshPage = function(rp){
        if(!rp) rp = 1;
        var params = { max: self.pagination.resultsPerPage(), offset:rp-1,  sort:'lastUpdated', order:'desc'};

        var url = fcConfig.activityListUrl + ((fcConfig.activityListUrl.indexOf('?') > -1) ? '&' : '?') + $.param( params );
        $.ajax({
            url: url,
            type: 'GET',
            contentType: 'application/json',
            success: function (data) {
                self.load(data.activities, rp, data.total, data.showCrud);
            },
            error: function (data) {
                alert('An unhandled error occurred: ' + data);
            },
            complete: function(){
                self.transients.loading(false);
            }
        });
    };

    self.refreshPage();
};

var ActivityViewModel = function(activity){
    var self = this;
    if(!activity) activity = {};

    self.activityId = ko.observable(activity.activityId);
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