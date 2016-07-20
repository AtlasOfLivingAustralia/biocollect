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
    <g:if test="${myFavourites}">
        <title><g:message code="site.myFavouriteSites.heading"/></title>
    </g:if>
    <g:else>
        <title><g:message code="site.allSites.heading"/></title>
    </g:else>
    <meta name="layout" content="${hubConfig.skin}"/>
    <script>
        var fcConfig = {
            listSitesUrl: '${createLink(controller: 'site', action: 'elasticsearch')}',
            viewSiteUrl: '${createLink(controller: 'site', action: 'index')}',
            editSiteUrl: '${createLink(controller: 'site', action: 'edit')}',
            addStarSiteUrl: "${createLink(controller: 'site', action: 'ajaxAddToFavourites')}",
            removeStarSiteUrl: "${createLink(controller: 'site', action: 'ajaxRemoveFromFavourites')}",
            poiGalleryUrl: "${createLink(controller: 'site', action: 'getImages')}",
            imagesForPoiUrl: "${createLink(controller: 'site', action: 'getPoiImages')}",
            imageLeafletViewer: '${createLink(controller: 'resource', action: 'imageviewer', absolute: true)}',
            spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
            featureService: "${createLink(controller: 'proxy', action: 'feature')}",
            activityViewUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
            siteDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDelete')}",
            myFavourites: "${myFavourites}"
        }
    </script>
    <r:require modules="restoreTab,siteSearch"></r:require>
</head>

<body>
<div id="siteSearch" class="container-fluid">
    <g:if test="${myFavourites}">
        <div class="row-fluid">
            <div class="span6" id="heading">
                <h1 class="pull-left"><g:message code="site.myFavouriteSites.heading"/></h1>
            </div>
        </div>
    </g:if>

    <div class="row-fluid">
        <div class="span3 well">
            <bc:koLoading>
                <g:render template="/site/resultStats"></g:render>
                <g:render template="/site/facetView"></g:render>
            </bc:koLoading>
        </div>

        <div class="span9">
            <bc:koLoading>
                <g:render template="/site/searchSite"></g:render>
                <div class="alert alert-block hide well" data-bind="slideVisible: error() != ''">
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                    <span data-bind="text: error"></span>
                </div>
                <g:if test="${flash.errorMessage || flash.message}">
                    <div class="alert alert-error">
                        <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
                        ${flash.errorMessage?:flash.message}
                    </div>
                </g:if>
                <div class="row-fluid">
                    <div class="well">
                        <div class="span12 margin-top-10">
                            <ul class="nav nav-tabs" id="siteListResultTab">
                                <li><a href="#list" id="list-tab" data-toggle="tab">List</a></li>
                                <li><a href="#map" id="map-tab" data-toggle="tab">Map</a></li>
                                <li><a href="#images" id="images-tab" data-toggle="tab">Images</a></li>
                            </ul>

                            <div class="tab-content">
                                <div class="tab-pane" id="list">
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
                        <div class="row-fluid">
                            <div class="span12 text-center margin-top-10">
                                <g:render template="/shared/pagination"></g:render>
                            </div>
                        </div>
                    </div>
                </div>
            </bc:koLoading>
        </div>
    </div>
</div>
<script>
    var SITES_TAB_AMPLIFY_VAR = 'site-list-result-tab'
    $(document).ready(function () {
        RestoreTab('siteListResultTab','list-tab')

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

        $("body").on("shown.bs.tab", "#map-tab", function() {
            map.getMapImpl().invalidateSize();
            map.fitBounds()
        });

        function plotGeoJSON(){
            var siteList = sites.sites();
            map.clearMarkers();
            map.clearLayers();

            siteList.forEach(function (site) {
                var feature = site.extent
                if (feature && feature.source != 'none' && feature.geometry) {
                    var lng, lat, geometry, options;

                    if(feature.geometry.centre && feature.geometry.centre.length){
                        lng= parseFloat(feature.geometry.centre[0]);
                        lat = parseFloat(feature.geometry.centre[1]);
                        if(!feature.geometry.coordinates){
                            feature.geometry.coordinates = [lng, lat];
                        }

                        geometry = Biocollect.MapUtilities.featureToValidGeoJson(feature.geometry);
                        var options = {
                            markerWithMouseOver: true,
                            markerLocation: [lat, lng],
                            popup: $('#popup'+site.siteId()).html()
                        };
                        map.setGeoJSON(geometry, options);
                    }
                }
            });
        }
    })
</script>
</body>
</html>