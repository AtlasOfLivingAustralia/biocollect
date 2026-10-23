/*
 * Copyright (C) 2020 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 * 
 * Created by Temi on 17/1/20.
 */
describe("MapUtilities unit test", function () {
    beforeAll(function () {
        window.fcConfig = {
            imageLocation: '/'
        }
    });
    afterAll(function () {
        delete window.fcConfig;
    });

    it("getBaseLayer should return layer instance for passed code", function () {
        expect(Biocollect.MapUtilities.getBaseLayer("xyz")).toBeUndefined();
        expect(Biocollect.MapUtilities.getBaseLayer("minimal")).toEqual(jasmine.any(L.TileLayer));
        expect(Biocollect.MapUtilities.getBaseLayer("googlehybrid")).toEqual(jasmine.any(L.Google));
    });

    it("getALAMapBaseLayerOptions should return selected base layer and a list of base layers", function () {
        var baselayers = [{
            'code': 'minimal',
            'displayText': 'Road map',
            'isSelected': true
        },
            {
                'code': 'worldimagery',
                'displayText': 'Satellite',
                'isSelected': false
            }];
        var layers = Biocollect.MapUtilities.getALAMapBaseLayerOptions(baselayers);
        expect(layers.baseLayer).toBeDefined();
        expect(layers.baseLayer).toEqual(jasmine.any(L.TileLayer));
        expect(layers.otherLayers).toBeDefined();
        expect(layers.otherLayers['Road map']).toEqual(layers.baseLayer);
        expect(layers.otherLayers['Satellite']).toBeDefined();
    });

    it("addLoadedOverlayLayer should return overlay object and associated properties", function () {
        var overlay = {
                alaId: 'cl917',
                alaName: 'australian_coral_ecoregions',
                layerName: 'aust_coral_ecoregions',
                title: 'Australian Coral Ecoregions',
                defaultSelected: false,
                boundaryColour: '#e66101',
                showPropertyName: false,
                fillColour: '',
                textColour: '',
                userAccessRestriction: 'anyUser',
                inLayerShapeList: true,
                opacity: 0.5,
                changeLayerColour: false,
                display: {
                    "cqlFilter": "",
                    "propertyName": 'ECONAME'
                },
                style: {}
                ,
                bounds: [],
                restrictions:
                    {}
            }
        ;
        var config = Biocollect.MapUtilities.getOverlayConfig();
        var output = Biocollect.MapUtilities.addLoadedOverlayLayer(config, overlay);
        expect(output.layer).toBeDefined();
        expect(output.layer).toEqual(jasmine.any(L.TileLayer.WMS));
        expect(output.title).toBeDefined();
        expect(output.title).toEqual(overlay.title);
        expect(output.isSelected).toEqual(overlay.defaultSelected);
    });

    it("getOverlayInALAMapFormat should return overlay list and selected overlay list", function () {
        var overlays = [{
                alaId: 'cl917',
                alaName: 'australian_coral_ecoregions',
                layerName: 'aust_coral_ecoregions',
                title: 'Australian Coral Ecoregions',
                defaultSelected: true,
                boundaryColour: '#e66101',
                showPropertyName: false,
                fillColour: '',
                textColour: '',
                userAccessRestriction: 'anyUser',
                inLayerShapeList: true,
                opacity: 0.5,
                changeLayerColour: false,
                display: {
                    "cqlFilter": "",
                    "propertyName": 'ECONAME'
                },
                style: {}
                ,
                bounds: [],
                restrictions:
                    {}
            }]
        ;
        var config = Biocollect.MapUtilities.getOverlayConfig();
        var output = Biocollect.MapUtilities.getOverlayInALAMapFormat(config, overlays);
        expect(output.overlays).toBeDefined();
        expect(output.overlays['Australian Coral Ecoregions']).toEqual(jasmine.any(L.TileLayer.WMS));
        expect(output.overlayLayersSelectedByDefault).toBeDefined();
        expect(output.overlayLayersSelectedByDefault.length).toEqual(1);
        expect(output.overlayLayersSelectedByDefault[0]).toEqual('Australian Coral Ecoregions');
    });

    it("isContextualLayer should return true for all layer starting with 'cl'", function () {
        expect(Biocollect.MapUtilities.isContextualLayer('cl1')).toEqual(true);
        expect(Biocollect.MapUtilities.isContextualLayer('el1')).toEqual(false);
    });

    it("isEnvironmentalLayer should return true for all layer starting with 'el'", function () {
        expect(Biocollect.MapUtilities.isEnvironmentalLayer('cl1')).toEqual(false);
        expect(Biocollect.MapUtilities.isEnvironmentalLayer('el1')).toEqual(true);
    });

    it("featureToValidGeoJson accepts lines, multi geometries, features and collections", function () {
        expect(Biocollect.MapUtilities.featureToValidGeoJson(null)).toBeNull();
        expect(Biocollect.MapUtilities.featureToValidGeoJson({})).toBeNull();

        var line = Biocollect.MapUtilities.featureToValidGeoJson({
            type: 'LineString',
            coordinates: [[149, -35], [150, -36]]
        });
        expect(line.geometry.type).toBe('LineString');
        expect(line.geometry.coordinates).toEqual([[149, -35], [150, -36]]);

        var multiPolygon = Biocollect.MapUtilities.featureToValidGeoJson({
            type: 'MultiPolygon',
            coordinates: [[[[0, 0], [1, 0], [1, 1], [0, 0]]]]
        });
        expect(multiPolygon.geometry.type).toBe('MultiPolygon');

        var multiLine = Biocollect.MapUtilities.featureToValidGeoJson({
            type: 'MultiLineString',
            coordinates: [[[0, 0], [1, 1]]]
        });
        expect(multiLine.geometry.type).toBe('MultiLineString');

        var multiPoint = Biocollect.MapUtilities.featureToValidGeoJson({
            type: 'MultiPoint',
            coordinates: [[0, 0], [1, 1]]
        });
        expect(multiPoint.geometry.type).toBe('MultiPoint');

        var circle = Biocollect.MapUtilities.featureToValidGeoJson({
            type: 'Feature',
            geometry: {type: 'Point', coordinates: [149.1, -35.3]},
            properties: {radius: 25, point_type: 'Circle'}
        });
        expect(circle.geometry.type).toBe('Point');
        expect(circle.properties.type).toBe('Circle');
        expect(circle.properties.point_type).toBe('Circle');
        expect(circle.properties.radius).toBe(25);

        var collection = Biocollect.MapUtilities.featureToValidGeoJson({
            type: 'FeatureCollection',
            features: [
                {type: 'LineString', coordinates: [[0, 0], [1, 1]]},
                {type: 'Feature', geometry: {type: 'MultiPoint', coordinates: [[2, 2], [3, 3]]}, properties: {}}
            ]
        });
        expect(collection.type).toBe('FeatureCollection');
        expect(collection.features.length).toBe(2);
        expect(collection.features[0].geometry.type).toBe('LineString');
        expect(collection.features[1].geometry.type).toBe('MultiPoint');
    });

    it("constructGeoIndexObject keeps a point coordinate pair and indexes features as a collection", function () {
        var pointIndex = Biocollect.MapUtilities.constructGeoIndexObject({
            extent: {
                source: 'point',
                geometry: {
                    type: 'Point',
                    decimalLongitude: 149.1,
                    decimalLatitude: -35.3
                }
            }
        });
        expect(pointIndex).toEqual({
            type: 'Point',
            coordinates: [149.1, -35.3]
        });

        var featureIndex = Biocollect.MapUtilities.constructGeoIndexObject({
            features: [
                {
                    type: 'Feature',
                    geometry: {type: 'Point', coordinates: [149.1, -35.3]},
                    properties: {type: 'Circle', point_type: 'Circle', radius: 12}
                },
                {
                    type: 'Feature',
                    geometry: {type: 'Polygon', coordinates: [[[0, 0], [1, 0], [1, 1], [0, 0]]]},
                    properties: {}
                }
            ]
        });
        expect(featureIndex.type).toBe('GeometryCollection');
        expect(featureIndex.geometries[0]).toEqual({
            type: 'Circle',
            coordinates: [149.1, -35.3],
            radius: 12
        });
        expect(featureIndex.geometries[1].type).toBe('Polygon');
    });

    it("sitePayloadForSave leaves an unchanged site on its original extent and omits features", function () {
        var pointSite = {
            extent: {
                source: 'point',
                geometry: {
                    type: 'Point',
                    decimalLatitude: -35.3,
                    decimalLongitude: 149.1,
                    coordinates: [149.1, -35.3],
                    centre: [149.1, -35.3],
                    datum: 'WGS84'
                }
            },
            poi: [{
                poiId: 'p1',
                name: 'Photo',
                type: 'photoPoints',
                description: '',
                geometry: {decimalLatitude: -35.3, decimalLongitude: 149.1}
            }]
        };
        var unchangedPoint = Biocollect.MapUtilities.sitePayloadForSave(pointSite, [], pointSite.poi, false);
        expect(unchangedPoint.features).toBeUndefined();
        expect(unchangedPoint.extent).toEqual(pointSite.extent);
        expect(unchangedPoint.poi).toEqual(pointSite.poi);

        var circleSite = {
            extent: {
                source: 'drawn',
                geometry: {
                    type: 'Circle',
                    radius: 50,
                    coordinates: [149.1, -35.3],
                    centre: [149.1, -35.3]
                }
            },
            poi: []
        };
        var unchangedCircle = Biocollect.MapUtilities.sitePayloadForSave(circleSite, [], [], false);
        expect(unchangedCircle.features).toBeUndefined();
        expect(unchangedCircle.extent).toEqual(circleSite.extent);
        expect(unchangedCircle.poi).toEqual([]);

        var pidSite = {
            extent: {
                source: 'pid',
                geometry: {type: 'pid', pid: 'cl123', name: 'Park'}
            },
            poi: [{name: 'Gate', geometry: {decimalLatitude: 1, decimalLongitude: 2}}]
        };
        var unchangedPid = Biocollect.MapUtilities.sitePayloadForSave(pidSite, [], pidSite.poi, false);
        expect(unchangedPid.features).toBeUndefined();
        expect(unchangedPid.extent).toEqual(pidSite.extent);
        expect(unchangedPid.poi).toEqual(pidSite.poi);

        var emptySite = {extent: {source: 'none'}, poi: []};
        var emptyPayload = Biocollect.MapUtilities.sitePayloadForSave(emptySite, [], [], true);
        expect(emptyPayload.features).toBeUndefined();
        expect(emptyPayload.extent).toEqual({source: 'none'});
    });

    it("sitePayloadForSave keeps a single point or circle and stores many geometries as features", function () {
        var pointSite = {
            extent: {
                source: 'point',
                geometry: {
                    type: 'Point',
                    decimalLatitude: -35.3,
                    decimalLongitude: 149.1,
                    coordinates: [149.1, -35.3],
                    centre: [149.1, -35.3]
                }
            },
            poi: []
        };
        var moved = Biocollect.MapUtilities.sitePayloadForSave(pointSite, [{
            type: 'Feature',
            geometry: {type: 'Point', coordinates: [149.2, -35.4]},
            properties: {}
        }], [], true);
        expect(moved.features).toBeUndefined();
        expect(moved.extent.source).toBe('point');
        expect(moved.extent.geometry.type).toBe('Point');
        expect(moved.extent.geometry.coordinates).toEqual([149.2, -35.4]);
        expect(moved.extent.geometry.decimalLongitude).toBe(149.2);
        expect(moved.extent.geometry.decimalLatitude).toBe(-35.4);

        var drawnPoint = JSON.parse(JSON.stringify(pointSite));
        drawnPoint.extent.source = 'drawn';
        var movedDrawn = Biocollect.MapUtilities.sitePayloadForSave(drawnPoint, [{
            type: 'Feature',
            geometry: {type: 'Point', coordinates: [149.2, -35.4]},
            properties: {}
        }], [], true);
        expect(movedDrawn.extent.source).toBe('drawn');
        expect(movedDrawn.extent.geometry.type).toBe('Point');

        var circle = Biocollect.MapUtilities.sitePayloadForSave({extent: {source: 'none'}, poi: []}, [{
            type: 'Feature',
            geometry: {type: 'Point', coordinates: [149.1, -35.3]},
            properties: {type: 'Circle', point_type: 'Circle', radius: 25}
        }], [], true);
        expect(circle.features).toBeUndefined();
        expect(circle.extent.source).toBe('drawn');
        expect(circle.extent.geometry.type).toBe('Circle');
        expect(circle.extent.geometry.radius).toBe(25);
        expect(circle.extent.geometry.coordinates).toEqual([149.1, -35.3]);
        expect(Array.isArray(circle.extent.geometry.coordinates[0])).toBe(false);

        var multi = Biocollect.MapUtilities.sitePayloadForSave({extent: {source: 'none'}, poi: []}, [
            {
                type: 'Feature',
                geometry: {type: 'Point', coordinates: [149, -35]},
                properties: {type: 'Circle', point_type: 'Circle', radius: 10}
            },
            {
                type: 'Feature',
                geometry: {type: 'Polygon', coordinates: []},
                properties: {type: 'pid', pid: 'abc'}
            }
        ], [], true);
        expect(multi.extent.source).toBe('drawn');
        expect(multi.features.length).toBe(2);
        expect(multi.features[0].properties.type).toBe('Circle');
        expect(multi.features[0].properties.point_type).toBe('Circle');
        expect(multi.features[1].properties.type).toBe('pid');
        expect(multi.features[1].properties.pid).toBe('abc');
    });


});