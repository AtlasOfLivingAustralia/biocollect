var Biocollect = Biocollect || {};

Biocollect.MapUtilities = {
    /**
     * Converts a 'feature' object from Ecodata into valid GeoJSON that can be handled by the ALA.Map.
     *
     * @param feature
     * @returns {{type: string, geometry: {}, properties: {}}}
     */
    featureToValidGeoJson: function(feature) {
        var geoJson = {
            type: "Feature",
            geometry: {},
            properties: {}
        };

        if (feature.type.toLowerCase() == 'pid') {
            if (feature.aream2 == 0 || feature.areaKmSq == 0){
                geoJson.geometry.type = ALA.MapConstants.DRAW_TYPE.POINT_TYPE;
                if (feature.coordinates) {
                    geoJson.geometry.coordinates = feature.coordinates;
                }
                else if (feature.centre){
                    geoJson.geometry.coordinates = feature.centre;
                }
            }else{
                geoJson.geometry.type = ALA.MapConstants.DRAW_TYPE.POLYGON_TYPE;
                geoJson.geometry.coordinates = feature.coordinates || [];
            }
            geoJson.properties.pid = feature.pid;
        } else if (feature.type.toLowerCase() == "circle") {
            geoJson.geometry.type = ALA.MapConstants.DRAW_TYPE.POINT_TYPE;
            geoJson.geometry.coordinates = feature.coordinates;
            geoJson.properties.point_type = ALA.MapConstants.DRAW_TYPE.CIRCLE_TYPE;
            geoJson.properties.radius = feature.radius;
        } else if (feature.type.toLowerCase() == "point") {
            geoJson.geometry.type = ALA.MapConstants.DRAW_TYPE.POINT_TYPE;
            geoJson.geometry.coordinates = feature.coordinates;
        } else if (feature.type.toLowerCase() == "polygon") {
            geoJson.geometry.type = ALA.MapConstants.DRAW_TYPE.POLYGON_TYPE;
            geoJson.geometry.coordinates = feature.coordinates;
            geoJson.properties.radius = feature.radius;
        } else if (feature.type.toLowerCase() == "linestring") {
            geoJson.geometry.type = ALA.MapConstants.DRAW_TYPE.LINE_TYPE;
            geoJson.geometry.coordinates = feature.coordinates;
        }

        return geoJson;
    },

    /**
     * Creates an instance of the L.Control.TwoStepSelector control from the ALA Map plugin
     * @param map The map the control will be placed in
     * @param featuresServiceUrl The URL for the WMS features service
     * @param regionListUrl The URL to retrieve the list of available regions
     * @returns {*} L.Control.TwoStepSelector
     */
    createKnownShapeMapControl: function(map, featuresServiceUrl, regionListUrl) {
        var regionOptions = {
            id: "regionSelection",
            title: "Select a known shape",
            firstStepPlaceholder: "Choose a layer...",
            secondStepPlaceholder: "Choose a shape...",
            firstStepItemLookup: function (populateStep1Callback) {
                $.ajax({
                    url: regionListUrl,
                    dataType: 'json'
                }).done(function (data) {
                    var regions = _.sortBy(data.regions, "value");
                    populateStep1Callback(regions);
                });
            },
            secondStepItemLookup: function (selectedLayerKey, populateStep2Callback) {
                $.ajax({
                    url: featuresServiceUrl + '?layerId=' + selectedLayerKey,
                    dataType: 'json'
                }).done(function (data) {
                    var layers = [];
                    data.forEach(function (layer) {
                        layers.push({key: layer.pid, value: layer.name});
                    });

                    layers = _.sortBy(layers, "value");
                    populateStep2Callback(layers);
                });
            },
            selectionAction: function (selectedValue) {
                map.addWmsLayer(selectedValue)
            }
        };

        return new L.Control.TwoStepSelector(regionOptions);
    },

    /**
     * This object is used specifically to create a geospatial index to allow searching by geographic points/regions/bounding boxes.
     * Known regions (e.g. states/territories, etc) are treated as Polygons for the purposes of searching.
     * The structure of the resulting 'geoIndex' object is designed to suit Elastic Search's geo_shape mappings.
     * See https://www.elastic.co/guide/en/elasticsearch/reference/1.7/mapping-geo-shape-type.html for more info.
     */
    constructGeoIndexObject: function(site) {
        var geoIndex = {};

        if (site && site.extent && site.extent && site.extent.geometry) {
            var geometry = site.extent.geometry;

            if (geometry.type == "Point") {
                geoIndex = {
                    type: geometry.type,
                    coordinates: [geometry.decimalLongitude, geometry.decimalLatitude]
                };
            } else if (geometry.type == "Circle") {
                geoIndex = {
                    type: geometry.type,
                    coordinates: geometry.coordinates,
                    radius: geometry.radius
                };
            } else if (geometry.type == "pid" || geometry.type == "Polygon") {
                geoIndex = {
                    type: "Polygon",
                    coordinates: geometry.type == "pid" ? [ALA.MapUtils.bboxToPointArray(geometry.bbox, true)] : geometry.coordinates
                };
            }
        }

        return geoIndex;
    },

    /**
     * Translate base layer configuration to a format understood by ALA map plugin.
     */
    getALAMapBaseLayerOptions: function (baseLayers) {
        var options = {baseLayer: undefined, otherLayers: {}};
        baseLayers = baseLayers || [];
        baseLayers.forEach(function (baseLayer) {
            var baseConfig = Biocollect.MapUtilities.getBaseLayer(baseLayer.code);
            var title = baseConfig.title || baseLayer.displayText;
            if (baseLayer.isSelected) {
                options.baseLayer = baseConfig;
            }

            options.otherLayers[title] = baseConfig;
        });

        // randomly pick a default base layer if none selected
        if (!options.baseLayer) {
            for(var name in options.otherLayers) {
                options.baseLayer = options.otherLayers[name];
                break;
            }
        }

        return options;
    },

    /**
     * Get {L.tileLayer | L.Google} base map for a given code.
     * @param code
     * @returns {L.tileLayer | L.Google}
     */
    getBaseLayer: function (code) {
        var option, layer;
        switch (code) {
            case 'minimal':
                option = {
                    // See https://cartodb.com/location-data-services/basemaps/
                    url: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                    options: {
                        uniqueName: 'minimal',
                        subdomains: "abcd",
                        attribution: 'Map data &copy; <a target="_blank" rel="noopener noreferrer" href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, imagery &copy; <a target="_blank" rel="noopener noreferrer" href="http://cartodb.com/attributions">CartoDB</a>',
                        maxZoom: 21,
                        maxNativeZoom: 21
                    }
                };
                layer = L.tileLayer(option.url, option.options);
                break;
            case 'worldimagery':
                option = {
                    // see https://www.arcgis.com/home/item.html?id=10df2279f9684e4a9f6a7f08febac2a9
                    url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                    options: {
                        uniqueName: 'worldimagery',
                        attribution: '<a target="_blank" rel="noopener noreferrer" href="https://www.arcgis.com/home/item.html?id=10df2279f9684e4a9f6a7f08febac2a9">Tiles from Esri</a> &mdash; Sources: Esri, DigitalGlobe, Earthstar Geographics, CNES/Airbus DS, GeoEye, USDA FSA, USGS, Aerogrid, IGN, IGP, and the GIS User Community',
                        maxZoom: 21,
                        maxNativeZoom: 17
                    }
                };
                layer = L.tileLayer(option.url, option.options);
                break;
            case 'detailed':
                option = {
                    // see https://wiki.openstreetmap.org/wiki/Standard_tile_layer
                    url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    options: {
                        uniqueName: 'detailed',
                        subdomains: "abc",
                        attribution: '&copy; <a target="_blank" rel="noopener noreferrer" href="https://www.openstreetmap.org/copyright">OpenStreetMap contributors</a>',
                        maxZoom: 21,
                        maxNativeZoom: 18
                    }
                };
                layer = L.tileLayer(option.url, option.options);
                break;
            case 'topographic':
                option = {
                    // see https://www.arcgis.com/home/item.html?id=30e5fe3149c34df1ba922e6f5bbf808f
                    url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
                    options: {
                        uniqueName: 'topographic',
                        attribution: '<a target="_blank" rel="noopener noreferrer" href="https://www.arcgis.com/home/item.html?id=30e5fe3149c34df1ba922e6f5bbf808f">Tiles from Esri</a> &mdash; Sources: Esri, HERE, Garmin, Intermap, INCREMENT P, GEBCO, USGS, FAO, NPS, NRCAN, GeoBase, IGN, Kadaster NL, Ordnance Survey, Esri Japan, METI, Esri China (Hong Kong), &copy; OpenStreetMap contributors, GIS User Community',
                        maxZoom: 21,
                        maxNativeZoom: 17
                    }
                };
                layer = L.tileLayer(option.url, option.options);
                break;
            case 'googlehybrid':
                layer = new L.Google('HYBRID', {uniqueName: 'googlehybrid', maxZoom: 21, nativeMaxZoom: 21});
                break;
            case 'googleroadmap':
                layer = new L.Google('ROADMAP', {uniqueName: 'googleroadmap', maxZoom: 21, nativeMaxZoom: 21});
                break;
            case 'googleterrain':
                layer = new L.Google('TERRAIN', {uniqueName: 'googleterrain', maxZoom: 21, nativeMaxZoom: 21});
                break;
        }

        return layer;
    },

    /**
     * Intersect mouse click position with overlays and show on a popup.
     * @param {ALA.Map} map The map to contain the control
     */
    intersectOverlaysAndShowOnPopup: function (map, callback) {
        // create the layers control
        // set baseLayers to null so it will use the defaults specified when the pfMap was created.
        var config = Biocollect.MapUtilities.getOverlayConfig();

        // double click detected using https://stackoverflow.com/a/54463793/31567
        var clickTimeoutID;

        // register event handlers
        map.registerListener('click', function (e) {

            if (e.originalEvent.detail === 1) {
                console.log('[Map] Event: Single click event.');

                /** Is this a true single click or it it a single click that's part of a double click?
                 * The only way to find out is to wait it for either a specific amount of time or the `dblclick` event.
                 */
                clickTimeoutID = window.setTimeout(
                    function () {
                        var customLayerId = [];
                        console.log('[Map] Behaviour: Single click detected.');

                        console.log('[Map] Detected click on map at [' + e.latlng.lat + ',' + e.latlng.lng + ']. Loading details for location and zooming to bounds.');

                        // layer ids is comma separated
                        map.getOverlayLayers('selected').forEach(function (value) {
                            value.customLayerId && customLayerId.push(value.customLayerId);
                        });

                        var layerIds = customLayerId.join(',');

                        if (layerIds) {
                            map.startLoading();
                            var intersectQs = 'layerId=' + layerIds + '&lat=' + e.latlng.lat + '&lng=' + e.latlng.lng;
                            var intersectUrl = config.intersectService + '?' + intersectQs;

                            $.ajax(
                                // get the layers + object in layer that intersect
                                {url: intersectUrl, dataType: 'json'}
                            ).then(function (data) {

                                // get the most recently selected overlay
                                var topLayer = map.getTopSelectedOverlayLayer();
                                var topLayerId = topLayer ? topLayer.customLayerId : null;

                                // show a popup on the map that lists each layer + object
                                var popupContentItems = [];
                                data.forEach(function (item) {

                                    var overlayLayer = map.getOverlayLayers().find(function (value) {
                                        return value.customLayerId === item.field;
                                    });

                                    var overlayTitle = overlayLayer.customLayerTitle;

                                    var popupContentItem = '';
                                    if (item.pid) {
                                        popupContentItem = overlayTitle + ': ' + item.value;
                                    } else if (item.units) {
                                        popupContentItem = overlayTitle + ': ' + item.value + item.units;
                                    } else {
                                        popupContentItem = overlayTitle + ': (none)';
                                    }
                                    popupContentItems.push(popupContentItem);

                                    if (item.pid && topLayerId && item.field === topLayerId) {
                                        // at the click location, zoom / pan to the most recently selected overlay layer
                                        console.log('[Map] Zooming to ' + overlayTitle + ' (' + overlayLayer.customLayerId + '): ' + item.value + '.');
                                        var objectUrl = config.wmsFeatureUrl + item.pid;
                                        $.ajax({url: objectUrl, dataType: 'json'}).then(function (data) {
                                            var latLngs = ALA.MapUtils.bboxToPointArray(data.bbox, true);
                                            var bounds = new L.LatLngBounds(latLngs);
                                            map.getMapImpl().fitBounds(bounds);
                                        });
                                    }

                                });

                                if (!callback) {
                                    L.popup()
                                        .setLatLng(e.latlng)
                                        .setContent('<p>At this location:</p><ul><li>' + popupContentItems.join('</li><li>') + '</li></ul>')
                                        .openOn(map.getMapImpl());
                                }
                                else {
                                    callback(popupContentItems, data, e);
                                }

                                map.finishLoading();
                            }, function () {
                                map.finishLoading();
                            });
                        }
                    },

                    /**
                     * how much time users have to perform the second click in a double click
                     * accessibility notes:
                     * No way of detecting the system's double-click speed in the browser.
                     * If the system double click speed is slower than our default 500 ms above, both the single- and double-click behaviors will be triggered.
                     * Either don't use rely on combined single and double click on one and the same item.
                     * Or: add a setting in the options to have the ability to increase the value.
                     * default is 500 ms and the range 100-900mms on Windows
                     */
                    500
                );

            } else if (e.originalEvent.detail === 2) {
                console.log('[Map] Event: Double click event.');
                console.log('[Map] Behaviour: Double click detected.');

                // it's a dblclick, so cancel the single click behavior.
                window.clearTimeout(clickTimeoutID);
            } // triple, quadruple, etc. clicks are ignored.
        });
    },

    /**
     * Get leaflet object for an overlay
     * @param config - links to different map services created by {Biocollect.MapUtilities.getOverlayConfig}
     * @param overlay - overlay configuration
     * @return {{layer: object{L.tileLayer.wms}, title: string, isSelected: boolean}}
     */
    addLoadedOverlayLayer: function (config, overlay) {
        var alaName = overlay.alaName;
        var layerId = overlay.alaId;
        var layerName = overlay.layerName;
        var title = overlay.title;
        var isSelected = overlay.defaultSelected === true;
        var cqlFilter = (overlay.display || {}).cqlFilter;
        var sldStyle = overlay.sld;
        var url = config.wmsLayerUrl;
        var requestParams = [];
        var bounds = [];

        if (overlay.bounds && Object.keys(overlay.bounds).length > 0){
            bounds = [
                [overlay.bounds.latSouthMin, overlay.bounds.lngWestMin],
                [overlay.bounds.latNorthMax, overlay.bounds.lngEastMax]
            ];
        }

        var newLayerOptions = {
            layers: alaName,
            uniqueName: alaName,
            format: 'image/png',
            transparent: true,
            styles: ''
        };

        if (cqlFilter) {
            requestParams.push('cql_filter=' + encodeURIComponent(cqlFilter));
        }

        if (Biocollect.MapUtilities.isContextualLayer(layerId) && (overlay.changeLayerColour || overlay.showPropertyName) && sldStyle) {
            requestParams.push('sld_body=' + encodeURIComponent(sldStyle));
        }

        url += requestParams.join('&');
        var layer = L.tileLayer.wms(url, newLayerOptions);
        layer.customLayerId = layerId;
        layer.customLayerName = layerName;
        layer.customLayerTitle = title;

        // add getBounds() function so the WMS layer can participate in map.fitBounds() and map.getBounds() calls.
        layer.getBounds = function () {
            return new L.LatLngBounds(bounds);
        };

        // set opacity
        if ((overlay.opacity != undefined) && (overlay.opacity >= 0) && (overlay.opacity <= 1)) {
            layer.setOpacity(overlay.opacity);
        } else {
            layer.setOpacity(0.5);
        }

        console.log('[Map] Loaded overlay layer ' + title + ' (' + layerId + ').');

        // add the new layer to the overlay control (and map if it is selected)
        // map.addOverlayLayer(layer, title, isSelected);
        return {layer: layer, title: title, isSelected: isSelected}
    },

    /**
     * Get leaflet  objects for overlays
     * @returns {{
     *       overlays: {object{string: L.tileLayer.wms},
     *       overlayLayersSelectedByDefault: array{string}
     *   }}
     */
    getOverlayInALAMapFormat: function(config, overlays){
        overlays = overlays || [];
        var result = {
            overlays: {},
            overlayLayersSelectedByDefault: []
        },
        zIndex = overlays.length;

        overlays.forEach(function (overlay) {
            var overlayLayer = Biocollect.MapUtilities.addLoadedOverlayLayer(config, overlay);
            result.overlays[overlayLayer.title] = overlayLayer.layer;
            overlayLayer.layer.setZIndex(zIndex);
            zIndex --;

            if(overlayLayer.isSelected){
                result.overlayLayersSelectedByDefault.push(overlayLayer.title);
            }
        });

        return result;
    },

    /**
     * Create leaflet {L.tileLayer.wms} or {L.tileLayer} objects from map configuration i.e. leaflet objects for baseLayer and overlays configuration.
     * @param mapLayersConfig
     * @returns {{
     * overlays: object{string: L.tileLayer.wms},
     * baseLayer: object{L.tileLayer | L.Google},
     * otherLayers: object{string: object{L.tileLayer | L.Google}},
     * overlayLayersSelectedByDefault: array{string},
     * overlayConfig: object
     * }}
     */
    getBaseLayerAndOverlayFromMapConfiguration: function (mapLayersConfig) {
        var baseConfig = Biocollect.MapUtilities.getALAMapBaseLayerOptions(mapLayersConfig.baseLayers);
        var overlayConfig = Biocollect.MapUtilities.getOverlayConfig();
        var overlayLayerConfig = Biocollect.MapUtilities.getOverlayInALAMapFormat(overlayConfig, mapLayersConfig.overlays);
        return  {
            overlayConfig: overlayConfig,
            overlays: overlayLayerConfig.overlays,
            overlayLayersSelectedByDefault: overlayLayerConfig.overlayLayersSelectedByDefault,
            baseLayer: baseConfig.baseLayer,
            otherLayers: baseConfig.otherLayers
        };
    },

    /**
     * Get links to different map services
     * @returns {{layersStyle: string, wmsFeaturesUrl: string, wmsFeatureUrl: string, wmsLayerUrl: string, intersectService: string}}
     */
    getOverlayConfig: function(){
        return  {
            'wmsLayerUrl': fcConfig.spatialWms + "/wms/reflect?",
            'wmsFeatureUrl': fcConfig.featureService + "?featureId=",
            'wmsFeaturesUrl': fcConfig.featuresService + '?layerId=',
            'intersectService': fcConfig.intersectService,
            'layersStyle': fcConfig.layersStyle
        };
    },

    /**
     * Is given layer a contextual layer?
     *
     */
    isContextualLayer: function (layerId) {
        if(layerId.indexOf('cl')>= 0) {
            return true;
        }

        return false;
    },

    /**
     * Is given layer an environmental layer?
     *
     */
    isEnvironmentalLayer: function (layerId) {
        if(layerId.indexOf('el')>= 0) {
            return true;
        }

        return false;
    },

    /**
     *
     */
    getLegendURL: function (layer, style) {
        if (layer.wmsParams) {
            var params = {
                request: 'GetLegendGraphic',
                version: layer.wmsParams.version,
                format: 'image/png',
                layer: layer.wmsParams.layers,
                style: style,
                legend_options:"dpi:90;forceLabels:on;bgColor:#f2f9fc;fontAntiAliasing:true;countMatched:true;fontSize:12;fontName:Arial;",
                rule: ''
            };

            return  layer._wmsUrl + L.Util.getParamString(params, layer._wmsUrl, true);
        }
    }
};