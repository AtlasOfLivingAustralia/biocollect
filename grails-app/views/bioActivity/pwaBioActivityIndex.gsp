<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="pwa"/>
    <title>View | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/'+ hubConfig.urlPath)},Home"/>
    <meta name="breadcrumbParent2" content="${createLink(controller: 'project', action: 'index')}/${pActivity.projectId},Project"/>
    <meta name="breadcrumb" content="${pActivity.name}"/>
    <asset:stylesheet src="pwa-bio-activity-index-manifest.css"/>
    <asset:script type="text/javascript">
    var fcConfig = {
        <g:applyCodec encodeAs="none">
        projectId: "${projectId}",
        projectActivityId: "${projectActivityId}",
        type: "${type}",
        isPWA: true,
        siteUrl: "/ws/site",
        activityURL: "/ws/activity",
        projectActivityURL: "/ws/projectActivity",
        activityViewURL: "/pwa/bioActivity/index",
        metadataURL: "/ws/projectActivity/activity",
        htmlFragmentURL: "/pwa/indexFragment/${projectActivityId}",
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
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        bieWsUrl: "${grailsApplication.config.bieWs.baseURL}",
        imageLocation:"${asset.assetPath(src:'')}",
        imageLeafletViewer: '${createLink(controller: 'resource', action: 'imageviewer', absolute: true)}',
        projectIndexUrl: "${createLink(controller: 'project', action: 'index')}",
        activityViewUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
        getGuidForOutputSpeciesUrl : "${createLink(controller: 'record', action: 'getGuidForOutputSpeciesIdentifier')}",
        uploadImagesUrl: "${createLink(controller: 'image', action: 'upload')}",
        searchBieUrl: "${raw(createLink(controller: 'search', action: 'searchSpecies', params: [projectActivityId: pActivity.projectActivityId, limit: 10]))}",
        speciesListUrl: "${createLink(controller: 'proxy', action: 'speciesItemsForList')}",
        speciesProfileUrl: "${createLink(controller: 'proxy', action: 'speciesProfile')}",
        noImageUrl: '${asset.assetPath(src: "font-awesome/5.15.4/svgs/regular/image.svg")}',
        speciesImageUrl:"${createLink(controller:'species', action:'speciesImage')}",
        mapLayersConfig: ${ grailsApplication.config.getProperty('pwa.mapConfig', Map) as JSON },
        excelOutputTemplateUrl: "${createLink(controller: 'proxy', action:'excelOutputTemplate')}",
        pwaAppUrl: "${grailsApplication.config.getProperty('pwa.appUrl')}",
        bulkUpload: false,
        isPWA: true,
        isCaching: ${params.getBoolean('cache', false)},
        returnTo: '${createLink(uri: "/pwa/offlineList", params:  [projectActivityId: projectActivityId])}'
        ${(params?.version) ? ',version: ' + params?.version : ''}
        </g:applyCodec>
        },
        here = document.location.href;
    </asset:script>
    <asset:javascript src="pwa-bio-activity-index-manifest.js"/>
</head>

