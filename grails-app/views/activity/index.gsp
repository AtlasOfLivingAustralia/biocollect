<%@ page import="au.org.ala.biocollect.merit.ActivityService; grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="bs4"/>
    <title>View | ${activity.type} | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/'+ hubConfig.urlPath)},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'project', action: 'index')}/${project.projectId},Project"/>
    <meta name="breadcrumb" content="${activity.type}"/>

    <g:set var="commentUrl" value="${resource(dir: '/activity')}/${activity.activityId}/comment"></g:set>

    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <asset:script type="text/javascript">
        var fcConfig = {
        <g:applyCodec encodeAs="none">
            intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
        activityDeleteUrl: "${createLink(controller: 'activity', action: 'ajaxDelete')}",
        projectViewUrl: "${createLink(controller: 'project', action: 'index')}/",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}/",
        imageLocation:"${asset.assetPath(src: '')}",
        createCommentUrl : "${commentUrl}",
        commentListUrl:"${commentUrl}",
        updateCommentUrl:"${commentUrl}",
        deleteCommentUrl:"${commentUrl}",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        bieWsUrl: "${grailsApplication.config.bieWs.baseURL}",
        surveyName: "${metaModel.name}",
        noImageUrl: '${asset.assetPath(src: "font-awesome/5.15.4/svgs/regular/image.svg")}',
        speciesConfig: ${raw(fc.modelAsJavascript(model: speciesConfig))},
        speciesSearch: "${raw(createLink(controller: 'project', action: 'searchSpecies', params: [id: project.projectId, limit: 10]))}",
        speciesSearchUrl: "${raw(createLink(controller: 'project', action: 'searchSpecies', params: [id: project.projectId, limit: 10]))}",
        speciesProfileUrl: "${raw(createLink(controller: 'proxy', action: 'speciesProfile'))}",
        speciesListUrl: "${createLink(controller: 'proxy', action: 'speciesItemsForList')}",
        searchBieUrl: "${raw(createLink(controller: 'project', action: 'searchSpecies', params: [id: project.projectId, limit: 10]))}",
        getGuidForOutputSpeciesUrl : "${createLink(controller: 'record', action: 'getGuidForOutputSpeciesIdentifier')}",
        project:${raw(fc.modelAsJavascript(model: project))},
        mapLayersConfig: <fc:modelAsJavascript model="${mapService.getMapLayersConfig(project, null)}"/>,
        excelOutputTemplateUrl: "${createLink(controller: 'proxy', action: 'excelOutputTemplate')}",
        sites: ${raw(fc.modelAsJavascript(model: project?.sites))}
        </g:applyCodec>
        },
        here = document.location.href;
    </asset:script>
    <asset:stylesheet src="forms-manifest.css"/>
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="forms-manifest.js"/>
    <asset:javascript src="meritActivity.js"/>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
    <g:set var="pActivity" value="${[commentsAllowed: false]}"/>
</head>

