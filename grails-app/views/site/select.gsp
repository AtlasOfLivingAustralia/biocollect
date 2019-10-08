<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Add existing site | Field Capture</title>
    <asset:script type="text/javascript">
        var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            siteDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDelete')}",
            siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
            activityEditUrl: "${createLink(controller: 'activity', action: 'edit')}",
            activityCreateUrl: "${createLink(controller: 'activity', action: 'create')}",
            spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
            spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
            spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
            sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
            sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}"
        },
        returnTo = "${params.returnTo}";
    </asset:script>
    <asset:stylesheet src="leaflet-manifest.css"/>
    <asset:javascript src="common.js"/>
    <asset:javascript src="leaflet-manifest.js"/>
    <asset:javascript src="siteSelection.js"/>
</head>

<body>
<div class="container-fluid">
    <h1>Add sites to <a href="${params.returnTo}">${project.name}</a></h1>

    <div class="row-fluid">
        <bc:koLoading>
            <div class="well span6">
                <div class="row-fluid">
                    <div class="span5">
                        <form class="form-search" data-bind="submit: searchSites">
                            <div class="input-append">
                                <input type="text" class="search-query" data-bind="value: currentSearch"
                                       placeholder="Filter..."/>
                                <button type="submit" class="btn btn-primary">Search</button>
                            </div>
                            <div class="span12">
                            </div>
                            <div class="span12">
                                    <div class=" btn-group span6" data-toggle="buttons-checkbox">
                                        <button type="button" class="btn  btn-small btn-info"
                                                    data-bind="click: toggleMyFavourites">Only Favourites<i data-bind="visible: myFavourites"
                                                    class="toggleIndicator icon-remove icon-white"></i></button>
                                    </div>
                            </div>
                            <div class="row-fluid margin-top-2" ><span data-bind="text: matchingSiteCount()"
                                       class=""></span> matching sites.</div>
                        </form>
                    </div>
                </div>

                <ul data-bind="foreach: sites" style="margin: 0px;">
                    <li style="list-style: none;">
                        <div class="row-fluid margin-bottom-1">
                            <span class="span8">
                                <strong>
                                    <span data-bind="text:name"></span>
                                </strong>
                                <br/>

                                <div data-bind="visible:$data.extent === undefined">No georeference information available</div>

                                <div data-bind="visible:$data.extent !== undefined && extent.geometry != null && extent.geometry.state != null">
                                    State:&nbsp;<span
                                        data-bind="text:$data.extent !== undefined && extent.geometry != null ? extent.geometry.state : ''"></span>
                                </div>

                                <div data-bind="visible:$data.extent !== undefined && extent.geometry != null && extent.geometry.lga != null">
                                    LGA:&nbsp;<span
                                        data-bind="text:$data.extent !== undefined && extent.geometry != null ? extent.geometry.lga : ''"></span>
                                </div>
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
                <div class="row-fluid margin-top-2">
                    <button class="btn btn-primary" data-bind="click: useSelectedSites">Update sites</button>
                    <button class="btn" data-bind="click: cancelUpdate">Cancel</button>
                </div>
            </div>
        </bc:koLoading>

        <div class="span6">
            <m:map id="siteMap"/>
        </div>
    </div>

    <g:if env="development">
        <div class="container-fluid">
            <div class="expandable-debug">
                <hr/>

                <h3>Debug</h3>

                <div>
                    <h4>KO model</h4>
                    <pre data-bind="text:ko.toJSON($root,null,2)"></pre>
                </div>
            </div>
        </div>
    </g:if>
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