<%@ page import="net.sf.json.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>${project?.name?.encodeAsHTML()} | <g:message code="g.projects"/> | <g:message code="g.fieldCapture"/></title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'projectFinder')},Home"/>
    <meta name="breadcrumbParent2" content="${createLink(controller: 'project', action: 'index')}/${project.projectId},${project.name?.encodeAsHTML()}"/>
    <meta name="breadcrumb" content="Edit"/>

    <r:script disposition="head">
    var fcConfig = {
        projectUpdateUrl: "${createLink(action:'ajaxUpdate')}",
        organisationCreateUrl: "${createLink(controller: 'organisation', action: 'create')}",
        organisationLinkBaseUrl: "${createLink(controller: 'organisation', action: 'index')}",
        organisationSearchUrl: "${createLink(controller: 'organisation', action: 'search')}",
        // organisationSearchUrl: "${createLink(controller: 'organisation', action: 'searchMyOrg')}",
        spatialService: '${createLink(controller:'proxy',action:'feature')}',
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        geocodeUrl: "${grailsApplication.config.google.geocode.url}",
        imageLocation:"${resource(dir:'/images')}",
        siteMetaDataUrl: "${createLink(controller:'site', action:'locationMetadataForPoint')}",
        returnTo: "${createLink(controller: 'project', action: 'index', id: project?.projectId)}",
        scienceTypes: ${scienceTypes as grails.converters.JSON},
        lowerCaseScienceType: ${grailsApplication.config.biocollect.scienceType.collect{ it?.toLowerCase() } as grails.converters.JSON},
        ecoScienceTypes: ${ecoScienceTypes as grails.converters.JSON},
        lowerCaseEcoScienceType: ${grailsApplication.config.biocollect.ecoScienceType.collect{ it?.toLowerCase() } as grails.converters.JSON},
        countriesUrl: "${createLink(controller: 'project', action: 'getCountries')}",
        uNRegionsUrl: "${createLink(controller: 'project', action: 'getUNRegions')}",
        dataCollectionWhiteListUrl: "${createLink(controller: 'project', action: 'getDataCollectionWhiteList')}"
        },
        here = window.location.href;

    </r:script>
    <r:require modules="knockout,jqueryValidationEngine,datepicker,amplify,jQueryFileUpload,projects,organisation, fuseSearch, map, largeCheckbox"/>
</head>

<body>
<div class="container-fluid validationEngineContainer" id="validation-container">
<form id="projectDetails" class="form-horizontal">
    <g:render template="details" model="${pageScope.variables}"/>
    <div class="well">
        <button type="button" id="save" class="btn btn-primary"><g:message code="g.save"/></button>
        <button type="button" id="cancel" class="btn"><g:message code="g.cancel"/></button>
    </div>
</form>

</div>
<r:script>
$(function(){

    var PROJECT_DATA_KEY="CreateProjectSavedData";

    var programsModel = <fc:modelAsJavascript model="${programs}"/>;
    var project = <fc:modelAsJavascript model="${project?:[:]}"/>;

    <g:if test="${params.returning}">
        var storedProject = amplify.store(PROJECT_DATA_KEY);
        if(storedProject !== undefined) {
            project = JSON.parse(storedProject);
            amplify.store(PROJECT_DATA_KEY, null);
        }
    </g:if>

    var viewModel =  new CreateEditProjectViewModel(project, true, {storageKey:PROJECT_DATA_KEY});
    viewModel.loadPrograms(programsModel);

    $('#projectDetails').validationEngine();
    $('.helphover').popover({animation: true, trigger:'hover'});

    ko.applyBindings(viewModel, document.getElementById("projectDetails"));

    $('#cancel').click(function () {
        document.location.href = "${createLink(action: 'index', id: project?.projectId)}";
    });
    $('#save').click(function () {
    if(viewModel.transients.kindOfProject() == 'citizenScience' && !viewModel.transients.isDataEntryValid()){
        bootbox.dialog("Use of this system for data collection is not available for non-biodiversity related projects." +
            " Press continue to turn data collection feature off. Otherwise, press cancel to modify the form.", [{
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
            }]);
    } else {
        if ($('#projectDetails').validationEngine('validate')) {
            var projectErrors = viewModel.transients.projectHasErrors()
                if (!projectErrors) {
                    viewModel.saveWithErrorDetection(function(data) {
                        var projectId = "${project?.projectId}" || data.projectId;
                        document.location.href = "${createLink(action: 'index')}/" + projectId;
                    });
                } else {
                    bootbox.alert(projectErrors);
                }
        }
    }
    });
 });
</r:script>

</body>
</html>