<body>
<div class="container-fluid validationEngineContainer" id="validation-container">
    <div id="koActivityMainBlock">
        <g:if test="${editInMerit}">
            <div class="alert alert-danger">
                <strong>Note:</strong> This activity can only be edited in the <a
                    href="${g.createLink(action: 'edit', id: activity.activityId, base: grailsApplication.config.merit.url)}"
                    target="_merit">MERIT system</a>
            </div>
        </g:if>


        <div class="row title-block card input-block-level">
            <div class="col-sm-12 title-attribute">
                <h1><span data-bind="click:goToProject"
                          class="clickable">${project?.name?.encodeAsHTML() ?: 'no project defined!!'}</span></h1>

                <h3>Activity: <span data-bind="text:type"></span></h3>
                <h4><span>${project.associatedProgram?.encodeAsHTML()}</span> <span>${project.associatedSubProgram?.encodeAsHTML()}</span>
                </h4>
            </div>
        </div>

        <div class="row mt-3 ml-3">
            <div class="${mapFeatures.toString() != '{}' ? 'col-sm-9' : 'col-sm-12'}" style="font-size: 1.2em">
                <!-- Common activity fields -->
                <div class="row">
                    <span class="col-sm-6"><span class="badge badge-secondary rounded-pill">Description:</span> <span
                            data-bind="text:description"></span></span>
                    <span class="col-sm-6"><span class="badge badge-secondary rounded-pill">Type:</span> <span data-bind="text:type"></span></span>
                </div>

                <div class="row mt-3">
                    <span class="col-sm-6"><span class="badge badge-secondary rounded-pill">Starts:</span> <span
                            data-bind="text:startDate.formattedDate"></span></span>
                    <span class="col-sm-6"><span class="badge badge-secondary rounded-pill">Ends:</span> <span
                            data-bind="text:endDate.formattedDate"></span></span>
                </div>

                <div class="row mt-3">
                    <span class="col-sm-6"><span class="badge badge-secondary rounded-pill">Project stage:</span> <span
                            data-bind="text:projectStage"></span></span>
                    <span class="col-sm-6"><span class="badge badge-secondary rounded-pill">Major theme:</span> <span data-bind="text:mainTheme"></span>
                    </span>
                </div>

                <div class="row mt-3">
                    <span class="col-sm-6"><span class="badge badge-secondary rounded-pill">Activity status:</span> <span
                            data-bind="text:progress"></span></span>
                </div>
            </div>
        </div>

        <g:if env="development" test="${!printView}">
            <div class="expandable-debug">
                <hr/>

                <h3>Debug</h3>

                <div>
                    <h4>KO model</h4>
                    <pre data-bind="text:ko.toJSON($root,null,2)"></pre>
                    <h4>Activity</h4>
                    <pre>${activity?.encodeAsHTML()}</pre>
                    <h4>Site</h4>
                    <pre>${site?.encodeAsHTML()}</pre>
                    <h4>Sites</h4>
                    <pre>${(sites as JSON).toString()}</pre>
                    <h4>Project</h4>
                    <pre>${project?.encodeAsHTML()}</pre>
                    <h4>Activity model</h4>
                    <pre>${metaModel}</pre>
                    <h4>Output models</h4>
                    <pre>${outputModels}</pre>
                    <h4>Themes</h4>
                    <pre>${themes.toString()}</pre>
                    <h4>Map features</h4>
                    <pre>${mapFeatures.toString()}</pre>
                </div>
            </div>
        </g:if>
    </div>
    <div class="row ml-3 mr-3">
        <div class="col-sm-12">
        <!-- ko stopBinding: true -->
        <g:each in="${metaModel?.outputs}" var="outputName">

            <g:if test="${outputName != 'Photo Points'}">
                <g:render template="/output/outputJSModel" plugin="ecodata-client-plugin"
                          model="${[viewModelInstance: activity.activityId + fc.toSingleWord([name: outputName]) + 'ViewModel',
                                    edit             : false, model: outputModels[outputName],
                                    outputName       : outputName]}"></g:render>
                <g:render template="/output/readOnlyOutput"
                          model="${[activity     : activity,
                                    outputModel  : outputModels[outputName],
                                    outputName   : outputName,
                                    activityModel: metaModel,
                                    disablePrepop: activity.progress != au.org.ala.biocollect.merit.ActivityService.PROGRESS_PLANNED]}"
                          plugin="ecodata-client-plugin"></g:render>

            </g:if>
        </g:each>
        <!-- /ko -->
        <g:if test="${pActivity?.commentsAllowed}">
            <g:render template="/comment/comment"></g:render>
        </g:if>
        <div class="form-actions">
            <button type="button" id="cancel" class="btn btn-dark"><i class="far fa-arrow-alt-circle-left"></i> return</button>
        </div>
    </div>
    </div>
</div>

<!-- templates -->

<asset:script type="text/javascript">

    var returnTo = "${returnTo}";

    function ActivityLevelData() {
        var self = this;
        self.activity = JSON.parse('${(activity as JSON).toString().encodeAsJavaScript()}');
        self.site = JSON.parse('${(site as JSON).toString().encodeAsJavaScript()}');
        self.metaModel = <fc:modelAsJavascript model="${metaModel}"/>;
        self.themes = <fc:modelAsJavascript model="${themes}"/>;
        // We only need the sites from a pActivity within works projects
        self.pActivity = fcConfig.project
    }

    var activityLevelData = new ActivityLevelData();

    $(function(){

        $('.helphover').popover({animation: true, trigger:'hover'});

        $('#cancel').on('click',function () {
            document.location.href = returnTo;
        });

        var viewModel = new ActivityViewModel(
            activityLevelData.activity,
            activityLevelData.site,
            fcConfig.project,
            activityLevelData.metaModel,
            activityLevelData.themes);
        ko.applyBindings(viewModel);
    <g:if test="${pActivity.commentsAllowed}">
        ko.applyBindings(new CommentListViewModel(),document.getElementById('commentOutput'));
    </g:if>

    });
</asset:script>
</body>
</html>
