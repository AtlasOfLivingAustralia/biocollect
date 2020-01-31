ko.components.register('map-config-selector', {
    viewModel: function (params) {
        var self = this,
            mapLayersConfig = params.mapLayersConfig,
            baseLayers = mapLayersConfig.baseLayers,
            overlays = mapLayersConfig.overlays,
            alaMapId = 'previewBaseLayer',
            alaMap;
        // models
        self.baseLayers = mapLayersConfig.baseLayers = ko.observableArray();
        self.overlays = mapLayersConfig.overlays = ko.observableArray();

        // helper observables
        self.selectedBaseLayer = ko.observable();
        self.selectedOverlay = ko.observable();
        self.allBaseLayers = ko.observableArray();
        self.allOverlays = ko.observableArray();
        self.codeChecked = ko.observable();
        self.showMap = ko.observable(false);
        self.showAdvancedFeatures = params.showAdvancedFeatures || false ;
        self.codeChecked.subscribe(validateIsSelected);

        // helper functions
        self.addBaseLayerClickHandler = function() {
            self.addBaseLayer(self.selectedBaseLayer());
        };

        self.addOverlayClickHandler = function() {
            self.addOverlay(self.selectedOverlay());
        };

        self.addBaseLayer = function (selected) {
            self.allBaseLayers.remove(selected);
            if (self.baseLayers.indexOf(selected) < 0 ) {
                self.baseLayers.push(selected);
            }
        };

        self.removeBaseLayer = function () {
            self.baseLayers.remove(this);
            if (self.allBaseLayers.indexOf(this) < 0) {
                self.allBaseLayers.push(this);
            }
        };

        self.addOverlay = function (selected) {
            self.allOverlays.remove(selected);
            if (self.overlays.indexOf(selected) < 0 ) {
                self.overlays.push(selected);
            }
        };

        self.removeOverlay = function () {
            self.overlays.remove(this);
            if (self.allOverlays.indexOf(this) < 0) {
                self.allOverlays.push(this);
            }
        };

        /**
         * Move an element in array above its current position.
         * @param koArray
         * @param element
         */
        self.moveDown = function( koArray, element ) {
            var array = koArray();
            var index = koArray.indexOf(element);
            var temp = array[index + 1];
            array[index] = temp;
            array[index + 1] = element;
            koArray(array);
        };

        /**
         * Move an element in array below its current position.
         * @param koArray
         * @param element
         */
        self.moveUp = function(koArray, element ) {
            var array = koArray();
            var index = koArray.indexOf(element);
            var temp = array[index - 1];
            array[index] = temp;
            array[index - 1] = element;
            koArray(array);
        };

        /**
         * Check if element is the last member of an array.
         * @param koArray
         * @param element
         * @returns {boolean}
         */
        self.canMoveDown = function(koArray, element){
            var array = koArray(),
                index = koArray.indexOf(element);
            if (array && (index < (array.length - 1))) {
                return true
            }

            return false
        };

        /**
         * Check if element is the first member of an array.
         * @param koArray
         * @param element
         * @returns {boolean}
         */
        self.canMoveUp = function(koArray, element){
            var array = koArray(),
                index = koArray.indexOf(element);
            if (array && (index > 0)) {
                return true
            }

            return false
        };


        /**
         * Create a map with the selected base layers and overlays.
         */
        self.previewLayer = function () {
            var previewObject = this;
            self.showMap(true);

            if(alaMap) {
                var mapImpl = alaMap.getMapImpl();
                mapImpl.eachLayer(function (layer) {
                    mapImpl.removeLayer(layer);
                });

                alaMap.destroy();
            }

            getOverlayStyle(fcConfig.layersStyle).then(function (data) {
                var overlays = ko.toJS(self.overlays);
                if ( data && overlays && overlays.length > 0) {
                    overlays.forEach(function (overlay) {
                        if(overlay.changeLayerColour) {
                            overlay.sld = data[overlay.alaId];
                        }
                    });
                }

                var baseLayerOverlayConfig = Biocollect.MapUtilities.getBaseLayerAndOverlayFromMapConfiguration({baseLayers: ko.toJS(self.baseLayers), overlays: ko.toJS(overlays)});
                alaMap = new ALA.Map(alaMapId, {
                    baseLayer: baseLayerOverlayConfig.baseLayer,
                    otherLayers: baseLayerOverlayConfig.otherLayers,
                    overlays: baseLayerOverlayConfig.overlays,
                    overlayLayersSelectedByDefault: baseLayerOverlayConfig.overlayLayersSelectedByDefault,
                    drawControl: false,
                    allowSearchLocationByAddress: false,
                    allowSearchByRegionByAddress: false,
                    useMyLocation: false,
                    scrollWheelZoom: true,
                    touchZoom: true,
                    dragging: true
                });
            });
        };

        /**
         * Get SLD style for selected overlays
         * @param url
         * @returns {*|jQuery|{getAllResponseHeaders, abort, setRequestHeader, readyState, getResponseHeader, overrideMimeType, statusCode}}
         */
        function getOverlayStyle (url) {
            var overlays = self.overlays();
            if(overlays && overlays.length > 0) {
                return $.ajax( url, {
                    method: 'POST',
                    data: JSON.stringify(ko.toJS(overlays)),
                    contentType: "application/json"
                });
            } else {
                return $.Deferred().resolve(undefined);
            }
        }

        function validateIsSelected(newValue) {
            self.baseLayers().forEach(function (layer) {
                if (layer.code() == newValue) {
                    layer.isSelected(true);
                } else {
                    layer.isSelected(false);
                }
            });
        }

        function load(params) {
            if(params) {
                params.allBaseLayers = params.allBaseLayers || [];
                params.allBaseLayers.forEach(function (value) {
                    self.allBaseLayers.push(new BaseMapViewModel(value));
                });

                params.baseLayers = params.baseLayers || [];
                params.baseLayers.forEach(function (value) {
                    var matchedObservable;
                    self.allBaseLayers().forEach(function (layer) {
                        if (layer.code() == value.code) {
                            matchedObservable = layer;
                            matchedObservable.displayText(value.displayText);
                            matchedObservable.isSelected(value.isSelected);
                        }
                    });

                    if (!matchedObservable) {
                        matchedObservable = new BaseMapViewModel(value);
                    }

                    if (matchedObservable.isSelected()) {
                        self.codeChecked(matchedObservable.code());
                    }

                    self.addBaseLayer(matchedObservable);
                });

                params.allOverlays = params.allOverlays || [];
                params.allOverlays.forEach(function (value) {
                    self.allOverlays.push(new OverlayViewModel(value));
                });

                params.overlays = params.overlays || [];
                params.overlays.forEach(function (value) {
                    var matchedObservable;
                    self.allOverlays().forEach(function (layer) {
                        if (layer.alaId == value.alaId) {
                            matchedObservable = layer;
                            matchedObservable.load(value);
                        }
                    });

                    if (!matchedObservable) {
                        matchedObservable = new OverlayViewModel(value);
                    }

                    self.addOverlay(matchedObservable);
                });
            }
        }

        function BaseMapViewModel(baseMapOptions) {
            this.code = ko.observable(baseMapOptions.code);
            this.displayText = ko.observable(baseMapOptions.displayText || "");
            this.isSelected = ko.observable(baseMapOptions.isSelected || false);
            this.removeBaseLayer = self.removeBaseLayer;

            this.moveDown = function (baseLayer) {
                self.moveDown(self.baseLayers, baseLayer);
            };

            this.moveUp = function (baseLayer) {
                self.moveUp(self.baseLayers, baseLayer);
            };

            this.canMoveDown = function (baseLayer) {
                return self.canMoveDown(self.baseLayers, baseLayer);
            };

            this.canMoveUp = function (baseLayer) {
                return self.canMoveUp(self.baseLayers, baseLayer);
            };

        }

        function OverlayViewModel(overlayMapOptions) {
            this.alaId = overlayMapOptions.alaId;
            this.alaName = overlayMapOptions.alaName;
            this.layerName = overlayMapOptions.layerName;
            this.title = ko.observable(overlayMapOptions.title || "");
            this.defaultSelected = ko.observable(overlayMapOptions.defaultSelected || false);
            this.boundaryColour = ko.observable(overlayMapOptions.boundaryColour || "#e66101");
            this.fillColour = ko.observable(overlayMapOptions.fillColour || "");
            this.textColour = ko.observable(overlayMapOptions.textColour || "");
            this.showPropertyName = ko.observable(overlayMapOptions.showPropertyName || false);
            this.userAccessRestriction = ko.observable(overlayMapOptions.userAccessRestriction || "anyUser");
            this.inLayerShapeList = ko.observable(overlayMapOptions.inLayerShapeList || false);
            this.opacity = ko.observable(overlayMapOptions.opacity || 1.0);
            this.changeLayerColour =  ko.observable(overlayMapOptions.changeLayerColour || false);
            this.style = overlayMapOptions.style;
            this.display = overlayMapOptions.display;

            this.moveDown = function (overlay) {
                self.moveDown(self.overlays, overlay);
            };

            this.moveUp = function (overlay) {
                self.moveUp(self.overlays, overlay);
            };

            this.canMoveDown = function (overlay) {
                return self.canMoveDown(self.overlays, overlay);
            };

            this.canMoveUp = function (overlay) {
                return self.canMoveUp(self.overlays, overlay);
            };
        }
        
        OverlayViewModel.prototype.load = function (overlayMapOptions){
            this.title(overlayMapOptions.title);
            this.defaultSelected(overlayMapOptions.defaultSelected);
            this.boundaryColour(overlayMapOptions.boundaryColour);
            this.fillColour(overlayMapOptions.fillColour);
            this.textColour(overlayMapOptions.textColour);
            this.showPropertyName(overlayMapOptions.showPropertyName);
            this.userAccessRestriction(overlayMapOptions.userAccessRestriction);
            this.inLayerShapeList(overlayMapOptions.inLayerShapeList);
            this.opacity(overlayMapOptions.opacity);
            this.changeLayerColour(overlayMapOptions.changeLayerColour);
        };

        OverlayViewModel.prototype.removeOverlay = self.removeOverlay;

        load({baseLayers: baseLayers, overlays: overlays, allBaseLayers: params.allBaseLayers, allOverlays: params.allOverlays});
    },
    template:componentService.getTemplate('map-config-selector')

});