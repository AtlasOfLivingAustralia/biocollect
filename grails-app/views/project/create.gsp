<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
`<g:set var="projectService" bean="projectService"></g:set>`
<g:set var="mapService" bean="mapService"></g:set>
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title> <g:message code="g.create"/> | <g:message code="g.project"/> | <g:message code="g.fieldCapture"/></title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumb" content="Create Project"/>
    <asset:script type="text/javascript">
    var fcConfig = {
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
        projectUpdateUrl: "${createLink(action:'ajaxCreate')}",
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
        deleteSiteUrl: "${createLink(controller:'site', action:'delete')}",
        returnTo: "${createLink(controller: 'project', action: 'index', id: project?.projectId)}",
        <g:applyCodec encodeAs="none">
            scienceTypes: ${scienceTypes as grails.converters.JSON},
            ecoScienceTypes: ${ecoScienceTypes as grails.converters.JSON},
            lowerCaseScienceType: ${grailsApplication.config.biocollect.scienceType.collect{ it?.toLowerCase() } as grails.converters.JSON},
            lowerCaseEcoScienceType: ${grailsApplication.config.biocollect.ecoScienceType.collect{ it?.toLowerCase() } as grails.converters.JSON},
            dataCollectionWhiteListUrl: "${createLink(controller: 'project', action: 'getDataCollectionWhiteList')}",
            countriesUrl: "${createLink(controller: 'project', action: 'getCountries')}",
            hideProjectEditScienceTypes: ${!!hubConfig?.content?.hideProjectEditScienceTypes},
            uNRegionsUrl: "${createLink(controller: 'project', action: 'getUNRegions')}",
            allBaseLayers: ${grailsApplication.config.map.baseLayers as grails.converters.JSON},
            allOverlays: ${grailsApplication.config.map.overlays as grails.converters.JSON},
            mapLayersConfig: ${mapService.getMapLayersConfig(project, pActivity) as JSON},
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
<div class="container-fluid validationEngineContainer" id="validation-container">
    <h2><g:message code="project.create.register"/></h2>
    <p>
        <g:message code="project.create.description"/>
    </p>

    <form id="projectDetails" class="form-horizontal">
        <g:render template="details" model="${pageScope.variables}"/>
        <div class="row" style="display: none" data-bind="visible: true">
            <div class="col-12 btn-space">
                <div class="alert warning" data-bind="visible: !termsOfUseAccepted() && !isExternal()"><g:message code="project.details.termsOfUseAgreement.saveButtonWarning"/></div>

                <button type="button" id="save" class="btn btn-primary-dark" data-bind="disable: (!termsOfUseAccepted() && !isExternal())" title="<g:message code="g.save.title"/>"><i class="fas fa-hdd"></i> <g:message code="g.save"/></button>
                <button type="button" id="publish" class="btn btn-primary-dark" data-bind="enable: ((((isCitizenScience() || isEcoScience()) && isExternal()) || isWorks()) && termsOfUseAccepted())"><i class="fas fa-hdd"></i> <g:message code="g.publish"/></button>
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

    <g:if test="${citizenScience}">
    viewModel.transients.kindOfProject("citizenScience");
    $('#cancel').click(function () {
        document.location.href = "${createLink(action: 'homePage')}";
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
                bootbox.dialog({message:"${message(code:'project.create.warningdatacollection')}"},
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
                var projectErrors = viewModel.transients.projectHasErrors()
                if (!projectErrors) {
                    viewModel.saveWithErrorDetection(function(data) {
                        var projectId = "${project?.projectId}" || data.projectId;

                        if (viewModel.isExternal()) {
                            document.location.href = "${createLink(action: 'index')}/" + projectId;
                        } else {
                            document.location.href = "${createLink(action: 'newProjectIntro')}/" + projectId;
                        }
                    },function(data) {
                        var responseText = data.responseText || "${message(code:'project.create.error')}";
                        bootbox.alert(responseText);
                    });
                } else {
                    bootbox.alert(projectErrors);
                }
            }
        }
    });

    $('#publish').click(function () {
        if ($('#projectDetails').validationEngine('validate')) {
            if(viewModel.transients.kindOfProject() == 'citizenScience' && !viewModel.transients.isDataEntryValid()){
                bootbox.dialog({message:"${message(code:'project.create.warningdatacollection')}"},
                    [{
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
                    }]
                );
            } else {
                var projectErrors = viewModel.transients.projectHasErrors()
                if (!projectErrors) {
                    viewModel.publicationStatus = true;

                    viewModel.saveWithErrorDetection(function(data) {
                        var projectId = "${project?.projectId}" || data.projectId;

                        if (viewModel.isExternal()) {
                            document.location.href = "${createLink(action: 'index')}/" + projectId;
                        } else {
                            document.location.href = "${createLink(action: 'newProjectIntro')}/" + projectId;
                        }
                    },function(data) {
                        var responseText = data.responseText || "${message(code:'project.create.error')}";
                        bootbox.alert(responseText);
                    });
                } else {
                    bootbox.alert(projectErrors);
                }
            }
        }
    });

    ko.applyBindings(viewModel, document.getElementById("projectDetails"));
 });
</asset:script>

</body>
</html>