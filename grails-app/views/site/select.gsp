<%@ page import="grails.converters.JSON;" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Add existing site | Field Capture</title>
    <asset:script type="text/javascript">
        var fcConfig = {
            intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
            featuresService: "${createLink(controller: 'proxy', action: 'features')}",
            featureService: "${createLink(controller: 'proxy', action: 'feature')}",
            spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
            layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            siteDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDelete')}",
            siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
            activityEditUrl: "${createLink(controller: 'activity', action: 'edit')}",
            activityCreateUrl: "${createLink(controller: 'activity', action: 'create')}",
            spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
            spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
            spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
            sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
            mapLayersConfig: ${mapService.getMapLayersConfig(project, pActivity) as JSON},
            sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}"
        },
        returnTo = "${params.returnTo}";
    </asset:script>
    <asset:stylesheet src="leaflet-manifest.css"/>
    <asset:javascript src="common.js"/>
    <asset:javascript src="leaflet-manifest.js"/>
    <asset:javascript src="siteSelection.js"/>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
</head>

<body>
<div class="container-fluid">
    <h1>Add sites to <a href="${params.returnTo}">${project.name}</a></h1>

    <div class="row-fluid">
        <bc:koLoading>
            <div class="span6">
                <div class="row-fluid">
                    <div class="span5">
                        <span data-bind="text: matchingSiteCount()"
                                                                   class=""></span> matching sites.
                    </div>
                    <div class="span7">
                        <form class="form-search  pull-right" data-bind="submit: searchSites">
                            <div class="input-append">
                                <input type="text" class="search-query" data-bind="value: currentSearch"
                                       placeholder="Filter..."/>
                                <button type="submit" class="btn btn-primary">Search</button>
                            </div>
                        </form>
                    </div>
                </div>

                <ul data-bind="foreach: sites" style="margin: 0px;">
                    <li style="list-style: none;" data-bind="attr: {id: siteId}">
                        <div class="row-fluid margin-bottom-1">
                            <span class="span8">
                                <h4 data-bind="text:name"></h4>

                                <div data-bind="visible:$data.extent === undefined">No georeference information available</div>
                                <dl>
                                    <dt data-bind="if:$data.extent !== undefined && extent.geometry != null && extent.geometry.state != null && extent.geometry.state != undefined && extent.geometry.state != ''"><State></State></dt>
                                    <dd data-bind="if:$data.extent !== undefined && extent.geometry != null && extent.geometry.state != null && extent.geometry.state != undefined && extent.geometry.state != ''">
                                        <!-- ko if: ((extent.geometry.state.join && extent.geometry.state.join(', ') || extent.geometry.state ).length <= 71) -->
                                        <div
                                                data-bind="text:$data.extent !== undefined && extent.geometry != null ? extent.geometry.state : ''"></div>
                                        <!-- /ko -->
                                        <!-- ko if: ((extent.geometry.state.join && extent.geometry.state.join(', ') || extent.geometry.state ).length > 71) -->
                                        <div class="inline-block">
                                            <div class="state-data in collapse">
                                                <!-- ko text: extent.geometry.state.join(', ').slice(0, 71) + '...' --> <!-- /ko -->
                                                <button class="btn btn-mini collapsed" data-toggle="collapse" data-bind="attr: { 'data-target': '#' + siteId + ' .state-data' }">Show more</button>
                                            </div>
                                            <div class="state-data collapse">
                                                <!-- ko text: extent.geometry.state --> <!-- /ko -->
                                                <button class="btn btn-mini" data-toggle="collapse" data-bind="attr: { 'data-target': '#' + siteId + ' .state-data' }">Show less</button>
                                            </div>
                                        </div>
                                        <!-- /ko -->
                                    </dd>
                                    <dt data-bind="if:$data.extent !== undefined && extent.geometry != null && ((extent.geometry.lga != null) && (extent.geometry.lga != undefined) && (extent.geometry.lga != ''))">
                                        LGA
                                    </dt>
                                    <dd data-bind="if:$data.extent !== undefined && extent.geometry != null && ((extent.geometry.lga != null) && (extent.geometry.lga != undefined) && (extent.geometry.lga != ''))">
                                        <!-- ko if: (((extent.geometry.lga.join && extent.geometry.lga.join(', ')) || extent.geometry.lga ).length <= 71) -->
                                        <div
                                                data-bind="text:$data.extent !== undefined && extent.geometry != null ? extent.geometry.lga : ''"></div>
                                        <!-- /ko -->
                                        <!-- ko if: (((extent.geometry.lga.join && extent.geometry.lga.join(', ')) || extent.geometry.lga).length > 71) -->
                                        <div data-bind="attr: {id: siteId}">
                                            <div class="lga-data in collapse">
                                                <!-- ko text: (extent.geometry.lga.join && extent.geometry.lga.join(', ') || extent.geometry.lga ).slice(0, 71) + '...' --> <!-- /ko -->
                                                <button class="btn btn-mini collapsed" data-toggle="collapse" data-bind="attr: { 'data-target': '#' + siteId + ' .lga-data' }">Show more</button>
                                            </div>
                                            <div class="lga-data collapse">
                                                <!-- ko text: extent.geometry.lga --> <!-- /ko -->
                                                <button class="btn btn-mini" data-toggle="collapse" data-bind="attr: { 'data-target': '#' + siteId + ' .lga-data' }">Show less</button>
                                            </div>
                                        </div>
                                        <!-- /ko -->
                                    </dd>
                                </dl>
                            </span>
                            <span class="span2">
                                <button class="viewOnMap btn btn-small"
                                        data-bind="click: $parent.mapSite, disable:$data.extent === undefined">
                                    <i class="icon-eye-open"></i>
                                    Preview
                                </button>
                            </span>
                            <span class="span2 ">
                                <button class="addSite btn btn-success btn-small pull-right"
                                        data-bind="click: $parent.addSite, visible: !isProjectSite()">
                                    <i class="icon-plus icon-white"></i>
                                    Add
                                </button>
                                <button class="removeSite btn btn-danger btn-small pull-right"
                                        data-bind="click: $parent.removeSite, visible: isProjectSite() ">
                                    <i class="icon-minus  icon-white"></i>
                                    Remove
                                </button>
                            </span>
                        </div>
                    </li>
                </ul>
                <g:render template="/shared/pagination"/>
                <div class="row-fluid margin-top-2 text-right">
                    <button class="btn btn-primary" data-bind="click: useSelectedSites">Add sites</button>
                    <button class="btn" data-bind="click: cancelUpdate">Cancel</button>
                </div>
            </div>
        </bc:koLoading>

        <div class="span6">
            <m:map id="siteMap" width="100%"/>
        </div>
    </div>
</div>
</body>
<asset:script type="text/javascript">
    var siteModel = null;
    $(function(){

        var existingSites = <fc:modelAsJavascript model="${project?.sites?.collect { "${it.siteId}" } ?: []}"/>;
        var projectId = "${project.projectId ?: '1'}"

        var config = {
            featuresService: "${createLink(controller: 'proxy', action: 'features')}",
            featureService: "${createLink(controller: 'proxy', action: 'feature')}",
            wmsFeatureUrl: "${createLink(controller: 'proxy', action: 'feature')}",
            wmsLayerUrl: "${grailsApplication.config.spatial.geoserverUrl}",
            spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
            updateSitesUrl: "${createLink(controller: 'site', action: 'ajaxUpdateProjects')}",
            returnTo: "${params.returnTo}",
            siteQueryUrl: "${createLink(controller: 'site', action: 'search')}?query="
        }

        siteModel = new SiteSelectModel(config, projectId, existingSites);
        ko.applyBindings(siteModel);


    });

</asset:script>

</html>