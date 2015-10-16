<%@ page import="grails.converters.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>My Data | Bio Collect</title>
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
            activityListUrl: "${createLink(controller: 'bioActivity', action: 'ajaxList')}",
            recordListUrl: "${createLink(controller: 'record', action: 'ajaxList')}"
        },
        here = document.location.href;
    </r:script>
    <r:require modules="knockout, projectActivityInfo, jqueryValidationEngine, restoreTab, myActivity, records"/>
</head>
<body>

<div class="container-fluid">
    <h2>My Data</h2>

    <div class="row-fluid">

        <div class="span12">

            <ul class="nav nav-tabs" id="ul-survey-activities">
                <li><a href="#survey-records" id= "survey-records-tab" data-toggle="tab">Records</a></li>
                <li><a href="#survey-activities" id="survey-activities-tab" data-toggle="tab">Surveys</a></li>
            </ul>

            <div class="tab-content">
                <div class="tab-pane" id="survey-records">
                    <g:render template="allRecords" model="[show:true]"/>
                </div>
                <div class="tab-pane" id="survey-activities">
                    <g:render template="allActivities" model="[show:true]"/>
                </div>
            </div>
        </div>
    </div>
</div>


<r:script>
    $(window).load(function () {
        $(".main-content").show();
        initialiseActivities();
        initialiseRecords();
        new RestoreTab('ul-survey-activities', 'survey-records-tab');
    });
</r:script>

</body>
</html>