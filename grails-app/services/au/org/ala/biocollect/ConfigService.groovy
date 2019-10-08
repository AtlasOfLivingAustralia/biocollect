package au.org.ala.biocollect

import ch.qos.logback.classic.Level
import grails.core.GrailsApplication
import org.slf4j.LoggerFactory
/**
 *  Compute those computational configurations which their dependent fields may be overwritten by external
 */
class ConfigService {

    GrailsApplication grailsApplication
    /**
     * Reset possible configrations replaced by external config
     * @return
     */
    def computeConfig() {


        if (grailsApplication.config.loggerLevel){
            log.info('Reset Logger Level to ' + grailsApplication.config.loggerLevel.toString().toUpperCase() )
            ch.qos.logback.classic.Logger logger =
                    (ch.qos.logback.classic.Logger)LoggerFactory.getLogger("au.org.ala.biocollect");
            logger.setLevel( Level.valueOf(grailsApplication.config.loggerLevel.toString().toUpperCase()))
        }


        log.debug('Computing config properties..........')

        log.debug("Register to CAS: " + grailsApplication.config.getProperty("security.cas.appServerName"))

        def googleMapApiKey = grailsApplication.config.getProperty("google.maps.apiKey")
        if (googleMapApiKey){
            grailsApplication.config.google.maps.url =  grailsApplication.config["google.maps.base"] + googleMapApiKey
            log.debug('Google Map URL:' + grailsApplication.config.google.maps.url)
        }else
            throw new Exception('You.Need.To.Add.A.Config.Property.Named.google.maps.apiKey')

        def ecodataBaseUrl = grailsApplication.config.getProperty("ecodata.baseURL")
        if (ecodataBaseUrl){
            grailsApplication.config.ecodata.service.url = ecodataBaseUrl + '/ws'
            log.debug('Ecodata service URL:' + grailsApplication.config.ecodata.service.url)
        }else
            throw new Exception('You need to define ecodata base URL')

        def meritBaseUrl = grailsApplication.config.getProperty("merit.baseURL")
        if (meritBaseUrl){
            grailsApplication.config.merit.project.url = meritBaseUrl + '/project/index'
            log.debug('Merit project URL:' + grailsApplication.config.merit.project.url)
        }else
            throw new Exception('You need to define ecodata base URL!')
        //It is used by redirect and others,
        if (grailsApplication.config.server.serverURL){
            //Need to be confirmed if it is used by redirect and others,
            grailsApplication.config.grails.serverURL = grailsApplication.config.server.serverURL
            grailsApplication.config.upload.images.url = grailsApplication.config.grails.serverURL + '/image?id='
            grailsApplication.config.upload.file.url = grailsApplication.config.grails.serverURL + '/file?id='

        }else
            throw new Exception('You need to define server.serverURL!')


        def spatial = grailsApplication.config.getProperty("spatial.baseURL")
        if(spatial){
            log.debug(spatial)
            grailsApplication.config.spatial.layersUrl = spatial+"/layers-service"
            grailsApplication.config.spatial.geoserverUrl = spatial+"/geoserver"
            grailsApplication.config.spatial.wms.url = spatial+"/geoserver/ALA/wms?"
            grailsApplication.config.spatial.wms.cache.url =spatial+"/geoserver/gwc/service/wms?"
        }else
            throw new Exception('You need to define spatial portal URL')

    }
}
