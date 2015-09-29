var RecordListsViewModel = function(){
  var self = this;
  self.records = ko.observableArray();
  self.pagination = new PaginationViewModel({},self);
  self.transients = {};
  self.transients.loading = ko.observable(true);

  self.load = function(records, pagination){
    self.records([]);
    var list = $.map(records ? records : [] , function(record, index){
      return new RecordViewModel(record);
    });
    self.records(list);
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
        self.load(data.records, data.pagination);
      },
      error: function (data) {
        alert('An unhandled error occurred: ' + data);
      },
      complete: function(){
        self.transients.loading(false);
      }
    });
  };

  //self.refreshPage();
};

var RecordViewModel = function(record){
  var self = this;
  if(!record) record = {};

  self.recordId = ko.observable(record.recordId);
  self.activityId = ko.observable(record.activityId);
  self.projectActivityId = ko.observable(activity.projectActivityId);
  self.lastUpdated = ko.observable(activity.lastUpdated).extend({simpleDate: false});
  self.transients = {};
  self.transients.viewUrl = ko.observable(fcConfig.activityViewUrl + "/" + self.activityId());
  self.transients.editUrl = ko.observable(fcConfig.activityEditUrl + "/" + self.activityId());
  self.transients.deleteUrl = ko.observable(fcConfig.activityDeleteUrl + "/" + self.activityId());
  self.transients.addUrl = ko.observable(fcConfig.activityAddUrl + "/" + self.projectActivityId());
  self.transients.pActivity = new pActivityInfo(activity.pActivity);
};