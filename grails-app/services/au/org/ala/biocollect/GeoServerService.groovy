package au.org.ala.biocollect

import au.org.ala.biocollect.merit.CommonService
import au.org.ala.biocollect.merit.ProjectService
import au.org.ala.biocollect.merit.SettingService
import au.org.ala.biocollect.merit.UserService
import au.org.ala.biocollect.merit.WebService

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
        webService.proxyGetRequest(response, url, true, true)
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

        webService.doGet("${grailsApplication.config.ecodata.baseURL}/ws/search/getHeatmap", params)
    }
}