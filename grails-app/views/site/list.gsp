<!--
/*
 * Copyright (C) 2016 Atlas of Living Australia
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
 * Created by Temi on 29/01/16.
 */
-->
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>List of all sites</title>
    <meta name="layout" content="${hubConfig.skin}"/>
    <script>
        var fcConfig = {
            listSitesUrl: '${createLink(controller: 'site', action: 'search')}',
            viewSiteUrl: '${createLink(controller: 'site', action: 'index')}',
            poiGalleryUrl: "${createLink(controller: 'site', action: 'getImages')}",
            imagesForPoiUrl: "${createLink(controller: 'site', action: 'getPoiImages')}",
            imageLeafletViewer: '${createLink(controller: 'resource', action: 'imageviewer', absolute: true)}',
            spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
            featureService: "${createLink(controller: 'proxy', action: 'feature')}"
        }
    </script>
    <r:require modules="siteSearch"></r:require>
</head>

<body>
<div id="siteSearch" class="container-fluid">
    <div class="row-fluid">
        <div class="span3">
            <g:render template="/site/searchSite"></g:render>
            <g:render template="/site/facetView"></g:render>
        </div>

        <div class="span9">
            <g:render template="/site/resultStats"></g:render>
            <bc:koLoading>
                <div class="alert alert-block hide" data-bind="slideVisible: error() != ''">
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                    <h4>Error!</h4>
                    <span data-bind="text: error"></span>
                </div>
            </bc:koLoading>
            <div class="row-fluid">
                <div class="span12 margin-top-10">
                    <ul class="nav nav-tabs" id="myTab">
                        <li class="active"><a href="#list" data-toggle="tab">List</a></li>
                        <li><a href="#map" data-toggle="tab" id="mapTab">Map</a></li>
                        <li><a href="#images" data-toggle="tab">Images</a></li>
                    </ul>

                    <div class="tab-content">
                        <div class="tab-pane active" id="list">
                            <g:render template="/site/listView"></g:render>
                        </div>

                        <div class="tab-pane" id="map">
                            <g:render template="siteMap" model="${[id:'leafletMap']}"></g:render>
                        </div>

                        <!-- ko stopBinding: true -->
                        <div class="tab-pane" id="images">
                            <g:render template="poiGallery" ></g:render>
                        </div>
                        <!-- /ko -->

                    </div>
                </div>
            </div>
            <div class="row-fluid">
                <div class="span12 text-center margin-top-10">
                    <g:render template="/shared/pagination"></g:render>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
    $(document).ready(function () {
        var sites = new SitesListViewModel();
        var params = {
            loadOnInit: false
        }
        ko.applyBindings(sites, document.getElementById('siteSearch'));
        var gallery = initPoiGallery(params, 'images');
        sites.gallery.subscribe(function(){
            gallery.setParams({
                    id: sites.gallery().join(',')
            });
            gallery.loadGallery()
        });
        sites.sites.subscribe(plotGeoJSON);

        var map = initMap({},'leafletMap')

        $("body").on("shown.bs.tab", "#mapTab", function() {
            map.getMapImpl().invalidateSize();
            map.fitBounds()
        });

        function plotGeoJSON(){
            var siteList = sites.sites();
            map.clearMarkers();
            map.clearLayers();

            siteList.forEach(function (site) {
                var feature = site.extent
                if (feature.geometry) {
                    var lng = parseFloat(feature.geometry.centre[0]),
                        lat = parseFloat(feature.geometry.centre[1]),
                        geometry;

                    if(!feature.geometry){

                        feature.geometry.coordinates= [lng, lat];
                    }
                    geometry = Biocollect.MapUtilities.featureToValidGeoJson(feature.geometry);

                    var options = {
                        markerWithMouseOver: true,
                        markerLocation: [lat, lng],
                        popup: $('#popup'+site.siteId()).html()
                    };
                    console.log(geometry, options);
                    map.setGeoJSON(geometry, options);
                }
            });
        }
    })
</script>
</body>
</html>