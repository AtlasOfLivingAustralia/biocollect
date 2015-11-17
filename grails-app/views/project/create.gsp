<%@ page import="net.sf.json.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Create | Project | <g:message code="g.fieldCapture"/></title>
    <r:script disposition="head">
    var fcConfig = {
        projectUpdateUrl: "${createLink(action:'ajaxUpdate')}",
        organisationLinkBaseUrl: "${createLink(controller: 'organisation', action: 'index')}",
        organisationCreateUrl: "${createLink(controller: 'organisation', action: 'create')}",
        spatialService: '${createLink(controller:'proxy',action:'feature')}',
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        geocodeUrl: "${grailsApplication.config.google.geocode.url}",
        siteMetaDataUrl: "${createLink(controller:'site', action:'locationMetadataForPoint')}",
        returnTo: "${createLink(controller: 'project', action: 'index', id: project?.projectId)}"
        },
        here = window.location.href;

    </r:script>
    <r:require modules="knockout,jqueryValidationEngine,datepicker,amplify,drawmap,jQueryFileUpload,projects,organisation,fuseSearch"/>
</head>

<body>
<div class="container-fluid validationEngineContainer" id="validation-container">

<ul class="breadcrumb">
    <li><g:link controller="home"><g:message code="g.home"/></g:link> <span class="divider">/</span></li>

    <li class="active">Create Project</li>
</ul>
    <h2>Register a new project</h2>
    <p>
    Please tell us about your project by completing the form below.  Questions marked with a * are mandatory.
    </p>
    <form id="projectDetails" class="form-horizontal">
        <g:render template="details" model="${pageScope.variables}"/>

        <g:if test="${grailsApplication.config.termsOfUseUrl}">
            <div class="row-fluid" style="display: none" data-bind="visible: !isExternal()">
                <div class="well">
                    <h4 class="block-header"><g:message code="project.details.termsOfUseAgreement"/></h4>

                    <div class="clearfix">
                        <label class="control-label span3" for="termsOfUseAgreement"><g:message code="project.details.termsOfUseAgreement"/><fc:iconHelp><g:message code="project.details.termsOfUseAgreement.help"/></fc:iconHelp></label>
                        <div class="controls span9">
                            <input data-bind="checked:termsOfUseAccepted, disable: !transients.termsOfUseClicked()" type="checkbox" id="termsOfUseAgreement" name="termsOfUseAgreement" data-validation-engine="validate[required]" title="<g:message code="project.details.termsOfUseAgreement.checkboxTip"/>"/>
                            I confirm that have read and accept the <a href="${grailsApplication.config.termsOfUseUrl}" data-bind="click: clickTermsOfUse" target="_blank">Terms of Use</a>.
                        </div>
                    </div>
                </div>
            </div>
        </g:if>
        <div class="well" style="display: none" data-bind="visible: true"> <!-- hide the panel until knockout has finished. Needs to use an inline style for this to work. -->
            <div class="alert warning" data-bind="visible: !termsOfUseAccepted() && !isExternal()"><g:message code="project.details.termsOfUseAgreement.saveButtonWarning"/></div>
            <button type="button" id="save" class="btn btn-primary" data-bind="disable: !termsOfUseAccepted() && !isExternal()"><g:message code="g.save"/></button>
            <button type="button" id="cancel" class="btn"><g:message code="g.cancel"/></button>
        </div>
    </form>
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
    viewModel.isMetadataSharing(true);

    $('#projectDetails').validationEngine();
    $('.helphover').popover({animation: true, trigger:'hover'});

    <g:if test="${citizenScience}">
    viewModel.transients.kindOfProject("citizenScience");
    $('#cancel').click(function () {
        document.location.href = "${createLink(action: 'citizenScience')}";
    });
    </g:if>
    <g:else>
    $('#cancel').click(function () {
        document.location.href = "${createLink(action: 'index', id: project?.projectId)}";
    });
    </g:else>
    $('#save').click(function () {
        if ($('#projectDetails').validationEngine('validate')) {

            viewModel.saveWithErrorDetection(function(data) {
                var projectId = "${project?.projectId}" || data.projectId;
            <g:if test="${citizenScience}">
                document.location.href = "${createLink(action: 'newProjectIntro')}/" + projectId;
            </g:if>
            <g:else>
                document.location.href = "${createLink(action: 'index')}/" + projectId;
            </g:else>
            });
        }
    });

    ko.applyBindings(viewModel, document.getElementById("projectDetails"));
 });
</r:script>

</body>
</html>