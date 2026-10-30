var Biocollect = Biocollect || {};

(function () {

    function bcCloneJson(value) {
        if (value === undefined) {
            return undefined;
        }
        return JSON.parse(JSON.stringify(value));
    }

    function bcFeatureProperties(feature) {
        return (feature && feature.properties) || {};
    }

    function bcFeatureGeometry(feature) {
        if (!feature) {
            return {};
        }
        return feature.geometry || feature;
    }

    /**
     * Canonical kind used to decide whether a save can keep the stored extent.
     * Circle and pid are identified from properties, because neither is plain GeoJSON.
     */
    function bcFeatureKind(feature) {
        if (!feature) {
            return '';
        }
        var props = bcFeatureProperties(feature);
        var geom = bcFeatureGeometry(feature);
        var geomType = geom.type || '';
        var propType = props.type || '';
        if (props.pid || String(propType).toLowerCase() === 'pid' || String(geomType).toLowerCase() === 'pid') {
            return 'pid';
        }
        if (props.point_type === 'Circle' || propType === 'Circle' || String(propType).toLowerCase() === 'circle' ||
            geomType === 'Circle' || String(geomType).toLowerCase() === 'circle') {
            return 'Circle';
        }
        var canonical = {
            point: 'Point',
            polygon: 'Polygon',
            linestring: 'LineString',
            multipoint: 'MultiPoint',
            multipolygon: 'MultiPolygon',
            multilinestring: 'MultiLineString',
            geometrycollection: 'GeometryCollection'
        };
        return canonical[String(geomType || propType).toLowerCase()] || (geomType || propType);
    }

    function bcCoordsClose(a, b, tolerance) {
        tolerance = tolerance || 1e-5;
        if (a === b) {
            return true;
        }
        if (a == null || b == null) {
            return false;
        }
        if (typeof a === 'number' || typeof b === 'number' || (typeof a === 'string' && a !== '' && !isNaN(a))) {
            var na = Number(a), nb = Number(b);
            return !isNaN(na) && !isNaN(nb) && Math.abs(na - nb) <= tolerance;
        }
        if (Object.prototype.toString.call(a) === '[object Array]' && Object.prototype.toString.call(b) === '[object Array]') {
            if (a.length !== b.length) {
                return false;
            }
            for (var i = 0; i < a.length; i++) {
                if (!bcCoordsClose(a[i], b[i], tolerance)) {
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    function bcWalkCoords(node, visit) {
        if (!node || Object.prototype.toString.call(node) !== '[object Array]') {
            return;
        }
        if (node.length >= 2 && (typeof node[0] === 'number' || typeof node[0] === 'string') && !isNaN(node[0]) &&
            (typeof node[1] === 'number' || typeof node[1] === 'string') && !isNaN(node[1]) &&
            (node.length === 2 || typeof node[2] === 'number')) {
            visit([Number(node[0]), Number(node[1])]);
            return;
        }
        for (var i = 0; i < node.length; i++) {
            bcWalkCoords(node[i], visit);
        }
    }

    function bcLngLat(feature) {
        var geom = bcFeatureGeometry(feature);
        var coords = geom.coordinates;
        if (coords && (typeof coords[0] === 'number' || typeof coords[0] === 'string') && !isNaN(coords[0]) &&
            coords.length >= 2 && (typeof coords[1] === 'number' || typeof coords[1] === 'string')) {
            return [Number(coords[0]), Number(coords[1])];
        }
        if (geom.decimalLongitude != null && geom.decimalLatitude != null && geom.decimalLongitude !== '' && geom.decimalLatitude !== '') {
            return [Number(geom.decimalLongitude), Number(geom.decimalLatitude)];
        }
        var points = [];
        bcWalkCoords(coords, function (point) { points.push(point); });
        if (!points.length) {
            return null;
        }
        var minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
        points.forEach(function (point) {
            minX = Math.min(minX, point[0]);
            maxX = Math.max(maxX, point[0]);
            minY = Math.min(minY, point[1]);
            maxY = Math.max(maxY, point[1]);
        });
        return [(minX + maxX) / 2, (minY + maxY) / 2];
    }

    function bcBoundsOfFeatures(features) {
        var minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity, any = false;
        (features || []).forEach(function (feature) {
            var kind = bcFeatureKind(feature);
            var centre = bcLngLat(feature);
            if (kind === 'Circle' && centre) {
                var radius = Number(bcFeatureProperties(feature).radius || bcFeatureGeometry(feature).radius || 0);
                var lat = centre[1];
                var dLat = radius / 111320;
                var cos = Math.cos(lat * Math.PI / 180);
                var dLng = cos ? radius / (111320 * cos) : dLat;
                minX = Math.min(minX, centre[0] - dLng);
                maxX = Math.max(maxX, centre[0] + dLng);
                minY = Math.min(minY, centre[1] - dLat);
                maxY = Math.max(maxY, centre[1] + dLat);
                any = true;
                return;
            }
            bcWalkCoords(bcFeatureGeometry(feature).coordinates, function (point) {
                any = true;
                minX = Math.min(minX, point[0]);
                maxX = Math.max(maxX, point[0]);
                minY = Math.min(minY, point[1]);
                maxY = Math.max(maxY, point[1]);
            });
            if (!any && centre) {
                any = true;
                minX = Math.min(minX, centre[0]);
                maxX = Math.max(maxX, centre[0]);
                minY = Math.min(minY, centre[1]);
                maxY = Math.max(maxY, centre[1]);
            }
        });
        if (!any) {
            return null;
        }
        return {west: minX, south: minY, east: maxX, north: maxY};
    }

    function bcRingFromBounds(bounds) {
        if (!bounds) {
            return null;
        }
        return [[
            [bounds.west, bounds.south],
            [bounds.west, bounds.north],
            [bounds.east, bounds.north],
            [bounds.east, bounds.south],
            [bounds.west, bounds.south]
        ]];
    }

    function bcDefined(target) {
        var copy = {};
        Object.keys(target || {}).forEach(function (key) {
            if (target[key] !== undefined && target[key] !== null && target[key] !== '') {
                copy[key] = target[key];
            }
        });
        return copy;
    }

    function bcAreaKmSq(featureOrCollection) {
        if (typeof ALA !== 'undefined' && ALA.MapUtils && typeof ALA.MapUtils.calculateAreaKmSq === 'function') {
            try {
                var area = ALA.MapUtils.calculateAreaKmSq(featureOrCollection);
                if (area || area === 0) {
                    return area;
                }
            } catch (e) {
                // Fall through to the circle calculation below.
            }
        }
        var features = featureOrCollection && featureOrCollection.type === 'FeatureCollection' ? featureOrCollection.features : [featureOrCollection];
        var total = 0, any = false;
        (features || []).forEach(function (feature) {
            if (bcFeatureKind(feature) === 'Circle') {
                var radius = Number(bcFeatureProperties(feature).radius || 0);
                total += (Math.PI * radius * radius) / 1000000;
                any = true;
            }
        });
        return any ? total : null;
    }

    function bcPrepareSpecialFeature(feature) {
        if (!feature || feature.type !== 'Feature') {
            return feature;
        }
        var copy = bcCloneJson(feature);
        copy.properties = copy.properties || {};
        var kind = bcFeatureKind(copy);
        if (kind === 'Circle') {
            var centre = bcLngLat(copy);
            copy.properties.type = 'Circle';
            copy.properties.point_type = 'Circle';
            if (copy.properties.radius == null && copy.geometry) {
                copy.properties.radius = copy.geometry.radius;
            }
            copy.geometry = {type: 'Point', coordinates: centre};
        } else if (kind === 'pid') {
            copy.properties.type = 'pid';
            if (!copy.properties.pid && copy.geometry) {
                copy.properties.pid = copy.geometry.pid;
            }
        }
        return copy;
    }

    function bcFeaturesFromSite(site) {
        if (!site) {
            return [];
        }
        if (site.features && site.features.length) {
            return site.features.map(function (feature) {
                return bcPrepareSpecialFeature(feature.type === 'Feature' ? feature : Biocollect.MapUtilities.featureToValidGeoJson(feature));
            }).filter(Boolean);
        }
        var source = site.extent && site.extent.source ? String(site.extent.source).toLowerCase() : '';
        if (!site.extent || !site.extent.geometry || source === 'none') {
            return [];
        }
        var feature = Biocollect.MapUtilities.featureToValidGeoJson(site.extent.geometry);
        return feature ? [bcPrepareSpecialFeature(feature)] : [];
    }

    function bcSameFeature(a, b) {
        var kindA = bcFeatureKind(a), kindB = bcFeatureKind(b);
        if (!kindA || kindA !== kindB) {
            return false;
        }
        if (kindA === 'pid') {
            return String(bcFeatureProperties(a).pid || '') === String(bcFeatureProperties(b).pid || '');
        }
        if (kindA === 'Circle') {
            var radiusA = Number(bcFeatureProperties(a).radius);
            var radiusB = Number(bcFeatureProperties(b).radius);
            return Math.abs(radiusA - radiusB) <= 0.05 && bcCoordsClose(bcLngLat(a), bcLngLat(b));
        }
        return bcCoordsClose(bcFeatureGeometry(a).coordinates, bcFeatureGeometry(b).coordinates);
    }

    function bcPoiSignature(poi) {
        return (poi || []).map(function (item) {
            var geometry = item.geometry || {};
            return {
                poiId: item.poiId || '',
                name: item.name || '',
                type: item.type || '',
                description: item.description || '',
                lat: geometry.decimalLatitude == null ? null : Number(geometry.decimalLatitude),
                lng: geometry.decimalLongitude == null ? null : Number(geometry.decimalLongitude),
                bearing: geometry.bearing == null || geometry.bearing === '' ? null : Number(geometry.bearing)
            };
        });
    }

    function bcExtentFromSingleFeature(feature, original) {
        var kind = bcFeatureKind(feature);
        var props = bcFeatureProperties(feature);
        var centre = bcLngLat(feature);
        var originalSource = original && original.extent && original.extent.source ? String(original.extent.source).toLowerCase() : '';
        var geometry;

        if (kind === 'pid') {
            geometry = bcDefined({
                type: 'pid',
                pid: props.pid,
                name: props.name,
                fid: props.fid,
                layerName: props.fieldname || props.layerName,
                bbox: props.bbox,
                areaKmSq: props.area_km,
                centre: centre
            });
            return {source: 'pid', geometry: geometry};
        }

        if (kind === 'Circle') {
            geometry = bcDefined({
                type: 'Circle',
                radius: props.radius,
                coordinates: centre,
                centre: centre,
                areaKmSq: bcAreaKmSq(feature)
            });
            return {source: 'drawn', geometry: geometry};
        }

        if (kind === 'Point') {
            geometry = bcDefined({
                type: 'Point',
                decimalLatitude: centre ? centre[1] : null,
                decimalLongitude: centre ? centre[0] : null,
                coordinates: centre,
                centre: centre,
                datum: 'WGS84'
            });
            return {source: originalSource === 'drawn' ? 'drawn' : 'point', geometry: geometry};
        }

        var geom = bcFeatureGeometry(feature);
        geometry = bcDefined({
            type: geom.type,
            coordinates: geom.coordinates,
            centre: centre,
            areaKmSq: bcAreaKmSq(feature)
        });
        return {source: 'drawn', geometry: geometry};
    }

    function bcStoredFeature(feature) {
        var copy = bcPrepareSpecialFeature(feature);
        copy.properties = copy.properties || {};
        if (bcFeatureKind(copy) === 'Circle') {
            copy.properties.type = 'Circle';
            copy.properties.point_type = 'Circle';
        } else if (bcFeatureKind(copy) === 'pid') {
            copy.properties.type = 'pid';
        }
        return copy;
    }

Biocollect.MapUtilities = {
    /**
     * Converts a 'feature' object from Ecodata into valid GeoJSON that can be handled by the ALA.Map.
     *
     * @param feature
     * @returns {{type: string, geometry: {}, properties: {}}}
     */
    featureToValidGeoJson: function(feature) {
        if (!feature || !feature.type) {
            return null;
        }

        if (feature.type === 'Feature' || feature.type === 'FeatureCollection') {
            if (feature.type === 'FeatureCollection') {
                return {
                    type: 'FeatureCollection',
                    features: (feature.features || []).map(function (child) {
                        return Biocollect.MapUtilities.featureToValidGeoJson(child);
                    }).filter(Boolean)
                };
            }
            return bcPrepareSpecialFeature(bcCloneJson(feature));
        }

        var geoJson = {
            type: "Feature",
            geometry: {},
            properties: {}
        };
        var featureType = String(feature.type).toLowerCase();

        if (featureType === 'pid') {
            if (feature.aream2 == 0 || feature.areaKmSq == 0){
                geoJson.geometry.type = 'Point';
                if (feature.coordinates) {
                    geoJson.geometry.coordinates = feature.coordinates;
                }
                else if (feature.centre){
                    geoJson.geometry.coordinates = feature.centre;
                }
            }else{
                geoJson.geometry.type = 'Polygon';
                geoJson.geometry.coordinates = feature.coordinates || [];
            }
            geoJson.properties.pid = feature.pid;
            geoJson.properties.type = 'pid';
            if (feature.name) {
                geoJson.properties.name = feature.name;
            }
            if (feature.fid) {
                geoJson.properties.fid = feature.fid;
            }
            if (feature.layerName) {
                geoJson.properties.fieldname = feature.layerName;
            }
            if (feature.bbox) {
                geoJson.properties.bbox = feature.bbox;
            }
        } else if (featureType === "circle") {
            geoJson.geometry.type = 'Point';
            geoJson.geometry.coordinates = feature.coordinates || feature.centre;
            geoJson.properties.type = 'Circle';
            geoJson.properties.point_type = 'Circle';
            geoJson.properties.radius = feature.radius;
        } else if (featureType === "point") {
            geoJson.geometry.type = 'Point';
            geoJson.geometry.coordinates = feature.coordinates || (feature.decimalLongitude != null && feature.decimalLatitude != null ? [Number(feature.decimalLongitude), Number(feature.decimalLatitude)] : feature.centre);
        } else if (featureType === "polygon") {
            geoJson.geometry.type = 'Polygon';
            geoJson.geometry.coordinates = feature.coordinates;
            geoJson.properties.radius = feature.radius;
        } else if (featureType === "linestring") {
            geoJson.geometry.type = 'LineString';
            geoJson.geometry.coordinates = feature.coordinates;
        } else if (featureType === "multipolygon" || featureType === "multilinestring" || featureType === "multipoint") {
            geoJson.geometry.type = bcFeatureKind(feature);
            geoJson.geometry.coordinates = feature.coordinates;
        }

        return geoJson.geometry.type ? geoJson : null;
    },

    /**
     * Creates an instance of the L.Control.TwoStepSelector control from the ALA Map plugin
     * @param map The map the control will be placed in
     * @param featuresServiceUrl The URL for the WMS features service
     * @param regionListUrl The URL to retrieve the list of available regions
     * @returns {*} L.Control.TwoStepSelector
     */
    createKnownShapeMapControl: function(map, featuresServiceUrl, regionListUrl, extraOptions = {}) {
        var regionOptions = {
            id: "regionSelection",
            title: "Select layer",
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

        return new L.Control.TwoStepSelector(Object.assign({}, regionOptions, extraOptions));
    },

    /**
     * This object is used specifically to create a geospatial index to allow searching by geographic points/regions/bounding boxes.
     * Known regions (e.g. states/territories, etc) are treated as Polygons for the purposes of searching.
     * The structure of the resulting 'geoIndex' object is designed to suit Elastic Search's geo_shape mappings.
     * See https://www.elastic.co/guide/en/elasticsearch/reference/1.7/mapping-geo-shape-type.html for more info.
     */
    constructGeoIndexObject: function(site) {
        var geoIndex = {};

        if (site && site.features && site.features.length) {
            return {
                type: 'GeometryCollection',
                geometries: site.features.map(function (feature) {
                    var geometry = (feature && feature.geometry) || {};
                    var properties = (feature && feature.properties) || {};
                    if (properties.type === 'Circle' || properties.point_type === 'Circle' || geometry.type === 'Circle') {
                        return {
                            type: 'Circle',
                            coordinates: geometry.coordinates,
                            radius: properties.radius || geometry.radius
                        };
                    }
                    return {
                        type: geometry.type,
                        coordinates: geometry.coordinates
                    };
                })
            };
        }

        if (site && site.extent && site.extent.geometry) {
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
            } else if (geometry.type == "LineString" || geometry.type == "MultiPolygon" || geometry.type == "MultiLineString" || geometry.type == "MultiPoint") {
                geoIndex = {
                    type: geometry.type,
                    coordinates: geometry.coordinates
                };
            }
        }

        return geoIndex;
    },

    /**
     * GeoJSON for a stored site. Uses site.features when that array is present, otherwise the extent.
     * The result is for the map only and is not written back unless the user changes the geometry.
     */
    geoJsonForSite: function (site) {
        if (!site) {
            return null;
        }
        if (site.features && site.features.length) {
            return Biocollect.MapUtilities.geoJsonFromMapFeatures({features: site.features});
        }
        var source = site.extent && site.extent.source ? String(site.extent.source).toLowerCase() : '';
        if (site.extent && site.extent.geometry && source !== 'none') {
            return Biocollect.MapUtilities.featureToValidGeoJson(site.extent.geometry);
        }
        return null;
    },

    geoJsonFromMapFeatures: function (mapFeatures) {
        if (!mapFeatures || !mapFeatures.features || !mapFeatures.features.length) {
            return null;
        }
        var flat = [];
        mapFeatures.features.forEach(function (feature) {
            var converted = Biocollect.MapUtilities.featureToValidGeoJson(feature);
            if (!converted) {
                return;
            }
            if (converted.type === 'FeatureCollection') {
                flat = flat.concat(converted.features || []);
            } else {
                flat.push(converted);
            }
        });
        if (!flat.length) {
            return null;
        }
        if (flat.length === 1) {
            return flat[0];
        }
        return {type: 'FeatureCollection', features: flat};
    },

    featuresForSite: function (site) {
        var geoJson = Biocollect.MapUtilities.geoJsonForSite(site);
        if (!geoJson) {
            return [];
        }
        if (geoJson.type === 'FeatureCollection') {
            return geoJson.features || [];
        }
        return [geoJson];
    },

    describeFeature: function (feature) {
        var kind = bcFeatureKind(feature);
        var radius = bcFeatureProperties(feature).radius;
        if (radius == null && bcFeatureGeometry(feature).radius != null) {
            radius = bcFeatureGeometry(feature).radius;
        }
        return {
            type: kind,
            radius: kind === 'Circle' ? radius : null,
            areaKmSq: bcAreaKmSq(feature)
        };
    },

    /** True when both values are finite, in-range coordinates. Zero is valid; blank values are not. */
    isValidLatLng: function (lat, lng) {
        var latitude = parseFloat(lat), longitude = parseFloat(lng);
        return isFinite(latitude) && isFinite(longitude) && Math.abs(latitude) <= 90 && Math.abs(longitude) <= 180;
    },

    /**
     * Feature for a known-shape (pid) WMS layer. The layer has a geometry and metadata only after ALA.Map has
     * retrieved it, so the layer options are the fallback until then.
     */
    pidFeatureFromLayer: function (layer, pid) {
        var options = layer.options || {};
        var retrieved = typeof layer.toGeoJSON === 'function' ? layer.toGeoJSON() : null;
        var meta = (retrieved && retrieved.properties) || {};
        return {
            type: 'Feature',
            geometry: retrieved && retrieved.geometry ? retrieved.geometry : {type: 'Polygon', coordinates: []},
            properties: bcDefined({
                type: 'pid',
                pid: pid,
                name: meta.name || options.name,
                fid: meta.fid || options.fid,
                fieldname: meta.fieldname || options.fieldname || options.layerName,
                bbox: meta.bbox || options.bbox,
                area_km: meta.area_km != null ? meta.area_km : options.area_km
            })
        };
    },

    featuresMatchSite: function (site, mapFeatures) {
        var stored = bcFeaturesFromSite(site);
        var current = (mapFeatures || []).map(bcPrepareSpecialFeature).filter(function (feature) {
            return feature && bcFeatureKind(feature) && bcFeatureProperties(feature).type !== 'poi';
        });
        if (stored.length !== current.length) {
            return false;
        }
        for (var i = 0; i < stored.length; i++) {
            if (!bcSameFeature(stored[i], current[i])) {
                return false;
            }
        }
        return true;
    },

    /**
     * Geometry section of a site save. Unchanged geometry omits features and returns the original extent.
     * site.features is included only when the site now has more than one geometry, or as [] to clear stored features.
     * geometryDirty false forces the original extent even if the map GeoJSON cannot represent a pid.
     */
    sitePayloadForSave: function (originalSite, mapFeatures, poi, geometryDirty) {
        var original = originalSite || {};
        var originalExtent = original.extent ? bcCloneJson(original.extent) : {source: 'none'};
        var originalPoi = original.poi ? bcCloneJson(original.poi) : [];
        var currentPoi = poi === undefined ? originalPoi : poi;
        var poiUnchanged = JSON.stringify(bcPoiSignature(currentPoi)) === JSON.stringify(bcPoiSignature(originalPoi));
        var current = (mapFeatures || []).filter(function (feature) {
            return feature && bcFeatureProperties(feature).type !== 'poi';
        }).map(bcPrepareSpecialFeature);
        var unchanged = geometryDirty === false || Biocollect.MapUtilities.featuresMatchSite(original, current);

        // An omitted features array leaves the stored one in place, so it has to be sent empty.
        function clearStoredFeatures(payload) {
            if (original.features && original.features.length) {
                payload.features = [];
            }
            return payload;
        }

        if (unchanged) {
            var unchangedPayload = {
                extent: originalExtent,
                poi: poiUnchanged ? originalPoi : currentPoi
            };
            return unchangedPayload;
        }

        if (!current.length) {
            return clearStoredFeatures({
                extent: {source: 'none'},
                poi: currentPoi
            });
        }

        if (current.length === 1) {
            return clearStoredFeatures({
                extent: bcExtentFromSingleFeature(current[0], original),
                poi: currentPoi
            });
        }

        var bounds = bcBoundsOfFeatures(current);
        var centre = bounds ? [(bounds.west + bounds.east) / 2, (bounds.south + bounds.north) / 2] : null;
        var summary = {
            type: 'Polygon',
            coordinates: bcRingFromBounds(bounds),
            centre: centre,
            areaKmSq: bcAreaKmSq({type: 'FeatureCollection', features: current})
        };
        if (centre) {
            summary.decimalLongitude = centre[0];
            summary.decimalLatitude = centre[1];
        }
        return {
            extent: {source: 'drawn', geometry: bcDefined(summary)},
            features: current.map(bcStoredFeature),
            poi: currentPoi
        };
    },

    /**
     * Translate base layer configuration to a format understood by ALA map plugin.
     */
    getALAMapBaseLayerOptions: function (baseLayers) {
        var options = {baseLayer: undefined, otherLayers: {}};
        baseLayers = baseLayers || [];
        baseLayers.forEach(function (baseLayer) {
            var baseConfig = Biocollect.MapUtilities.getBaseLayer(baseLayer.code, baseLayer);
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
     * @param config - used to get basemap url
     * @returns {L.tileLayer | L.Google}
     */
    getBaseLayer: function (code, config) {
        config = config || {};
        var option, layer,
            url = config.url;
        switch (code) {
            case 'minimal':
                option = {
                    // See https://cartodb.com/location-data-services/basemaps/
                    url: url || 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                    options: {
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
                    url: url || 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                    options: {
                        attribution: '<a target="_blank" rel="noopener noreferrer" href="https://www.arcgis.com/home/item.html?id=10df2279f9684e4a9f6a7f08febac2a9">Tiles from Esri</a> &mdash; Sources: Esri, DigitalGlobe, Earthstar Geographics, CNES/Airbus DS, GeoEye, USDA FSA, USGS, Aerogrid, IGN, IGP, and the GIS User Community',
                        maxZoom: 21,
                        maxNativeZoom: 17
                    }
                };
                layer = L.tileLayer(option.url, option.options);
                break;
            case 'maptilersatellite':
                option = {
                    url:  url || 'https://api.maptiler.com/maps/hybrid/256/{z}/{x}/{y}.jpg?key=O11Deo7fBLatChkUYGIH',
                    options: {
                        attribution: '<a href="https://www.maptiler.com/copyright/" target="_blank">© MapTiler</a> <a href="https://www.openstreetmap.org/copyright" target="_blank">© OpenStreetMap contributors</a>',
                        maxZoom: 21,
                        maxNativeZoom: 21
                    }
                };
                layer = L.tileLayer(option.url, option.options);
                break;

            case 'detailed':
                option = {
                    // see https://wiki.openstreetmap.org/wiki/Standard_tile_layer
                    url: url || 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    options: {
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
                    url: url || 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
                    options: {
                        attribution: '<a target="_blank" rel="noopener noreferrer" href="https://www.arcgis.com/home/item.html?id=30e5fe3149c34df1ba922e6f5bbf808f">Tiles from Esri</a> &mdash; Sources: Esri, HERE, Garmin, Intermap, INCREMENT P, GEBCO, USGS, FAO, NPS, NRCAN, GeoBase, IGN, Kadaster NL, Ordnance Survey, Esri Japan, METI, Esri China (Hong Kong), &copy; OpenStreetMap contributors, GIS User Community',
                        maxZoom: 21,
                        maxNativeZoom: 17
                    }
                };
                layer = L.tileLayer(option.url, option.options);
                break;
            case 'googlehybrid':
                layer = new L.Google('HYBRID', {maxZoom: 21, nativeMaxZoom: 21});
                break;
            case 'googleroadmap':
                layer = new L.Google('ROADMAP', {maxZoom: 21, nativeMaxZoom: 21});
                break;
            case 'googleterrain':
                layer = new L.Google('TERRAIN', {maxZoom: 21, nativeMaxZoom: 21});
                break;
        }

        return layer;
    },

    /**
     * Intersect mouse click position with overlays and show on a popup.
     * @param {ALA.Map} map The map to contain the control
     */
    intersectOverlaysAndShowOnPopup: function (map) {
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
                        console.log('[Map] Behaviour: Single click detected.');

                        console.log('[Map] Detected click on map at [' + e.latlng.lat + ',' + e.latlng.lng + ']. Loading details for location and zooming to bounds.');
                        map.startLoading();

                        // layer ids is comma separated
                        var layerIds = map.getOverlayLayers('selected').map(function (value) {
                            return value.customLayerId;
                        }).join(',');

                        if (layerIds) {
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
                                        popupContentItem = '<li>' + overlayTitle + ': ' + item.value + '</li>';
                                    } else if (item.units) {
                                        popupContentItem = '<li>' + overlayTitle + ': ' + item.value + item.units + '</li>';
                                    } else {
                                        popupContentItem = '<li>' + overlayTitle + ': (none)</li>';
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

                                L.popup()
                                    .setLatLng(e.latlng)
                                    .setContent('<p>At this location:</p><ul>' + popupContentItems.join('') + '</ul>')
                                    .openOn(map.getMapImpl());

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
    }
};

})();