<%@ page import="grails.converters.JSON; au.org.ala.biocollect.merit.SettingPageType" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title><g:message code="g.citizenScience"/> | <g:message code="g.fieldCapture"/></title>
    <r:script disposition="head">
    var fcConfig = {
        baseUrl: "${grailsApplication.config.grails.serverURL}",
        spatialService: '${createLink(controller:'proxy',action:'feature')}',
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
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
        defaultSearchRadiusMetersForPoint: "${grailsApplication.config.defaultSearchRadiusMetersForPoint ?: "50km"}",
        imageLocation:"${resource(dir:'/images')}",
        logoLocation:"${resource(dir:'/images/filetypes')}",
        dashboardUrl: "${g.createLink(controller: 'report', action: 'dashboardReport', params: params)}",
        projectListUrl: "${createLink(controller: 'project', action: 'getProjectList')}",
        projectIndexBaseUrl : "${createLink(controller:'project',action:'index')}/",
        organisationBaseUrl : "${createLink(controller:'organisation',action:'index')}/",
        isCitizenScience: true,
        isOrganisationPage: false
    }
    <g:if test = "${grailsApplication.config.merit.projectLogo}" >
        fcConfig.meritProjectLogo = fcConfig.imageLocation + "/" + "${grailsApplication.config.merit.projectLogo}";
    </g:if>
    </r:script>
    <script type="text/javascript" src="//www.google.com/jsapi"></script>
    <r:require modules="js_iso8601,knockout,jqueryValidationEngine,drawmap,projects,projectFinder"/>
</head>
<body>
<div id="wrapper" class="content container-fluid">
    <g:render template="/shared/projectFinderQueryPanel" model="${[showSearch:false]}"/>
    <div class="row-fluid">
        <div class="span12" id="heading">
            <h1 class="pull-left"><g:message code="project.citizenScience.heading"/></h1>
        </div>
    </div>
    <g:render template="/shared/projectFinderResultPanel"></g:render>
</div>
<r:script>
    $("#newPortal").on("click", function() {
        document.location.href = "${createLink(controller:'project',action:'create',params:[citizenScience:true])}";
    });

    var projectFinder = new ProjectFinder();

</r:script>
</body>
</html>
