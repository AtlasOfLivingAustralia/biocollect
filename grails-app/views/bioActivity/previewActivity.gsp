<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="ajaxLayout"/>

    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <asset:stylesheet src="common.css"/>
    <asset:stylesheet src="forms-manifest.css"/>
    <g:if test="${hubConfig.skin == "configurableHubTemplate1"}">
        <link rel="stylesheet" type="text/css"
              href="${createLink(controller: 'hub', action: 'getStyleSheet')}?hub=${hubConfig.urlPath}&ver=${hubConfig.lastUpdated}">
    </g:if>
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
        documentUpdateUrl: "${g.createLink(controller:"proxy", action:"documentUpdate")}",
        documentDeleteUrl: "${g.createLink(controller:"proxy", action:"deleteDocument")}",
        projectViewUrl: "${createLink(controller: 'project', action: 'index')}/",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}/",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        speciesProfileUrl: "${createLink(controller: 'proxy', action: 'speciesProfile')}",
        imageLocation:"${asset.assetPath(src:'')}",
        speciesSearch: "${createLink(controller: 'search', action: 'searchSpecies', params: [id: pActivity.projectActivityId, limit: 10])}",
        bioActivityUpdate: "${createLink(controller: 'bioActivity', action: 'ajaxUpdate', params: [pActivityId: pActivity.projectActivityId])}",
        bioActivityView: "${createLink(controller: 'bioActivity', action: 'index')}/",
        excelDataUploadUrl: "${createLink(controller:'bioActivity', action:'extractDataFromExcelTemplate', params:[pActivityId:pActivity.projectActivityId])}",
        getOutputSpeciesIdUrl : "${createLink(controller: 'output', action: 'getOutputSpeciesIdentifier')}",
        getGuidForOutputSpeciesUrl : "${createLink(controller: 'record', action: 'getGuidForOutputSpeciesIdentifier')}",
        uploadImagesUrl: "${createLink(controller: 'image', action: 'upload')}",
        mapLayersConfig: ${mapService.getMapLayersConfig(project, pActivity) as JSON},
        excelOutputTemplateUrl: "${createLink(controller: 'proxy', action:'excelOutputTemplate')}",
        searchBieUrl: "${createLink(controller: 'search', action: 'searchSpecies', params: [id: pActivity.projectActivityId, limit: 10])}"
        }
    </asset:script>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
    <asset:javascript src="common.js"/>
    <asset:javascript src="forms-manifest.js"/>
    <asset:javascript src="enterBioActivityData.js"/>
    <asset:javascript src="projectActivityInfo.js"/>
</head>

<body>
    <div id="main-content">
        <g:render template="createEditActivityBody"></g:render>
    </div>
</body>
</html>