<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Add existing site | Field Capture</title>
    <r:script disposition="head">
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
    </r:script>
    <r:require modules="knockout,map,amplify,siteSelection"/>
</head>

<body>
<div class="container-fluid">
    <h1>Add sites to <a href="${params.returnTo}">${project.name}</a></h1>

    <div class="row-fluid">

        <div class="well span6">

            <div class="row-fluid margin-bottom-2">
                <div class="span5">
                    <form class="form-search" data-bind="submit: searchSites">
                        <div class="input-append">
                            <input type="text" class="search-query" data-bind="value: currentSearch"
                                   placeholder="Filter..."/>
                            <button type="submit" class="btn btn-primary">Search</button>
                        </div>
                        <div><span data-bind="text: matchingSiteCount()" class="margin-top-1"></span> matching sites.</div>
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
                                State:&nbsp;<span data-bind="text:$data.extent !== undefined && extent.geometry != null ? extent.geometry.state : ''"></span>
                            </div>
                            <div data-bind="visible:$data.extent !== undefined && extent.geometry != null && extent.geometry.lga != null">
                                LGA:&nbsp;<span data-bind="text:$data.extent !== undefined && extent.geometry != null ? extent.geometry.lga : ''"></span>
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

            <div id="paginateTable" class="hide" style="text-align:center;">
                <span id="paginationInfo" style="display:inline-block;float:left;margin-top:4px;"></span>

                <div class="btn-group">
                    <button class="btn btn-small prev"><i class="icon-chevron-left"></i>&nbsp;previous</button>
                    <button class="btn btn-small next">next&nbsp;<i class="icon-chevron-right"></i></button>
                </div>
                <g:if env="development">
                    total: <span id="total"></span>
                    offset: <span id="offset"></span>
                </g:if>
            </div>

            <div class="row-fluid margin-top-2">
                <button class="btn btn-primary" data-bind="click: useSelectedSites">Update sites</button>
                <button class="btn" data-bind="click: cancelUpdate">Cancel</button>
            </div>
        </div>

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
<r:script>
    var siteModel = null;
    $(function(){

        var existingSites = <fc:modelAsJavascript model="${project?.sites?.collect { "${it.siteId}" } ?: []}"/>;
        var projectId = "${project.projectId?:'1'}"

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

</r:script>

</html>