<%@ page import="grails.converters.JSON;" contentType="text/javascript;charset=UTF-8" %>
const pwaConfig = {
    "cacheName": "${grailsApplication.config.getProperty('pwa.cacheVersion')}",
    "pathsToIgnoreCache": ${grailsApplication.config.getProperty('pwa.serviceWorkerConfig.pathsToIgnoreCache', List) as JSON },
    "cachePathForRequestsStartingWith": ${grailsApplication.config.getProperty('pwa.serviceWorkerConfig.cachePathForRequestsStartingWith', List) as JSON },
    "filesToPreCache": <config:getFilesToPreCacheForPWA/>,
    "noCacheTileFile": "${asset.assetPath(src: grailsApplication.config.getProperty("pwa.serviceWorkerConfig.noCacheTileFile"))}",
    "baseMapPrefixUrl": "${grailsApplication.config.getProperty('pwa.serviceWorkerConfig.baseMapPrefixUrl')}"
}