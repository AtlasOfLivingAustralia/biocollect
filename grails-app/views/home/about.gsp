<%@ page import="au.org.ala.biocollect.merit.SettingPageType" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE HTML>
<html>
<head>
  <meta name="layout" content="${hubConfig.skin}"/>
  <title>${settingType.title?:'About'} | Field Capture</title>
  <asset:script type="text/javascript">
    var fcConfig = {
        baseUrl: "${grailsApplication.config.grails.serverURL}",
        spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
        spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
        spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}"
    }
  </asset:script>
</head>
<body>
    <div id="wrapper" class="container-fluid">
        <div class="row-fluid">
            <div class="span8" id="">
                <h1>${settingType.title?:'About the website'}
                    <g:if test="${fc.userInRole(role: grailsApplication.config.security.cas.alaAdminRole) || fc.userInRole(role: grailsApplication.config.security.cas.adminRole)}">
                        <span style="display: inline-block; margin: 0 10px;">
                            <a href="${g.createLink(controller:"admin",action:"editSettingText", id: settingType.name, params: [layout: hubConfig.skin, returnUrl: g.createLink(controller: params.controller, action: params.action, id: params.id, absolute: true)])}"
                               class="btn btn-small"><i class="icon-edit"></i> Edit</a>
                        </span>
                    </g:if>
                </h1>
            </div>
        </div>
        <div class="row-fluid">
            <div class="span7">
                <div class="" id="aboutDescription" style="margin-top:20px;">
                    <markdown:renderHtml>${content}</markdown:renderHtml>
                </div>
            </div><!-- /.spanN  -->
            <g:if test="${showNews}">
            <g:set var="newsText"><fc:getSettingContent settingType="${SettingPageType.NEWS}"/></g:set>
            <div class="span5 well well-small">
                <g:if test="${fc.userInRole(role: grailsApplication.config.security.cas.alaAdminRole) || fc.userInRole(role: grailsApplication.config.security.cas.adminRole)}">
                    <a href="${g.createLink(controller:"admin",action:"editSettingText", id: SettingPageType.NEWS.name, params: [layout: hubConfig.skin, returnUrl: g.createLink(controller: params.controller, action: params.action, absolute: true)])}"
                       class="btn btn-small pull-right"><i class="icon-edit"></i> Edit</a>
                </g:if>
                ${newsText}
            </div>
            </g:if>

        </div><!-- /.row-fluid  -->
    </div>
</body>
</html>