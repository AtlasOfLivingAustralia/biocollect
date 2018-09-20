function EmailViewModel(options) {
    var self = this,
        notificationId = options.notificationId || '#project-notification-tab',
        initMembers = false,
        specialRecipientList = [
        {
            userId: "ALL",
            displayName: "All Members"
        },
        {
            userId: "ALL_ADMINS",
            displayName: "All Admins"
        },
        {
            userId: "ALL_EDITORS",
            displayName: "All Editors"
        },
        {
            userId: "ALL_PROJECT_PARTICIPANTS",
            displayName: "All Project Participants"
        }];
    self.body = ko.observable('');
    self.subject = ko.observable('');

    self.transients = {};
    self.transients.recipients = ko.observableArray([]);
    self.transients.members = ko.observableArray([]);
    var pagination = self.transients.pagination = new PaginationViewModel(undefined, self);
    pagination.loadPagination(1,10);

    self.sendNotification = function () {
        var emailData = getData(false);
        var request = self.placeNotificationRequest(emailData, options.projectNotificationUrl);
        request.done(function () {
            alert("Email successfully sent.");
            clear();
        }).fail(function () {
            alert("Failed to send email.");
        });
    };

    self.sendTestNotification = function () {
        var emailData = getData(true);
        var request = self.placeNotificationRequest(emailData, options.projectTestNotificationUrl);
        request.done(function () {
            alert("Sent test email.");
        }).fail(function () {
            alert("Failed to send test email.");
        });
    };

    self.getProjectMembers = function (pageData) {
        $.ajax({
            url: options.getProjectMembersURL,
            data: pageData,
            contentType: 'application/json',
            success: function (result) {
                if (result.data) {
                    self.transients.members(result.data);
                    self.transients.pagination.totalResults(result.recordsTotal);
                }
            }
        });
    };

    self.addMember = function (data) {
        self.transients.recipients.push(data);
    };

    self.removeMember = function (data) {
        self.transients.recipients.remove(data);
    };

    self.placeNotificationRequest = function (emailData, url) {
        return $.ajax({
            url: url,
            data: emailData,
            method: 'post',
            contentType: 'application/json'
        });
    };

    self.isMemberSelected = function (data) {
        var isPresent = false;
        self.transients.recipients().forEach(function (member) {
            if(member.userId === data.userId){
                isPresent = true;
            }
        });

        return isPresent;
    };

    self.refreshPage = function (offset) {
        self.getProjectMembers(self.getPaginationData(offset));
    };

    self.getPaginationData = function (offset) {
        return {
            start: offset,
            length: pagination.resultsPerPage()
        }
    };

    self.getRoleDisplayName = function (role) {
        return (role && decodeCamelCase(role)) || role;
    };

    function getData(isTest) {
        var data = ko.toJS(self);

        if (!isTest) {
            data.recipients = getRecipientsUserId();
        }

        return ko.toJSON(data, {ignore: 'transients'});
    };

    function getRecipientsUserId() {
        var recipients = self.transients.recipients(),
            userIds = [];
        recipients && recipients.forEach(function (data) {
            userIds.push(data.userId);
        });

        return userIds;
    }

    function clear() {
        self.body('');
        self.subject('');
        self.transients.recipients([]);
    };

    $(notificationId).on('shown', function(){
        if(!initMembers){
            self.getProjectMembers();
            initMembers = true;
        }
    });
};