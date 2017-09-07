
function IssuesViewModel (issues) {
    var self = this;
    self.status = ko.observable();
    self.issues = ko.observableArray();
    self.load = function(issues) {
        if (!issues) {
            issues = {};
        }
        self.status(issues.status || 'active');
        if (issues.issues) {
            self.issues($.map(issues.issues, function (obj) {
                return new IssueViewModel(obj);
            }));
        }
        else {
            self.issues.push(new IssueViewModel());
        }
    };
    self.modelAsJSON = function() {
        var tmp = {};
        tmp = ko.mapping.toJS(self);
        tmp['status'] = 'active';
        var jsData = {"issues": tmp};
        var json = JSON.stringify(jsData, function (key, value) {
            return value === undefined ? "" : value;
        });
        return json;
    };
    self.addIssue = function(){
        self.issues.push(new IssueViewModel());
    };
    self.removeIssue = function(issue) {
        self.issues.remove(issue);
    };
    self.load(issues);
};

function IssueViewModel (issue) {
    var self = this;
    if(!issue) issue = {};
    self.type = ko.observable(issue.type);
    self.description = ko.observable(issue.description);
    self.assessment = ko.observable(issue.assessment);
    self.actionPlan = ko.observable(issue.actionPlan);
    self.impact = ko.observable(issue.impact);
    self.impact.options = ['critical', 'significant', 'moderate', 'low'];
};
