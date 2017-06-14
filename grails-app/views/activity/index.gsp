<%@ page import="grails.converters.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <g:if test="${printView}">
        <meta name="layout" content="nrmPrint"/>
        <title>Print | ${activity.type} | Field Capture</title>
    </g:if>
    <g:else>
        <meta name="layout" content="${hubConfig.skin}"/>
        <title>Edit | ${activity.type} | Field Capture</title>
    </g:else>
    <g:set var="commentUrl" value="${resource(dir:'/activity')}/${activity.activityId}/comment"></g:set>

    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js"></script>
    <r:script disposition="head">
    var fcConfig = {
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
        activityDeleteUrl: "${createLink(controller: 'activity', action: 'ajaxDelete')}",
        projectViewUrl: "${createLink(controller: 'project', action: 'index')}/",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}/",
        imageLocation:"${resource(dir:'/images')}",
        createCommentUrl : "${commentUrl}",
        commentListUrl:"${commentUrl}",
        updateCommentUrl:"${commentUrl}",
        deleteCommentUrl:"${commentUrl}",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        getGuidForOutputSpeciesUrl : "${createLink(controller: 'record', action: 'getGuidForOutputSpeciesIdentifier')}"
        },
        here = document.location.href;
    </r:script>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
    <r:require modules="knockout,jqueryValidationEngine,datepicker,timepicker,jQueryFileUploadUI,map,leaflet_google_base,species,activity,comments,viewmodels"/>
</head>
<body>
<div class="container-fluid validationEngineContainer" id="validation-container">
    <div id="koActivityMainBlock">
        <g:if test="${!printView && !hubConfig.content?.hideBreadCrumbs}">
            <ul class="breadcrumb">
                <li><g:link controller="home">Home</g:link> <span class="divider">/</span></li>
                <li><a data-bind="click:goToProject" class="clickable">Project</a> <span class="divider">/</span></li>
                <li class="active">
                    <span data-bind="text:type"></span>
                    <span data-bind="text:startDate.formattedDate"></span><span data-bind="visible:endDate">/</span><span data-bind="text:endDate.formattedDate"></span>
                </li>
            </ul>
        </g:if>

        <g:if test="${editInMerit}">
            <div class="alert alert-error">
                <strong>Note:</strong> This activity can only be edited in the <a href="${g.createLink(action:'edit',  id:activity.activityId, base:grailsApplication.config.merit.url)}" target="_merit">MERIT system</a>
            </div>
        </g:if>


        <div class="row-fluid title-block well well-small input-block-level">
            <div class="span12 title-attribute">
                <h1><span data-bind="click:goToProject" class="clickable">${project?.name?.encodeAsHTML() ?: 'no project defined!!'}</span></h1>
                <g:if test="${site}">
                    <h2><span data-bind="click:goToSite" class="clickable">Site: ${site.name?.encodeAsHTML()}</span></h2>
                </g:if>
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
            <g:if test="${mapFeatures.toString() != '{}'}">
                <div class="span3">
                    <div id="smallMap" style="width:100%"></div>
                </div>
            </g:if>
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

    <g:each in="${metaModel?.outputs}" var="outputName">
        <g:set var="blockId" value="${fc.toSingleWord([name: outputName])}"/>
        <g:set var="model" value="${outputModels[outputName]}"/>
        <g:set var="output" value="${activity.outputs.find {it.name == outputName}}"/>
        <g:if test="${!output}">
            <g:set var="output" value="[name: outputName]"/>
        </g:if>
        <div class="output-block" id="ko${blockId}">
            <h3>${outputName}</h3>
            <!-- add the dynamic components -->
            <md:modelView model="${model}" site="${site}"/>
            <r:script>
        $(function(){

            var viewModelName = "${blockId}ViewModel",
                viewModelInstance = viewModelName + "Instance";

            // load dynamic models - usually objects in a list
                <md:jsModelObjects model="${model}" site="${site}" speciesLists="${speciesLists}" viewModelInstance="${blockId}ViewModelInstance"/>

                this[viewModelName] = function (site) {
                    var self = this;
                    self.name = "${output.name}";
                self.outputId = "${output.outputId}";
                self.data = {};
                self.transients = {};
                 self.transients.selectedSite = ko.observable(site);
                self.transients.dummy = ko.observable();

                // add declarations for dynamic data
                <md:jsViewModel model="${model}" output="${output.name}" viewModelInstance="${blockId}ViewModelInstance"/>

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
                <md:jsLoadModel model="${model}"/>

                // if there is no data in tables then add an empty row for the user to add data
                if (typeof self.addRow === 'function' && self.rowCount() === 0) {
                    self.addRow();
                }
                self.transients.dummy.notifySubscribers();
            };
        };

        window[viewModelInstance] = new this[viewModelName](site);
        window[viewModelInstance].loadData(${output.data ?: '{}'});

            ko.applyBindings(window[viewModelInstance], document.getElementById("ko${blockId}"));
        });

            </r:script>
        </div>
    </g:each>

    <g:if test="${projectActivity?.commentsAllowed}">
        <g:render template="/comment/comment"></g:render>
    </g:if>
    <div class="form-actions">
        <button type="button" id="cancel" class="btn">return</button>
    </div>
</div>

<!-- templates -->

<r:script>

    var returnTo = "${returnTo}";

    function ActivityLevelData() {
        var self = this;
        self.activity = JSON.parse('${(activity as JSON).toString().encodeAsJavaScript()}');
        self.site = JSON.parse('${(site as JSON).toString().encodeAsJavaScript()}');
        self.pActivity = {sites: []};
    }

    var activityLevelData = new ActivityLevelData();

    $(function(){

        $('.helphover').popover({animation: true, trigger:'hover'});

        $('#cancel').click(function () {
            document.location.href = returnTo;
        });

        function ViewModel (act, site, project, metaModel) {
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
            self.progress = ko.observable(act.progress || 'started');
            self.mainTheme = ko.observable(act.mainTheme);
            self.type = ko.observable(act.type);
            self.siteId = ko.observable(act.siteId);
            self.projectId = act.projectId;
            self.transients = {};
            self.transients.site = site;
            self.transients.project = project;
            self.transients.metaModel = metaModel || {};
            self.transients.activityProgressValues = ['planned','started','finished'];
            self.transients.themes = $.map(${themes}, function (obj, i) { return obj.name });
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
        }


        var viewModel = new ViewModel(
            ${(activity as JSON).toString()},
            ${site ?: 'null'},
            ${project ?: 'null'},
            ${metaModel ?: 'null'});

        ko.applyBindings(viewModel,document.getElementById('koActivityMainBlock'));

        ko.applyBindings(new CommentListViewModel(),document.getElementById('commentOutput'))

        var mapFeatures = $.parseJSON('${mapFeatures?.encodeAsJavaScript()}');
        if(mapFeatures !=null && mapFeatures.features !== undefined && mapFeatures.features.length >0){
           var mapOptions ={
                    mapContainer: "smallMap",
                    zoomToBounds:true,
                    zoomLimit:16,
                    featureService: "${createLink(controller: 'proxy', action:'feature')}",
                    wmsServer: "${grailsApplication.config.spatial.geoserverUrl}"
                };

            viewModel.siteMap = new new ALA.Map("smallMap", {});
        }
    });
</r:script>
</body>
</html>