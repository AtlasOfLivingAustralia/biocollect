<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<asset:script type="text/javascript">
    function getMetadataAndInitialise() {
        var activityId = getActivityId();
        var projectActivityMetadataPromise = entities.getProjectActivityMetadata(fcConfig.projectActivityId,  activityId);
        projectActivityMetadataPromise.then(function (metadataResult){
            var metadata = metadataResult.data;
            initialise(metadata)
        }, function (){
            alert("${g.message(code: 'project.activity.metadata.error', default:'Error loading survey metadata')}");
        });

        function getActivityId() {
            var url = new URL(window.location.href);
            return url.searchParams.get("activityId");
        }

        function initialise(metadata) {
            var activity = metadata.activity || null;
            var pActivity = metadata.pActivity || null;
            var projectSite = metadata.projectSite || null;
            var project = metadata.project || null;
            var site = metadata.site || null;
            var metaModel = metadata.metaModel || null;
            var speciesConfig = metadata.speciesConfig;
            var outputModels = metadata.outputModels;
            var mapFeatures = metadata.mapFeatures;
            var mobile = true;

            var master = new Master(activityId, fcConfig);
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

            window.activityLevelData = new ActivityLevelData();

            $(function() {
                if (window.viewModel)
                    return;

                $('#validation-container').validationEngine('attach', {scroll: true});

                $('.helphover').popover({animation: true, trigger:'hover'});

                $('#save').on('click',function () {
                    master.save();
                    master.removeTemporarySite();
                });

                $('#saveOffline').on('click',function () {
                    master.offlineSave();
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

                var projectId = fcConfig.projectId;
                var siteId = activity.siteId;
                var outputModelConfig = {
                    projectId:projectId,
                    activityId:activityId,
                    siteId: siteId,
                    speciesConfig : speciesConfig
                };
                master.setViewModel(viewModel);

                outputModelConfig = _.extend(fcConfig, outputModelConfig);

                if(metaModel.supportsSites) {
                    var mapFeatures = mapFeatures;
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
                for(var index in metaModel.outputs) {
                    var outputName = metaModel.outputs[index];
                    if (outputName != 'Photo Points') {
                        var blockId = outputName.replaceAll(' ', '_');
                        var viewModelName = blockId + 'ViewModel';
                        var elementId = 'ko' + blockId;
                        var output = $.grep(activity.outputs || [], function(it){return it.name == outputName})[0] || { name: outputName};
                        var config = $.grep(metaModel.outputConfig || [], function(it){return it.outputName == outputName})[0] || {};
                        config.model = outputModels[outputName];
                        config = _.extend(activityLevelData, outputModelConfig, config);
                        initialiseOutputViewModel(viewModelName, config.model.dataModel, elementId, activity, output, master, config, viewModel);

                        setTimeout(function(){
                            // Forcing map refresh because of tricky race condition that resets the map
                            // to the project area. This refresh needs to happen after everything else has run.
                            ecodata.forms[blockId + "ViewModelInstance"].reloadGeodata();
                        }, 0);
                    }
                }

                master.listenForResolution()
            });
        };
    };
</asset:script>