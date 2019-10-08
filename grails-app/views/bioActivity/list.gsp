<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>${title} | Bio Collect</title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumb" content="${title}"/>
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <g:set var="wsParameters" value="${[version: params.version, spotterId: "${spotterId}", projectActivityId: "${projectActivityId}"]}"/>
    <asset:stylesheet src="forms-manifest.css"/>
    <asset:stylesheet src="facets-filter-view.css"/>
    <asset:script type="text/javascript">
    var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
            activityViewUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
            activityEditUrl: "${createLink(controller: 'bioActivity', action: 'edit')}",
            activityDeleteUrl: "${createLink(controller: 'bioActivity', action: 'delete')}",
            activityBulkDeleteUrl: "${createLink(controller: 'bioActivity', action: 'bulkDelete')}",
            activityBulkEmbargoUrl: "${createLink(controller: 'bioActivity', action: 'bulkEmbargo')}",
            activityBulkReleaseUrl: "${createLink(controller: 'bioActivity', action: 'bulkRelease')}",
            activityAddUrl: "${createLink(controller: 'bioActivity', action: 'create')}",
            activityListUrl: "${createLink(controller: 'bioActivity', action: 'ajaxList')}",
            searchProjectActivitiesUrl: "${createLink(controller: 'bioActivity', action: 'searchProjectActivities', params: [projectId: projectId])}",
            worksActivityEditUrl: "${createLink(controller: 'activity', action: 'enterData')}",
            worksActivityViewUrl: "${createLink(controller: 'activity', action: 'index')}",
            downloadProjectDataUrl: "${createLink(controller: 'bioActivity', action: 'downloadProjectData')}",
            getRecordsForMapping: "${createLink(controller: 'bioActivity', action: 'getProjectActivitiesRecordsForMapping', params: wsParameters)}",
            projectIndexUrl: "${createLink(controller: 'project', action: 'index')}",
            siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
            bieUrl: "${grailsApplication.config.bie.baseURL}",
            speciesPage: "${grailsApplication.config.bie.baseURL}/species/",
            view: "${view}",
            returnTo: "${returnTo}",
            projectLinkPrefix: "${createLink(controller: 'project')}/",
            recordImageListUrl: '${createLink(controller: "project", action: "listRecordImages")}',
            imageLeafletViewer: '${createLink(controller: 'resource', action: 'imageviewer', absolute: true)}',
            imageLocation:"${asset.assetPath(src:'')}",
            version: "${params?.version}",
            projectId: "${projectId}",
            projectActivityId: "${projectActivityId}",
            spotterId: ${spotterId?:'undefined'},
            flimit: ${grailsApplication.config.facets.flimit?:10},
            hideProjectAndSurvey: ${hubConfig.content?.hideProjectAndSurvey?:false},
            occurrenceUrl: "${occurrenceUrl}",
            spatialUrl: "${spatialUrl}",
            absenceIconUrl:"${asset.assetPath(src: 'triangle.png')}"
        },
        here = document.location.href;
    </asset:script>
    <asset:javascript src="common.js"/>
    <asset:javascript src="forms-manifest.js"/>
    <asset:javascript src="enterBioActivityData.js"/>
    <asset:javascript src="projectActivityInfo.js"/>
    <asset:javascript src="facets.js"/>
    <asset:javascript src="projects.js"/>
</head>
<body>

<div class="container-fluid">
    <div class="row-fluid">
        %{--page title--}%
        <div class="span4">
            <h2>${title}</h2>
        </div>
        %{-- quick links --}%
        <div class="span8">
            <g:render template="/shared/quickLinks" model="${[cssClasses: 'pull-right']}"></g:render>
        </div>
        %{--quick links END--}%
    </div>

    <div class="main-content" style="display:none;">
        <g:render template="/bioActivity/activities"/>
    </div>
    <div class="loading-message">
        <span class="fa fa-spin fa-spinner"></span>&nbsp;Loading...
    </div>
</div>

<asset:script type="text/javascript">
    $(function() {
        initialiseData(fcConfig.view);
    });
</asset:script>

</body>
</html>