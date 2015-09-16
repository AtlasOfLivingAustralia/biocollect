<%@ page import="grails.converters.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <g:if test="${printView}">
        <meta name="layout" content="nrmPrint"/>
        <title>Print | My Records| Bio Collect</title>
    </g:if>
    <g:else>
        <meta name="layout" content="${hubConfig.skin}"/>
        <title>My Records | Bio Collect</title>
    </g:else>

    <script type="text/javascript" src="${grailsApplication.config.google.maps.url}"></script>
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <r:script disposition="head">
    var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            activityViewUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
            activityEditUrl: "${createLink(controller: 'bioActivity', action: 'edit')}",
            activityDeleteUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
            activityAddUrl: "${createLink(controller: 'bioActivity', action: 'create')}"
        },
        here = document.location.href;
    </r:script>
    <r:require modules="knockout, projectActivityInfo"/>
</head>
<body>

<div class="container-fluid">
    <h1>Showing records for <span data-bind="text: displayName"></span> </h1>
    <div class="row-fluid">

        <div class="span12">

            <ul class="nav nav-tabs">
                <li class="active"><a href="#survey-activities" data-toggle="pill">Activties</a></li>
                <li><a href="#survey-records" data-toggle="pill">Records</a></li>
            </ul>

            <div class="tab-content">
                <div class="tab-pane active" id="survey-activities">
                    <!-- ko foreach : activities -->
                    <div class="row-fluid">
                        <div class="span12">
                            <div class="span1 text-right">
                                <label data-bind="text: $index()+1"></label>
                            </div>
                            <div class="span2">
                                <span data-bind="text: lastUpdated.formattedDate"></span>
                            </div>
                            <div class="span5">
                                <a data-bind="attr:{'href': transients.viewUrl}">
                                    <a data-bind="attr:{'href': transients.addUrl}"><i class="icon-plus">+</i></a>
                                    <span data-bind="text: transients.pActivity.name"></span>
                                </a>
                            </div>
                            <div class="span4">
                                <a data-bind="attr:{'href': transients.viewUrl}"><span class="badge badge-info">view</span></a>
                                <a data-bind="attr:{'href': transients.editUrl}"><span class="badge badge-warning">edit</span></a>
                                <a data-bind="attr:{'href': transients.deleteUrl}"><span class="badge badge-important">delete</span></a>
                            </div>
                        </div>
                    </div>
                    <!-- /ko -->
                </div>
                <div class="tab-pane" id="survey-records">
                </div>
            </div>


        </div>
    </div>

</div>

<r:script>
    var ActivityListsViewModel = function(){
        var self = this;
        self.activities = ko.observableArray();
        self.displayName = ko.observable();

        self.load = function(activities, displayName){
            $.map(activities ? activities : [] , function(activity, index){
                self.activities.push(new ActivityViewModel(activity));
            });
            self.displayName(displayName);
        };
    };

    var ActivityViewModel = function(activity){
        var self = this;
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

    var viewModel = new ActivityListsViewModel();
    var activities = ${(activities as JSON).toString()}
    var displayName = '${displayName}';
    viewModel.load(activities, displayName);

    ko.applyBindings(viewModel);

</r:script>
</body>
</html>