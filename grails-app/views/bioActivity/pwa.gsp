<html>
<head>
    <meta name="layout" content="pwa" />
    <asset:stylesheet src="pwa-manifest.css"/>
    <asset:javascript src="pwa-manifest.js"/>
    <asset:script type="text/javascript">
        window.addEventListener('load', function () {
            if('serviceWorker' in navigator) {
                navigator.serviceWorker.register("/sw.js", {scope: "/pwa", updateViaCache: 'none'})
                    .then(function (registration) {
                        console.log("Registration successful " + registration.scope);
                    })
                    .catch(function (error) {
                        console.log("Service worker failed " + error);
                    });

                navigator.serviceWorker.onerror = function (error) {
                    console.log("Service worker error " + error.message);
                    console.log(JSON.stringify(error));
                };
            }

        });
    </asset:script>
    <asset:script type="text/javascript">
        var params = getParams(), initialized = false;
        var fcConfig = {
                createActivityUrl: "/pwa/bioActivity/edit/" + params.projectActivityId + "?cache=true",
                indexActivityUrl: "/pwa/bioActivity/index/" + params.projectActivityId+ "?cache=true",
                baseMapUrl: "${grailsApplication.config.getProperty("pwa.baseMapUrl")}",
                fetchSpeciesUrl: "${createLink(controller: 'search', action: 'searchSpecies')}",
                metadataURL: "/ws/projectActivity/activity",
                siteUrl: '${createLink(controller: 'site', action: 'index' )}',
                offlineListUrl: '${createLink(uri: "/pwa/offlineList", params: [cache: true] )}',
                totalUrl: '${createLink(controller: 'species', action: 'totalSpecies' )}',
                downloadSpeciesUrl: '${createLink(controller: 'species', action: 'speciesDownload' )}',
                originUrl: "${grailsApplication.config.getProperty("server.serverURL")}",
                bulkUpload: true,
                pwaAppUrl: "${grailsApplication.config.getProperty('pwa.appUrl')}",
                maxAreaInKm: ${grailsApplication.config.getProperty("pwa.maxAreaInKm")},
                isCaching: ${params.getBoolean('cache', false)},
                enableOffline: true
            };

       const crs = L.CRS.EPSG3857,
            tileSize = ${grailsApplication.config.getProperty("pwa.tileSize", Integer, 512)},
            minNumberOfTilesPerZoom = 25,
            maxArea = fcConfig.maxAreaInKm * 1000 * 1000, // 25 sq km
            maxTilesPerAxis = 5,
            cacheName = 'v3';


        function getParams() {
            var searchParams = new URL(window.location.href).searchParams;
            var params = {};
            searchParams.forEach(function(value, key) {
                params[key] = value;
            });

            return params;
        };

        function startInitialising() {
            if(navigator.serviceWorker.controller) {
                initialise();
            } else {
                navigator.serviceWorker.addEventListener('controllerchange', initialise);
            }
        };

        function initialise() {

            !initialized && entities.getCredentials().then(function (){
                        var vm = new OfflineViewModel({
                            projectActivityId: params.projectActivityId,
                            mapId: 'map',
                            baseMapUrl: fcConfig.baseMapUrl,
                            totalUrl: fcConfig.totalUrl,
                            downloadSpeciesUrl: fcConfig.downloadSpeciesUrl,
                            baseMapOptions: {
                                attribution: '<a target="_blank" rel="noopener noreferrer" href="https://www.arcgis.com/home/item.html?id=10df2279f9684e4a9f6a7f08febac2a9">Tiles from Esri</a> &mdash; Sources: Esri, DigitalGlobe, Earthstar Geographics, CNES/Airbus DS, GeoEye, USDA FSA, USGS, Aerogrid, IGN, IGP, and the GIS User Community',
                                maxZoom: 20
                            }
                        });

                        ko.applyBindings(vm);
                        initialized = true;
            });
        };

        document.addEventListener("credential-saved", startInitialising);
        document.addEventListener("credential-failed", function () {
            alert("Error occurred while saving credentials. Please close modal and try again.");
        });

        window.addEventListener('load', function (){
            setTimeout(startInitialising, 2000);
        });
    </asset:script>
