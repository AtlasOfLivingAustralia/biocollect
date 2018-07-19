<%@ page import="grails.converters.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <g:if test="${printView}">
        <meta name="layout" content="nrmPrint"/>
        <title>Print | ${activity.type} | Field Capture</title>
    </g:if>
    <g:else>
        <meta name="layout" content="${mobile ? 'mobile' : hubConfig.skin}"/>
        <title>View | ${activity.type} | Bio Collect</title>
    </g:else>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumbParent2" content="${createLink(controller: 'project', action: 'index')}/${pActivity.projectId},Project"/>
    <meta name="breadcrumb" content="${pActivity.name}"/>
    <asset:stylesheet src="forms-manifest.css"/>
    <g:if test="${mobile}">
        <asset:stylesheet src="mobile_activity.css"/>
    </g:if>

    %{-- this will ultimately follow through to the comment controller using url mapping --}%
    <g:set var="commentUrl" value="${resource(dir:'/bioActivity')}/${activity.activityId}/comment"></g:set>

    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <asset:script type="text/javascript">
    var fcConfig = {
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
        activityDeleteUrl: "${createLink(controller: 'activity', action: 'ajaxDelete')}",
        projectViewUrl: "${createLink(controller: 'project', action: 'index')}/",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}/",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        imageLocation:"${asset.assetPath(src:'')}",
        createCommentUrl : "${commentUrl}",
        commentListUrl:"${commentUrl}",
        updateCommentUrl:"${commentUrl}",
        deleteCommentUrl:"${commentUrl}",
        imageLeafletViewer: '${createLink(controller: 'resource', action: 'imageviewer', absolute: true)}',
        projectIndexUrl: "${createLink(controller: 'project', action: 'index')}",
        activityViewUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
        getGuidForOutputSpeciesUrl : "${createLink(controller: 'record', action: 'getGuidForOutputSpeciesIdentifier')}",
        uploadImagesUrl: "${createLink(controller: 'image', action: 'upload')}",
        searchBieUrl: "${createLink(controller: 'search', action: 'searchSpecies', params: [id: pActivity.projectActivityId, limit: 10])}",
        speciesListUrl: "${createLink(controller: 'proxy', action: 'speciesItemsForList')}",
        speciesImageUrl:"${createLink(controller:'species', action:'speciesImage')}",
        ${(params?.version) ? ',version: ' + params?.version : ''}
        },
        here = document.location.href;
    </asset:script>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
    <asset:javascript src="common.js"/>
    <asset:javascript src="forms-manifest.js"/>
</head>

