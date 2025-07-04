<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title>${project?.name?.encodeAsHTML()} | <g:message code="g.projects"/> | <g:message
            code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(uri: "/" + hubConfig.urlPath)},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'project', action: 'index')}/${project.projectId},${project.name?.encodeAsHTML()}"/>
    <meta name="breadcrumb" content="Introduction"/>
    <asset:javascript src="common.js"/>
</head>

<body>
<div class="container-fluid">
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
            <fc:markdownToHtml>${raw(text)}</fc:markdownToHtml>
        </div>
    </div>

    <div class="row">
        <div class="col-12">
            <g:link controller="project" action="index" params="[id: project.projectId]"
                    class="btn btn-primary" onclick="amplify.store('ul-main-project-state', '#admin-tab'); amplify.store('ul-cs-internal-project-admin-state', '#project-activity')">
                <g:message code="g.continue"/>
            </g:link>
        </div>
    </div>

</div>

</body>
</html>
