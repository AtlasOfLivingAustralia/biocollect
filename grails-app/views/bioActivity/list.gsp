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
            activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
            activityViewUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
            activityEditUrl: "${createLink(controller: 'bioActivity', action: 'edit')}",
            activityDeleteUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
            activityAddUrl: "${createLink(controller: 'bioActivity', action: 'create')}",
            activityListUrl: "${createLink(controller: 'bioActivity', action: 'ajaxList')}"

        },
        here = document.location.href;
    </r:script>
    <r:require modules="knockout, pagination, projectActivityInfo, jqueryValidationEngine, restoreTab"/>
</head>
<body>

<div class="container-fluid">
    <h2>My activities and records</h2>
    <div class="row-fluid">

        <div class="span12">

            <ul class="nav nav-tabs" id="ul-survey-activities">
                <li><a href="#survey-activities" id="survey-activities-tab" data-toggle="tab">Activties</a></li>
                <li><a href="#survey-records" id= "survey-records-tab" data-toggle="tab">Records</a></li>
            </ul>

            <div class="tab-content">
                <div class="tab-pane active" id="survey-activities">
                    <div class="row-fluid">
                        <div class="span12 ">
                            <div class="span12 text-center">
                                <h1 class="text-success">Total activities: <span  data-bind="text: pagination.totalResults()"></span></h1>
                            </div>

                        </div>
                     </div>
                    </br>
                    <!-- ko foreach : activities -->
                    <div class="row-fluid">
                        <div class="span12">
                            <div class="span1 text-right">
                                <label data-bind="text: $parent.pagination.start() + $index()">
                                </label>
                            </div>
                            <div class="span2 text-center">
                                <span data-bind="text: lastUpdated.formattedDate"></span>
                            </div>
                            <div class="span5">
                                <a data-bind="attr:{'href': transients.viewUrl}">
                                    <a data-bind="attr:{'href': transients.viewUrl}"><span data-bind="text: transients.pActivity.name"></span></a>

                                </a>
                            </div>
                            <div class="span4 text-right">
                                <a data-bind="attr:{'href': transients.addUrl}"><span class="badge badge-default">add</span></a>
                                <a data-bind="attr:{'href': transients.viewUrl}"><span class="badge badge-info">view</span></a>
                                <a data-bind="attr:{'href': transients.editUrl}"><span class="badge badge-warning">edit</span></a>
                                <a data-bind="attr:{'href': transients.deleteUrl}"><span class="badge badge-important">delete</span></a>
                            </div>
                        </div>
                    </div>
                    <!-- /ko -->
                    </br>
                    <g:render template="../shared/pagination"/>
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
        self.pagination = new PaginationViewModel({},self);

        self.load = function(activities, displayName, pagination){
            self.activities([]);
            var activities = $.map(activities ? activities : [] , function(activity, index){
                return new ActivityViewModel(activity);
            });
            self.activities(activities);
            self.displayName(displayName);
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
                    $('html, body').animate({ scrollTop: $("#main-content").offset().top }, 0);
                },
                error: function (data) {
                    alert('An unhandled error occurred: ' + data);
                }
            });
        };

    };

    var ActivityViewModel = function(activity, pagination){
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
    var pagination = ${(pagination as JSON).toString()}
    var displayName = '${displayName}';
    viewModel.load(activities, displayName, pagination);

    ko.applyBindings(viewModel);
    new RestoreTab('ul-survey-activities', 'survey-activities-tab');
</r:script>
</body>
</html>