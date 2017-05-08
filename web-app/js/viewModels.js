/*
 * Helper functions for <md:jsViewModel> tag
 */

/**
 * Create KO observables for a given geolocation field on an Ala.Map and register various listeners to keep the two in sync.
 *
 * @param args The arguments object
 * @param args.viewModel The ViewModel to attach handlers for the UI to bind events to.
 * @param args.container The ViewModel that contains the data properties, addtional properties will be attached here
 * @param args.name The name of the model or something.
 * @param args.edit Whether this map is in edit mode
 * @param args.readonly Whether this map is readonly
 * @param args.markerOrShapeNotBoth Whether to allow both a marker and a feature.
 * @param args.proxyFeatureUrl The proxy feature URL
 * @param args.spatialGeoserverUrl The Spatial Portal geoserver URL
 * @param args.updateSiteUrl The URL to use to add or update a site.
 * @param args.listSitesUrl The URL to use to retrieve the list of sites for a project activity
 * @param args.uniqueNameUrl The URL to use to check whether a site name is unique within a project activity.
 * @param args.activityLevelData The activity level data
 */
function enmapify(args) {
    "use strict";


    var viewModel = args.viewModel,
        container = args.container,
        name = args.name,
        edit = args.edit,
        readonly = args.readonly,
        markerOrShapeNotBoth = args.markerOrShapeNotBoth,
        proxyFeatureUrl = args.proxyFeatureUrl,
        spatialGeoserverUrl = args.spatialGeoserverUrl,
        updateSiteUrl = args.updateSiteUrl,
        listSitesUrl = args.listSitesUrl,
        activityLevelData = args.activityLevelData,
        uniqueNameUrl = args.uniqueNameUrl + "/" + activityLevelData.pActivity.projectActivityId,
        hideSiteSelection = args.hideSiteSelection || false,
        hideMyLocation = args.hideMyLocation || false,
        siteIdObservable = container[name] = ko.observable(),
        nameObservable = container[name + "Name"] = ko.observable(),
        latObservable = container[name + "Latitude"] = ko.observable(),
        lonObservable = container[name + "Longitude"] = ko.observable(),
        previousLatObservable = container[name + "HiddenLatitude"] = ko.observable(),
        previousLonObservable = container[name + "HiddenLongitude"] = ko.observable(),
        latLonDisabledObservable = container[name + "LatLonDisabled"] = ko.observable(),
        centroidLatObservable = container[name + "CentroidLatitude"] = ko.observable(),
        centroidLonObservable = container[name + "CentroidLongitude"] = ko.observable(),
        sitesObservable = container[name + "SitesArray"] = ko.observableArray(activityLevelData.pActivity.sites),
        loadingObservable = container[name + "Loading"] = ko.observable(false)
        ;


    var mapOptions = {
        wmsFeatureUrl: proxyFeatureUrl + "?featureId=",
        wmsLayerUrl: spatialGeoserverUrl + "/wms/reflect?",
        draggableMarkers: !readonly,
        drawControl: !readonly,
        showReset: false,
        singleDraw: true,
        singleMarker: true,
        markerOrShapeNotBoth: markerOrShapeNotBoth,
        useMyLocation: !readonly && !hideMyLocation,
        allowSearchLocationByAddress: !readonly,
        allowSearchRegionByAddress: false,
        zoomToObject: true,
        markerZoomToMax: true,
        drawOptions:  activityLevelData.mobile || readonly || !activityLevelData.pActivity.allowAdditionalSurveySites ?
            {
                polyline: false,
                polygon: false,
                rectangle: false,
                circle: false,
                edit: false
            }
            :
            {
                polyline: false,
                polygon: true,
                circle: true,
                rectangle: true,
                edit: true
            }
    };

    // undefined/null, Google Maps or Default should enable Google Maps view
    if (activityLevelData.pActivity.baseLayersName !== 'Open Layers') {
        var googleLayer = new L.Google('ROADMAP',{maxZoom: 21, nativeMaxZoom: 21});
        var otherLayers = {
            Roadmap: googleLayer,
            Hybrid: new L.Google('HYBRID', {maxZoom: 21, nativeMaxZoom: 21}),
            Terrain: new L.Google('TERRAIN',{maxZoom: 21, nativeMaxZoom: 21})
        };

        mapOptions.baseLayer = googleLayer;
        mapOptions.otherLayers = otherLayers;
    }

    var map = new ALA.Map(name + 'Map', mapOptions);

    container[name + "Map"] = map;

    var latSubscriber = latObservable.subscribe(updateMarkerPosition);
    var lngSubscriber = lonObservable.subscribe(updateMarkerPosition);

    var siteIdSubscriber;

    function updateFieldsForMap(params) {
        latSubscriber.dispose();
        lngSubscriber.dispose();

        var markerLocation = null;
        var markerLocations = map.getMarkerLocations();
        if (markerLocations && markerLocations.length > 0) {
            markerLocation = markerLocations[0];
        }

        var geo = map.getGeoJSON();
        var feature;

        // When removing layers, events can also be fired, we want to avoid processing those
        // otherwise we could override the siteId
        var isRemoveEvent = params && params.type && params.type == "layerremove";
        if (markerLocation) {
            // Prevent sitesubscriber from been reset, when we are in the process of clearing the map
            // If the user dropped a pin or search a location then the select location should be deselected
            if(!isRemoveEvent) {

                siteSubscriber.dispose();

                console.log("Updating location fields to pin");
                siteIdObservable(null);
                latObservable(markerLocation.lat);
                lonObservable(markerLocation.lng);
                latLonDisabledObservable(false);
                centroidLatObservable(null);
                centroidLonObservable(null);

                $(document).trigger('markerupdated');

                siteSubscriber = siteIdObservable.subscribe(updateMapForSite);
            }

        } else if (geo && geo.features && geo.features.length > 0) {
            console.log("Updating location fields to site");
            latLonDisabledObservable(true);
            feature = geo.features[0];
            var c = centroid(feature);
            latObservable(null);
            lonObservable(null);
            centroidLonObservable(c[0]);
            centroidLatObservable(c[1]);
        } else {
            console.log("Clearing location fields");
            latLonDisabledObservable(false);
            latObservable(null);
            lonObservable(null);
            centroidLatObservable(null);
            centroidLonObservable(null);
        }

        latSubscriber = latObservable.subscribe(updateMarkerPosition);
        lngSubscriber = lonObservable.subscribe(updateMarkerPosition);
    }

    function centroid(feature) {
        var coords;
        if (feature.geometry.type == 'Polygon') {
            coords = feature.geometry.coordinates[0];
            var rcoords = _.clone(coords);
            rcoords.push(rcoords.shift());
            var zipped = _.chain(coords).zip(rcoords);
            var a = zipped.map(function (c) {
                return c[0][0] * c[1][1] - c[1][0] * c[0][1];
            });
            var sum = function (memo, v) {
                return memo + v;
            };
            var sixA = 6 * (a.reduce(sum, 0).value() / 2);
            var zippedAValue = zipped.zip(a.value());
            var cx = zippedAValue.map(function (c) {
                    return ( c[0][0][0] + c[0][1][0] ) * c[1];
                }).reduce(sum, 0).value() / sixA;
            var cy = zippedAValue.map(function (c) {
                    return ( c[0][0][1] + c[0][1][1] ) * c[1];
                }).reduce(sum, 0).value() / sixA;
            return [cx, cy];
        } else if (feature.geometry.type == 'Point') {
            coords = feature.geometry.coordinates;
            return [coords[0], coords[1]];
        } else {
            console.log(feature.geometry.type + ' is not a supported type for centroid()');
            return [0, 0];
        }

    }

    function updateMapForSite(siteId) {
        if (typeof siteId !== "undefined" && siteId) {
            if(lonObservable()) {
                previousLonObservable(lonObservable());
            }

            if(latObservable()) {
                previousLatObservable(latObservable());
            }



            var matchingSite = $.grep(sitesObservable(), function (site) {
                return siteId == site.siteId
            })[0];
            if (matchingSite) {
                console.log("Clearing map before displaying a new shape")
                map.clearBoundLimits();
                if (matchingSite.extent.geometry.pid) {
                    console.log("Displaying site with geometry.")
                    map.setGeoJSON(Biocollect.MapUtilities.featureToValidGeoJson(matchingSite.extent.geometry));
                } else {
                    console.log("Displaying site without geometry.")
                    map.setGeoJSON(siteExtentToValidGeoJSON(matchingSite.extent));
                }
            }
        } else { // Drop a pin, restore previous coordinates if any
            console.log("Displaying pin")
            if(previousLatObservable() && previousLonObservable()) {
                lonObservable(previousLonObservable());
                latObservable(previousLatObservable());
            } else {
                console.log("Resetting map because of non-previous lat long")
                map.resetMap()
            }
        }
    }

    function getProjectArea() {
        return $.grep(activityLevelData.pActivity.sites, function (item) {
            return item.name.indexOf('Project area for') == 0
        });
    }

    function createGeoJSON(geoJSON, layerOptions) {
        if (typeof geoJSON === 'string') {
            geoJSON = JSON.parse(geoJSON);
        }

        return L.geoJson(geoJSON, layerOptions);
    }

    function zoomToProjectArea() {
        console.log('Zooming to project area')
        if (activityLevelData.pActivity.sites) {
            var site = getProjectArea(),
                geojson;
            site = site && site[0];

            if (site) {
                if (site.extent.geometry.pid) {
                    geojson = createGeoJSON(Biocollect.MapUtilities.featureToValidGeoJson(site.extent.geometry));
                } else {
                    geojson = createGeoJSON(siteExtentToValidGeoJSON(site.extent));
                }

                var bounds = geojson.getBounds(),
                    mapImpl = map.getMapImpl();

                mapImpl.fitBounds(bounds);
            }
        }
    }

    function updateMarkerPosition() {
        if ((!siteIdObservable() || !args.markerOrShapeNotBoth) && latObservable() && lonObservable()) {
            console.log("Displaying new marker")
            map.addMarker(latObservable(), lonObservable());
            previousLatObservable(latObservable())
            previousLonObservable(lonObservable())
        }
    }

    viewModel.selectManyCombo = function (obj, event) {
        if (event.originalEvent) {
            var item = event.originalEvent.target.attributes["combolist"].value.split(".");
            var list = container[item[0]][item[1]]();
            var value = event.originalEvent.target.value;
            for (var k in list) {
                if (list[k] == value) return;
            }
            list.push(value);
            container[item[0]][item[1]](list);
        }
    };

    viewModel.removeTag = function (obj, event) {
        if (event.originalEvent) {
            event.originalEvent.preventDefault();

            var element = event.originalEvent.target;
            while (!element.attributes["combolist"]) element = element.parentElement;

            var combolist = element.attributes["combolist"];
            var value = element.firstChild.value;
            var item = combolist.value.split(".");
            var list = container[item[0]][item[1]]();
            var found = false;
            for (var k in list) {
                if (list[k] == value) {
                    list.splice(k, 1);
                    container[item[0]][item[1]](list);
                    element.remove();
                    return;
                }
            }
        }
    };

    var siteSubscriber = siteIdObservable.subscribe(updateMapForSite);
// make sure the lat/lng fields are cleared when the marker is removed by cancelling a new marker
    map.registerListener("layerremove", updateFieldsForMap);
    map.registerListener("draw:created", function (e) {
        console.log("draw created");
        var type = e.layerType,
            layer = e.layer;

        if (type === 'marker') {
            console.log("marker");
            return;
        }
        completeDraw();
    });
    var saved = false;
    map.registerListener("draw:edited", function (e) {
        console.log("edited", e);
        saved = true;
    });
    map.registerListener("draw:editstop", function (e) {
        console.log("editstop", e);
        if (!siteIdObservable() && !saved) {
            console.log("clear geo json");
            map.clearLayers();
        } else if (saved) {
            completeDraw();
        } else {
            console.log("cancelled edit with selected site, not clearing geometry")
        }
        saved = false;
    });
    map.subscribe(updateFieldsForMap);
    if (!edit && !readonly) {
        map.markMyLocation();
    }

    function completeDraw() {
        siteSubscriber.dispose();
        siteIdObservable(null);
        Biocollect.Modals.showModal({
            viewModel: new AddSiteViewModel(uniqueNameUrl)
        }).then(function (newSite) {
            loadingObservable(true);
            var extent = convertGeoJSONToExtent(map.getGeoJSON());
            blockUIWithMessage("Adding Site \"" + newSite.name + "\", please stand by...");
            return addSite({
                pActivityId: activityLevelData.pActivity.projectActivityId,
                site: {
                    name: newSite.name,
                    projects: [
                        activityLevelData.pActivity.projectId
                    ],
                    extent: extent
                }
            }).then(function (data, jqXHR, textStatus) {
                return reloadSiteData().then(function () {
                    return data.id
                })
            })
                .always(function () {
                    $.unblockUI();
                    loadingObservable(false);
                })
                .done(function (id) {
                    siteIdObservable(id);
                })
                .fail(saveSiteFailed);
        }).fail(enableEditMode);


        siteSubscriber = siteIdObservable.subscribe(updateMapForSite);
    }

    function enableEditMode() {
        console.log('Init edit mode')
        // this is gross hack around the map plugin not giving access to the Draw Control
        var event = document.createEvent('Event');
        event.initEvent('click', true, true);
        var cb = document.getElementsByClassName('leaflet-draw-edit-edit');
        !cb[0].dispatchEvent(event);
    }

    function addSite(site) {
        return $.ajax({
            method: 'POST',
            url: updateSiteUrl,
            data: JSON.stringify(site),
            contentType: 'application/json',
            dataType: 'json'
        });
    }

    function saveSiteFailed(jqXHR, textStatus, errorThrown) {
        bootbox.alert("An error occured while attempting to save your geometry. 😠");
        map.clearLayers();
    }

    function convertGeoJSONToExtent(gj) {
        var feature = gj.features[0];
        var geometryType = feature.geometry.type;
        var latLng = null;
        var extent = {
            geometry: {}
        };
        if (geometryType === ALA.MapConstants.DRAW_TYPE.POINT_TYPE) {
            extent.geometry.centre = latLng;
        }

        var geoType = determineExtentType(feature);
        extent.geometry.type = geoType;
        extent.source = geoType == "Point" ? "Point" : geoType == "pid" ? "pid" : "drawn";
        extent.geometry.radius = feature.properties.radius;

        // the feature created by a WMS layer will have the area in the 'area_km' property
        if (feature.properties.area_km) {
            extent.geometry.areaKmSq = feature.properties.area_km;
        } else {
            extent.geometry.areaKmSq = ALA.MapUtils.calculateAreaKmSq(feature);
        }
        extent.geometry.coordinates = _.clone(feature.geometry.coordinates);

        extent.geometry.bbox = feature.properties.bbox;
        extent.geometry.pid = feature.properties.pid;
        extent.geometry.name = feature.properties.name;
        extent.geometry.fid = feature.properties.fid;
        extent.geometry.layerName = feature.properties.fieldname;

        return extent;
    }

    function determineExtentType(geoJsonFeature) {
        var type = null;

        if (geoJsonFeature.geometry.type === ALA.MapConstants.DRAW_TYPE.POINT_TYPE) {
            if (geoJsonFeature.properties.radius) {
                type = ALA.MapConstants.DRAW_TYPE.CIRCLE_TYPE;
            } else {
                type = ALA.MapConstants.DRAW_TYPE.POINT_TYPE;
            }
        } else if (geoJsonFeature.geometry.type === ALA.MapConstants.DRAW_TYPE.POLYGON_TYPE) {
            if (geoJsonFeature.properties.pid) {
                type = "pid";
            } else {
                type = ALA.MapConstants.DRAW_TYPE.POLYGON_TYPE;
            }
        }

        return type;
    }

    function reloadSiteData() {
        return $.getJSON(listSitesUrl + '/' + activityLevelData.pActivity.projectActivityId).then(function (data, textStatus, jqXHR) {
            sitesObservable(data);
        });
    }

    loadingObservable.subscribe(function (value) {
        value ? map.startLoading() : map.finishLoading();
    });

    if (!readonly) {
        map.addButton("<span class='fa fa-undo reset-map' title='Reset map'></span>", function () {
            map.resetMap();
            if(!hideSiteSelection){
                if (activityLevelData.pActivity.sites.length == 1) {
                    updateMapForSite(activityLevelData.pActivity.sites[0].siteId);
                }
            }
        }, "bottomright");
    }

    if (args.zoomToProjectArea) {
        console.log('Zooming to project area original config')
        zoomToProjectArea();
    } else if (activityLevelData.pActivity.sites.length == 1) {
        console.log('One site for activity')
        container[name](activityLevelData.pActivity.sites[0].siteId);
    } else if (activityLevelData.projectSite && activityLevelData.projectSite.extent) {
        console.log('Will display project site')
        map.fitToBoundsOf(Biocollect.MapUtilities.featureToValidGeoJson(activityLevelData.projectSite.extent.geometry));
    }

}

