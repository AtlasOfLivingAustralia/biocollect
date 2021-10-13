<%@ page import="grails.converters.JSON;" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<html>
<head>
    <g:set var="title" value="${myFavourites? message(code: "site.myFavouriteSites.heading") : message(code: "site.allSites.heading")}"/>
    <title>${title}</title>
%{--    <meta name="layout" content="${hubConfig.skin}"/>--}%
    <meta name="layout" content="bs4"/>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumb" content="${title}"/>
    <script>
        var fcConfig = {
            intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
            featuresService: "${createLink(controller: 'proxy', action: 'features')}",
            featureService: "${createLink(controller: 'proxy', action: 'feature')}",
            spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
            layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
            listSitesUrl: '${createLink(controller: 'site', action: 'elasticsearch')}',
            viewSiteUrl: '${createLink(controller: 'site', action: 'index')}',
            editSiteUrl: '${createLink(controller: 'site', action: 'edit')}',
            addStarSiteUrl: "${createLink(controller: 'site', action: 'ajaxAddToFavourites')}",
            removeStarSiteUrl: "${createLink(controller: 'site', action: 'ajaxRemoveFromFavourites')}",
            poiGalleryUrl: "${createLink(controller: 'site', action: 'getImages')}",
            imagesForPoiUrl: "${createLink(controller: 'site', action: 'getPoiImages')}",
            imageLeafletViewer: '${createLink(controller: 'resource', action: 'imageviewer', absolute: true)}',
            activityViewUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
            siteDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDelete')}",
            <g:applyCodec encodeAs="none">
                mapLayersConfig: ${mapService.getMapLayersConfig(project, pActivity) as JSON},
            </g:applyCodec>
            myFavourites: "${myFavourites}"
        }
    </script>
    <asset:stylesheet src="sites-manifest.css"/>
    <asset:stylesheet src="leaflet-manifest.css"/>
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="leaflet-manifest.js"/>
    <asset:javascript src="sites-manifest.js"/>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
</head>

