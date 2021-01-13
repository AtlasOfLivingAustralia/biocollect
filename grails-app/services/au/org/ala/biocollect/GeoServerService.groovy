package au.org.ala.biocollect

import au.org.ala.biocollect.merit.*
import grails.web.http.HttpHeaders

class GeoServerService {
    WebService webService
    def grailsApplication
    SettingService settingService
    CommonService commonService
    UserService userService
    ProjectService projectService

    public static final String PROJECT_TYPE = "project"

    def wms (response, request,params) {
        if (!params.hub) {
            def hub = settingService.getHubConfig()
            params.hub = hub.urlPath
        }

        params.userId = userService.getCurrentUserId()

        switch (params.dataType) {
            case PROJECT_TYPE:
                params = projectService.buildProjectSearch(params, request)
                break
            default:
                break
        }

        String url = "${grailsApplication.config.ecodata.baseURL}/ws/geoServer/wms" + commonService.buildUrlParamsFromMap(params)
        int timeout = grailsApplication.config.geoServer.readTimeout as int
        webService.proxyGetRequest(response, url, true, true, timeout, [HttpHeaders.EXPIRES, HttpHeaders.CACHE_CONTROL, HttpHeaders.CONTENT_DISPOSITION, HttpHeaders.CONTENT_TYPE])
    }

    def createStyle (params) {
        webService.doPost("${grailsApplication.config.ecodata.baseURL}/ws/geoServer/createStyle", params.getJSON())
    }

    def getLayerName (type, indices, dataType = '') {
        webService.doGet("${grailsApplication.config.ecodata.baseURL}/ws/geoServer/getLayerName", [type: type, indices: indices, dataType: dataType])
    }

    def getHeatmapFeatures(params, request) {
        switch (params.dataType) {
            case PROJECT_TYPE:
                params = projectService.buildProjectSearch(params, request)
                break
            default:
                break
        }

        webService.doGet("${grailsApplication.config.ecodata.baseURL}/ws/search/getHeatmap" + commonService.buildUrlParamsFromMap(params), [:])
    }
}