<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
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

        $('#save').on('click',function () {
            master.save();
            master.removeTemporarySite();
        });

        $('#cancel').on('click',function () {
            if (fcConfig.bulkUpload)
                $(document).trigger('activitycreatecancelled')
            else
                document.location.href = fcConfig.returnTo;
        });

        $('#reset').on('click',function () {
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
        master.setViewModel(viewModel);

        outputModelConfig = _.extend(fcConfig, outputModelConfig);

        if(metaModel.supportsSites) {
            var mapFeatures = $.parseJSON('${mapFeatures?.encodeAsJavaScript()}');
            var overlayLayersMapControlConfig = Biocollect.MapUtilities.getOverlayConfig();
            var baseLayersAndOverlays = Biocollect.MapUtilities.getBaseLayerAndOverlayFromMapConfiguration(fcConfig.mapLayersConfig);
            var mapOptions = {
                drawControl: false,
                showReset: true,
                draggableMarkers: false,
                useMyLocation: false,
                allowSearchLocationByAddress: false,
                allowSearchRegionByAddress: false,
                addLayersControlHeading: true,
                autoZIndex: false,
                preserveZIndex: true,
                baseLayer: baseLayersAndOverlays.baseLayer,
                otherLayers: baseLayersAndOverlays.otherLayers,
                overlays: baseLayersAndOverlays.overlays,
                overlayLayersSelectedByDefault: baseLayersAndOverlays.overlayLayersSelectedByDefault,
                wmsFeatureUrl: overlayLayersMapControlConfig.wmsFeatureUrl,
                wmsLayerUrl: overlayLayersMapControlConfig.wmsLayerUrl
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

        var output = $.grep(activity.outputs || [], function(it){return it.name == outputName})[0] || { name: outputName};
        var config = $.grep(metaModel.outputConfig || [], function(it){return it.outputName == outputName})[0] || {};
        config.model = outputModels[outputName];
        config = _.extend(activityLevelData, outputModelConfig, config);
        initialiseOutputViewModel(viewModelName, config.model.dataModel, elementId, activity, output, master, config, viewModel);

        setTimeout(function(){
            // Forcing map refresh because of tricky race condition that resets the map
            // to the project area. This refresh needs to happen after everything else has run.
            ecodata.forms["${blockId}ViewModelInstance"].reloadGeodata();
        }, 0);
        </g:if>
    </g:each>

    master.listenForResolution()
});
</asset:script>