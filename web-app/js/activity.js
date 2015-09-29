var ActivityListsViewModel = function(){
    var self = this;
    self.activities = ko.observableArray();
    self.pagination = new PaginationViewModel({},self);
    self.transients = {};
    self.transients.loading = ko.observable(true);

    self.load = function(activities, displayName, pagination){
        self.activities([]);
        var activities = $.map(activities ? activities : [] , function(activity, index){
            return new ActivityViewModel(activity);
        });
        self.activities(activities);
        self.pagination.loadPagination(pagination);
    };

    self.refreshPage = function(rp){
        if(!rp) rp = 1;
        var params = { rp:rp};
        var url = fcConfig.activityListUrl + "?" +$.param( params );
        $.ajax({
            url: url,
            type: 'GET',
            contentType: 'application/json',
            success: function (data) {
                self.load(data.activities, data.displayName, data.pagination);
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
    self.transients.viewUrl = ko.observable(fcConfig.activityViewUrl + "/" + self.activityId());
    self.transients.editUrl = ko.observable(fcConfig.activityEditUrl + "/" + self.activityId());
    self.transients.deleteUrl = ko.observable(fcConfig.activityDeleteUrl + "/" + self.activityId());
    self.transients.addUrl = ko.observable(fcConfig.activityAddUrl + "/" + self.projectActivityId());
    self.transients.pActivity = new pActivityInfo(activity.pActivity);
};