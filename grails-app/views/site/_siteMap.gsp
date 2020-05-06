<m:map id="${id}"></m:map>
<div class="hide">
    <!-- ko foreach: sites -->
    <div class="margin-left-20" data-bind="attr:{id: 'popup'+siteId()}">
        <div><i class="icon-map-marker"></i> <a
                href="" data-bind="attr:{href: getSiteUrl()}, text: name"></a></div>

        <div data-bind="visible: type"><span><i class="icon-star-empty"></i> Site type:</span> <span data-bind="text: type"></span></div>

        <div data-bind="visible: numberOfPoi() != undefined"><span><i class="icon-star-empty"></i> Number of POI:</span> <span
                data-bind="text: numberOfPoi"></span><br></div>

        <div data-bind="visible: numberOfProjects() != undefined"><i class="icon-star-empty"></i> Number of associated projects: <span
                data-bind="text: numberOfProjects"></span></div>
    </div>
    <!-- /ko -->
</div>
<script>
    function initMap(params, id) {
        var overlayLayersMapControlConfig = Biocollect.MapUtilities.getOverlayConfig();
        var baseLayersAndOverlays = Biocollect.MapUtilities.getBaseLayerAndOverlayFromMapConfiguration(fcConfig.mapLayersConfig);

        var mapOptions = $.extend({
            autoZIndex: false,
            preserveZIndex: true,
            addLayersControlHeading: true,
            allowSearchLocationByAddress: false,
            drawControl: false,
            singleMarker: false,
            singleDraw: false,
            useMyLocation: false,
            allowSearchByAddress: false,
            draggableMarkers: false,
            showReset: false,
            zoomToObject: true,
            markerOrShapeNotBoth: false,
            trackWindowHeight: true,
            baseLayer: baseLayersAndOverlays.baseLayer,
            otherLayers: baseLayersAndOverlays.otherLayers,
            overlays: baseLayersAndOverlays.overlays,
            overlayLayersSelectedByDefault: baseLayersAndOverlays.overlayLayersSelectedByDefault,
            wmsFeatureUrl: overlayLayersMapControlConfig.wmsFeatureUrl,
            wmsLayerUrl: overlayLayersMapControlConfig.wmsLayerUrl
        }, params);

        var map = new ALA.Map('map', mapOptions);

        L.Icon.Default.imagePath = $('#' + id).attr('data-leaflet-img');

        map.addButton("<span class='fa fa-refresh reset-map' title='Reset zoom'></span>", map.fitBounds, "bottomright");

        return map;
    }
</script>