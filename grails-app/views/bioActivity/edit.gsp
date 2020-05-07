<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <g:if test="${printView}">
        <meta name="layout" content="nrmPrint"/>
        <title>Print | ${activity.type} | Bio Collect</title>
    </g:if>
    <g:else>
        <meta name="layout" content="${mobile ? 'mobile' : hubConfig.skin}"/>
        <title>Edit | ${activity.type} | Bio Collect</title>
    </g:else>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumbParent2" content="${createLink(controller: 'project', action: 'index')}/${pActivity.projectId},Project"/>
    <meta name="breadcrumb" content="${pActivity.name}"/>
    <asset:stylesheet src="common.css"/>
    <asset:stylesheet src="forms-manifest.css"/>
    <g:if test="${mobile}">
        <asset:stylesheet src="mobile_activity.css"/>
    </g:if>

    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <asset:script type="text/javascript">
    var fcConfig = {
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
        activityDeleteUrl: "${createLink(controller: 'activity', action: 'ajaxDelete')}",
        activityDeleteAndReturnToUrl: "${createLink(action: 'delete', id: activity.activityId, params: [returnTo: grailsApplication.config.grails.serverURL + '/' + returnTo])}",
        documentUpdateUrl: "${g.createLink(controller:"proxy", action:"documentUpdate")}",
        documentDeleteUrl: "${g.createLink(controller:"proxy", action:"deleteDocument")}",
        projectViewUrl: "${createLink(controller: 'project', action: 'index')}/",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}/",
        siteDeleteUrl: "${createLink(controller: 'site', action: 'forceDelete')}/",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        speciesProfileUrl: "${createLink(controller: 'proxy', action: 'speciesProfile')}",
        searchBieUrl: "${createLink(controller: 'search', action: 'searchSpecies', params: [id: pActivity.projectActivityId, limit: 10])}",
        speciesListUrl: "${createLink(controller: 'proxy', action: 'speciesItemsForList')}",
        speciesImageUrl:"${createLink(controller:'species', action:'speciesImage')}",
        imageLocation:"${asset.assetPath(src:'')}",
        uploadImagesUrl: "${createLink(controller: 'image', action: 'upload')}",
        speciesSearchUrl: "${createLink(controller: 'search', action: 'searchSpecies', params: [id: pActivity.projectActivityId, limit: 10])}",
        bioActivityUpdate: "${createLink(controller: 'bioActivity', action: 'ajaxUpdate', params: [pActivityId: pActivity.projectActivityId, id: id])}",
        bioActivityMobileUpdate: "${createLink(controller: 'bioActivity', action: 'ajaxUpdate', params: [pActivityId: pActivity.projectActivityId, id: id, isMobile: true])}",
        excelDataUploadUrl: "${createLink(controller:'bioActivity', action:'extractDataFromExcelTemplate', id:projectActivityId)}",
        getOutputSpeciesIdUrl : "${createLink(controller: 'output', action: 'getOutputSpeciesIdentifier')}",
        getGuidForOutputSpeciesUrl : "${createLink(controller: 'record', action: 'getGuidForOutputSpeciesIdentifier')}",
        bioActivityView: "${createLink(controller: 'bioActivity', action: 'index')}/",
        activityId: "${id}",
        returnTo: "${returnTo}",
        returnToMobile: "${createLink(controller: 'mobile', action: 'status')}#successfully-posted",
        excelOutputTemplateUrl: "${createLink(controller: 'proxy', action:'excelOutputTemplate')}",
        mapLayersConfig: ${mapService.getMapLayersConfig(project, pActivity) as JSON}
        },
        here = document.location.href;
    </asset:script>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
    <asset:javascript src="common.js"/>
    <asset:javascript src="forms-manifest.js"/>
    <asset:javascript src="enterBioActivityData.js"/>
</head>


<body>
    <g:render template="createEditActivityBody"></g:render>
</body>
</html>