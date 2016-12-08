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
        organisationSearchUrl: "${createLink(controller: 'organisation', action: 'search')}",
        spatialService: '${createLink(controller:'proxy',action:'feature')}',
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        geocodeUrl: "${grailsApplication.config.google.geocode.url}",
        siteMetaDataUrl: "${createLink(controller:'site', action:'locationMetadataForPoint')}",
        returnTo: "${createLink(controller: 'project', action: 'index', id: project?.projectId)}",
        scienceTypes: ${scienceTypes as grails.converters.JSON},
        ecoScienceTypes: ${ecoScienceTypes as grails.converters.JSON},
        lowerCaseScienceType: ${grailsApplication.config.biocollect.scienceType.collect{ it?.toLowerCase() } as grails.converters.JSON},
        lowerCaseEcoScienceType: ${grailsApplication.config.biocollect.ecoScienceType.collect{ it?.toLowerCase() } as grails.converters.JSON},
        dataCollectionWhiteListUrl: "${createLink(controller: 'project', action: 'getDataCollectionWhiteList')}",
        countriesUrl: "${createLink(controller: 'project', action: 'getCountries')}",
        uNRegionsUrl: "${createLink(controller: 'project', action: 'getUNRegions')}"
        },
        here = window.location.href;

    </r:script>
    <r:require modules="knockout,jqueryValidationEngine,datepicker,amplify,jQueryFileUpload,projects,organisation,fuseSearch,map,largeCheckbox"/>
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
                        <div class="controls span9 large-checkbox">
                            <input data-bind="checked:termsOfUseAccepted, disable: !transients.termsOfUseClicked()" type="checkbox" id="termsOfUseAgreement" name="termsOfUseAgreement" data-validation-engine="validate[required]" title="<g:message code="project.details.termsOfUseAgreement.checkboxTip"/>"/>
                            <label for="termsOfUseAgreement"><span></span> I confirm that have read and accept the <a href="${grailsApplication.config.termsOfUseUrl}" data-bind="click: clickTermsOfUse" target="_blank">Terms of Use</a>.</label>
                            <div class="margin-bottom-1"></div>
                            <p><g:message code="project.details.termsOfUseAgreement.help"/></p>
                            <p><img src="${request.contextPath}/images/cc.png" alt="Creative Commons Attribution 3.0"></p>
                        </div>
                    </div>
                </div>
            </div>
        </g:if>
        <div class="well" style="display: none" data-bind="visible: true"> <!-- hide the panel until knockout has finished. Needs to use an inline style for this to work. -->
            <div class="alert warning" data-bind="visible: !termsOfUseAccepted() && !isExternal()"><g:message code="project.details.termsOfUseAgreement.saveButtonWarning"/></div>
            <button type="button" id="save" class="btn btn-primary" data-bind="disable: (!termsOfUseAccepted() && !isExternal())"><g:message code="g.save"/></button>
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
            if(viewModel.transients.kindOfProject() == 'citizenScience' && !viewModel.transients.isDataEntryValid()){
                bootbox.dialog("Use of this system for data collection is not available for non-biodiversity related projects." +
                    "Press continue to turn data collection feature off. Otherwise, press cancel to modify the form.",
                    [{
                      label: "Continue",
                      className: "btn-primary",
                      callback: function() {
                        viewModel.isExternal(true);
                        $('#save').click()
                      }
                    },{
                        label: "Cancel",
                        className: "btn-alert",
                        callback: function() {
                            $('html, body').animate({
                                scrollTop: $("#scienceTypeControlGroup").offset().top
                            }, 2000);
                       }
                    }]
                );
            } else {
                if (viewModel.transients.kindOfProject() == 'ecoscience' || viewModel.transients.siteViewModel.isValid(true)) {
                    viewModel.saveWithErrorDetection(function(data) {
                        var projectId = "${project?.projectId}" || data.projectId;

                        if (viewModel.isExternal()) {
                            document.location.href = "${createLink(action: 'index')}/" + projectId;
                        } else {
                            document.location.href = "${createLink(action: 'newProjectIntro')}/" + projectId;
                        }
                    });
                } else {
                    bootbox.alert("You must define the spatial extent of the project area");
                }
            }
        }
    });

    ko.applyBindings(viewModel, document.getElementById("projectDetails"));
 });
</r:script>

</body>
</html>