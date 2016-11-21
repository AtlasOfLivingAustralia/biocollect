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
      siteObservable = container[name] = ko.observable(),
      nameObservable = container[name + "Name"] = ko.observable(),
      latObservable = container[name + "Latitude"] = ko.observable(),
      lonObservable = container[name + "Longitude"] = ko.observable(),
      latLonDisabledObservable = container[name + "LatLonDisabled"] = ko.observable(),
      featureObservable = container[name + "Feature"]  = ko.observable(),
      sitesObservable = container[name + "SitesArray"] = ko.observableArray(activityLevelData.pActivity.sites),
      loadingObservable = container[name + "Loading"] = ko.observable(false);
  ;

  // sitesObservable(activityLevelData.pActivity.sites);

  var googleLayer = new L.Google('ROADMAP');
  var otherLayers = {
    Roadmap: googleLayer,
    Hybrid: new L.Google('HYBRID'),
    Terrain: new L.Google('TERRAIN')
  };

  var mapOptions = {
    baseLayer: googleLayer,
    otherLayers: otherLayers,
    wmsFeatureUrl: proxyFeatureUrl + "?featureId=",
    wmsLayerUrl: spatialGeoserverUrl + "/wms/reflect?",
    draggableMarkers: !readonly,
    drawControl: !readonly,
    showReset: false,
    singleDraw: true,
    singleMarker: true,
    markerOrShapeNotBoth: markerOrShapeNotBoth,
    useMyLocation: !readonly,
    allowSearchLocationByAddress: !readonly,
    allowSearchRegionByAddress: false,
    zoomToObject: true,
    drawOptions: {
      polyline: false,
      polygon: true,
      circle: true,
      rectangle: true,
      edit: true
    }
  };

  var map = new ALA.Map(name + 'Map', mapOptions);

  container[name + "Map"] = map;

  var latSubscriber = latObservable.subscribe(updateMarkerPosition);
  var lngSubscriber = lonObservable.subscribe(updateMarkerPosition);
  var featureSubscriber = featureObservable.subscribe(updateMarkerPosition);

  function updateFieldsForMap() {
    // console.debug("updateFieldsFor${model.name}Map", arguments);
    latSubscriber.dispose();
    lngSubscriber.dispose();
    featureSubscriber.dispose();

    var markerLocation = null;
    var markerLocations = map.getMarkerLocations();
    if (markerLocations && markerLocations.length > 0) {
      markerLocation = markerLocations[0];
    }

    var geo = map.getGeoJSON();
    var feature;

    if (markerLocation) {
      latObservable(markerLocation.lat);
      lonObservable(markerLocation.lng);
      latLonDisabledObservable(false);
      if (geo && geo.features && geo.features.length > 0) {
        feature = geo.features[0];
        featureObservable(feature);
      }
    } else if (geo && geo.features && geo.features.length > 0) {
      console.log("Computing centroid");
      latLonDisabledObservable(true);
      feature = geo.features[0];
      featureObservable(geo.features[0]);
      var c = centroid(feature);
      lonObservable(c[0]);
      latObservable(c[1]);
    } else {
      latLonDisabledObservable(false);
      latObservable(null);
      lonObservable(null);
    }

    latSubscriber = latObservable.subscribe(updateMarkerPosition);
    lngSubscriber = lonObservable.subscribe(updateMarkerPosition);
    featureSubscriber = featureObservable.subscribe(updateMarkerPosition);
  }

  function centroid(feature) {
    var coords;
    if (feature.geometry.type == 'Polygon') {
      coords = feature.geometry.coordinates[0];
      var rcoords = _.clone(coords);
      rcoords.push(rcoords.shift());
      var zipped = _.chain(coords).zip(rcoords);
      var a = zipped.map(function(c) {
        return c[0][0]*c[1][1] - c[1][0]*c[0][1];
      });
      var sum = function(memo, v) { return memo + v; };
      var sixA = 6 * (a.reduce(sum, 0).value() / 2);
      var zippedAValue = zipped.zip(a.value());
      var cx = zippedAValue.map(function(c) {
          return ( c[0][0][0] + c[0][1][0] ) * c[1];
        }).reduce(sum, 0).value() / sixA;
      var cy = zippedAValue.map(function(c) {
          return ( c[0][0][1] + c[0][1][1] ) * c[1];
        }).reduce(sum, 0).value() / sixA;
      return [cx, cy];
    } else if (feature.geometry.type == 'Point') {
      coords = feature.geometry.coordinates;
      return [ coords[0], coords[1] ];
    } else {
      console.log(feature.geometry.type + ' is not a supported type for centroid()');
      return [0,0];
    }

  }

  function updateMapForSite(siteId) {
    map.resetMap();
    if (typeof siteId !== "undefined" && siteId) {
      var matchingSite = $.grep(sitesObservable(), function(site) { return siteId == site.siteId})[0];
      if (matchingSite) {
        map.clearBoundLimits();
        if (matchingSite.extent.geometry.pid) {
          map.setGeoJSON(Biocollect.MapUtilities.featureToValidGeoJson(matchingSite.extent.geometry));
        } else {
          map.setGeoJSON(siteExtentToValidGeoJSON(matchingSite.extent));
        }
      }
    }
  }

  function updateMarkerPosition() {
    if (latObservable() && lonObservable()) {
      map.addMarker(latObservable(), lonObservable());
    }
    if (featureObservable()) {
      map.setGeoJSON(featureObservable());
    }
  }

  viewModel.selectManyCombo = function(obj, event) {
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

  viewModel.removeTag = function(obj, event) {
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

  var siteSubscriber = siteObservable.subscribe(updateMapForSite);
// make sure the lat/lng fields are cleared when the marker is removed by cancelling a new marker
  map.registerListener("layerremove", updateFieldsForMap);
  map.registerListener("draw:created", function(e) {
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
  map.registerListener("draw:edited", function(e) {
    console.log("edited", e);
    saved = true;
  });
  // map.registerListener("draw:editstart", function() {
  //   console.log("editstart", arguments);
  // });
  map.registerListener("draw:editstop", function(e) {
    console.log("editstop", e);
    if (!siteObservable() && !saved) {
      console.log("clear geo json");
      map.clearLayers();
    } else if (saved) {
      completeDraw();
    } else {
      console.log("cancelled edit with selected site, not clearing geometry")
    }
    saved = false;
  });
  // map.registerListener("draw:drawstart", function() {
  //   console.log("draw start");
  // });
  // map.registerListener("draw:drawstop", function() {
  //   console.log("draw stop");
  // });
  map.subscribe(updateFieldsForMap);
  if (!edit && !readonly) {
    map.markMyLocation();
  }

  function completeDraw() {
    siteSubscriber.dispose();
    siteObservable(null);
    bootbox.prompt("Site Name (Cancel to edit)", function(newSiteName) {
      if (newSiteName) {
        loadingObservable(true);
        var extent = convertGeoJSONToExtent(map.getGeoJSON());
        console.log(extent);

        addSite({
          pActivityId: activityLevelData.pActivity.projectActivityId,
          site: {
            name: newSiteName,
            projects: [
              activityLevelData.pActivity.projectId
            ],
            extent: extent
          }
        }).then(function(data, textStatus, jqXHR) {
          // bootbox.alert("Success!");
          console.log(data);
          return reloadSiteData().then(function() { return data.id });
        })
          .done(function(id) {
            siteObservable(id);
          })
          .fail(failed)
          .always(function() {
            loadingObservable(false);
          });
      } else {
        enableEditMode();
      }
    });
    siteSubscriber = siteObservable.subscribe(updateMapForSite);
  }

  function enableEditMode() {
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

  function failed(jqXHR, textStatus, errorThrown) {
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
    return $.getJSON(listSitesUrl + '/' + activityLevelData.pActivity.projectActivityId).then(function(data, textStatus, jqXHR) {
      sitesObservable(data);
    });
  }

  loadingObservable.subscribe(function(value) {
    value ? map.startLoading() : map.finishLoading();
  });

  if (!readonly) {
    map.addButton("<span class='fa fa-undo reset-map' title='Reset map'></span>", function () {
      map.resetMap();
      if (activityLevelData.pActivity.sites.length == 1) {
        updateMapForSite(activityLevelData.pActivity.sites[0].siteId);
      }
    }, "bottomleft");
  }

  if (activityLevelData.pActivity.sites.length == 1) {
    container[name](activityLevelData.pActivity.sites[0].siteId);
  } else if (activityLevelData.projectSite && activityLevelData.projectSite.extent) {
    map.fitToBoundsOf(Biocollect.MapUtilities.featureToValidGeoJson(activityLevelData.projectSite.extent.geometry));
  }

  //return self;
}


