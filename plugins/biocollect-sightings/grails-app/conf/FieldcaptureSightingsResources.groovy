/*
 * Copyright (C) 2014 Atlas of Living Australia
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
 */

modules = {
    pigeonhole {
        dependsOn 'jquery'
        resource url: 'css/pigeonhole.css', plugin: 'biocollect-sightings'
        resource url: 'js/application.js', plugin: 'biocollect-sightings'
    }

    'jquery-ui' {
        dependsOn 'jquery'

        resource url: '/vendor/jquery-ui/jquery-ui-1.11.2-no-autocomplete.js', plugin: 'biocollect-sightings'
        resource url: '/vendor/jquery-ui/themes/smoothness/jquery-ui.css', attrs:[media:'all'], plugin: 'biocollect-sightings'
    }

    submitSighting {
        dependsOn 'moment, leaflet, bootbox, identify'
        resource url: '/js/submitSighting.js', plugin: 'biocollect-sightings'
        resource url: '/js/initLeafletMap.js', plugin: 'biocollect-sightings'
    }

    identify {
        dependsOn 'jquery'
        resource url: '/js/identify.js', plugin: 'biocollect-sightings'
        resource url: '/css/identify.css', plugin: 'biocollect-sightings'
    }

    fileuploads {
        resource url: 'js/jquery.fileupload/jquery.ui.widget.js', plugin: 'biocollect-sightings'
        resource url: 'js/jquery.fileupload/load-image.all.min.js', plugin: 'biocollect-sightings'
        resource url: 'js/jquery.fileupload/jquery.iframe-transport.js', plugin: 'biocollect-sightings'
        resource url: 'js/jquery.fileupload/jquery.fileupload.js', plugin: 'biocollect-sightings'
        resource url: 'js/jquery.fileupload/jquery.fileupload-process.js', plugin: 'biocollect-sightings'
        resource url: 'js/jquery.fileupload/jquery.fileupload-image.js', plugin: 'biocollect-sightings'
        //resource url:'js/jquery.fileupload/jquery.fileupload-jquery-ui.js', plugin: 'biocollect-sightings'
    }

    imageBrowser {
        resource url: 'js/imageBrowser.js', plugin: 'biocollect-sightings'
    }

    qtip {
        dependsOn 'jquery'
        resource url: 'vendor/jquery.qtip/jquery.qtip.min.css', plugin: 'biocollect-sightings'
        resource url: 'vendor/jquery.qtip/jquery.qtip.min.js', plugin: 'biocollect-sightings'
    }

    purl {
        dependsOn 'jquery' // not strictly needed but syntax is nicer with jQuery
        resource url: '/vendor/purl/purl.js', plugin: 'biocollect-sightings'
        resource url: '/vendor/purl/purl.js', plugin: 'biocollect-sightings'
    }

    moment {
        resource url: 'js/moment.min.js', plugin: 'biocollect-sightings'
        resource url: 'js/moment-duration-format.js', plugin: 'biocollect-sightings'
    }


    bs2_datepicker {
        dependsOn 'bootstrap', 'moment'
        resource url: 'vendor/bootstrap2-datetimepicker-0.0.11/js/bootstrap-datetimepicker.min.js', plugin: 'biocollect-sightings'
        resource url: 'vendor/bootstrap2-datetimepicker-0.0.11/css/bootstrap-datetimepicker.custom.css', plugin: 'biocollect-sightings'
    }

    exif {
//        dependsOn 'jqueryMigrate'
        resource url: 'vendor/jquery.exif/jquery.exif.js', plugin: 'biocollect-sightings'
    }

    leaflet {
        defaultBundle 'leaflet'
        resource url: 'vendor/leaflet-0.7.3/leaflet.css', plugin: 'biocollect-sightings'
        resource url: 'vendor/leaflet-0.7.3/leaflet.js', plugin: 'biocollect-sightings'
    }

    udraggable {
        dependsOn 'jquery'
        resource url: 'vendor/jquery.event.ue/jquery.event.ue.js', plugin: 'biocollect-sightings'
        resource url: 'vendor/jquery.udraggable/jquery.udraggable.js', plugin: 'biocollect-sightings'
    }

    leafletLocate {
        dependsOn 'leaflet'
        resource url: 'vendor/leaflet-plugins/leaflet-locatecontrol-gh-pages/src/L.Control.Locate.js', plugin: 'biocollect-sightings'
        //resource url:'http://api.tiles.mapbox.com/mapbox.js/plugins/leaflet-locatecontrol/v0.24.0/L.Control.Locate.js', plugin:'fieldcapture-sightings'
        resource url: 'vendor/leaflet-plugins/leaflet-locatecontrol-gh-pages/src/L.Control.Locate.css', plugin: 'biocollect-sightings'
        //resource url:'http://api.tiles.mapbox.com/mapbox.js/plugins/leaflet-locatecontrol/v0.24.0/L.Control.Locate.css', plugin:'fieldcapture-sightings'
        resource url: 'vendor/leaflet-plugins/leaflet-locatecontrol-gh-pages/src/L.Control.Locate.ie.css', plugin: 'biocollect-sightings', wrapper: { s -> "<!--[if lt IE 9]>$s<![endif]-->" }
    }

    leafletGeoSearch {
        dependsOn 'leaflet'
        resource url: 'vendor/leaflet-plugins/L.GeoSearch/src/js/l.control.geosearch.js', plugin: 'biocollect-sightings'
        resource url: 'vendor/leaflet-plugins/L.GeoSearch/src/js/l.geosearch.provider.google.js', plugin: 'biocollect-sightings'
        resource url: 'vendor/leaflet-plugins/L.GeoSearch/src/js/l.geosearch.provider.openstreetmap.js', plugin: 'biocollect-sightings'
        resource url: 'vendor/leaflet-plugins/L.GeoSearch/src/css/l.geosearch.css', plugin: 'biocollect-sightings'
    }

    leafletGeocoding {
        dependsOn 'leaflet'
        resource url: 'vendor/leaflet-plugins/leaflet.geocoding/leaflet.geocoding.js', plugin: 'biocollect-sightings'
    }

    leafletGoogle {
        dependsOn 'leaflet'
//        resource url: 'https://maps.google.com/maps/api/js?v=3.2&sensor=false', plugin: 'biocollect-sightings', attrs: [type: "js"], disposition: 'head'
        resource url: 'vendor/leaflet-plugins/Google.js', plugin: 'biocollect-sightings'
    }

    inview {
        dependsOn 'jquery'
        resource url: 'vendor/jquery.inview/jquery.inview.js', plugin: 'biocollect-sightings'
    }

    bootbox {
        dependsOn 'bootstrap, jquery'
        resource url: 'vendor/bootbox/bootbox.min.js', plugin: 'biocollect-sightings'
    }

    /**
     * See https://github.com/jschr/bootstrap-modal
     */
    bootstrapModal {
        dependsOn 'bootstrap'
        resource url: 'vendor/bootstrap-modal/bootstrap-modal.css', plugin: 'biocollect-sightings'
    }
}