<body>
    <div class="container">
        <h1><g:message code="pwa.view.record"/></h1>
        <bc:koLoading>
            <div id="form-placeholder"></div>
        </bc:koLoading>
        <a class="btn btn-primary" href="${createLink(controller: 'bioActivity', action: 'pwaOfflineList', params: [projectActivityId: projectActivityId])}"><i class="far fa-arrow-alt-circle-left"></i> <g:message code="pwa.btn.back"/> </a>
    </div>
    <script type="text/javascript">
        var urlObject = new URL(window.location.href)
        var activityId = getActivityId();

        function getMetadataAndInitialise () {
            var projectActivityMetadataPromise = entities.getProjectActivityMetadata(fcConfig.projectActivityId, activityId);
            projectActivityMetadataPromise.then(function (metadataResult) {
                var metadata = metadataResult.data;
                initialise(metadata)
            }, function () {
                alert("${g.message(code: 'project.activity.metadata.error', default:'Error loading survey metadata')}");
            });
        }

        function getActivityId() {
            var url = new URL(window.location.href);
            return url.searchParams.get("activityId");
        }

        function initialise(metadata) {
            var activity = metadata.activity || null;
            var pActivity = metadata.pActivity || null;
            var projectSite = metadata.projectSite || null;
            var site = metadata.site || null;
            var project = metadata.project || null;
            metaModel = metadata.metaModel || null;
            var speciesConfig = metadata.speciesConfig;
            outputModels = metadata.outputModels;
            var mapFeatures = metadata.mapFeatures;
            var mobile = true;
            var activityId = activity.activityId;
            var projectId = activity.projectId;
            var siteId = activity.siteId;
            outputModelConfig = {
                projectId: projectId,
                activityId: activityId,
                siteId: siteId,
                speciesConfig: speciesConfig
            };

            outputModelConfig = _.extend(fcConfig, outputModelConfig);
            context = {
                project: fcConfig.project,
                documents: activity.documents,
                pActivity: pActivity
            };

            var returnTo = fcConfig.returnTo;

            function ActivityLevelData() {
                var self = this;
                self.activity = activity;
                self.site = site;
                self.pActivity = pActivity;
            }

            window.activityLevelData = new ActivityLevelData();

            $(function () {
                $('.helphover').popover({animation: true, trigger: 'hover'});

                $('#cancel').on('click', function () {
                    document.location.href = returnTo;
                });

                function ViewModel(act, site, project, metaModel, pActivity) {
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

                ko.applyBindings(viewModel);
                if (metaModel.supportsSites) {
                    if (mapFeatures && mapFeatures.features) {
                        var overlayLayersMapControlConfig = Biocollect.MapUtilities.getOverlayConfig();
                        var baseLayersAndOverlays = Biocollect.MapUtilities.getBaseLayerAndOverlayFromMapConfiguration(fcConfig.mapLayersConfig);
                        var mapOptions = {
                            autoZIndex: false,
                            preserveZIndex: true,
                            drawControl: false,
                            showReset: false,
                            draggableMarkers: false,
                            useMyLocation: false,
                            allowSearchLocationByAddress: false,
                            allowSearchRegionByAddress: false,
                            addLayersControlHeading: true,
                            baseLayer: baseLayersAndOverlays.baseLayer,
                            otherLayers: baseLayersAndOverlays.otherLayers,
                            overlays: baseLayersAndOverlays.overlays,
                            overlayLayersSelectedByDefault: baseLayersAndOverlays.overlayLayersSelectedByDefault,
                            wmsFeatureUrl: overlayLayersMapControlConfig.wmsFeatureUrl,
                            wmsLayerUrl: overlayLayersMapControlConfig.wmsLayerUrl
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
                }

                for (var index in metaModel.outputs) {
                    var outputName = metaModel.outputs[index];
                    var blockId = outputName.replaceAll(' ', '_');
                    var viewModelName = blockId + "ViewModel",
                        elementId = "ko" + blockId,
                        viewModelInstance = viewModelName + "Instance";

                    var output = $.grep(activity.outputs || [], function (it) {
                        return it.name == outputName
                    })[0] || {name: outputName};
                    var config = $.grep(metaModel.outputConfig || [], function (it) {
                        return it.outputName == outputName
                    })[0] || {};
                    config.model = outputModels[outputName];
                    config = _.extend({}, outputModelConfig, config);
                    ecodata.forms[viewModelInstance] = new ecodata.forms[viewModelName](output, config.model.dataModel, context, config);
                    ecodata.forms[viewModelInstance].initialise(output.data);
                    ko.applyBindings(ecodata.forms[viewModelInstance], document.getElementById(elementId));
                }
            });
        }

        window.addEventListener("load", function () {
            if(fcConfig.bulkUpload) {
                window.parent && window.parent.postMessage({eventName: 'viewmodelloadded', event: 'viewmodelloadded', data: {}}, fcConfig.originUrl);
            }
            else if (fcConfig.isPWA) {
                window.parent.postMessage({eventName: 'viewmodelloadded', event:'viewmodelloadded', data: {}}, fcConfig.pwaAppUrl);
            }
        });
    </script>
</body>
</html>
