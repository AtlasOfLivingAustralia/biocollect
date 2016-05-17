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
%{-- this will ultimately follow through to the comment controller using url mapping --}%
    <g:set var="commentUrl" value="${resource(dir:'/bioActivity')}/${activity.activityId}/comment"></g:set>

    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <r:script disposition="head">
    var fcConfig = {
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
        activityDeleteUrl: "${createLink(controller: 'activity', action: 'ajaxDelete')}",
        projectViewUrl: "${createLink(controller: 'project', action: 'index')}/",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}/",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        imageLocation:"${resource(dir:'/images')}",
        createCommentUrl : "${commentUrl}",
        commentListUrl:"${commentUrl}",
        updateCommentUrl:"${commentUrl}",
        deleteCommentUrl:"${commentUrl}",
        imageLeafletViewer: '${createLink(controller: 'resource', action: 'imageviewer', absolute: true)}',
        projectIndexUrl: "${createLink(controller: 'project', action: 'index')}",
        activityViewUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
        version: ${params?.version}
        },
        here = document.location.href;
    </r:script>
    <r:require modules="knockout,jqueryValidationEngine,datepicker,timepicker,jQueryFileUploadUI,species,activity, projectActivityInfo, imageViewer, comments, map, responsiveTableStacked"/>
</head>

<body>
<div class="container-fluid validationEngineContainer" id="validation-container">

    <div id="koActivityMainBlock">

        <g:if test="${!printView && !mobile}">
            <ul class="breadcrumb">
                <li><g:link controller="home">Home</g:link> <span class="divider">/</span></li>
                <li><a href="#" data-bind="click:goToProject" class="clickable">Project</a> <span class="divider">/</span></li>
                <li class="active">
                    <span data-bind="text:type"></span>
                </li>
            </ul>
        </g:if>

        <g:render template="header"/>

        <g:if test="${params?.version}">
            <div class="well">
                <h4>
                    Version:
                    <span id="versionMsg"></span>
                </h4>
            </div>
        </g:if>

        <g:if test="${metaModel?.supportsSites?.toBoolean()}">
            <div class="row-fluid" data-bind="if: transients.site">
                <div class="span12 well">
                    <h3>Site location: <span data-bind="text: transients.site.name"></span></h3>

                    <m:map id="activitySiteMap" width="100%" height="300px"/>
                </div>
            </div>
        </g:if>

        <g:if test="${metaModel?.supportsPhotoPoints?.toBoolean()}">
            <div class="output-block well" data-bind="with:transients.photoPointModel">
                <h3>Photo Points</h3>
                <g:render template="/site/photoPoints" model="[readOnly: true]"/>
            </div>
        </g:if>

    <!-- ko stopBinding:true -->
        <g:each in="${metaModel?.outputs}" var="outputName">
            <g:set var="blockId" value="${fc.toSingleWord([name: outputName])}"/>
            <g:set var="model" value="${outputModels[outputName]}"/>
            <g:set var="output" value="${activity.outputs.find { it.name == outputName }}"/>
            <g:if test="${!output}">
                <g:set var="output" value="[name: outputName]"/>
            </g:if>

            <div class="output-block well" id="ko${blockId}">
                <h3>${outputName}</h3>
                <div data-bind="if:outputNotCompleted">
                    <label class="checkbox" ><input type="checkbox" disabled="disabled" data-bind="checked:outputNotCompleted"> <span data-bind="text:transients.questionText"></span> </label>
                </div>
                <g:if test="${!output.outputNotCompleted}">
                    <!-- add the dynamic components -->
                    <md:modelView model="${model}" site="${site}" readonly="true"/>
                </g:if>
                <r:script>
                    $(function(){
                        var viewModelName = "${blockId}ViewModel";
                        var viewModelInstance = viewModelName + "Instance";

                        // load dynamic models - usually objects in a list
                    <md:jsModelObjects model="${model}" site="${site}" speciesLists="${speciesLists}"
                                       viewModelInstance="${blockId}ViewModelInstance"/>

                    this[viewModelName] = function (site, config, outputNotCompleted) {
                        var self = this;
                        self.name = "${output.name}";
                            self.outputId = "${output.outputId}";
                            self.data = {};
                            self.transients = {};
                            self.transients.selectedSite = ko.observable(site);
                            var notCompleted = outputNotCompleted;
                            if (notCompleted === undefined) {
                                notCompleted = config.collapsedByDefault;
                            }
                            self.outputNotCompleted = ko.observable(notCompleted);
                            self.transients.optional = config.optional || false;
                            self.transients.questionText = config.optionalQuestionText || 'No '+self.name+' was completed during this activity';
                            self.transients.dummy = ko.observable();

                            // add declarations for dynamic data
                    <md:jsViewModel model="${model}" output="${output.name}"
                                    viewModelInstance="${blockId}ViewModelInstance" readonly="true"/>

                    // this will be called when generating a savable model to remove transient properties
                    self.removeBeforeSave = function (jsData) {
                        // add code to remove any transients added by the dynamic tags
                    <md:jsRemoveBeforeSave model="${model}"/>
                    delete jsData.activityType;
                    delete jsData.transients;
                    return jsData;
                };

                self.loadData = function (data) {
                        // load dynamic data
                    <md:jsLoadModel model="${model}" readonly="true"/>

                    // if there is no data in tables then add an empty row for the user to add data
                    if (typeof self.addRow === 'function' && self.rowCount() === 0) {
                        self.addRow();
                    }
                    self.transients.dummy.notifySubscribers();
                };
            };

            var config = ${fc.modelAsJavascript(model:metaModel.outputConfig?.find{it.outputName == outputName}, default:'{}')};
            var outputNotCompleted = ${output.outputNotCompleted?:'undefined'};

            window[viewModelInstance] = new this[viewModelName](site, config, outputNotCompleted);
            window[viewModelInstance].loadData(${output.data ?: '{}'});

                        ko.applyBindings(window[viewModelInstance], document.getElementById("ko${blockId}"));
                    });
                </r:script>
            </div>
        </g:each>
    <!-- /ko -->
    </div>

    <g:if test="${pActivity.commentsAllowed}">
        <g:render template="/comment/comment"></g:render>
    </g:if>

    <g:if test="${!mobile}">
        <div class="form-actions">
            <button type="button" id="cancel" class="btn">return</button>
        </div>
    </g:if>
</div>
<!-- templates -->

<r:script>
        var returnTo = "${returnTo}";

        function ActivityLevelData() {
            var self = this;
            self.activity = JSON.parse('${(activity as JSON).toString().encodeAsJavaScript()}');
            self.site = JSON.parse('${(site as JSON).toString().encodeAsJavaScript()}');
            self.pActivity = JSON.parse('${(pActivity as JSON).toString().encodeAsJavaScript()}');
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
    ${(activity as JSON).toString()},
    ${site ?: 'null'},
    ${project ?: 'null'},
    ${metaModel ?: 'null'},
    ${pActivity ?: 'null'});

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
</r:script>
</body>
</html>