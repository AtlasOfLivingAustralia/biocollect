<%@ page import="grails.converters.JSON; au.org.ala.biocollect.merit.SettingPageType" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
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
    <meta name="layout" content="bs4"/>
    <title><g:if test="${title}">${title}</g:if><g:else><g:message code="g.${label}"/></g:else> | <g:message
            code="g.fieldCapture"/></title>
    <asset:stylesheet src="project-finder-manifest.css"/>
    %{--    <asset:stylesheet src="project-finder.css" />--}%
    <asset:script type="text/javascript">
        var fcConfig = {
            intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
        baseUrl: "${grailsApplication.config.grails.serverURL}",
        spatialService: '${createLink(controller: 'proxy', action: 'feature')}',
        regionListUrl: "${createLink(controller: 'regions', action: 'regionsList')}",
        geocodeUrl: "${grailsApplication.config.google.geocode.url}",
        siteMetaDataUrl: "${createLink(controller: 'site', action: 'locationMetadataForPoint')}",
        spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
        spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
        spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}",
        organisationLinkBaseUrl: "${createLink(controller: 'organisation', action: 'index')}",
        defaultSearchRadiusMetersForPoint: "${grailsApplication.config.defaultSearchRadiusMetersForPoint ?: "100km"}",
        imageLocation:"${asset.assetPath(src: '')}",
        logoLocation:"${asset.assetPath(src: 'filetypes')}",
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
        enablePartialSearch: ${hubConfig.content.enablePartialSearch ?: false},
        downloadWorksProjectsUrl: "${createLink(controller: 'project', action: 'downloadWorksProjects')}",
        mapLayersConfig: ${mapService.getMapLayersConfig(project, pActivity) as JSON},

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
    <asset:javascript src="common.js"/>
    <asset:javascript src="project-activity-manifest.js"/>
    <asset:javascript src="projects-manifest.js"/>
    <asset:javascript src="project-finder.js"/>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
</head>

<body>
<content tag="pagefinderbuttons">
    <g:if test="${isUserPage}">
        <button id="newPortal" type="button" class="btn btn-primary-dark"><g:message
                code="project.citizenScience.portalLink"/></button>
    </g:if>
    <g:else>
        <g:if test="${!hubConfig.content?.hideProjectFinderHelpButtons}">
            <button class="btn btn-primary-dark btn-gettingstarted"
                    onclick="window.location = '${createLink(controller: 'home', action: 'gettingStarted')}'">
                <i class="fas fa-info"></i> Getting started</button>
            <button class="btn btn-primary-dark btn-whatisthis"
                    onclick="window.location = '${createLink(controller: 'home', action: 'whatIsThis')}'">
                <i class="fas fa-question"></i> What is this?</button>
        </g:if>
    </g:else>
</content>
<section class="text-center section-padding">
    <div class="container">
        <div class="row">
            <div class="col-12 col-md-10 offset-0 offset-md-1" id="heading">
                <h1>
                    <g:if test="${title}">
                        ${title}
                    </g:if>
                    <g:else>
                        <g:message code="project.${label}.heading"/>
                    </g:else>
                </h1>
            </div>
        </div>
    </div>
</section>
%{--<div id="wrapper" class="content container-fluid padding-top-10">--}%
%{--    <div id="project-finder-container">--}%
%{--        <div>--}%
%{--            <g:render template="/shared/projectFinderResultSummary"/>--}%
%{--        </div>--}%

%{--        <div class="row-fluid">--}%
%{--            <div id="filterPanel" class="span3">--}%
%{--                <g:render template="/shared/projectFinderQueryPanel" model="${[showSearch: false]}"/>--}%
%{--            </div>--}%
%{--            <g:render template="/shared/projectFinderResultPanel"/>--}%
%{--        </div>--}%
%{--    </div>--}%
%{--</div>--}%

