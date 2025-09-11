<%@ page import="grails.converters.JSON; au.org.ala.biocollect.merit.SettingPageType" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="bs4"/>
    <title><g:message code="project.works.heading"/> | <g:message code="project.works.heading"/></title>
    <asset:script type="text/javascript">
    var fcConfig = {
        <g:applyCodec encodeAs="none">
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
        defaultSearchRadiusMetersForPoint: "${grailsApplication.config.defaultSearchRadiusMetersForPoint ?: "100"}",
        imageLocation:"${asset.assetPath(src:'')}",
        logoLocation:"${asset.assetPath(src:'filetypes')}",
        projectListUrl: "${raw(createLink(controller: 'project', action: 'search', params:[initiator:'biocollect']))}",
        projectIndexBaseUrl : "${createLink(controller:'project',action:'index')}/",
        organisationBaseUrl : "${createLink(controller:'organisation',action:'index')}/",
        paginationMessage: '${hubConfig.getTextForShowingProjects(grailsApplication.config.content.defaultOverriddenLabels)}',
        isCitizenScience: false,
        showAllProjects: false,
        meritProjectLogo:"${asset.assetPath(src:'merit_project_logo.jpg')}",
        associatedPrograms: <fc:modelAsJavascript model="${associatedPrograms}"/>,
        flimit: ${grailsApplication.config.facets.flimit},
        pwaAppUrl: "${grailsApplication.config.getProperty('pwa.appUrl')}/mobile-app/project/",
        </g:applyCodec>
        dashboardUrl: "${g.createLink(controller: 'report', action: 'dashboardReport', params: params)}"
    }
        <g:if test = "${grailsApplication.config.merit.projectLogo}" >
            fcConfig.meritProjectLogo = fcConfig.imageLocation + "${grailsApplication.config.merit.projectLogo}";
        </g:if>
    </asset:script>
    <g:render template="/shared/conditionalLazyLoad"/>
    <script type="text/javascript" src="//www.google.com/jsapi"></script>
    <asset:stylesheet src="projects-manifest.css"/>
    <asset:stylesheet src="project-finder.css"/>
    <asset:javascript src="common.js"/>
    <asset:javascript src="project-activity-manifest.js"/>
    <asset:javascript src="projects-manifest.js"/>
    <asset:javascript src="project-finder.js"/>
</head>
<body>
<content tag="bannertitle">
    <g:message code="project.works.heading"/>
</content>
<g:if test="${!hubConfig.content?.hideProjectFinderHelpButtons}">
    <content tag="pagefinderbuttons">
        <button class="btn btn-info btn-getttingstarted" onclick="window.location = '${createLink(controller: 'home', action: 'gettingStarted')}"><i class="fas fa-info"></i> Getting started</button>
        <button class="btn btn-info btn-whatisthis" onclick="window.location = '${createLink(controller: 'home', action: 'whatIsThis')}"><i class="fas fa-question"></i> What is this?</button>
    </content>
</g:if>
<div id="wrapper" class="content container-fluid">
    <g:render template="/shared/projectFinderQueryPanel" model="${[showSearch:false]}"/>

    <g:render template="/shared/projectFinderResultPanel"></g:render>


</div>
<asset:script type="text/javascript">
    $("#newPortal").on("click", function() {
        document.location.href = "${raw(createLink(controller:'project',action:'create',params:[works:true]))}";
    });

    var projectFinder = new ProjectFinder({enablePartialSearch: ${hubConfig.content.enablePartialSearch?:false}});

</asset:script>
<g:render template="/shared/resizeFilter" model="[dependentDiv: '#project-finder-container .projects-container',
                                                  target: '#project-finder-container #filters',
                                                  listenTo: '#project-finder-container']" />
</body>
</html>
