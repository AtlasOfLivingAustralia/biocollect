<%@ page import="grails.converters.JSON; org.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<!DOCTYPE html>
<html>
<head>
  <meta name="layout" content="bs4"/>
  <title> ${create ? 'New' : ('Edit | ' + site?.name?.encodeAsHTML())} | Sites | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/'+ hubConfig.urlPath)},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'site', action: 'list')},Sites"/>
    <g:if test="${project}">
        <meta name="breadcrumb" content="Create new site for ${project?.name?.encodeAsHTML()}"/>
    </g:if>
    <g:elseif test="${create}">
        <meta name="breadcrumb" content="Create"/>
    </g:elseif>
    <g:else>
        <meta name="breadcrumbParent3"
              content="${createLink(controller: 'site', action: 'index')}/${site?.siteId},${site?.name?.encodeAsHTML()}"/>
        <meta name="breadcrumb" content="Edit"/>
    </g:else>

    <asset:script type="text/javascript">
    var fcConfig = {
        <g:applyCodec encodeAs="none">
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
        spatialService: '${createLink(controller:'proxy',action:'feature')}',
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        geocodeUrl: "${grailsApplication.config.google.geocode.url}",
        siteMetaDataUrl: "${createLink(controller:'site', action:'locationMetadataForPoint')}",
        <g:if test="${project}">
            pageUrl : "${createLink(controller:'site', action:'createForProject', params:[projectId:project.projectId,checkForState:true])}",
            projectUrl : "${createLink(controller:'project', action:'index', id:project.projectId)}",
        </g:if>
        <g:elseif test="${site}">
            pageUrl : "${createLink(controller:'site', action:'edit', id: site?.siteId, params:[checkForState:true])}",
        </g:elseif>
        <g:else>
            pageUrl : "${createLink(controller:'site', action:'create', params:[checkForState:true])}",
        </g:else>
        sitePageUrl : "${createLink(controller: 'site', action: 'index')}/${site?.siteId}",
        homePageUrl : "${createLink(controller: 'home', action: 'index')}",
        ajaxUpdateUrl: "${createLink(action: 'ajaxUpdate', id: site?.siteId)}",
        mapLayersConfig: <fc:modelAsJavascript model="${mapService.getMapLayersConfig(project, null)}" />,
        returnTo: "${createLink(controller: 'project', action: 'index', id: project?.projectId)}"
        </g:applyCodec>
        },
        here = window.location.href;

    </asset:script>
    <asset:stylesheet src="sites-manifest.css"/>
    <asset:stylesheet src="leaflet-manifest.css"/>
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="leaflet-manifest.js"/>
    <asset:javascript src="sites-manifest.js"/>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
</head>
<body>
    <div class="container-fluid validationEngineContainer" id="validation-container">
        <bs:form action="update" inline="true">
            <g:render template="siteDetails" model="${[showLine: true]}"/>
            <div class="row mt-3">
                <div class="form-actions col-12">
                    <button type="button" id="save" class="btn btn-primary-dark"><i class="fas fa-hdd"></i> Save changes</button>
                    <button type="button" id="cancel" class="btn btn-dark"><i class="far fa-times-circle"></i> Cancel</button>
                </div>
            </div>
        </bs:form>
    </div>
    <g:if env="development">
    <div class="container-fluid">
        <div class="expandable-debug">
            <hr />
            <h3>Debug</h3>
            <div>
                <h4>KO model</h4>
                <pre data-bind="text:ko.toJSON($root,null,2)"></pre>
                <h4>Activities</h4>
                <pre>${site?.activities?.encodeAsHTML()}</pre>
                <h4>Site</h4>
                <pre>${site?.encodeAsHTML()}</pre>
                <h4>Projects</h4>
                <pre>${projects?.encodeAsHTML()}</pre>
                <h4>Features</h4>
                <pre>${mapFeatures}</pre>
            </div>
        </div>
    </div>
    </g:if>

<asset:script type="text/javascript">
    $(function(){

        $('#validation-container').validationEngine('attach', {scroll: false});

        $('.helphover').popover({animation: true, trigger:'hover'});

        var siteViewModel = initSiteViewModel(true, ${!userCanEdit});
        $('#cancel').on('click',function () {
            if(siteViewModel.saved()){
                document.location.href = fcConfig.sitePageUrl;
            } else if(fcConfig.projectUrl){
                document.location.href = fcConfig.projectUrl;
            } else {
                document.location.href = fcConfig.homePageUrl;
            }
        });

        $('#save').on('click',function () {
            if ($('#validation-container').validationEngine('validate')) {
                var json = siteViewModel.toJS();
                //validate  if extent.geometry.pid, then update extent.source to pid, extent.geometry.type to pid
                if (json.extent.geometry.pid){
                    json.extent.source = 'pid';
                    json.extent.geometry.type = 'pid'
                }
                var data = {
                    site: json
                    <g:if test="${project?.projectId}">
                        ,
                        projectId: '${project?.projectId.encodeAsHTML()}'
                    </g:if>

                    <g:if test="${pActivityId}">
                        ,
                        pActivityId: '${pActivityId.encodeAsHTML()}'
                    </g:if>
                };

                $.ajax({
                    url: fcConfig.ajaxUpdateUrl,
                    type: 'POST',
                    data: JSON.stringify(data),
                    contentType: 'application/json',
                    success: function (data) {
                        if(data.status == 'created'){
                        <g:if test="${project}">
                            document.location.href = fcConfig.projectUrl;
                        </g:if>
                        <g:else>
                            document.location.href = fcConfig.sitePageUrl + '/' + data.id;
                        </g:else>
                        } else if(data.status == 'updated'){
                            document.location.href = fcConfig.sitePageUrl;
                        } else {
                            bootbox.alert('There was a problem saving this site', function() {location.reload();});
                        }
                    },
                    error: function (data) {
                        var errorMessage = data.responseText || 'There was a problem saving this site'
                        bootbox.alert(errorMessage);
                    }
                });
            }
        });
    });
</asset:script>

</body>
</html>
