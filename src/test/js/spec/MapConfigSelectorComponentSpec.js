describe("Map config component unit tests", function () {

    var vm = null;
    var mockElement = null;
    var facetFilterVM = null;
    beforeAll(function () {
        window.fcConfig = {
            allBaseLayers: [{
                'code': 'minimal',
                'displayText': 'Road map',
                'isSelected': true
            },
                {
                    'code': 'worldimagery',
                    'displayText': 'Satellite',
                    'isSelected': false
                }],
            allOverlays: [{
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
            }, {
                alaId: 'cl1059',
                alaName: 'drainage_divisions_level2',
                layerName: 'aust_river_basins',
                title: 'River Basins',
                defaultSelected: false,
                boundaryColour: '#005ce6',
                showPropertyName: false,
                fillColour: '#bef7cf',
                textColour: '#FFF',
                userAccessRestriction: 'anyUser',
                inLayerShapeList: true,
                opacity: 0.5,
                changeLayerColour: false,
                display: {
                    "cqlFilter": "",
                    "propertyName": 'Level2Name'
                },
                style: {},
                bounds: [],
                restrictions: {}
            }]
        };

        vm = {
            mapLayersConfig: {
                baseLayers: undefined,
                overlays: undefined
            }
        };

        mockElement = document.createElement('div');
        mockElement.id = 'mapConfigSelectorId';
        var mapConfigComponent = document.createElement('map-config-selector');
        mapConfigComponent.setAttribute('params', "allBaseLayers: fcConfig.allBaseLayers, allOverlays: fcConfig.allOverlays, mapLayersConfig: mapLayersConfig");
        mockElement.appendChild(mapConfigComponent);
        ko.applyBindings(vm, mockElement);
    });

    beforeEach(function () {
        removeLayer('.remove-base-layer');
        removeLayer('.remove-overlay');
    });

    it("adding a base layer and overlay should get added to observable", function () {
        addLayer('.add-base-layer');
        var baseLayers = vm.mapLayersConfig.baseLayers();
        expect(baseLayers.length).toEqual(1);

        addLayer('.add-overlay');
        var overlays = vm.mapLayersConfig.overlays();
        expect(overlays.length).toEqual(1);
    });

    it("remove button should delete selected base layer and overlay ", function () {
        addLayer('.add-base-layer');
        var baseLayers = vm.mapLayersConfig.baseLayers();
        expect(baseLayers.length).toEqual(1);
        removeLayer('.remove-base-layer');
        baseLayers = vm.mapLayersConfig.baseLayers();
        expect(baseLayers.length).toEqual(0);


        addLayer('.add-overlay');
        var overlays = vm.mapLayersConfig.overlays();
        expect(overlays.length).toEqual(1);
        removeLayer('.remove-overlay');
        overlays = vm.mapLayersConfig.overlays();
        expect(overlays.length).toEqual(0);
    });

    it("move up should work as expected", function () {
        addLayer('.add-base-layer');
        addLayer('.add-base-layer');

        var baseLayers = vm.mapLayersConfig.baseLayers(),
            first = baseLayers[0],
            second = baseLayers[1];
        moveUp(".move-up-base-layer:enabled");
        var swapped = vm.mapLayersConfig.baseLayers();
        expect(swapped[1]).toEqual(first);
        expect(swapped[0]).toEqual(second);

        addLayer('.add-overlays');
        addLayer('.add-overlays');
        var baseLayers = vm.mapLayersConfig.overlays(),
            first = baseLayers[0],
            second = baseLayers[1];
        moveUp(".move-up-overlays:enabled");
        var swapped = vm.mapLayersConfig.overlays();
        expect(ko.toJS(swapped[1])).toEqual(ko.toJS(first));
        expect(swapped[0]).toEqual(second);
    });

    it("move down should work as expected", function () {
        addLayer('.add-base-layer');
        addLayer('.add-base-layer');
        var baseLayers = vm.mapLayersConfig.baseLayers(),
            first = baseLayers[0],
            second = baseLayers[1];
        moveDown(".move-down-base-layer:enabled");
        var swapped = vm.mapLayersConfig.baseLayers();
        expect(swapped[1]).toEqual(first);
        expect(swapped[0]).toEqual(second);

        addLayer('.add-overlays');
        addLayer('.add-overlays');
        var baseLayers = vm.mapLayersConfig.overlays(),
            first = baseLayers[0],
            second = baseLayers[1];
        moveDown(".move-up-overlays:enabled");
        var swapped = vm.mapLayersConfig.overlays();
        expect(ko.toJS(swapped[1])).toEqual(ko.toJS(first));
        expect(swapped[0]).toEqual(second);
    });

    function addLayer(className) {
        $(mockElement).find(className).click();
    }

    function removeLayer(className) {
        $(mockElement).find(className).click();
    }

    function moveUp(selector) {
        $(mockElement).find(selector).click();
    }

    function moveDown(selector) {
        $(mockElement).find(selector).click();
    }

});