<body>
<div class="container-fluid validationEngineContainer" id="validation-container">

    <div id="koActivityMainBlock">
        <g:if test="${!mobile}">
            <div class="row-fluid">
                %{--page title--}%
                <div class="span4">
                    <h2><g:message code="record.view.title"></g:message></h2>
                </div>
                %{-- quick links --}%
                <div class="span8">
                    <g:render template="/shared/quickLinks" model="${[cssClasses: 'pull-right']}"></g:render>
                </div>
                %{--quick links END--}%
            </div>
        </g:if>

        <g:if test="${params?.version}">
            <div class="well">
                <h4>
                    Version:
                    <span id="versionMsg"></span>
                </h4>
            </div>
        </g:if>

        <g:if test="${metaModel?.supportsSites?.toBoolean()}">
            <h3 class="text-error text-center well-title">Site location: <span data-bind="text: transients.site.name"></span></h3>
            <div data-bind="if: transients.site">
                <div class="output-block well text-center">
                    <m:map id="activitySiteMap" width="90%" height="300px"/>
                </div>
            </div>
        </g:if>

        <g:if test="${metaModel?.supportsPhotoPoints?.toBoolean()}">
            <h3 class="text-center text-error well-title">Photo Points</h3>
            <div class="output-block well" data-bind="with:transients.photoPointModel">
                <g:render template="/site/photoPoints" model="[readOnly: true]"/>
            </div>
        </g:if>

    <!-- ko stopBinding:true -->
        <g:each in="${metaModel?.outputs}" var="outputName">
            <script type="text/javascript" src="${createLink(controller: 'dataModel', action: 'getScript', params: [outputName: outputName])}"></script>
            <g:set var="blockId" value="${fc.toSingleWord([name: outputName])}"/>
            <g:set var="model" value="${outputModels[outputName]}"/>
            <g:set var="output" value="${activity.outputs.find { it.name == outputName }}"/>
            <g:if test="${!output}">
                <g:set var="output" value="[name: outputName]"/>
            </g:if>

            <div class="output-block well" id="ko${blockId}">
                <div data-bind="if:outputNotCompleted">
                    <label class="checkbox" ><input type="checkbox" disabled="disabled" data-bind="checked:outputNotCompleted"> <span data-bind="text:transients.questionText"></span> </label>
                </div>
                <g:if test="${!output.outputNotCompleted}">
                    <!-- add the dynamic components -->
                    <md:modelView model="${model}" site="${site}" readonly="true" userIsProjectMember="${userIsProjectMember}"/>
                </g:if>
                <asset:script type="text/javascript">
                    $(function(){
                        var viewModelName = "${blockId}ViewModel",
                            elementId = "ko${blockId}",
                            outputName = "${outputName}",
                            viewModelInstance = viewModelName + "Instance";

                        var output = $.grep(activity.outputs || [], function(it){return it.name == outputName})[0] || { name: outputName};
                        var config = $.grep(metaModel.outputConfig || [], function(it){return it.outputName == outputName})[0] || {};
                        config.model = outputModels[outputName];
                        config = _.extend({}, outputModelConfig, config);
                        ecodata.forms[viewModelInstance] = new ecodata.forms[viewModelName](output, config.model.dataModel, context, config);
                        ecodata.forms[viewModelInstance].loadData(output.data);
                        ko.applyBindings(ecodata.forms[viewModelInstance], document.getElementById(elementId));
                    });
                </asset:script>
            </div>
        </g:each>
    <!-- /ko -->
    </div>

    <g:if test="${pActivity.commentsAllowed}">
        <g:render template="/comment/comment"></g:render>
    </g:if>

    <g:if test="${!mobile}">
        <div class="form-actions">
            <g:if test="${hasEditRights}">
                <a class="btn btn-primary" href="${createLink(controller: 'bioActivity', action: 'edit')}/${activity.activityId}">Edit</a>
            </g:if>
            <button type="button" id="cancel" class="btn">return</button>
        </div>
    </g:if>
</div>
<!-- templates -->

