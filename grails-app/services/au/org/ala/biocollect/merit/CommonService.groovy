package au.org.ala.biocollect.merit

import grails.converters.JSON
import org.codehaus.groovy.grails.web.mapping.LinkGenerator

import javax.xml.bind.DatatypeConverter
import java.text.SimpleDateFormat

class CommonService {

    LinkGenerator grailsLinkGenerator

    List ignores = ["action","controller"]

    def buildUrlParamsFromMap(map) {
        if (!map) return ''
        def params = '?'
        map.eachWithIndex { k,v,i ->
            def vL = [v].flatten().findAll { it != null } // String[] and String both converted to List
            params += (i?'&':'') + k + '=' + vL.collect { URLEncoder.encode(String.valueOf(it), "UTF-8") }.join("&${k}=")
        }
        params
    }

    def simpleDateLocalTime(String dateStr) {
        if (!dateStr) { return '' }
        def cal = DatatypeConverter.parseDateTime(dateStr)
        def date = cal.getTime()
        new SimpleDateFormat("dd/MM/yy").format(date)
    }

    /**
     * Returns json that describes in a generic fashion the features to be placed on a map that
     * will represent the site's locations.
     *
     * @param project
     */
    def getMapFeatures(project) {
        def featuresMap = [zoomToBounds: true, zoomLimit: 12, highlightOnHover: true, features: []]
        project.sites.each { site ->
            featuresMap.features << site.extent?.geometry
        }
        return featuresMap as JSON
    }

    /**
     * copies grails parameters but ignores a predefined list of keys
     * @param params
     * @return
     */
    Map parseParams(Map params){
        Map result = [:]
        params.each { key, value ->
            if(!(key in ignores)){
                result[key] = value;
            }
        }
        result
    }
}
