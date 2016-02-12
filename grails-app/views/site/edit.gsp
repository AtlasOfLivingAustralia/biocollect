<%@ page import="net.sf.json.JSON; org.codehaus.groovy.grails.web.json.JSONArray" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <meta name="layout" content="${hubConfig.skin}"/>
  <title> ${create ? 'New' : ('Edit | ' + site?.name?.encodeAsHTML())} | Sites | Field Capture</title>
  <style type="text/css">
    legend {
        border: none;
        margin-bottom: 5px;
    }
    h1 input[type="text"] {
        color: #333a3f;
        font-size: 28px;
        /*line-height: 40px;*/
        font-weight: bold;
        font-family: Arial, Helvetica, sans-serif;
        height: 42px;
    }
    .no-border { border-top: none !important; }
  </style>
    <r:script disposition="head">
    var fcConfig = {
        spatialService: '${createLink(controller:'proxy',action:'feature')}',
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        geocodeUrl: "${grailsApplication.config.google.geocode.url}",
        siteMetaDataUrl: "${createLink(controller:'site', action:'locationMetadataForPoint')}",
        <g:if test="${project}">
            pageUrl : "${grailsApplication.config.grails.serverName}${createLink(controller:'site', action:'createForProject', params:[projectId:project.projectId,checkForState:true])}",
            projectUrl : "${grailsApplication.config.grails.serverName}${createLink(controller:'project', action:'index', id:project.projectId)}",
        </g:if>
        <g:elseif test="${site}">
            pageUrl : "${grailsApplication.config.grails.serverName}${createLink(controller:'site', action:'edit', id: site?.siteId, params:[checkForState:true])}",
        </g:elseif>
        <g:else>
            pageUrl : "${grailsApplication.config.grails.serverName}${createLink(controller:'site', action:'create', params:[checkForState:true])}",
        </g:else>
        sitePageUrl : "${createLink(action: 'index', id: site?.siteId)}",
        homePageUrl : "${createLink(controller: 'home', action: 'index')}",
        ajaxUpdateUrl: "${createLink(action: 'ajaxUpdate', id: site?.siteId)}",
        returnTo: "${createLink(controller: 'project', action: 'index', id: project?.projectId)}"
        },
        here = window.location.href;

    </r:script>
    <r:require modules="knockout, jqueryValidationEngine, amplify, projects, map"/>
</head>
<body>
    <div class="container-fluid validationEngineContainer" id="validation-container">
        <ul class="breadcrumb">
            <li><g:link controller="home">Home</g:link> <span class="divider">/</span></li>
            <li>Sites<span class="divider">/</span></li>
            <g:if test="${project}">
                <li class="active">Create new site for ${project?.name?.encodeAsHTML()}</li>
            </g:if>
            <g:elseif test="${create}">
                <li class="active">Create</li>
            </g:elseif>
            <g:else>
                <li><g:link controller="site" action="index" id="${site?.siteId}">
                    <span data-bind="text: name">${site?.name?.encodeAsHTML()}</span>
                </g:link><span class="divider">/</span></li>
                <li class="active">Edit</li>
            </g:else>
        </ul>

        <bs:form action="update" inline="true">
            <g:render template="siteDetails" />
            <div class="row-fluid">
                <div class="form-actions span12">
                    <button type="button" id="save" class="btn btn-primary">Save changes</button>
                    <button type="button" id="cancel" class="btn">Cancel</button>
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

<r:script>
    $(function(){

        $('#validation-container').validationEngine('attach', {scroll: false});

        $('.helphover').popover({animation: true, trigger:'hover'});

        var siteViewModel = initSiteViewModel(true);
        $('#cancel').click(function () {
            if(siteViewModel.saved()){
                document.location.href = fcConfig.sitePageUrl;
            } if(fcConfig.projectUrl){
                document.location.href = fcConfig.projectUrl;
            }else {
                document.location.href = fcConfig.homePageUrl;
            }
        });

        $('#save').click(function () {
            if ($('#validation-container').validationEngine('validate')) {
                var json = siteViewModel.toJS();
                var data = {
                    site: json
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
                            document.location.href = fcConfig.sitePageUrl + '/' + json.siteId;
                        </g:else>
                        } else {
                            alert('There was a problem saving this site');
                        }
                    },
                    error: function (data) {
                        alert('There was a problem saving this site');
                    }
                });
            }
        });
    });
</r:script>

</body>
</html>