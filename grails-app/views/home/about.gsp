<%@ page import="au.org.ala.biocollect.merit.SettingPageType" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE HTML>
<html>
<head>
  <meta name="layout" content="${hubConfig.skin}"/>
  <title>${settingType.title?:'About'} | Field Capture</title>
  <asset:script type="text/javascript">
    var fcConfig = {
      <g:applyCodec encodeAs="none">
        baseUrl: "${grailsApplication.config.grails.serverURL}",
        spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
        spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
        spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}"
      </g:applyCodec>
    }
  </asset:script>
</head>
<body>
    <div id="wrapper" class="container-fluid">
        <div class="row">
            <div class="col-md-8" id="">
                <h1>${settingType.title?:'About the website'}
                    <g:if test="${fc.userInRole(role: grailsApplication.config.security.cas.alaAdminRole) || fc.userInRole(role: grailsApplication.config.security.cas.adminRole)}">
                        <span class="d-inline-block my-2">
                            <a href="${raw(g.createLink(controller:"admin",action:"editSettingText", id: settingType.name, params: [layout: hubConfig.skin, returnUrl: raw(g.createLink(controller: params.controller, action: params.action, id: params.id, absolute: true))]))}"
                               class="btn btn-sm btn-dark"><i class="fas fa-pencil-alt"></i> Edit</a>
                        </span>
                    </g:if>
                </h1>
            </div>
        </div>
        <div class="row">
            <div class="col-md-7">
                <div class="mt-3" id="aboutDescription">
                    <markdown:renderHtml>${raw(content)}</markdown:renderHtml>
                </div>
            </div>
            <g:if test="${showNews}">
            <g:set var="newsText"><fc:getSettingContent settingType="${SettingPageType.NEWS}"/></g:set>
            <div class="col-md-5">
                <g:if test="${fc.userInRole(role: grailsApplication.config.security.cas.alaAdminRole) || fc.userInRole(role: grailsApplication.config.security.cas.adminRole)}">
                    <a href="${raw(g.createLink(controller:"admin",action:"editSettingText", id: SettingPageType.NEWS.name, params: [layout: hubConfig.skin, returnUrl: raw(g.createLink(controller: params.controller, action: params.action, absolute: true))]))}"
                       class="btn btn-sm btn-dark pull-right"><i class="fas fa-pencil-alt"></i> Edit</a>
                </g:if>
                ${raw(newsText)}
            </div>
            </g:if>

        </div>
    </div>
</body>
</html>