var AddSiteViewModel = function (uniqueNameUrl) {
    var self = this;
    self.uniqueNameUrl = uniqueNameUrl;

    self.inflight = null;
    self.name = ko.observable();
    self.throttledName = ko.computed(this.name).extend({throttle: 400});
    self.nameStatus = ko.observable(AddSiteViewModel.NAME_STATUS.BLANK);

    self.name.subscribe(function (name) {
        self.precheckUniqueName(name);
    });
    self.throttledName.subscribe(function (name) {
        self.checkUniqueName(name);
    });
};

AddSiteViewModel.NAME_STATUS = {
    BLANK: 'blank'
    , CHECKING: 'checking'
    , CONFLICT: 'conflict'
    , ERROR: 'error'
    , OK: 'ok'
};

AddSiteViewModel.prototype.template = "AddSiteModal";
AddSiteViewModel.prototype.add = function () {
    if (this.nameStatus() === AddSiteViewModel.NAME_STATUS.OK) {
        var newSite = {
            name: this.name()
        };
        this.modal.close(newSite);
    }
};

AddSiteViewModel.prototype.cancel = function () {
    // Close the modal without passing any result data.
    this.modal.close();
};

AddSiteViewModel.prototype.precheckUniqueName = function (name) {
    if (this.inflight) this.inflight.abort();

    this.nameStatus(name === '' ? AddSiteViewModel.NAME_STATUS.BLANK : AddSiteViewModel.NAME_STATUS.CHECKING);
};

AddSiteViewModel.prototype.checkUniqueName = function (name) {
    var self = this;

    if (name === '') return;

    self.inflight = $.getJSON(self.uniqueNameUrl + "?name=" + encodeURIComponent(name))
        .done(function (data, textStatus, jqXHR) {
            self.nameStatus(AddSiteViewModel.NAME_STATUS.OK);
        }).fail(function (jqXHR, textStatus, errorThrown) {
            if (errorThrown === 'abort') {
                console.log('abort');
                return;
            }

            switch (jqXHR.status) {
                case 409:
                    self.nameStatus(AddSiteViewModel.NAME_STATUS.CONFLICT);
                    break;
                default:
                    self.nameStatus(AddSiteViewModel.NAME_STATUS.ERROR);
                    bootbox.alert("An error occured checking your name. 😠");
                    console.error("Error checking unique status", jqXHR, textStatus, errorThrown);
            }
        });
};

