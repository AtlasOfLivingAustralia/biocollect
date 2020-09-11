<%@ page import="grails.converters.JSON;" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
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
                    <!-- ko if: !loading() -->
                    <div class="span5">
                        <span data-bind="text: matchingSiteCount()"
                                                                   class=""></span> matching sites.
                    </div>
                    <!-- /ko -->
                    <!-- ko if: loading -->
                    <div class="span5">
                        <div>
                            <span class="fa fa-spin fa-spinner"></span>&nbsp;Loading...
                        </div>
                    </div>
                    <!-- /ko -->
                    <div class="span7">
                        <form class="form-search  pull-right" data-bind="submit: searchSites">
                            <div class="input-append">
                                <input type="text" class="search-query" data-bind="value: currentSearch"
                                       placeholder="Search by keyword"/>
                                <button type="submit" class="btn btn-primary">Search</button>
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
                                <button class="viewOnMap btn btn-small margin-top-5"
                                        data-bind="click: $parent.mapSite, disable:$data.extent === undefined">
                                    <i class="icon-eye-open"></i>
                                    Preview
                                </button>
                                <button class="addSite btn btn-success btn-small margin-top-5"
                                        data-bind="click: $parent.addSite, visible: !isProjectSite()">
                                    <i class="icon-plus icon-white"></i>
                                    Select
                                </button>
                                <button class="removeSite btn btn-danger btn-small margin-top-5"
                                        data-bind="click: $parent.removeSite, visible: isProjectSite() ">
                                    <i class="icon-minus  icon-white"></i>
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
                                <div class="row-fluid">
                                    <div class="span12">
                                        <g:render template="/shared/pagination"/>
                                    </div>
                                </div>
                                <div class="row-fluid">
                                    <div class="span12 text-right">
                                        <button class="btn btn-primary margin-top-5" data-bind="click: useSelectedSites">Add selected sites</button>
                                        <button class="btn margin-top-5" data-bind="click: cancelUpdate">Cancel</button>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </tfoot>
                </table>
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