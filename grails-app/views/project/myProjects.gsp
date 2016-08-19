<%--
 Created by Temi Varghese on 29/09/15.
--%>

<%@ page import="grails.converters.JSON; au.org.ala.biocollect.merit.SettingPageType" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title><g:message code="g.myProjects"/> | <g:message code="g.citizenScience"/></title>
    <r:script disposition="head">
    var fcConfig = {
        baseUrl: "${grailsApplication.config.grails.serverURL}",
        spatialService: '${createLink(controller:'proxy',action:'feature')}',
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        regionListUrl: "${createLink(controller: 'regions', action: 'regionsList')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        geocodeUrl: "${grailsApplication.config.google.geocode.url}",
        siteMetaDataUrl: "${createLink(controller:'site', action:'locationMetadataForPoint')}",
        spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
        spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
        spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}",
        organisationLinkBaseUrl: "${createLink(controller: 'organisation', action: 'index')}",
        imageLocation:"${resource(dir:'/images')}",
        logoLocation:"${resource(dir:'/images/filetypes')}",
        dashboardUrl: "${g.createLink(controller: 'report', action: 'dashboardReport', params: params)}",
        isUserPage: true,
        <g:if test="${hubConfig.defaultFacetQuery.contains('isWorks:true')}">
            isUserWorksPage: true,
        </g:if>
        <g:if test="${hubConfig.defaultFacetQuery.contains('isEcoScience:true')}">
            isUserEcoSciencePage: true,
        </g:if>
        projectListUrl: "${createLink(controller: 'project', action: 'search', params:[initiator:'biocollect'])}",
        projectIndexBaseUrl : "${createLink(controller:'project',action:'index')}/",
        organisationBaseUrl : "${createLink(controller:'organisation',action:'index')}/",
        defaultSearchRadiusMetersForPoint: "${grailsApplication.config.defaultSearchRadiusMetersForPoint ?: "100km"}",
        showAllProjects: true,
        meritProjectLogo:"${resource(dir:'/images', file:'merit_project_logo.jpg')}",
        meritProjectUrl: "${grailsApplication.config.merit.project.url}",
        isCitizenScience: false,
        hideWorldWideBtn: true
  }
    </r:script>
    <r:require modules="js_iso8601,projects,projectFinder,map"/>
</head>
<body>
<div id="wrapper" class="content container-fluid">
    <div class="row-fluid">
        <div class="span6" id="heading">
            <h1 class="pull-left"><g:message code="project.myProjects.heading"/></h1>
        </div>
        <g:if test="${user}">
            <button id="newPortal" type="button" class="pull-right btn"><g:message
                    code="project.citizenScience.portalLink"/></button>
        </g:if>
    </div>

    <g:render template="/shared/projectFinder"/>
</div>
<r:script>
    $("#newPortal").on("click", function() {
        <g:if test="${!hubConfig.defaultFacetQuery.contains('isWorks:true')}">
            document.location.href = "${createLink(controller:'project',action:'create',params:[citizenScience:true])}";
        </g:if>
        <g:if test="${hubConfig.defaultFacetQuery.contains('isWorks:true')}">
            document.location.href = "${createLink(controller:'project',action:'create',params:[works:true])}";
        </g:if>
        <g:if test="${hubConfig.defaultFacetQuery.contains('isEcoScience:true')}">
            document.location.href = "${createLink(controller:'project',action:'create',params:[ecoScience:true])}";
        </g:if>
    });

    var projectFinder = new ProjectFinder();
</r:script>
</body>
</html>
