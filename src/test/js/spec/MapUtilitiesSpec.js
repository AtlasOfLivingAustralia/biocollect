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
    var originalALA;

    beforeAll(function () {
        originalALA = window.ALA;
        window.ALA = {MapConstants: {DRAW_TYPE: {
            POINT_TYPE: 'Point',
            CIRCLE_TYPE: 'Circle',
            POLYGON_TYPE: 'Polygon',
            LINE_TYPE: 'LineString'
        }}};
        window.fcConfig = {
            imageLocation: '/'
        }
    });
    afterAll(function () {
        if (originalALA === undefined) {
            delete window.ALA;
        } else {
            window.ALA = originalALA;
        }
        delete window.fcConfig;
    });

    it("calculates bounds for a circle before it is added to a map", function () {
        var centre = L.latLng(-35.2153316684663, 148.88671875);
        var radius = 7993.38666198557;
        var bounds = L.circle(centre, {radius: radius}).getBounds();

        expect(bounds.contains(centre)).toBeTrue();
        expect(Math.abs(centre.distanceTo(L.latLng(bounds.getNorth(), centre.lng)) - radius)).toBeLessThan(30);
        expect(Math.abs(centre.distanceTo(L.latLng(centre.lat, bounds.getEast())) - radius)).toBeLessThan(30);
    });

    it("preserves circle bounds after the circle is added to a map", function () {
        var element = document.createElement('div');
        element.style.width = '500px';
        element.style.height = '500px';
        document.body.appendChild(element);

        var centre = L.latLng(-35.2153316684663, 148.88671875);
        var radius = 7993.38666198557;
        var map = L.map(element).setView(centre, 10);
        var bounds = L.circle(centre, {radius: radius}).addTo(map).getBounds();

        expect(bounds.contains(centre)).toBeTrue();
        expect(Math.abs(centre.distanceTo(L.latLng(bounds.getNorth(), centre.lng)) - radius)).toBeLessThan(30);
        expect(Math.abs(centre.distanceTo(L.latLng(centre.lat, bounds.getEast())) - radius)).toBeLessThan(30);
        map.remove();
        element.remove();
    });

    it("renders a circular site as a circle even when it has a pid", function () {
        var map = jasmine.createSpyObj('map', ['addWmsLayer', 'setGeoJSON']);
        var feature = {type: 'Circle', coordinates: [148.88671875, -35.2153316684663], radius: 8000, pid: 9121748};

        Biocollect.MapUtilities.setSiteMapFeature(map, feature);

        expect(map.addWmsLayer).not.toHaveBeenCalled();
        expect(map.setGeoJSON).toHaveBeenCalledWith({
            type: 'Feature',
            geometry: {type: ALA.MapConstants.DRAW_TYPE.POINT_TYPE, coordinates: feature.coordinates},
            properties: {point_type: ALA.MapConstants.DRAW_TYPE.CIRCLE_TYPE, radius: feature.radius}
        });
    });

    it("renders a pid site using its WMS layer", function () {
        var map = jasmine.createSpyObj('map', ['addWmsLayer', 'setGeoJSON']);

        Biocollect.MapUtilities.setSiteMapFeature(map, {type: 'PID', pid: 'region-1'});

        expect(map.addWmsLayer).toHaveBeenCalledWith('region-1');
        expect(map.setGeoJSON).not.toHaveBeenCalled();

        Biocollect.MapUtilities.setSiteMapFeature(map, {pid: 'legacy-region'});
        expect(map.addWmsLayer).toHaveBeenCalledWith('legacy-region');

        Biocollect.MapUtilities.setSiteMapFeature(map, {type: 'Polygon', pid: 'polygon-region'});
        expect(map.addWmsLayer).toHaveBeenCalledWith('polygon-region');
    });

    it("preserves other GeoJSON geometries when rendering a site", function () {
        var map = jasmine.createSpyObj('map', ['addWmsLayer', 'setGeoJSON']);
        var coordinates = [[[[148, -35], [149, -35], [149, -36], [148, -35]]]];
        var wrapped = {type: 'FeatureCollection'};
        ALA.MapUtils = {wrapGeometryInGeoJSONFeatureCol: jasmine.createSpy().and.returnValue(wrapped)};

        Biocollect.MapUtilities.setSiteMapFeature(map, {type: 'MultiPolygon', coordinates: coordinates, name: 'site'});

        expect(ALA.MapUtils.wrapGeometryInGeoJSONFeatureCol).toHaveBeenCalledWith({type: 'MultiPolygon', coordinates: coordinates});
        expect(map.setGeoJSON).toHaveBeenCalledWith(wrapped);
        expect(map.addWmsLayer).not.toHaveBeenCalled();
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


});