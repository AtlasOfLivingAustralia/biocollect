<%@ page import="au.org.ala.biocollect.merit.ActivityService; grails.converters.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <g:if test="${printView}">
        <meta name="layout" content="nrmPrint"/>
        <title>Print | ${activity.type} | Field Capture</title>
    </g:if>
    <g:else>
        <meta name="layout" content="${hubConfig.skin}"/>
        <title>View | ${activity.type} | Field Capture</title>
    </g:else>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'project', action: 'index')}/${project.projectId},Project"/>
    <meta name="breadcrumb" content="${activity.type}"/>

    <g:set var="commentUrl" value="${resource(dir:'/activity')}/${activity.activityId}/comment"></g:set>

    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <asset:script type="text/javascript">
    var fcConfig = {
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
        activityDeleteUrl: "${createLink(controller: 'activity', action: 'ajaxDelete')}",
        projectViewUrl: "${createLink(controller: 'project', action: 'index')}/",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}/",
        imageLocation:"${asset.assetPath(src:'')}",
        createCommentUrl : "${commentUrl}",
        commentListUrl:"${commentUrl}",
        updateCommentUrl:"${commentUrl}",
        deleteCommentUrl:"${commentUrl}",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        surveyName: "${metaModel.name}",
        speciesConfig: ${fc.modelAsJavascript(model: speciesConfig)},
        speciesSearch: "${createLink(controller: 'project', action: 'searchSpecies', params: [id: project.projectId, limit: 10])}",
        speciesSearchUrl: "${createLink(controller: 'project', action: 'searchSpecies', params: [id: project.projectId, limit: 10])}",
        speciesProfileUrl: "${createLink(controller: 'proxy', action: 'speciesProfile')}",
        speciesListUrl: "${createLink(controller: 'proxy', action: 'speciesItemsForList')}",
        searchBieUrl: "${createLink(controller: 'project', action: 'searchSpecies', params: [id: project.projectId, limit: 10])}",
        getGuidForOutputSpeciesUrl : "${createLink(controller: 'record', action: 'getGuidForOutputSpeciesIdentifier')}",
        project:${fc.modelAsJavascript(model:project)},
        sites: ${fc.modelAsJavascript(model:project?.sites)}
        },
        here = document.location.href;
    </asset:script>
    <asset:stylesheet src="forms-manifest.css"/>
    <asset:javascript src="common.js"/>
    <asset:javascript src="forms-manifest.js"/>
    <asset:javascript src="meritActivity.js"/>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
    <g:set var="pActivity" value="${[commentsAllowed:false]}"/>
</head>
<body>
<div class="container-fluid validationEngineContainer" id="validation-container">
    <div id="koActivityMainBlock">
        <g:if test="${editInMerit}">
            <div class="alert alert-error">
                <strong>Note:</strong> This activity can only be edited in the <a href="${g.createLink(action:'edit',  id:activity.activityId, base:grailsApplication.config.merit.url)}" target="_merit">MERIT system</a>
            </div>
        </g:if>


        <div class="row-fluid title-block well well-small input-block-level">
            <div class="span12 title-attribute">
                <h1><span data-bind="click:goToProject" class="clickable">${project?.name?.encodeAsHTML() ?: 'no project defined!!'}</span></h1>
                <h3>Activity: <span data-bind="text:type"></span></h3>
                <h4><span>${project.associatedProgram?.encodeAsHTML()}</span> <span>${project.associatedSubProgram?.encodeAsHTML()}</span></h4>
            </div>
        </div>

        <div class="row">
            <div class="${mapFeatures.toString() != '{}' ? 'span9' : 'span12'}" style="font-size: 1.2em">
                <!-- Common activity fields -->
                <div class="row-fluid">
                    <span class="span6"><span class="label">Description:</span> <span data-bind="text:description"></span></span>
                    <span class="span6"><span class="label">Type:</span> <span data-bind="text:type"></span></span>
                </div>
                <div class="row-fluid">
                    <span class="span6"><span class="label">Starts:</span> <span data-bind="text:startDate.formattedDate"></span></span>
                    <span class="span6"><span class="label">Ends:</span> <span data-bind="text:endDate.formattedDate"></span></span>
                </div>
                <div class="row-fluid">
                    <span class="span6"><span class="label">Project stage:</span> <span data-bind="text:projectStage"></span></span>
                    <span class="span6"><span class="label">Major theme:</span> <span data-bind="text:mainTheme"></span></span>
                </div>
                <div class="row-fluid">
                    <span class="span6"><span class="label">Activity status:</span> <span data-bind="text:progress"></span></span>
                </div>
            </div>
        </div>

        <g:if env="development" test="${!printView}">
            <div class="expandable-debug">
                <hr />
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

    <!-- ko stopBinding: true -->
    <g:each in="${metaModel?.outputs}" var="outputName">

        <g:if test="${outputName != 'Photo Points'}">
            <g:render template="/output/outputJSModel" plugin="ecodata-client-plugin"
                      model="${[viewModelInstance:activity.activityId+fc.toSingleWord([name: outputName])+'ViewModel',
                                edit:false, model:outputModels[outputName],
                                outputName:outputName]}"></g:render>
            <g:render template="/output/readOnlyOutput"
                      model="${[activity:activity,
                                outputModel:outputModels[outputName],
                                outputName:outputName,
                                activityModel:metaModel,
                                disablePrepop: activity.progress != au.org.ala.biocollect.merit.ActivityService.PROGRESS_PLANNED]}"
                      plugin="ecodata-client-plugin"></g:render>

        </g:if>
    </g:each>
    <!-- /ko -->
    <g:if test="${projectActivity?.commentsAllowed}">
        <g:render template="/comment/comment"></g:render>
    </g:if>
    <div class="form-actions">
        <button type="button" id="cancel" class="btn">return</button>
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

        $('#cancel').click(function () {
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