<section id="catalogueSection">
    <div id="project-finder-container">
        <div class="container-fluid show expander projects-container">

            <div id="sortBar" class="row d-flex">
                <div class="col-12 col-md-4 offset-md-8 text-right mb-3">
                    <div class="input-group">
                        <input id="pt-search" type="text" class="form-control" placeholder="<g:message code="projectfinder.search"/>" aria-label="<g:message code="projectfinder.search"/>" aria-describedby="pt-search-link">
                        <div class="input-group-append">
                            <button class="btn btn-primary-dark" type="button" id="pt-search-link"><i class="fas fa-search"></i></button>
                        </div>
                    </div>
                </div>
                <div class="col-6 col-md-4 mb-3 order-1 order-md-0">
                    <button class="btn btn-dark project-finder-filters-expander" data-toggle="collapse" data-target=".expander" aria-expanded="true" aria-controls="expander" title="Filter Projects">
                        <i class="fas fa-filter"></i> Filter Projects
                    </button>
                </div>
                <div class="col-6 col-sm-6 col-md-4 mb-3 text-right text-md-center order-2 order-md-1">
                    <div class="btn-group" role="group" aria-label="Catalogue Display Options">
                        <div class="btn-group nav nav-tabs project-finder-tab" role="group" aria-label="Catalogue Display Options">
                            <a type="button" class="btn btn-outline-dark active" id="grid-tab" data-toggle="tab" title="View as Grid" href="#grid" role="tab" aria-controls="View as Grid" aria-selected="true">
                                <i class="fas fa-th-large"></i></a>
                            <a type="button" class="btn btn-outline-dark" id="list-tab" data-toggle="tab" title="View as List" href="#list" role="tab" aria-controls="View as List">
                                <i class="fas fa-list"></i></a>
                            <a type="button" class="btn btn-outline-dark" id="map-tab" data-toggle="tab" title="View as Images" href="#map" role="tab" aria-controls="View on Map">
                                <i class="far fa-map"></i></a>
                        </div>
                        %{--                    <button type="button" class="btn btn-outline-dark active" title="View as Grid"><i class="fas fa-th-large"></i></button>--}%
                        %{--                    <button type="button" class="btn btn-outline-dark" title="View as List"><i class="fas fa-list"></i></button>--}%
                        %{--                    <button type="button" class="btn btn-outline-dark" title="View as Map"><i class="far fa-map"></i></button>--}%
                    </div>
                </div>
                <div class="col-12 col-md-4 text-center text-md-right order-0 order-md-2 pl-0 d-flex justify-content-end justify-content-md-end">
                    <div class="form-group">
                        <label for="sortBy" class="col-form-label">Sort by</label>
                        <select id="sortBy" class="form-control col custom-select" data-bind="value: sortBy" aria-label="Sort Order">
                            <option value="dateCreatedSort">Most Recent</option>
                            <option value="nameSort">Name</option>
                            <option value="_score">Relevance</option>
                            <option value="organisationSort">Organisation</option>
                        </select>
                    </div>
                    <div class="form-group ml-2 projects-from-select">
                        <label for="projectsFrom" class="col-form-label">Projects from</label>
                        <select id="projectsFrom" class="form-control col custom-select" data-bind="value: isWorldWide" aria-label="Projects from">
                            <option value="false">Australia</option>
                            <option value="true">Global</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="filter-bar d-flex align-items-center">
                <h4>Applied Filters: </h4>
                <!-- ko if: isGeoSearchEnabled -->
                <span class="filter-item"> <g:message code="projectfinder.geofilter"/> <button class="remove" data-bind="click: clearGeoSearch"><i class="far fa-times-circle"></i></button></span>
                <!-- /ko -->
                <!-- ko foreach: filterViewModel.selectedFacets -->
                <span class="filter-item"><strong data-bind="if: exclude">[EXCLUDE]</strong> <!-- ko text: displayNameWithoutCount() --> <!-- /ko --> <button class="remove" data-bind="click: remove"><i class="far fa-times-circle"></i></button></span>
                <!-- /ko -->
                <button type="button" class="btn btn-sm btn-dark clear-filters" data-bind="click: reset" aria-label="Clear all filters"><i class="far fa-times-circle"></i> Clear All</button>
            </div>
            <g:render template="/shared/pagination" model="[bs:4, classes:'mb-3']"/>

            <g:render template="/shared/projectFinderResultPanel"/>

            <g:render template="/shared/pagination" model="[bs:4]"/>

        </div>
        <g:render template="/shared/projectFinderQueryPanel" model="${[showSearch: false]}"/>
        <!-- /#filters -->
    </div>

</section>
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
    // $(function() {
    //
    // })();
</asset:script>
</body>
</html>
