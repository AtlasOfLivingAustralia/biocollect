describe('Test ProjectFinder', function () {
    var mockElement, mapTab, selectionControl, legendControl, playerControl, infoPanelControl, vm,
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
            mapLayersConfig: [],
            projectMapDisplays: [{
                value: "Heatmap",
                key: "heatmap",
                showLoggedOut: true,
                showLoggedIn: true,
                showProjectMembers: true,
                isDefault: "heatmap"
            }]
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
                    registerListener: emptyFn,
                    getMapImpl: function () {
                        return {
                            invalidateSize: emptyFn
                        }
                    }
                }
            }
        };

        if (typeof window.L === "undefined") {
            window.L = {}
        }

        window.L.geoJson = function () {
            var self = new function () {
            };
            new Emitter(self);
            self.fire = self.emit;
            return self;
        };

        if (typeof window.L.Control === 'undefined') {
            window.L.Control = {};
        }

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
            self.setContent = emptyFn;
        };
    });

    beforeEach(function () {
        mockElement = document.createElement('div');
        mockElement.id = 'project-finder-container';
        document.body.appendChild(mockElement);

        vm = new ProjectFinder({});
        vm.doMapSearch();
    });

    afterEach(function () {
        document.body.removeChild(mockElement);
    });

    it('should show the correct state of map', function () {
        expect(vm.getCurrentState()).toBe('heatmap');

        changeState('colourby', 'some-index');
        expect(vm.getCurrentState()).toBe('heatmap+index');

        changeState('colourby', '');
        expect(vm.getCurrentState()).toBe('heatmap');

        changeState('display', 'point_circle_project');
        expect(vm.getCurrentState()).toBe('point');

        changeState('display', 'polygon_sites_project');
        expect(vm.getCurrentState()).toBe('polygon');
    });

    it("should add parameters depending on state of map", function () {
        var params;
        params = vm.getParametersForState('point')
        expect(params.styles).toBe('point_circle_project');
        expect(params.env).toBe('size:5;opacity:0.1;');

        changeState('colourby', 'some-index');
        params = vm.getParametersForState('point+index');
        expect(params.styles).toBe(undefined);
        expect(params.env).toBe('size:5;opacity:0.1;');
        expect(params.cql_filter).toBe('some-index IS NOT NULL');
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