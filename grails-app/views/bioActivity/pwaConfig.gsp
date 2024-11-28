<%@ page import="grails.converters.JSON;" contentType="text/javascript;charset=UTF-8" defaultCodec="none" %>
const pwaConfig = {
    "cacheName": "${grailsApplication.config.getProperty('pwa.cacheVersion')}",
    "oldCacheToDelete": <fc:modelAsJavascript model="${grailsApplication.config.getProperty('pwa.oldCacheToDelete', List, [])}" />,
    "pathsToIgnoreCache": <fc:modelAsJavascript model="${grailsApplication.config.getProperty('pwa.serviceWorkerConfig.pathsToIgnoreCache', List, [])}" />,
    "cachePathForRequestsStartingWith": <fc:modelAsJavascript model="${grailsApplication.config.getProperty('pwa.serviceWorkerConfig.cachePathForRequestsStartingWith', List, [])}" />,
    "filesToPreCache": <config:getFilesToPreCacheForPWA/>,
    "noCacheTileFile": "${asset.assetPath(src: grailsApplication.config.getProperty("pwa.serviceWorkerConfig.noCacheTileFile"))}",
    "baseMapPrefixUrl": "${grailsApplication.config.getProperty('pwa.serviceWorkerConfig.baseMapPrefixUrl')}"
}