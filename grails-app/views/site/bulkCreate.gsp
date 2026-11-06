<%@ page contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"/>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="bs5"/>
    <title>Bulk load sites | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/' + hubConfig.urlPath)},Home"/>
    <g:if test="${project}">
        <meta name="breadcrumbParent2" content="${createLink(controller: 'project', action: 'index', id: project.projectId)},${project?.name?.encodeAsHTML()}"/>
    </g:if>
    <meta name="breadcrumb" content="Bulk load sites"/>
    <asset:script type="text/javascript">
    var fcConfig = {
        <g:applyCodec encodeAs="none">
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.getProperty('spatial.geoserverUrl')}",
        layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
        regionListUrl: "${createLink(controller: 'regions', action: 'regionsList')}",
        geocodeUrl: "${grailsApplication.config.getProperty('google.geocode.url')}",
        ajaxUpdateUrl: "${createLink(controller: 'site', action: 'ajaxUpdate')}",
        mapLayersConfig: <fc:modelAsJavascript model="${mapService.getMapLayersConfig(project, null)}" />,
        leafletAssetURL: "${assetPath(src: 'webjars/leaflet/1.6.0/dist/images')}",
        projectId: "${project?.projectId?.encodeAsJavaScript()}",
        siteType: "${siteType?.encodeAsJavaScript()}",
        pActivityId: "${pActivityId?.encodeAsJavaScript() ?: ''}",
        returnTo: "${returnTo?.encodeAsJavaScript() ?: ''}"
        </g:applyCodec>
    };
    </asset:script>
    <asset:stylesheet src="sites-manifest.css"/>
    <asset:stylesheet src="leaflet-manifest.css"/>
    <asset:javascript src="common-bs5.js"/>
    <asset:javascript src="leaflet-manifest.js"/>
    <asset:javascript src="sites-manifest.js"/>
    <script src="${grailsApplication.config.getProperty('google.maps.url')}" async defer></script>
</head>
<body>
<div id="bulk-create" class="container-fluid">
    <div class="row mt-3">
        <div class="col-12 col-lg-8">
            <h2>Bulk load sites</h2>
            <p>Draw or import geometries. Each geometry starts as its own draft. Create the selected drafts as separate sites, or merge them into one site.</p>
            <div id="bulkCreateMap" style="width:100%; height: 560px"></div>
        </div>
        <div class="col-12 col-lg-4">
            <div class="alert alert-info" data-bind="visible: processing">
                <p>Processing sites, please wait</p>
                <div class="progress">
                    <div class="progress-bar" role="progressbar" data-bind="style: { width: progressPercent() + '%' }, attr: { 'aria-valuenow': progress, 'aria-valuemin': 0, 'aria-valuemax': 100 }"></div>
                </div>
            </div>
            <div class="alert alert-success" data-bind="visible: finished() && !processing()">
                <p data-bind="text: statusMessage"></p>
            </div>
            <div class="alert alert-danger" data-bind="visible: errorMessage, text: errorMessage"></div>

            <div class="btn-group mb-3" role="group">
                <button type="button" class="btn btn-primary-dark" data-bind="click: createSelected, enable: hasSelection() && !processing()">Create sites</button>
                <button type="button" class="btn btn-dark" data-bind="click: createAsOneSite, enable: hasSelection() && !processing()">Create as one site</button>
                <button type="button" class="btn btn-dark" data-bind="click: mergeSelected, enable: hasSelection() && !processing()">Merge</button>
            </div>

            <div data-bind="visible: drafts().length === 0">
                <p>No drafts yet. Draw a shape or import a file.</p>
            </div>
            <div data-bind="foreach: drafts">
                <div class="border rounded p-2 mb-2">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" data-bind="checked: selected, enable: !siteCreated()">
                        <span class="badge text-bg-secondary" data-bind="text: statusLabel"></span>
                        <span data-bind="visible: loading"><i class="fa fa-spinner fa-spin"></i></span>
                    </div>
                    <div class="mb-2 mt-2">
                        <label class="form-label">Name</label>
                        <input class="form-control" type="text" data-bind="value: name, enable: !siteCreated()">
                    </div>
                    <p class="mb-2"><span data-bind="text: summary"></span></p>
                    <div class="btn-group btn-group-sm">
                        <button type="button" class="btn btn-dark" data-bind="click: $parent.zoomToDraft">Zoom</button>
                        <button type="button" class="btn btn-dark" data-bind="click: $parent.unpackDraft, visible: canUnpack()">Unpack</button>
                        <button type="button" class="btn btn-dark" data-bind="click: $parent.unmergeDraft, visible: canUnmerge()">Unmerge</button>
                        <button type="button" class="btn btn-danger" data-bind="click: $parent.deleteDraft, enable: !siteCreated()">Delete</button>
                    </div>
                </div>
            </div>

            <div class="mt-3">
                <button type="button" class="btn btn-dark" data-bind="click: goToProject">Go to project</button>
            </div>
        </div>
    </div>
</div>
<asset:script type="text/javascript">
    $(function () {
        var bulkCreateViewModel = new BulkCreateSiteViewModel({
            projectId: fcConfig.projectId,
            returnTo: fcConfig.returnTo,
            siteType: fcConfig.siteType,
            pActivityId: fcConfig.pActivityId
        });
        ko.applyBindings(bulkCreateViewModel, document.getElementById('bulk-create'));
    });
</asset:script>
</body>
</html>
