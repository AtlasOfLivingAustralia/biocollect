<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="${mobile ? 'mobile' : 'bs4'}"/>
    <title>Create | ${activity.type} | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/'+ hubConfig.urlPath)},Home"/>
    <meta name="breadcrumbParent2" content="${createLink(controller: 'project', action: 'index')}/${pActivity.projectId},Project"/>
    <meta name="breadcrumb" content="${pActivity.name}"/>
    <asset:stylesheet src="forms-manifest.css"/>
    <g:if test="${mobile}">
        <asset:stylesheet src="mobile_activity.css"/>
    </g:if>

    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
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
        activityDeleteUrl: "${createLink(controller: 'activity', action: 'ajaxDelete')}",
        activityDeleteAndReturnToUrl: "${raw(createLink(action: 'delete', id: activity.activityId, params: [returnTo: grailsApplication.config.grails.serverURL + '/' + returnTo]))}",
        documentUpdateUrl: "${g.createLink(controller:"proxy", action:"documentUpdate")}",
        documentDeleteUrl: "${g.createLink(controller:"proxy", action:"deleteDocument")}",
        projectViewUrl: "${createLink(controller: 'project', action: 'index')}/",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}/",
        siteDeleteUrl: "${createLink(controller: 'site', action: 'forceDelete')}/",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        bieWsUrl: "${grailsApplication.config.bieWs.baseURL}",
        speciesProfileUrl: "${createLink(controller: 'proxy', action: 'speciesProfile')}",
        imageLocation:"${asset.assetPath(src: '')}",
        noImageUrl: '${asset.assetPath(src: "font-awesome/5.15.4/svgs/regular/image.svg")}',
        speciesSearchUrl: "${raw(createLink(controller: 'search', action: 'searchSpecies', params: [projectActivityId: pActivity.projectActivityId, limit: 10]))}",
        searchBieUrl: "${raw(createLink(controller: 'search', action: 'searchSpecies', params: [projectActivityId: pActivity.projectActivityId, limit: 10]))}",
        speciesListUrl: "${createLink(controller: 'proxy', action: 'speciesItemsForList')}",
        speciesImageUrl:"${createLink(controller:'species', action:'speciesImage')}",
        bioActivityUpdate: "${raw(createLink(controller: 'bioActivity', action: 'ajaxUpdate', params: [pActivityId: pActivity.projectActivityId]))}",
        bioActivityView: "${createLink(controller: 'bioActivity', action: 'index')}/",
        excelDataUploadUrl: "${raw(createLink(controller:'bioActivity', action:'extractDataFromExcelTemplate', params:[pActivityId:pActivity.projectActivityId]))}",
        getOutputSpeciesIdUrl : "${createLink(controller: 'output', action: 'getOutputSpeciesIdentifier')}",
        getGuidForOutputSpeciesUrl : "${createLink(controller: 'record', action: 'getGuidForOutputSpeciesIdentifier')}",
        imageLeafletViewer: '${createLink(controller: 'resource', action: 'imageviewer', absolute: true)}',
        mapLayersConfig: <fc:modelAsJavascript model="${mapService.getMapLayersConfig(project, pActivity)}"/>,
        excelOutputTemplateUrl: "${createLink(controller: 'proxy', action:'excelOutputTemplate')}",
        uploadImagesUrl: "${createLink(controller: 'image', action: 'upload')}",
        overrideUseAlaFlag: true,
        </g:applyCodec>
        returnTo: "${returnTo ?: (createLink(controller: 'project', action: 'index')+ "/" + pActivity.projectId)}"
        },
        here = document.location.href;
    </asset:script>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="forms-manifest.js"/>
    <asset:javascript src="enterBioActivityData.js"/>
</head>

<body>
    <g:render template="createEditActivityBody"></g:render>
    <g:render template="activityInitialisationJavaScript"></g:render>
</body>
</html>
