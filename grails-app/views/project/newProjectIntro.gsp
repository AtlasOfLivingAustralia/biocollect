<%@ page import="net.sf.json.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>${project?.name?.encodeAsHTML()} | <g:message code="g.projects"/> | <g:message
            code="g.fieldCapture"/></title>

    <r:require module="application"></r:require>
</head>

<body>
<div class="container-fluid">

    <ul class="breadcrumb">
        <li><g:link controller="home"><g:message code="g.home"/></g:link> <span class="divider">/</span></li>
        <li><g:link controller="project" action="index"
                    id="${project.projectId}">${project.name?.encodeAsHTML()}</g:link> <span class="divider">/</span>
        </li>
        <li class="active"><g:message code="g.newProjectIntro"/></li>
    </ul>

    <div class="row-fluid">
        <div class="span1">
            <img class="logo" src="${project.documents?.find { it.role == 'logo' }?.thumbnailUrl}">
        </div>
        <div class="header-text span11">
            <h2>${project.name}</h2>
            <h4 class="organisation">${project.organisationName}</h4>
        </div>
    </div>

    <div class="row-fluid margin-top-2">
        <div class="well span12">
            <markdown:renderHtml>${text}</markdown:renderHtml>
        </div>
    </div>

    <div class="row-fluid well">
        <g:link controller="project" action="index" params="[id: project.projectId]"
                class="btn btn-primary"><g:message code="g.continue"/></g:link>
    </div>

</div>

</body>
</html>