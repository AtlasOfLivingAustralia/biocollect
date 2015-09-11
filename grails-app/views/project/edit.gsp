<%@ page import="net.sf.json.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>${project?.name?.encodeAsHTML()} | <g:message code="g.projects"/> | <g:message code="g.fieldCapture"/></title>
    <r:script disposition="head">
    var fcConfig = {
        projectUpdateUrl: "${createLink(action:'ajaxUpdate')}",
        organisationCreateUrl: "${createLink(controller: 'organisation', action: 'create')}",
        organisationLinkBaseUrl: "${createLink(controller: 'organisation', action: 'index')}",
        spatialService: '${createLink(controller:'proxy',action:'feature')}',
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        geocodeUrl: "${grailsApplication.config.google.geocode.url}",
        imageLocation:"${resource(dir:'/images')}",
        siteMetaDataUrl: "${createLink(controller:'site', action:'locationMetadataForPoint')}",
        returnTo: "${createLink(controller: 'project', action: 'index', id: project?.projectId)}"
        },
        here = window.location.href;

    </r:script>
    <r:require modules="knockout,jqueryValidationEngine,datepicker,amplify,drawmap,jQueryFileUpload,projects,organisation, fuseSearch"/>
</head>

<body>
<div class="container-fluid validationEngineContainer" id="validation-container">

<ul class="breadcrumb">
    <li><g:link controller="home"><g:message code="g.home"/></g:link> <span class="divider">/</span></li>
    <li><g:link controller="project" action="index"
                id="${project.projectId}">${project.name?.encodeAsHTML()}</g:link> <span class="divider">/</span>
    </li>
    <li class="active"><g:message code="g.edit"/></li>
</ul>
<form id="projectDetails" class="form-horizontal">
    <g:render template="details" model="${pageScope.variables}"/>
</form>
<div class="form-actions">
    <button type="button" id="save" class="btn btn-primary"><g:message code="g.save"/></button>
    <button type="button" id="cancel" class="btn"><g:message code="g.cancel"/></button>
</div>

</div>
<r:script>
$(function(){

    var PROJECT_DATA_KEY="CreateProjectSavedData";

    var programsModel = <fc:modelAsJavascript model="${programs}"/>;
    var userOrganisations = <fc:modelAsJavascript model="${userOrganisations?:[]}"/>;
    var organisations = <fc:modelAsJavascript model="${organisations?:[]}"/>;
    var project = <fc:modelAsJavascript model="${project?:[:]}"/>;

    <g:if test="${params.returning}">
        project = JSON.parse(amplify.store(PROJECT_DATA_KEY));
        amplify.store(PROJECT_DATA_KEY, null);
    </g:if>

    var viewModel =  new CreateEditProjectViewModel(project, true, userOrganisations, organisations, {storageKey:PROJECT_DATA_KEY});
    viewModel.loadPrograms(programsModel);

    $('#projectDetails').validationEngine();
    $('.helphover').popover({animation: true, trigger:'hover'});

    ko.applyBindings(viewModel, document.getElementById("projectDetails"));

    $('#cancel').click(function () {
        document.location.href = "${createLink(action: 'index', id: project?.projectId)}";
    });
    $('#save').click(function () {
        if ($('#projectDetails').validationEngine('validate')) {

            viewModel.saveWithErrorDetection(function(data) {
                var projectId = "${project?.projectId}" || data.projectId;
                document.location.href = "${createLink(action: 'index')}/" + projectId;
            });
        }
    });
 });
</r:script>

</body>
</html>