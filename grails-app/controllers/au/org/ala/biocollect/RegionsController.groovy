package au.org.ala.biocollect

import au.org.ala.biocollect.merit.CacheService
import au.org.ala.biocollect.merit.UserService
import grails.converters.JSON
import grails.core.GrailsApplication
import groovy.json.JsonSlurper
import org.apache.http.HttpStatus

class RegionsController {

    CacheService cacheService
    GrailsApplication grailsApplication
    UserService userService
    MapService mapService

    Map regionsList() {
        def regionsJson = cacheService.get('regions-list', {
            new JsonSlurper().parse(new File("/data/biocollect/config/regions.json"))
        })

        render regionsJson as JSON
    }

    /**
     * Get a SLD XML document that controls the layer's style.
     * Reference https://docs.geoserver.org/2.11.1/user/styling/sld/index.html
     * @param id The layer id.
     * @return XML document
     */
    def layersStyle() {
        if(request.isPost()){
            List layers = request.JSON ?: []
            Map result = [:]
            layers.each { layer ->
                // get the style content for the layer
                if (layer.changeLayerColour || layer.showPropertyName) {
                    def xml = mapService.buildXml(layer)
                    result[layer.alaId] = xml.toString()
                }
            }

            render text: result as JSON, contentType: "application/json", encoding: "UTF-8"
        } else {
            render text: "Request method not supported.", contentType: "text/plain", encoding: "UTF-8", status: HttpStatus.SC_METHOD_NOT_ALLOWED
            return
        }
    }
}
