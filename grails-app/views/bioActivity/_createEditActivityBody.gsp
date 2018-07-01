<%@ page import="grails.converters.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<g:set var="showCreate" value="${activity.activityId ||  (!activity.activityId && !hubConfig.content?.hideCancelButtonOnForm)}"></g:set>
<div class="container-fluid validationEngineContainer" id="validation-container">
    <div id="koActivityMainBlock">
        <g:if test="${!mobile}">
            <div class="row-fluid">
                %{--page title--}%
                <div class="span4">
                    <h2>${title}</h2>
                </div>
                %{-- quick links --}%
                <div class="span8">
                    <g:render template="/shared/quickLinks" model="${[cssClasses: 'pull-right']}"></g:render>
                </div>
                %{--quick links END--}%
            </div>
        </g:if>
<!-- ko stopBinding: true -->
<g:set var="user" value="${user}"/>
<g:each in="${metaModel?.outputs}" var="outputName">
    <g:if test="${outputName != 'Photo Points'}">
        <script type="text/javascript" src="${createLink(controller: 'dataModel', action: 'getScript', params: [outputName: outputName])}"></script>
        <g:set var="blockId" value="${fc.toSingleWord([name: outputName])}"/>
        <g:set var="model" value="${outputModels[outputName]}"/>
        <g:set var="output" value="${activity.outputs.find { it.name == outputName }}"/>

        <g:if test="${!output}">
            <g:set var="output" value="[name: outputName]"/>
        </g:if>

        <md:modelStyles model="${model}" edit="true"/>

        <div class="output-block" id="ko${blockId}">

            <div data-bind="if:transients.optional || outputNotCompleted()">
                <label class="checkbox" ><input type="checkbox" data-bind="checked:outputNotCompleted"> <span data-bind="text:transients.questionText"></span> </label>
            </div>

            <div id="${blockId}-content" class="well" data-bind="visible:!outputNotCompleted()">
                <!-- add the dynamic components -->
                <md:modelView model="${model}" site="${site}" edit="true" output="${output.name}" printable="${printView}"/>
            </div>
        </div>
    </g:if>
</g:each>
<!-- /ko -->


<g:if test="${metaModel.supportsSites?.toBoolean()}">
    <div >
        <h3 class="text-center text-error well-title">Site Details</h3>
        <div class="output-block text-center well">
            <fc:select
                    data-bind='options:transients.pActivitySites,optionsText:"name",optionsValue:"siteId",value:siteId,optionsCaption:"Choose a site..."'
                    printable="${printView}"/>
            <m:map id="activitySiteMap" width="90%" height="512px"/>
        </div>

    </div>
</g:if>

<g:if test="${metaModel.supportsPhotoPoints?.toBoolean()}">
    <h3 class="text-center text-error well-title">Photo Points</h3>
    <div class="output-block well" data-bind="with:transients.photoPointModel">
        <g:render template="/site/photoPoints"></g:render>
    </div>
</g:if>

<g:if test="${!printView}">
    <div class="form-actions">
        <g:if test="${!preview}">
            <button type="button" id="save" class="btn btn-primary">Submit</button>
        </g:if>
        <g:if test="${showCreate && !mobile}">
            <g:if test="${!preview}">
                <button type="button" id="cancel" class="btn">Cancel</button>
            </g:if>
        </g:if>
    </div>
</g:if>

<g:if env="development" test="${!printView && !preview}">
    <div class="expandable-debug">
        <hr/>

        <h3>Debug</h3>

        <div>
            <h4>KO model</h4>
            <pre data-bind="text:ko.toJSON($root.modelForSaving(),null,2)"></pre>
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
            <pre>${(outputModels as JSON)?.encodeAsHTML()}</pre>
            <h4>Map features</h4>
            <pre>${mapFeatures.toString()}</pre>
        </div>
    </div>
</g:if>

</div>

<div id="timeoutMessage" class="hide">

    <span class='label label-important'>Important</span><h4>There was an error while trying to save your changes.</h4>

    <p>This could be because your login has timed out or the internet is unavailable.</p>

    <p>Your data has been saved on this computer but you may need to login again before the data can be sent to the server.</p>
    <a href="${createLink(action: 'create', id: activity.activityId)}?returnTo=${returnTo}">Click here to refresh your login and reload this page.</a>
</div>


<g:render template="/shared/imagerViewerModal" model="[readOnly: false]"/>
<g:render template="/shared/attachDocument"/>
<g:render template="/shared/documentTemplate"/>