<body>
<div id="projectData">
    <div id="siteSearch" class="container">
        <div class="my-4 my-md-5">
            <div class="container">
                <bc:koLoading>
                <div class="alert alert-info show" data-bind="slideVisible: error() != ''">
                    <!-- ko text: error --> <!-- /ko -->
                </div>

                <g:if test="${flash.errorMessage || flash.message}">
                    <div class="alert alert-info alert-dismissable">
                        ${flash.errorMessage ?: flash.message}
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </g:if>

                <g:if test="${myFavourites}">
                    <div class="row">
                        <div class="col-12" id="heading">
                            <h1><g:message code="site.myFavouriteSites.heading"/></h1>
                        </div>
                    </div>
                </g:if>

                <div id="sortBar" class="row d-flex">
                    <div class="col col-md-4 mb-3 order-1 order-md-0 pr-1">
                        <button
                                data-toggle="collapse"
                                data-target="#filters"
                                aria-expanded="false"
                                aria-controls="filters"
                                class="btn btn-dark"
                                title="Filter Data">
                            <i class="fas fa-filter"></i> Filter Data
                        </button>
                    </div>
                    <div class="col col-sm-6 col-md-4 mb-3 text-right text-md-center order-2 order-md-1 pl-1">
                        <div class="btn-group nav nav-tabs" role="group" aria-label="Catalogue Display Options">
                            <a type="button" class="btn btn-outline-dark active" id="list-tab" data-toggle="tab" title="View as Grid" href="#list" role="tab" aria-controls="View as Grid" aria-selected="true"><i
                                    class="fas fa-th-large"></i></a>
                            <a type="button" class="btn btn-outline-dark" id="map-tab" data-toggle="tab" title="View as Map" href="#map" role="tab" aria-controls="View as Map"><i
                                    class="far fa-map"></i></a>
                            <a type="button" class="btn btn-outline-dark" id="images-tab" data-toggle="tab" title="View as Images" href="#images" role="tab" aria-controls="View as Images"><i
                                    class="far fa-images"></i></a>
                        </div>
                    </div>
                    <div class="col-12 col-md-4 text-center text-md-right order-0 order-md-2">
                        <g:render template="/site/searchSite"></g:render>
                    </div>
                </div>

                <div class="filter-bar d-flex align-items-center">
                    <h4><g:message code="label.applied.filters"/>: </h4>
                    <!-- ko foreach: selectedFacets -->
                    <span class="filter-item" data-bind="attr:{title:facet.metadata.displayName + ' : ' + displayName()}">
                        <!-- ko text: facet.metadata.displayName + ' : ' + displayName() --><!-- /ko -->
                        <button class="remove" data-remove data-bind="click: $root.removeFacetTerm">
                            <i class="far fa-times-circle"></i>
                        </button>
                    </span>
                    <!-- /ko -->
                    <button class="btn btn-sm btn-dark clear-filters"  data-bind="click: removeAllSelectedFacets" type="button"
                            aria-label="Clear all filters">
                        <i class="far fa-times-circle"></i> Clear All
                    </button>
                </div>

                <div class="records-found">
                    <div class="row d-flex align-items-center justify-content-between">
                        <div class="order-0 col-12 col-xl-auto flex-shrink-1">
                            <h4 data-bind="visible: sitesLoaded">Found <!-- ko text: pagination.totalResults --> <!-- /ko --> sites</h4>
                            <span data-bind="visible: !sitesLoaded()"><span class="fa fa-spin fa-spinner"></span>&nbsp;Sites Loading...</span>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-12">
                        <div class="tab-content mt-3">
                            <div class="tab-pane show active" id="list">
                                <g:render template="/site/listView"></g:render>
                            </div>

                            <div class="tab-pane" id="map">
                                <g:render template="siteMap" model="${[id: 'leafletMap']}"></g:render>
                            </div>

                            <!-- ko stopBinding: true -->
                            <div class="tab-pane" id="images">
                                <g:render template="poiGallery"></g:render>
                            </div>
                            <!-- /ko -->

                        </div>

                        <g:render template="/shared/pagination" model="${[bs: 4]}"></g:render>
                    </div>
                </div>
                </bc:koLoading>
            </div>
            <div class="collapse" id="filters">
                <button
                        class="close"
                        data-toggle="collapse"
                        data-target="#filters"
                        title="Close Filters"
                        aria-expanded="false"
                        aria-controls="filters">
                    <i class="far fa-times-circle"></i>
                </button>
                <div class="filter-group">
                    <bc:koLoading>
                        <g:render template="/site/resultStats"></g:render>
                        <g:render template="/site/facetView"></g:render>
                    </bc:koLoading>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
    var SITES_TAB_AMPLIFY_VAR = 'site-list-result-tab'
    $(document).ready(function () {
        RestoreTab('siteListResultTab', 'list-tab')

        var sites = new SitesListViewModel();
        var params = {
            loadOnInit: false
        }
        ko.applyBindings(sites, document.getElementById('siteSearch'));
        var gallery = initPoiGallery(params, 'images');
        sites.gallery.subscribe(function () {
            gallery.setParams({
                id: sites.gallery().join(',')
            });
            gallery.loadGallery()
        });
        sites.sites.subscribe(plotGeoJSON);

        var map = initMap({}, 'leafletMap')

        $("body").on("shown.bs.tab", "#map-tab", function () {
            map.getMapImpl().invalidateSize();
            map.fitBounds()
        });

        function plotGeoJSON() {
            var siteList = sites.sites();
            map.clearMarkers();
            map.clearLayers();

            siteList.forEach(function (site) {
                var feature = site.extent
                if (feature && feature.source != 'none' && feature.geometry) {
                    var lng, lat, geometry, options;
                    try {

                        if (feature.geometry.centre && feature.geometry.centre.length) {
                            lng = parseFloat(feature.geometry.centre[0]);
                            lat = parseFloat(feature.geometry.centre[1]);
                            if (!feature.geometry.coordinates ) {
                                feature.geometry.coordinates = [lng, lat];
                                if (feature.geometry.aream2 > 0){
                                    //ONLY apply on site list which show a marker instead of polygon
                                    //Change from Polygon to Point for geojson validation
                                    feature.geometry.type = 'Point'
                                }
                            }

                            geometry = Biocollect.MapUtilities.featureToValidGeoJson(feature.geometry);
                            var options = {
                                markerWithMouseOver: true,
                                markerLocation: [lat, lng],
                                popup: $('#popup' + site.siteId()).html()
                            };
                            map.setGeoJSON(geometry, options);
                        }
                    }catch(exception){
                        console.log("Site:"+site.siteId() +" reports exception: " + exception)
                    }
                }
            });
        }
    })
</script>
</body>
</html>