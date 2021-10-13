<%@ page import="grails.converters.JSON;" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title>Add existing site | <g:message code="g.biocollect"/></title>
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
            <g:applyCodec encodeAs="none">
                mapLayersConfig: ${mapService.getMapLayersConfig(project, pActivity) as JSON},
            </g:applyCodec>
            sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}"
        },
        returnTo = "${params.returnTo}";
    </asset:script>
    <asset:stylesheet src="leaflet-manifest.css"/>
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="leaflet-manifest.js"/>
    <asset:javascript src="siteSelection.js"/>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
</head>

<body>
<div class="container-fluid">
    <h1>Add sites to <a href="${params.returnTo}">${project.name}</a></h1>

    <div class="row">
        <div class="col-12 order-1 col-md-6 order-md-0">
            <bc:koLoading>
                <div class="row">
                    <!-- ko if: !loading() -->
                    <div class="col-12 col-md-5 order-1 order-md-0 mt-2 mt-md-0">
                        <span data-bind="text: matchingSiteCount()"
                              class=""></span> matching sites.
                    </div>
                    <!-- /ko -->
                    <!-- ko if: loading -->
                    <div class="col-12 col-md-5 order-1 order-md-0 mt-2 mt-md-0">
                        <div>
                            <span class="fa fa-spin fa-spinner"></span>&nbsp;Loading...
                        </div>
                    </div>
                    <!-- /ko -->
                    <div class="col-12 col-md-7 order-0 order-md-1 mt-2 mt-md-0">
                        <form class="text-md-right" data-bind="submit: searchSites">
                            <div class="input-group">
                                <input class="form-control" type="text" data-bind="value: currentSearch"
                                       placeholder="Search by keyword" aria-label="Search by keyword" aria-describedby="search-site-button"/>
                                <div class="input-group-append">
                                    <button class="btn btn-primary-dark" id="search-site-button" type="submit">Search</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
                <table class="table table-striped">
                    <thead>
                    <tr>
                        <th>
                            <g:message code="site.details.siteName"/>
                        </th>
                        <th>
                            <g:message code="actions"/>
                        </th>
                    </tr>
                    </thead>
                    <tbody>
                    <!-- ko foreach: sites -->
                    <tr data-bind="attr: {id: siteId}">
                        <td>
                            <h4 data-bind="text:name"></h4>
                        </td>
                        <td>
                            <button class="viewOnMap btn btn-sm btn-info mt-2"
                                    data-bind="click: $parent.mapSite, disable:$data.extent === undefined">
                                <i class="far fa-eye"></i>
                                Preview
                            </button>
                            <button class="addSite btn btn-sm btn-primary-dark mt-2"
                                    data-bind="click: $parent.addSite, visible: !isProjectSite()">
                                <i class="fas fa-plus"></i>
                                Select
                            </button>
                            <button class="removeSite btn btn-sm btn-danger mt-2"
                                    data-bind="click: $parent.removeSite, visible: isProjectSite() ">
                                <i class="fas fa-minus"></i>
                                Remove
                            </button>
                        </td>
                    </tr>
                    <!-- /ko -->
                    <tr data-bind="if: (sites().length == 0) && !loading() ">
                        <td colspan="2"><g:message code="site.details.nosites"/></td>
                    </tr>
                    </tbody>
                    <tfoot>
                    <tr>
                        <td colspan="2">
                            <div class="row">
                                <div class="col-12">
                                    <g:render template="/shared/pagination" model="${[bs: 4]}"/>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-12 text-right">
                                    <button class="btn btn-primary-dark mt-2" data-bind="click: useSelectedSites">Add selected sites</button>
                                    <button class="btn btn-dark mt-2" data-bind="click: cancelUpdate">Cancel</button>
                                </div>
                            </div>
                        </td>
                    </tr>
                    </tfoot>
                </table>
            </bc:koLoading>
        </div>
        <div class="col-12 order-0 col-md-6 order-md-1">
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