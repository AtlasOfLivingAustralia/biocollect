<!--
/*
 * Copyright (C) 2016 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 * 
 * Created by Temi on 11/11/16.
 */
-->
<%@ page import="grails.converters.JSON; au.org.ala.biocollect.merit.SettingPageType" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title><g:message code="hub.projectFinder"/> | ${hubConfig.title}</title>
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
<div class="${fluidLayout?'container-fluid':'container'}">
    <div class="row-fluid">
        <g:render template="/shared/projectFinderQueryInput"/>
    </div>
</div>
<div id="bannerHubContainer" class="container-fluid">
    <g:render template="/shared/bannerHub"/>
</div>

<div id="wrapper" class="content container-fluid">
    <div class="row-fluid">
        <div class="span6" id="heading">
            <h1 class="pull-left"><g:message code="project.myProjects.heading"/></h1>
        </div>
        <div class="span6">
            <h1>
                <div class="pull-right">
                    <a class="btn btn-info" href="${createLink(controller: 'home', action: 'gettingStarted')}"><i class="icon-info-sign icon-white"></i> Getting started</a>
                    <a class="btn btn-info" href="${createLink(controller: 'home', action: 'whatIsThis')}"><i class="icon-question-sign icon-white"></i> What is this?</a>
                </div>
            </h1>
        </div>
    </div>

    <g:render template="/shared/projectFinder" model="${[doNotShowSearchBtn: true]}"/>
</div>
<r:script>
    <g:if test="${hubConfig?.templateConfiguration?.homePage?.projectFinderConfig?.defaultView == 'grid'}">
        amplify.store('pt-view-state','tileView');
    </g:if>
    <g:elseif test="${hubConfig?.templateConfiguration?.homePage?.projectFinderConfig?.defaultView == 'list'}">
        amplify.store('pt-view-state','listView');
    </g:elseif>

    var projectFinder = new ProjectFinder();
</r:script>
</body>
</html>