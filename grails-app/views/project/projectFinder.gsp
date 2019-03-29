<%@ page import="grails.converters.JSON; au.org.ala.biocollect.merit.SettingPageType" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/html">
<g:if test="${isUserPage}">
    <g:set var="label" value="myProjects"/>
</g:if>
<g:else>
    <g:if test="${isCitizenScience}">
        <g:set var="label" value="citizenScience"/>
    </g:if>
    <g:if test="${isWorks}">
        <g:set var="label" value="works"/>
    </g:if>
    <g:if test="${isEcoScience}">
        <g:set var="label" value="ecoScience"/>
    </g:if>
    <g:if test="${!(isEcoScience || isWorks || isCitizenScience)}">
        <g:set var="title" value="${hubConfig.title}"/>
    </g:if>
</g:else>


<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title><g:if test="${title}">${title}</g:if><g:else><g:message code="g.${label}"/></g:else> | <g:message code="g.fieldCapture"/></title>
    <link rel="stylesheet" src="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400italic,600,700"/>
    <link rel="stylesheet" src="https://fonts.googleapis.com/css?family=Oswald:300"/>
    <asset:stylesheet src="projects-manifest.css" />
    <asset:stylesheet src="project-finder.css" />
    <asset:script type="text/javascript">
    var fcConfig = {
        baseUrl: "${grailsApplication.config.grails.serverURL}",
        spatialService: '${createLink(controller: 'proxy', action: 'feature')}',
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        regionListUrl: "${createLink(controller: 'regions', action: 'regionsList')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        geocodeUrl: "${grailsApplication.config.google.geocode.url}",
        siteMetaDataUrl: "${createLink(controller: 'site', action: 'locationMetadataForPoint')}",
        spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
        spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
        spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}",
        organisationLinkBaseUrl: "${createLink(controller: 'organisation', action: 'index')}",
        defaultSearchRadiusMetersForPoint: "${grailsApplication.config.defaultSearchRadiusMetersForPoint ?: "100km"}",
        imageLocation:"${asset.assetPath(src:'')}",
        logoLocation:"${asset.assetPath(src:'filetypes')}",
        dashboardUrl: "${g.createLink(controller: 'report', action: 'dashboardReport', params: params)}",
        projectListUrl: "${createLink(controller: 'project', action: 'search', params: [initiator: 'biocollect'])}",
        projectIndexBaseUrl : "${createLink(controller: 'project', action: 'index')}/",
        organisationBaseUrl : "${createLink(controller: 'organisation', action: 'index')}/",
        isCitizenScience: true,
        showAllProjects: false,
        meritProjectLogo:"${asset.assetPath(src: 'merit_project_logo.jpg')}",
        flimit: ${grailsApplication.config.facets.flimit},
        noImageUrl: '${asset.assetPath(src: "no-image-2.png")}',
        sciStarterImageUrl: '${asset.assetPath(src: 'robot.png')}',
        paginationMessage: '${hubConfig.getTextForShowingProjects(grailsApplication.config.content.defaultOverriddenLabels)}',
        enablePartialSearch: ${hubConfig.content.enablePartialSearch?:false},
        downloadWorksProjectsUrl: "${createLink(controller:'project', action:'downloadWorksProjects')}",

        <g:if test="${isUserPage}">
            <g:if test="${isWorks}">
                isUserWorksPage: true,
            </g:if>
            <g:if test="${isEcoScience}">
                isUserEcoSciencePage: true,
            </g:if>
                isUserPage: true,
                hideWorldWideBtn: true,
                isCitizenScience: false,
                showAllProjects: true
        </g:if>
        <g:else>
            <g:if test="${isEcoScience}">
                isCitizenScience: false,
                isBiologicalScience: true,
                hideWorldWideBtn: true,
                associatedPrograms: ${associatedPrograms},
            </g:if>
            <g:elseif test="${isWorks}">
                isCitizenScience: false,
                associatedPrograms: ${associatedPrograms},
            </g:elseif>
            <g:elseif test="${isCitizenScience}">
                isCitizenScience: true,
            </g:elseif>
                showAllProjects: false
        </g:else>
    }
        <g:if test="${grailsApplication.config.merit.projectLogo}">
            fcConfig.meritProjectLogo = fcConfig.imageLocation + "${grailsApplication.config.merit.projectLogo}";
        </g:if>
    </asset:script>
    <g:render template="/shared/conditionalLazyLoad"/>
    <script type="text/javascript" src="//www.google.com/jsapi"></script>
    <asset:javascript src="common.js" />
    <asset:javascript src="project-activity-manifest.js" />
    <asset:javascript src="projects-manifest.js" />
    <asset:javascript src="project-finder.js" />
</head>

<body>
<div id="wrapper" class="content container-fluid padding-top-10">
    <div id="project-finder-container">
        <div class="row-fluid">
            <div class="span12 padding10-small-screen" id="heading">
                <h1 class="pull-left">
                    <g:if test="${title}">
                        ${title}
                    </g:if>
                    <g:else>
                        <g:message code="project.${label}.heading"/>
                    </g:else>
                </h1>
                <g:if test="${isUserPage}">
                    <button id="newPortal" type="button" class="pull-right btn"><g:message
                            code="project.citizenScience.portalLink"/></button>
                </g:if>
                <g:else>
                    <g:if test="${!hubConfig.content?.hideProjectFinderHelpButtons}">
                    <div class="pull-right">
                        <button class="btn btn-info btn-gettingstarted" onclick="window.location = '${createLink(controller: 'home', action: 'gettingStarted')}'"><i
                                class="icon-info-sign icon-white"></i> Getting started</button>
                        <button class="btn btn-info btn-whatisthis" onclick="window.location = '${createLink(controller: 'home', action: 'whatIsThis')}'"><i
                                class="icon-question-sign icon-white"></i> What is this?</button>
                    </div>
                    </g:if>
                </g:else>
            </div>
        </div>

        <div>
            <g:render template="/shared/projectFinderResultSummary"/>
        </div>

        <div class="row-fluid">
            <div id="filterPanel" class="span3" style="display: none">
                <g:render template="/shared/projectFinderQueryPanel" model="${[showSearch: false]}"/>
            </div>
            <g:render template="/shared/projectFinderResultPanel"/>
        </div>
    </div>
</div>
<asset:script type="text/javascript">
    $("#newPortal").on("click", function() {
    <g:if test="${isCitizenScience}">
        document.location.href = "${createLink(controller: 'project', action: 'create', params: [citizenScience: true])}";
    </g:if>
    <g:if test="${isWorks}">
        document.location.href = "${createLink(controller: 'project', action: 'create', params: [works: true])}";
    </g:if>
    <g:if test="${isEcoScience}">
        document.location.href = "${createLink(controller: 'project', action: 'create', params: [ecoScience: true])}";
    </g:if>
    });

    var projectFinder = new ProjectFinder(fcConfig);
</asset:script>
</body>
</html>