</head>
<body>
<div class="container" id="download-metadata">
    <h1><g:message code="pwa.offline.checklist"/> </h1>
    <p class="lead">
        <g:message code="pwa.offline.checklist.intro"/>
    </p>
    <div class="list-group">
        <a href="#" class="list-group-item list-group-item-action" data-bind="css: {active: metadataStatus() == 'downloading', 'list-group-item-danger': metadataStatus() == 'error', 'list-group-item-success': metadataStatus() == 'downloaded'}">
            <div class="d-flex w-100 justify-content-between">
                <h5 class="mb-1"><g:message code="pwa.metadata.download"/></h5>
                <small>
                    <!-- ko template: {name: 'status-icons', data: metadataStatus} --><!-- /ko -->
                </small>
            </div>
            <p class="mb-1">
                <!-- ko if: metadataStatus() != 'error' -->
                <g:message code="pwa.metadata.download.intro"/>
                <!-- /ko -->
                <!-- ko if: metadataStatus() == 'error' -->
                <g:message code="pwa.metadata.download.error"/>
                <!-- /ko -->
            </p>
        </a>
        <a href="#" class="list-group-item list-group-item-action" data-bind="css: {active: formStatus() == 'downloading', 'list-group-item-danger': formStatus() == 'error', 'list-group-item-success': formStatus() == 'downloaded'}">
            <div class="d-flex w-100 justify-content-between">
                <h5 class="mb-1"><g:message code="pwa.form.download"/></h5>
                <small>
                    <!-- ko template: {name: 'status-icons', data: formStatus} --><!-- /ko -->
                </small>
            </div>
            <p class="mb-1">
                <!-- ko if: formStatus() != 'error' -->
                <g:message code="pwa.form.download.progress" />
                <!-- /ko -->
                <!-- ko if: formStatus() == 'error' -->
                <g:message code="pwa.form.download.error"/>
                <!-- /ko -->
            </p>
            <div>
                <div class="progress">
                    <div class="progress-bar progress-bar-striped bg-success progress-bar-animated" role="progressbar" aria-valuemin="0" aria-valuemax="100" data-bind="style: {width: percentageFormDownloaded() + '%'}, text: percentageFormDownloaded() + '%'"></div>
                </div>
            </div>
        </a>
        <a href="#" class="list-group-item list-group-item-action" data-bind="css: {active: speciesStatus() == 'downloading', 'list-group-item-danger': speciesStatus() == 'error', 'list-group-item-success': speciesStatus() == 'downloaded'}">
            <div class="d-flex w-100 justify-content-between">
                <h5 class="mb-1"><g:message code="pwa.species.download"/></h5>
                <small class="text-muted">
                    <!-- ko template: {name: 'status-icons', data: speciesStatus} --><!-- /ko -->
                </small>
            </div>
            <p class="mb-1">
                <!-- ko if: speciesStatus() != 'error' -->
                <g:message code="pwa.species.download.intro" />
                <!-- /ko -->
                <!-- ko if: speciesStatus() == 'error' -->
                <g:message code="pwa.species.download.error" />
                <!-- /ko -->
            </p>
            <div class="text-muted">
                <div class="progress">
                    <div class="progress-bar progress-bar-striped bg-success progress-bar-animated" role="progressbar" aria-valuemin="0" aria-valuemax="100" data-bind="style: {width: speciesDownloadPercentageComplete() + '%'}, text: speciesDownloadPercentageComplete() + '%'"></div>
                </div>
            </div>
        </a>
        <a href="#" class="list-group-item list-group-item-action list-group-item-success" data-bind="css: {active: sitesStatus() == 'downloading', 'list-group-item-danger': sitesStatus() == 'error', 'list-group-item-success': sitesStatus() == 'downloaded'}">
            <div class="d-flex w-100 justify-content-between">
                <h5 class="mb-1"><g:message code="pwa.sites.cache.title"/></h5>
                <small class="text-muted">
                    <!-- ko template: {name: 'status-icons', data: sitesStatus} --><!-- /ko -->
                </small>
            </div>
            <p class="mb-1">
                <!-- ko if: sitesStatus() != 'error' -->
                <g:message code="pwa.sites.download.intro" />
                <!-- /ko -->
                <!-- ko if: sitesStatus() == 'error' -->
                <g:message code="pwa.sites.download.error" />
                <!-- /ko -->
            </p>
            <div>
                <div class="progress">
                    <div class="progress-bar progress-bar-striped bg-success progress-bar-animated" role="progressbar" aria-valuemin="0" aria-valuemax="100" data-bind="style: {width: percentageSitesDownloaded() + '%'}, text: percentageSitesDownloaded() + '%'"></div>
                </div>
            </div>
        </a>
        <a href="#" class="list-group-item list-group-item-action list-group-item-success" data-bind="css: {active: mapStatus() == 'downloading', 'list-group-item-danger': mapStatus() == 'error', 'list-group-item-success': mapStatus() == 'downloaded'}">
            <div class="d-flex w-100 justify-content-between">
                <h5 class="mb-1"><g:message code="pwa.map.cache.title"/></h5>
                <small class="text-muted">
                    <!-- ko template: {name: 'status-icons', data: mapStatus} --><!-- /ko -->
                </small>
            </div>
            <p class="mb-1">
                <!-- ko if: mapStatus() != 'error' -->
                <g:message code="pwa.map.download.intro" />
                <!-- /ko -->
                <!-- ko if: mapStatus() == 'error' -->
                <g:message code="pwa.map.download.error" /> <button class="btn btn-sm btn-dark" data-bind="click: scrollToMapSection"><i class="fas fa-level-down-alt"></i> <g:message code="pwa.map.download.href" /> </button>
                <!-- /ko -->
            </p>
        </a>
    </div>


    <h1 class="mt-5"><g:message code="pwa.offline.options"/></h1>
    <h3 class="mt-3"><g:message code="pwa.species.download"/></h3>
    <div class="row">
        <div class="col-12">
            <form>
                <div class="form-group row">
                    <label class="col-sm-4 col-form-label"><g:message code="pwa.species.download.offline"/></label>
                    <div class="col-sm-8">
                        <button type="submit" class="btn btn-primary" data-bind="click: clickSpeciesDownload"><i class="fas fa-redo"></i> <g:message code="pwa.species.refresh"/></button>
                    </div>
                </div>
            </form>
            <div class="row" data-bind="slideVisible: showSpeciesProgressBar">
                <div class="col-12">
                    <h6><g:message code="pwa.map.download.species.progress"/> </h6>
                    <div class="progress">
                        <div class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar" aria-valuemin="0" aria-valuemax="100" data-bind="style: {width: speciesDownloadPercentageComplete() + '%'}, text: speciesDownloadPercentageComplete() + '%'"></div>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <h3 id="mapSection" class="mt-3"><g:message code="pwa.map.cache.title"/></h3>
    <div class="row">
        <div class="col-12 col-md-6">
            <!-- ko stopBinding: true -->
            <m:map id="map" width="100%"/>
            <!-- /ko -->
        </div>
        <div class="col-12 col-md-6">
            <div class="alert alert-info" role="alert">
                <g:message code="pwa.map.download.help" args="${[grailsApplication.config.getProperty("pwa.maxAreaInKm")]}" />
            </div>
            <form>
                <div class="form-group">
                    <label for="map-area"><g:message code="pwa.map.area"/></label>
                    <input type="text" readonly class="form-control" id="map-area" aria-describedby="map-area-help" data-bind="value: areaInKmOfBounds, css: {'is-invalid': !isBoundsWithinMaxArea(), 'is-valid': isBoundsWithinMaxArea}">
                    <small id="map-area-help" class="form-text text-muted"><g:message code="pwa.map.area.help" args="${[grailsApplication.config.getProperty("pwa.maxAreaInKm")]}"/></small>
                </div>
                <div class="form-group was-validated">
                    <label for="map-name"><g:message code="pwa.map.name"/> <span class="req-field"></span></label>
                    <input type="text" class="form-control" id="map-name" required aria-describedby="map-name-help" data-bind="value: name">
                    <small id="map-name-help" class="form-text text-muted"><g:message code="pwa.map.name.help"/></small>
                </div>
                <button type="submit" class="btn btn-primary" data-bind="enable: canDownload, click: clickDownload">Download map</button>
            </form>
            <div class="row">
                <div class="col-12">
                    <h6><g:message code="pwa.map.download"/> </h6>
                    <div class="progress">
                        <div class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar" aria-valuemin="0" aria-valuemax="100" data-bind="style: {width: downloadPercentageComplete() + '%'}, text: downloadPercentageComplete() + '%'"></div>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <h3 class="mt-3"><g:message code="pwa.map.downloaded.regions"/></h3>
    <div class="row">
        <div class="col-12">
            <table class="table">
                <thead>
                    <tr>
                        <th>
                            <g:message code="pwa.map.downloaded.regions.serial"/>
                        </th>
                        <th>
                            <g:message code="pwa.map.downloaded.regions.name"/>
                        </th>
                        <th>
                            <g:message code="pwa.map.downloaded.regions.actions"/>
                        </th>
                    </tr>
                </thead>

                <tbody>
                    <!-- ko foreach: offlineMaps -->
                    <tr>
                        <td data-bind="text: $index() + 1"></td>
                        <td data-bind="text: name"></td>
                        <td>
                            <button class="btn btn-primary" data-bind="click: $parent.preview"><g:message code="pwa.map.downloaded.regions.preview" /></button>
                            <button class="btn btn-danger" data-bind="click: $parent.removeMe"><g:message code="pwa.map.downloaded.regions.delete" /></button>
                        </td>
                    </tr>
                    <!-- /ko -->
                    <tr data-bind="if: offlineMaps().length == 0">
                        <td colspan="3">
                            <g:message code="pwa.offline.no.maps" />
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <!-- ko stopBinding: true -->
    <iframe id="form-content" style="opacity: 0" width="100%" height="25%"></iframe>
    <!-- /ko -->
</div>
<script id="status-icons" type="text/html">
    <!-- ko if: $data == 'waiting' -->
    <i class="far fa-clock fa-lg"></i>
    <!-- /ko -->
    <!-- ko if: $data == 'downloaded' -->
    <i class="far fa-check-square fa-lg"></i>
    <!-- /ko -->
    <!-- ko if: $data == 'downloading' -->
    <i class="fas fa-spinner fa-pulse fa-lg"></i>
    <!-- /ko -->
    <!-- ko if: $data == 'error' -->
    <i class="fas fa-exclamation fa-lg"></i>
    <!-- /ko -->
</script>
</body>
</html>