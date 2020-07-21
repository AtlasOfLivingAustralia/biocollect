package au.org.ala.biocollect

import au.org.ala.biocollect.merit.CommonService
import au.org.ala.biocollect.merit.SettingService
import au.org.ala.biocollect.merit.UserService
import au.org.ala.biocollect.merit.WebService

class GeoServerService {
    WebService webService
    def grailsApplication
    SettingService settingService
    CommonService commonService
    UserService userService

    def wms (response, params) {
        if (!params.hub) {
            def hub = settingService.getHubConfig()
            params.hub = hub.urlPath
        }

        params.userId = userService.getCurrentUserId()

        String url = "${grailsApplication.config.ecodata.baseURL}/ws/geoServer/wms" + commonService.buildUrlParamsFromMap(params)
        webService.proxyGetRequest(response, url, true, true)
    }

    def createStyle (params) {
        webService.doPost("${grailsApplication.config.ecodata.baseURL}/ws/geoServer/createStyle", params.getJSON())
    }

    def getLayerName (type, indices) {
        webService.doGet("${grailsApplication.config.ecodata.baseURL}/ws/geoServer/getLayerName", [type: type, indices: indices])
    }
}