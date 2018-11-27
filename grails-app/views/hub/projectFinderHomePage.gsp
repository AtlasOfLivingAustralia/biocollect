<%@ page import="grails.converters.JSON; au.org.ala.biocollect.merit.SettingPageType" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title><g:message code="hub.projectFinder"/> | ${hubConfig.title}</title>
    <link rel="stylesheet" src="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400italic,600,700"/>
    <link rel="stylesheet" src="https://fonts.googleapis.com/css?family=Oswald:300"/>
    <asset:stylesheet src="projects-manifest.css" />
    <asset:stylesheet src="project-finder.css" />
    <asset:script type="text/javascript">
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
        imageLocation:"${asset.assetPath(src:'')}",
        logoLocation:"${asset.assetPath(src:'filetypes')}",
        dashboardUrl: "${g.createLink(controller: 'report', action: 'dashboardReport', params: params)}",
        isUserPage: false,
        <g:if test="${hubConfig.defaultFacetQuery.contains('isWorks:true')}">
            isUserWorksPage: true,
        </g:if>
        <g:if test="${hubConfig.defaultFacetQuery.contains('isEcoScience:true')}">
            isUserEcoSciencePage: true,
        </g:if >
        <g:if test="${hubConfig.defaultFacetQuery.contains('isCitizenScience:true')}">
            isCitizenScience: true,
        </g:if>
        projectListUrl: "${createLink(controller: 'project', action: 'search', params:[initiator:'biocollect'])}",
        projectIndexBaseUrl : "${createLink(controller:'project',action:'index')}/",
        organisationBaseUrl : "${createLink(controller:'organisation',action:'index')}/",
        defaultSearchRadiusMetersForPoint: "${grailsApplication.config.defaultSearchRadiusMetersForPoint ?: "100km"}",
        showAllProjects: false,
        meritProjectLogo:"${asset.assetPath(src:'merit_project_logo.jpg')}",
        meritProjectUrl: "${grailsApplication.config.merit.project.url}",
        hideWorldWideBtn: ${!hubConfig?.templateConfiguration?.homePage?.projectFinderConfig?.showProjectRegionSwitch},
        flimit: ${grailsApplication.config.facets.flimit},
        noImageUrl: '${asset.assetPath(src: "no-image-2.png")}',
        sciStarterImageUrl: '${asset.assetPath(src: 'robot.png')}',
        downloadWorksProjectsUrl: "${createLink(controller:'project', action:'downloadWorksProjects')}"
  }
    </asset:script>
    <g:render template="/shared/conditionalLazyLoad"/>
    <asset:javascript src="common.js" />
    <asset:javascript src="projects-manifest.js" />
    <asset:javascript src="project-finder.js" />
    <style>
        %{-- Added to this page only to make image slider full page width --}%
        #main-content, #bannerHubContainer{
            padding-right: 0px;
            padding-left: 0px;
        }
    </style>
</head>
<body>
<div id="headerBannerSpace" class="container-fluid">
    <div class="row-fluid">
        <g:render template="/shared/projectFinderQueryInput"/>
    </div>
</div>

<g:render template="/shared/bannerHub"/>

<div id="wrapper" class="content container-fluid">
    <div class="row-fluid">
        <div class="span6" id="heading">
            <h1 class="pull-left">${hubConfig.title}</h1>
        </div>
        <div class="span6">
            <div class="pull-right margin-top-10 margin-bottom-10">
                <a class="btn btn-info" href="${createLink(controller: 'home', action: 'gettingStarted')}"><i class="icon-info-sign icon-white"></i> Getting started</a>
                <a class="btn btn-info" href="${createLink(controller: 'home', action: 'whatIsThis')}"><i class="icon-question-sign icon-white"></i> What is this?</a>
            </div>
        </div>
    </div>

    <g:render template="/shared/projectFinder" model="${[doNotShowSearchBtn: true]}"/>
</div>
<asset:script type="text/javascript">
    <g:if test="${hubConfig?.templateConfiguration?.homePage?.projectFinderConfig?.defaultView == 'grid'}">
        amplify.store('pt-view-state','tileView');
    </g:if>
    <g:elseif test="${hubConfig?.templateConfiguration?.homePage?.projectFinderConfig?.defaultView == 'list'}">
        amplify.store('pt-view-state','listView');
    </g:elseif>

    var projectFinder = new ProjectFinder(fcConfig);
</asset:script>
</body>
</html>