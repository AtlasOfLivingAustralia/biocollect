describe('Test ActivitiesAndRecordsViewModel', function () {
    var mockElement, mapTab, selectionControl, legendControl, playerControl, infoPanelControl,
        emptyFn = function () {
        };
    beforeAll(function () {
        window.fcConfig = {
            searchProjectActivitiesUrl: '',
            getLayerNameURL: 'getLayerNameURL',
            heatmapURL: '',
            organisationName: '',
            projectIndexUrl: '',
            activityDeleteUrl: '',
            worksActivityViewUrl: '',
            worksActivityEditUrl: '',
            dateRangeURL: '',
            mapDisplays: [],
            mapLayersConfig: []
        };

        window.ALA = {
            Map: function () {
                return {
                    addControl: function (control) {
                        if (control instanceof L.Control.Player) {
                            playerControl = control;
                        } else if (control instanceof L.Control.HorizontalMultiInput) {
                            selectionControl = control;
                        } else if (control instanceof L.Control.LegendImage) {
                            legendControl = control;
                        } else if (control instanceof L.Control.InfoPanel) {
                            infoPanelControl = control;
                        }

                    },
                    addButton: emptyFn,
                    registerListener: emptyFn
                }
            }
        };
        if (typeof window.L === 'undefined') {
            window.L = {
                geoJson: function () {
                    var self = new function () {
                    };
                    new Emitter(self);
                    self.fire = self.emit;
                    return self;
                },
                Control: {}
            }
        }
        ;
        window.L.Control.Player = function () {
            var self = this;
            new Emitter(self);
            self.fire = self.emit;
            self.isPlayerActive = emptyFn;
            self.getCurrentDuration = function () {
                return {interval: [1, 2]}
            }
        };
        window.L.Control.HorizontalMultiInput = function () {
            var self = this;
            new Emitter(self);
            self.fire = self.emit;
            self.setSelectOptions = emptyFn;
            self.changeLabel = emptyFn;
            self.disableItem = emptyFn;
            self.setSize = emptyFn;
        };
        window.L.Control.LegendImage = function () {
            var self = this;
            self.on = emptyFn;
            self.clearLegend = emptyFn;
        };
        window.L.Control.InfoPanel = function () {
            var self = this;
            self.on = emptyFn;
        };

        mockElement = document.createElement('div');
        mockElement.id = 'tabDifferentViews';
        mapTab = document.createElement('a');
        mapTab.id = 'dataMapTab'
        mockElement.appendChild(mapTab);
        document.body.appendChild(mockElement);
    });

    it('should show the correct state of map', function () {
        window.fcConfig.mapDisplays = [{
            value: "Heatmap",
            key: "heatmap",
            showLoggedOut: true,
            showLoggedIn: true,
            showProjectMembers: true,
            isDefault: "heatmap"
        }];

        var vm = new ActivitiesAndRecordsViewModel({});
        $(mapTab).trigger('show', [{target: 'dataMapTab'}]);
        vm.createOrUpdateMap();
        expect(vm.getCurrentState()).toBe('heatmap');

        changeState('colourby', 'some-index');
        expect(vm.getCurrentState()).toBe('heatmap+index');

        changeState('colourby', '');
        expect(vm.getCurrentState()).toBe('heatmap');

        changeState('display', 'point_circle');
        expect(vm.getCurrentState()).toBe('point');

        changeState('display', 'polygon_sites');
        expect(vm.getCurrentState()).toBe('polygon');

        changeState('display', 'cluster');
        expect(vm.getCurrentState()).toBe('cluster');

    });

    it("should add parameters depending on state of map", function () {
        var params;
        window.fcConfig.mapDisplays = [{
            value: "Heatmap",
            key: "heatmap",
            showLoggedOut: true,
            showLoggedIn: true,
            showProjectMembers: true,
            isDefault: "heatmap"
        }];

        var vm = new ActivitiesAndRecordsViewModel({});
        $(mapTab).trigger('show', [{target: 'dataMapTab'}]);
        vm.createOrUpdateMap();

        params = vm.getParametersForState('point')
        expect(params.styles).toBe('point_circle');
        expect(params.env).toBe('size:5;opacity:0.1;');

        changeState('colourby', 'some-index');
        params = vm.getParametersForState('point+index');
        expect(params.styles).toBe('');
        expect(params.env).toBe('size:5;opacity:0.1;');
        expect(params.cql_filter).toBe('some-index IS NOT NULL');

        changeState('colourby', '');
        params = vm.getParametersForState('point+time')
        expect(params.styles).toBe('point_circle');
        expect(params.env).toBe('size:5;opacity:0.1;');
        expect(params.time).toBe('1/2');


        changeState('colourby', 'some-index');
        params = vm.getParametersForState('point+index+time');
        expect(params.styles).toBe('');
        expect(params.env).toBe('size:5;opacity:0.1;');
        expect(params.cql_filter).toBe('some-index IS NOT NULL');
        expect(params.time).toBe('1/2');
    });

    function changeState(control, value) {
        var data = {
            item: {
                id: ""
            },
            value: ""
        };

        switch (control) {
            case 'colourby':
                data.item.id = "colour-by-select";
                break;
            case 'display':
                data.item.id = "activity-display-style";
                break;
            case 'size':
                data.item.id = "size-slider";
                break;
        }

        data.value = value;
        selectionControl && selectionControl.fire('change', data);
    }
});