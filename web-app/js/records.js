var RecordListsViewModel = function (placeHolder) {
    var self = this;
    self.records = ko.observableArray();
    self.pagination = new PaginationViewModel({}, self);
    self.transients = {};
    self.transients.loading = ko.observable(true);
    self.transients.placeHolder = placeHolder;

    self.load = function (records, page, total) {
        self.records([]);
        var list = $.map(records ? records : [], function (record, index) {
            return new RecordViewModel(record);
        });
        self.records(list);

        // only initialise the pagination if we are on the first page load
        if (page == 0) {
            self.pagination.loadPagination(page, total);
        }
    };

    self.refreshPage = function (offset) {
        if (!offset) {
            offset = 0;
        }
        var params = {max: self.pagination.resultsPerPage(), offset: offset, sort: 'lastUpdated', order: 'desc'};

        var url = fcConfig.recordListUrl + ((fcConfig.recordListUrl.indexOf('?') > -1) ? '&' : '?') + $.param(params);
        $.ajax({
            url: url,
            type: 'GET',
            contentType: 'application/json',

            success: function (data) {
                self.load(data.records, Math.ceil(offset / self.pagination.resultsPerPage()), data.total);
            },
            error: function (data) {
                alert('An unhandled error occurred: ' + data);
            },
            complete: function () {
                self.transients.loading(false);
            }
        });
    };

    self.delete = function (record) {
        bootbox.confirm("Are you sure you want to delete this record?", function (result) {
            if (result) {
                var url = fcConfig.recordDeleteUrl + "/" + record.occurrenceID();
                $.ajax({
                    url: url,
                    type: 'DELETE',
                    contentType: 'application/json',
                    success: function (data) {
                        if (data.text == 'deleted') {
                            showAlert("Successfully deleted.", "alert-success", self.transients.placeHolder);
                            self.refreshPage(0);
                        } else {
                            showAlert("Error deleting the record, please try again later.", "alert-error", self.transients.placeHolder);
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

    self.refreshPage(0);
};

var RecordViewModel = function (record) {
    var self = this;
    if (!record) record = {};
    self.occurrenceID = ko.observable(record.occurrenceID);
    self.showCrud = ko.observable(record.showCrud);
    var projectActivityOpen = true;
    if (record.pActivity.endDate) {
        projectActivityOpen = moment(record.pActivity.endDate).isAfter(moment());
    }
    self.showAdd = ko.observable(projectActivityOpen);
    self.name = ko.observable(record.name);
    self.guid = ko.observable(record.guid);
    self.activityId = ko.observable(record.activityId);
    self.projectActivityId = ko.observable(record.projectActivityId);
    self.lastUpdated = ko.observable(record.lastUpdated).extend({simpleDate: false});
    self.transients = {};
    self.transients.viewUrl = ko.observable(fcConfig.activityViewUrl + "/" + self.activityId()).extend({returnTo: fcConfig.returnTo});
    self.transients.editUrl = ko.observable(fcConfig.activityEditUrl + "/" + self.activityId()).extend({returnTo: fcConfig.returnTo});
    self.transients.addUrl = ko.observable(fcConfig.activityAddUrl + "/" + self.projectActivityId()).extend({returnTo: fcConfig.returnTo});
    self.transients.pActivity = new pActivityInfo(record.pActivity);
};