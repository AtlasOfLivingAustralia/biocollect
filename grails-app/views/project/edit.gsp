<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title>${project?.name?.encodeAsHTML()} | <g:message code="g.projects"/> | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/'+ hubConfig.urlPath)},Home"/>
    <meta name="breadcrumbParent2" content="${createLink(controller: 'project', action: 'index')}/${project.projectId},${project.name?.encodeAsHTML()}"/>
    <meta name="breadcrumb" content="Edit"/>

    <asset:script type="text/javascript">
    var fcConfig = {
        <g:applyCodec encodeAs="none">
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
        projectUpdateUrl: "${createLink(action:'ajaxUpdate')}",
        organisationCreateUrl: "${createLink(controller: 'organisation', action: 'create')}",
        organisationLinkBaseUrl: "${createLink(controller: 'organisation', action: 'index')}",
        organisationSearchUrl: "${createLink(controller: 'organisation', action: 'search')}",
        // organisationSearchUrl: "${createLink(controller: 'organisation', action: 'searchMyOrg')}",
        spatialService: '${createLink(controller:'proxy',action:'feature')}',
        geocodeUrl: "${grailsApplication.config.google.geocode.url}",
        imageLocation:"${asset.assetPath(src:'')}",
        siteMetaDataUrl: "${createLink(controller:'site', action:'locationMetadataForPoint')}",
        returnTo: "${createLink(controller: 'project', action: 'index', id: project?.projectId)}",
        scienceTypes: <fc:modelAsJavascript model="${scienceTypes}"/>,
        lowerCaseScienceType: <fc:modelAsJavascript model="${grailsApplication.config.biocollect.scienceType.collect{ it?.toLowerCase() }}" />,
        ecoScienceTypes: <fc:modelAsJavascript model="${ecoScienceTypes}"/>,
        lowerCaseEcoScienceType: <fc:modelAsJavascript model="${grailsApplication.config.biocollect.ecoScienceType.collect{ it?.toLowerCase() }}" />,
        countriesUrl: "${createLink(controller: 'project', action: 'getCountries')}",
        uNRegionsUrl: "${createLink(controller: 'project', action: 'getUNRegions')}",
        dataCollectionWhiteListUrl: "${createLink(controller: 'project', action: 'getDataCollectionWhiteList')}",
        allBaseLayers: <fc:modelAsJavascript model="${grailsApplication.config.map.baseLayers}"/>,
        allOverlays: <fc:modelAsJavascript model="${grailsApplication.config.map.overlays}"/>,
        mapLayersConfig: <fc:modelAsJavascript model="${mapService.getMapLayersConfig(project, null)}"/>,
        leafletAssetURL: "${assetPath(src: 'webjars/leaflet/0.7.7/dist/images')}"
        </g:applyCodec>
        },
        here = window.location.href;

    </asset:script>
    <asset:stylesheet src="project-create-manifest.css"/>
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="organisation.js"/>
    <asset:javascript src="projects-manifest.js"/>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
</head>

<body>
<content tag="bannertitle">
    <g:message code="project.edit"/>
</content>
<div class="container-fluid validationEngineContainer" id="validation-container">
<form id="projectDetails" class="form-horizontal">
    <g:render template="details" model="${pageScope.variables}"/>
    <div class="row">
        <div class="col-12 btn-space">
            <button type="button" id="save" class="btn btn-primary-dark"><i class="fas fa-hdd"></i> <g:message code="g.save"/></button>

            <!-- Publish workflow applies to all citizen science, eco science and works projects. When either citizen
                science or eco science, if isExternal is true, then enable the Publish button else disable the Publish button -->
            <button type="button" id="publish" class="btn btn-primary-dark" data-bind="enable: (isExternal() || isWorks() || (!isExternal() && transients.hasPublishedProjectActivities)), text:publishUnpublish()" title="<g:message code="g.publishUnpublish"/>"><i class="fas fa-hdd"></i></button>
            <button type="button" id="cancel" class="btn btn-dark"><i class="far fa-times-circle"></i> <g:message code="g.cancel"/></button>
        </div>
    </div>
</form>

</div>
<asset:script type="text/javascript">
$(function(){

    var PROJECT_DATA_KEY="CreateProjectSavedData";

    var programsModel = <fc:modelAsJavascript model="${programs}"/>;
    var project = <fc:modelAsJavascript model="${project?:[:]}"/>;
    var projectActivities = <fc:modelAsJavascript model="${projectActivities}"/>;

    <g:if test="${params.returning}">
        var storedProject = amplify.store(PROJECT_DATA_KEY);
        if(storedProject !== undefined) {
            project = JSON.parse(storedProject);
            amplify.store(PROJECT_DATA_KEY, null);
        }
    </g:if>

    var viewModel =  new CreateEditProjectViewModel(project, true, {storageKey:PROJECT_DATA_KEY});
    viewModel.loadPrograms(programsModel);
    viewModel.checkPublishedProjectActivities(projectActivities);

    $('#projectDetails').validationEngine();
    $('.helphover').popover({animation: true, trigger:'hover'});

    ko.applyBindings(viewModel, document.getElementById("projectDetails"));

    $('#cancel').on('click',function () {
        document.location.href = "${createLink(action: 'index', id: project?.projectId)}";
    });
    $('#save').on('click',function () {
    if(viewModel.transients.kindOfProject() == 'citizenScience' && !viewModel.transients.isDataEntryValid()){
        bootbox.dialog({message:"Use of this system for data collection is not available for non-biodiversity related projects." +
            " Press continue to turn data collection feature off. Otherwise, press cancel to modify the form."}, [{
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
                    },function(data) {
                        var responseText = data.responseText || 'An error occurred while saving project.';
                        bootbox.alert(responseText);
                    });
                } else {
                    bootbox.alert(projectErrors);
                }
        }
    }
    });

    $('#publish').click(function () {
    if(viewModel.transients.kindOfProject() == 'citizenScience' && !viewModel.transients.isDataEntryValid()){
        bootbox.dialog({message:"Use of this system for data collection is not available for non-biodiversity related projects." +
            " Press continue to turn data collection feature off. Otherwise, press cancel to modify the form."}, [{
              label: "Continue",
              className: "btn-primary",
              callback: function() {
                viewModel.isExternal(true);
                $('#publish').click()
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
                    <!-- In the edit mode first check the current projLifecycleStatus of the project and set the new status accordingly. -->
                    <!-- Also there is only one button for publish unpublish and the button label is set accordingly in javascript -->
                    if (project.projLifecycleStatus == 'unpublished')
                        viewModel.projLifecycleStatus = 'published';
                    else if (project.projLifecycleStatus == 'published')
                        viewModel.projLifecycleStatus = 'unpublished';

                    viewModel.saveWithErrorDetection(function(data) {
                        var projectId = "${project?.projectId}" || data.projectId;
                        document.location.href = "${createLink(action: 'index')}/" + projectId;
                    },function(data) {
                        var responseText = data.responseText || 'An error occurred while saving project.';
                        bootbox.alert(responseText);
                    });
                } else {
                    bootbox.alert(projectErrors);
                }
        }
    }
    });
 });
</asset:script>

</body>
</html>
