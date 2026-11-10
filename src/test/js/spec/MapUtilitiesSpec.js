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


});