<asset:script type="text/javascript">
    var activity = JSON.parse('${(activity as JSON).toString().encodeAsJavaScript()}');
    var site = JSON.parse('${(site as JSON).toString().encodeAsJavaScript()}');
    var pActivity = JSON.parse('${(pActivity as JSON).toString().encodeAsJavaScript()}');
    var projectSite = JSON.parse('${(projectSite as JSON).toString().encodeAsJavaScript()}');
    var project = <fc:modelAsJavascript model="${project}" default="null"/>;
    var metaModel = <fc:modelAsJavascript model="${metaModel}" default="null"/>;
    var speciesConfig = <fc:modelAsJavascript model="${speciesConfig}"/>;
    var outputModels = <fc:modelAsJavascript model="${outputModels}"/>;
    var mobile = ${mobile ?: false};

    var master = new Master(fcConfig.activityId, fcConfig);
    function ActivityLevelData() {
        var self = this;
        self.activity = activity;
        self.site = site;
        self.pActivity = pActivity;
        self.projectSite = projectSite;
        self.metaModel = metaModel;
        self.project = project;
        self.mobile = mobile;
    }

    var activityLevelData = new ActivityLevelData();

    $(function() {

        $('#validation-container').validationEngine('attach', {scroll: true});

        $('.helphover').popover({animation: true, trigger:'hover'});

        $('#save').click(function () {
            master.save();
            master.removeTemporarySite();
        });

        $('#cancel').click(function () {
            document.location.href = fcConfig.returnTo;
        });

        $('#reset').click(function () {
            master.reset();
        });

        viewModel = new ActivityHeaderViewModel(
            activityLevelData.activity,
            activityLevelData.site,
            activityLevelData.project,
            activityLevelData.metaModel,
            activityLevelData.pActivity,
            fcConfig);

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

        if(metaModel.supportsSites) {
            var mapFeatures = <fc:modelAsJavascript model="${mapFeatures}"/>;
            var mapOptions = {
                drawControl: false,
                showReset: true,
                draggableMarkers: false,
                useMyLocation: false,
                allowSearchLocationByAddress: false,
                allowSearchRegionByAddress: false,
                wmsFeatureUrl: "${createLink(controller: 'proxy', action: 'feature')}?featureId=",
                wmsLayerUrl: "${grailsApplication.config.spatial.geoserverUrl}/wms/reflect?"
            };

            activityLevelData.siteMap = new ALA.Map("activitySiteMap", mapOptions);

            if (mapFeatures && mapFeatures.features && mapFeatures.features.length > 0) {
                if (mapFeatures.features[0].pid) {
                    activityLevelData.siteMap.addWmsLayer(mapFeatures.features[0].pid);
                } else {
                    var geometry = _.pick(mapFeatures.features[0], "type", "coordinates");
                    var geoJson = ALA.MapUtils.wrapGeometryInGeoJSONFeatureCol(geometry);
                    activityLevelData.siteMap.setGeoJSON(geoJson);
                }
            } else if (activityLevelData.pActivity.sites.length == 1) {
                viewModel.siteId(activityLevelData.pActivity.sites[0].siteId);
            } else if (activityLevelData.projectSite && activityLevelData.projectSite.extent) {
                activityLevelData.siteMap.fitToBoundsOf(Biocollect.MapUtilities.featureToValidGeoJson(activityLevelData.projectSite.extent.geometry));
            }
        }

        ko.applyBindings(viewModel);
        viewModel.dirtyFlag.reset();
        master.register('activityModel', viewModel.modelForSaving, viewModel.dirtyFlag.isDirty, viewModel.dirtyFlag.reset);

<g:each in="${metaModel?.outputs}" var="outputName">
    <g:if test="${outputName != 'Photo Points'}">
        <g:set var="blockId" value="${fc.toSingleWord([name: outputName])}"/>
        var viewModelName = "${blockId}ViewModel",
            elementId = "ko${blockId}",
            outputName = "${outputName}";

        var output = $.grep(activity.outputs || [], function(it){return it.name == outputName})[0] || {};
        var config = $.grep(metaModel.outputConfig || [], function(it){return it.outputName == outputName})[0] || {};
        config.model = outputModels[outputName];
        config = _.extend({}, outputModelConfig, config);
        initialiseOutputViewModel(viewModelName, config.model.dataModel, elementId, activity, output, master, config);

        setTimeout(function(){
            // Forcing map refresh because of tricky race condition that resets the map
            // to the project area. This refresh needs to happen after everything else has run.
            ecodata.forms["${blockId}ViewModelInstance"].reloadGeodata();
        }, 0);
    </g:if>
</g:each>
});
</asset:script>
</div>
