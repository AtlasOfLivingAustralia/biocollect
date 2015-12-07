<%@ page import="grails.converters.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>My Data | Bio Collect</title>
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <r:script disposition="head">
    var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
            activityViewUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
            activityEditUrl: "${createLink(controller: 'bioActivity', action: 'edit')}",
            activityDeleteUrl: "${createLink(controller: 'bioActivity', action: 'delete')}",
            activityAddUrl: "${createLink(controller: 'bioActivity', action: 'create')}",
            activityListUrl: "${createLink(controller: 'bioActivity', action: 'ajaxList')}",
            searchProjectActivitiesUrl: "${createLink(controller: 'bioActivity', action: 'searchProjectActivities')}",
            recordListUrl: "${createLink(controller: 'record', action: 'ajaxList')}",
            recordDeleteUrl: "${createLink(controller: 'record', action: 'delete')}",
            projectIndexUrl: "${createLink(controller: 'project', action: 'index')}",
            siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
            bieUrl: "${grailsApplication.config.bie.baseURL}",
            view: "${view}",
            returnTo: "${view == 'allrecords' ? createLink(controller: 'bioActivity', action:'allRecords') : createLink(controller: 'bioActivity', action:'list') }"
        },
        here = document.location.href;
    </r:script>
    <r:require modules="knockout, projectActivityInfo, jqueryValidationEngine, restoreTab, myActivity"/>
</head>
<body>

<div class="container-fluid">
    <h2>${view == 'allrecords' ? 'All Records' : 'My Records'}</h2>
    <div class="main-content" style="display:none;">
        <g:render template="../bioActivity/activities"/>
    </div>
</div>

<r:script>
    $(function() {
        initialiseData(fcConfig.view == 'allrecords' ? fcConfig.view : 'myrecords');
    });
</r:script>

</body>
</html>