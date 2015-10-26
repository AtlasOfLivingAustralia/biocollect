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
        projectListUrl: "${createLink(controller: 'project', action: 'getProjectList')}",
        isCitizenScience: true,
        projectIndexBaseUrl : "${createLink(controller:'project',action:'index')}/",
        organisationBaseUrl : "${createLink(controller:'organisation',action:'index')}/"
    }
    </r:script>
    <script type="text/javascript" src="//www.google.com/jsapi"></script>
    <r:require modules="js_iso8601,projects,projectFinder"/>
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

    <div id="pt-root" class="row-fluid">
        <g:render template="projectsList"/>
    </div>
</div>
<r:script>
    $("#newPortal").on("click", function() {
        document.location.href = "${createLink(controller:'project',action:'create',params:[citizenScience:true])}";
    });

    var projectFinder = new ProjectFinder();
</r:script>
</body>
</html>
