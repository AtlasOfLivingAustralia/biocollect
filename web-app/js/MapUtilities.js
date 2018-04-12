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
    }
};