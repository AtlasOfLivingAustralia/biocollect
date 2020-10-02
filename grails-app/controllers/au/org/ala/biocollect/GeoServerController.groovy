package au.org.ala.biocollect

import grails.converters.JSON
import org.apache.http.HttpStatus

class GeoServerController {
    GeoServerService geoServerService
    static allowedMethods = [wms: 'GET', createStyle: 'POST', 'getLayerName': 'GET']
    
    def wms () {
        geoServerService.wms(response, request, params)
        return null
    }
    
    def createStyle () {
        Map result = geoServerService.createStyle(request)
        Map resp = result?.resp ?: result
        render (text: resp, contentType: 'application/json', status: result.statusCode)
    }

    def getLayerName () {
        if (params.type) {
            def response = geoServerService.getLayerName(params.type, params.indices, params.dataType)
            if (!response.error) {
                render (text: [layerName: response.resp?.layerName] as JSON, contentType: 'application/json', status: response.statusCode)
            } else {
                render (text: [error: response.error] as JSON, contentType: 'application/json', status: response.statusCode)
            }
        } else {
            render (text: [message: "Missing parameters - type - must be provided.", status: HttpStatus.SC_BAD_REQUEST])
        }
    }

    def getHeatmap () {
        Map response = geoServerService.getHeatmapFeatures(params, request)
        if (!response.error) {
            render (text: response.resp as JSON, contentType: 'application/json', status: response.statusCode)
        } else {
            render (text: [error: response.error] as JSON, contentType: 'application/json', status: response.statusCode)
        }
    }
}