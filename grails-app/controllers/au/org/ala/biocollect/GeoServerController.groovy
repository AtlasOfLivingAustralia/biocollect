package au.org.ala.biocollect

class GeoServerController {
    GeoServerService geoServerService
    static allowedMethods = [wms: 'GET', createStyle: 'POST']
    
    def wms () {
        geoServerService.wms(response, params)
        return null
    }
    
    def createStyle () {
        Map result = geoServerService.createStyle(request)
        Map resp = result?.resp ?: result
        render (text: resp, contentType: 'application/json', status: result.statusCode)
    }
}