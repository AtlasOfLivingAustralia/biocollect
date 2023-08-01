<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="pwa"/>
    <title>Create | <g:message code="g.biocollect"/></title>
    <asset:stylesheet src="pwa-bio-activity-create-or-edit-manifest.css"/>
    <asset:script type="text/javascript">
        var currentURL = window.location.href,
            url = new URL(currentURL),
            projectId = url.searchParams.get("projectId"),
            projectActivityId = url.searchParams.get("projectActivityId"),
            activityId = url.searchParams.get("activityId");

        var fcConfig = {
        <g:applyCodec encodeAs="none">
        projectId: "${projectId}",
        projectActivityId: "${projectActivityId}",
        type: "${type}",
        siteUrl: "/ws/site",
        activityURL: "/ws/activity",
        projectActivityURL: "/ws/projectActivity",
        activityViewURL: "/pwa/bioActivity/index",
        metadataURL: "/ws/projectActivity/activity",
        htmlFragmentURL: "/pwa/createOrEditFragment/${projectActivityId}",
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
        activityDeleteUrl: "${createLink(controller: 'activity', action: 'ajaxDelete')}",
        activityDeleteAndReturnToUrl: "${raw(createLink(action: 'delete', id: activityId, params: [returnTo: grailsApplication.config.grails.serverURL + '/' + returnTo]))}",
        documentUpdateUrl: "${g.createLink(controller:"proxy", action:"documentUpdate")}",
        documentDeleteUrl: "${g.createLink(controller:"proxy", action:"deleteDocument")}",
        projectViewUrl: "${createLink(controller: 'project', action: 'index')}/",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}/",
        siteDeleteUrl: "${createLink(controller: 'site', action: 'forceDelete')}/",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        bieWsUrl: "${grailsApplication.config.bieWs.baseURL}",
        speciesProfileUrl: "${createLink(controller: 'proxy', action: 'speciesProfile')}",
        imageLocation:"${asset.assetPath(src: '')}",
        speciesSearchUrl: "${raw(createLink(controller: 'search', action: 'searchSpecies', params: [projectActivityId: projectActivityId, limit: 10]))}",
        searchBieUrl: "${raw(createLink(controller: 'search', action: 'searchSpecies', params: [projectActivityId: projectActivityId, limit: 10]))}",
        speciesListUrl: "${createLink(controller: 'proxy', action: 'speciesItemsForList')}",
        speciesImageUrl:"${createLink(controller:'species', action:'speciesImage')}",
        bioActivityUpdate: "${raw(createLink(controller: 'bioActivity', action: 'ajaxUpdate', params: [pActivityId: projectActivityId]))}",
        bioActivityView: "${createLink(controller: 'bioActivity', action: 'index')}/",
        excelDataUploadUrl: "${raw(createLink(controller:'bioActivity', action:'extractDataFromExcelTemplate', params:[pActivityId:projectActivityId]))}",
        getOutputSpeciesIdUrl : "${createLink(controller: 'output', action: 'getOutputSpeciesIdentifier')}",
        getGuidForOutputSpeciesUrl : "${createLink(controller: 'record', action: 'getGuidForOutputSpeciesIdentifier')}",
        imageLeafletViewer: '${createLink(controller: 'resource', action: 'imageviewer', absolute: true)}',
        mapLayersConfig: ${ grailsApplication.config.getProperty('pwa.mapConfig', Map) as JSON },
        excelOutputTemplateUrl: "${createLink(controller: 'proxy', action:'excelOutputTemplate')}",
        uploadImagesUrl: "${createLink(controller: 'image', action: 'upload')}",
        originUrl: "${grailsApplication.config.getProperty('server.serverURL')}",
        pwaAppUrl: "${grailsApplication.config.getProperty('pwa.appUrl')}",
        bulkUpload: false,
        isPWA: true,
        isCaching: ${params.getBoolean('cache', false)},
        returnTo: '${createLink(uri: "/pwa/offlineList", params:  [projectActivityId: projectActivityId])}'
        </g:applyCodec>
        },
        here = document.location.href;
    </asset:script>
    <asset:javascript src="pwa-bio-activity-create-or-edit-manifest.js"/>
</head>

<body>
    <div class="container">
        <h1><g:message code="pwa.edit.record"/></h1>
        <bc:koLoading>
            <div id="form-placeholder"></div>
        </bc:koLoading>
    </div>
    <g:render template="asyncActivityInitialisationJavaScript"></g:render>
</body>
</html>