<asset:script type="text/javascript">
        var activity = JSON.parse('${(activity as JSON).toString().encodeAsJavaScript()}');
        var site = JSON.parse('${(site as JSON).toString().encodeAsJavaScript()}');
        var pActivity = JSON.parse('${(pActivity as JSON).toString().encodeAsJavaScript()}');
        var project = <fc:modelAsJavascript model="${project}" default="null"/>;
        var metaModel = <fc:modelAsJavascript model="${metaModel}" default="null"/>;
        var speciesConfig = <fc:modelAsJavascript model="${speciesConfig}"/>;
        var outputModels = <fc:modelAsJavascript model="${outputModels}"/>;
        var mobile = ${mobile ?: false};
        var activityId = '${activity.activityId}';
        var projectId = '${activity.projectId}';
        var siteId = '${activity.siteId?:""}';

        var outputModelConfig = {
            projectId:projectId,
            activityId:activityId,
            siteId: siteId,
            speciesConfig : speciesConfig
        };

        outputModelConfig = _.extend(fcConfig, outputModelConfig);

        var context = {
            project: fcConfig.project,
            documents: activity.documents
        };

        var returnTo = "${returnTo}";

        function ActivityLevelData() {
            var self = this;
            self.activity = activity;
            self.site = site;
            self.pActivity = pActivity;
        }

        var activityLevelData = new ActivityLevelData();

        $(function() {
            $('.helphover').popover({animation: true, trigger:'hover'});

            $('#cancel').click(function () {
                document.location.href = returnTo;
            });

            function ViewModel (act, site, project, metaModel, pActivity) {
                var self = this;
                self.activityId = act.activityId;
                self.description = ko.observable(act.description);
                self.notes = ko.observable(act.notes);
                self.startDate = ko.observable(act.startDate || act.plannedStartDate).extend({simpleDate: false});
                self.endDate = ko.observable(act.endDate || act.plannedEndDate).extend({simpleDate: false});
                self.eventPurpose = ko.observable(act.eventPurpose);
                self.fieldNotes = ko.observable(act.fieldNotes);
                self.associatedProgram = ko.observable(act.associatedProgram);
                self.associatedSubProgram = ko.observable(act.associatedSubProgram);
                self.projectStage = ko.observable(act.projectStage || "");
                self.type = ko.observable(act.type);
                self.siteId = ko.observable(act.siteId);
                self.site = site;
                self.projectId = act.projectId;
                self.transients = {};
                self.transients.pActivity = new pActivityInfo(pActivity);
                self.transients.pActivitySites = pActivity.sites;
                self.transients.site = site;
                self.transients.project = project;
                self.transients.metaModel = metaModel || {};
                self.goToProject = function () {
                    if (self.projectId) {
                        document.location.href = fcConfig.projectViewUrl + self.projectId;
                    }
                };
                self.goToSite = function () {
                    if (self.siteId()) {
                        document.location.href = fcConfig.siteViewUrl + self.siteId();
                    }
                };
                self.notImplemented = function () {
                    alert("Not implemented yet.")
                };

                if (metaModel && metaModel.supportsPhotoPoints) {
                    self.transients.photoPointModel = ko.observable(new PhotoPointViewModel(site, act));
                }
            }

            var viewModel = new ViewModel(
                activity,
                site,
                project,
                metaModel,
                pActivity
                );

            ko.applyBindings(viewModel,document.getElementById('koActivityMainBlock'));
            <g:if test="${pActivity.commentsAllowed}">
                ko.applyBindings(new CommentListViewModel(),document.getElementById('commentOutput'));
            </g:if>
            <g:if test="${metaModel?.supportsSites?.toBoolean()}">
                var mapFeatures = $.parseJSON('${mapFeatures?.encodeAsJavaScript()}');

                if (mapFeatures && mapFeatures.features) {
                    var mapOptions = {
                        drawControl: false,
                        showReset: false,
                        draggableMarkers: false,
                        useMyLocation: false,
                        allowSearchLocationByAddress: false,
                        allowSearchRegionByAddress: false,
                        wmsFeatureUrl: "${createLink(controller: 'proxy', action: 'feature')}?featureId=",
                        wmsLayerUrl: "${grailsApplication.config.spatial.geoserverUrl}/wms/reflect?"
                    }

                    viewModel.siteMap = new ALA.Map("activitySiteMap", mapOptions);

                    if (mapFeatures.features[0].pid) {
                        viewModel.siteMap.addWmsLayer(mapFeatures.features[0].pid);
                    } else {
                        var geometry = _.pick(mapFeatures.features[0], "type", "coordinates");
                        var geoJson = ALA.MapUtils.wrapGeometryInGeoJSONFeatureCol(geometry);
                        viewModel.siteMap.setGeoJSON(geoJson);
                    }
                }
            </g:if>
    });

    var versionMsg = $('#versionMsg')
    if (versionMsg.length > 0) versionMsg[0].innerHTML = moment(fcConfig.version, 'x').format('YYYY-MM-DD HH:mm:ss')
</asset:script>
</body>
</html>