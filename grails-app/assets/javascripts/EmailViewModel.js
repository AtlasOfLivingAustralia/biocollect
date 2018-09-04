function EmailViewModel(options) {
    var self = this;
    self.body = ko.observable(self.body || '');
    self.subject = ko.observable(self.subject || '');
    self.recipients = ko.observableArray(self.recipients || []);

    self.sendNotification = function () {
        var emailData = getData(false);
        var request = self.placeNotificationRequest(emailData);
        request.done(function () {
            alert("Email successfully sent.");
            clear();
        }).fail(function () {
            alert("Failed to send email.");
        });
    };

    self.sendTestNotification = function () {
        var emailData = getData(true);
        var request = self.placeNotificationRequest(emailData);
        request.done(function () {
            alert("Sent test email.");
        }).fail(function () {
            alert("Failed to send test email.");
        });
    };

    self.placeNotificationRequest = function (emailData) {
        return $.ajax({
            url: options.projectNotificationUrl,
            data: emailData,
            method: 'post',
            contentType: 'application/json'
        });
    };

    function getData(isTest) {
        var data = ko.toJS(self, {ignore: 'transients'});

        if (isTest) {
            delete data.recipients;
        }

        return ko.toJSON(data);
    };

    function clear() {
        self.body('');
        self.subject = ko.observable('');
        self.recipients = ko.observableArray([]);
    };
};