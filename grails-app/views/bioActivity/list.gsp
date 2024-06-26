<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<g:set var="utilService" bean="utilService"></g:set>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="bs4"/>
    <g:set var="title" value="${utilService.getHeaderLinkForContentTypeOrURI(view, contentURI)?.displayName?:title}"/>
    <title>${title} | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/' + hubConfig.urlPath)},Home"/>
    <meta name="breadcrumb" content="${title}"/>
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <g:set var="wsParameters" value="${[version: params.version, spotterId: "${spotterId}", projectActivityId: "${projectActivityId}"]}"/>
    <asset:stylesheet src="data-manifest.css"/>
    <asset:script type="text/javascript">
        var fcConfig = {
            <g:applyCodec encodeAs="none">
            intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
            featuresService: "${createLink(controller: 'proxy', action: 'features')}",
            featureService: "${createLink(controller: 'proxy', action: 'feature')}",
            spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
            layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
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
            searchProjectActivitiesUrl: "${raw(createLink(controller: 'bioActivity', action: 'searchProjectActivities', params: [projectId: projectId]))}",
            worksActivityEditUrl: "${createLink(controller: 'activity', action: 'enterData')}",
            worksActivityViewUrl: "${createLink(controller: 'activity', action: 'index')}",
            downloadProjectDataUrl: "${createLink(controller: 'bioActivity', action: 'downloadProjectData')}",
            getRecordsForMapping: "${raw(createLink(controller: 'bioActivity', action: 'getProjectActivitiesRecordsForMapping', params: wsParameters))}",
            projectIndexUrl: "${createLink(controller: 'project', action: 'index')}",
            siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
            bieUrl: "${grailsApplication.config.bie.baseURL}",
            bieWsUrl: "${grailsApplication.config.bieWs.baseURL}",
            speciesPage: "${grailsApplication.config.bie.baseURL}/species/",
            view: "${view}",
            projectLinkPrefix: "${createLink(controller: 'project')}/",
            recordImageListUrl: '${createLink(controller: "project", action: "listRecordImages")}',
            imageLeafletViewer: '${createLink(controller: 'resource', action: 'imageviewer', absolute: true)}',
            imageLocation:"${asset.assetPath(src:'')}",
            projectId: "${projectId}",
            projectActivityId: "${projectActivityId}",
            spotterId: ${spotterId?:'undefined'},
            flimit: ${grailsApplication.config.facets.flimit?:10},
            hideProjectAndSurvey: ${hubConfig.content?.hideProjectAndSurvey?:false},
            occurrenceUrl: "${raw(occurrenceUrl)}",
            spatialUrl: "${spatialUrl}",
            mapLayersConfig: <fc:modelAsJavascript model="${mapService.getMapLayersConfig(project, pActivity)}"/>,
            excelOutputTemplateUrl: "${createLink(controller: 'proxy', action:'excelOutputTemplate')}",
            absenceIconUrl:"${asset.assetPath(src: 'triangle.png')}",
            bulkImportId: "${bulkImportId}",
            </g:applyCodec>
            version: "${params?.version}",
            returnTo: "${returnTo}"
        },
        here = document.location.href;
    </asset:script>
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="forms-manifest.js"/>
    <asset:javascript src="enterBioActivityData.js"/>
    <asset:javascript src="projectActivityInfo.js"/>
    <asset:javascript src="facets.js"/>
    <asset:javascript src="chartjsManager.js"/>
    <asset:javascript src="projects.js"/>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
</head>
<body>
<content tag="bannertitle">
    <g:set var="customTitle" value="${hubConfig.templateConfiguration?.header?.links?.find {it.contentType == view}?.displayName}"/>
    ${customTitle?:title}
</content>
<g:if test="${hubConfig.quickLinks}">
<div class="container-fluid">
    <div class="row">
        %{-- quick links --}%
        <div class="col-12">
            <g:render template="/shared/quickLinks" model="${[cssClasses: 'float-right']}"></g:render>
        </div>
        %{--quick links END--}%
    </div>
</div>
</g:if>
<div class="main-content">
    <g:render template="/bioActivity/activities"/>
</div>
<div class="loading-message">
    <span class="fa fa-spin fa-spinner"></span>&nbsp;Loading...
</div>

<asset:script type="text/javascript">
    $(function() {
        initialiseData(fcConfig.view);
    });
</asset:script>
</body>
</html>
