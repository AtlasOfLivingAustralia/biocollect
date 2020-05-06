package au.org.ala.biocollect.merit

import grails.converters.JSON
import grails.web.mapping.LinkGenerator
import grails.web.servlet.mvc.GrailsParameterMap

import javax.servlet.http.HttpServletRequest
import javax.xml.bind.DatatypeConverter
import java.text.SimpleDateFormat

class CommonService {

    UserService userService

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

    /**
     * This function adds a standard set of parameters used by elastic search.
     * copies url parameter and deletes parameters added by grails.
     *
     * @param params
     * @param request
     * @param userId
     * @return
     */
    GrailsParameterMap constructDefaultSearchParams(Map params, HttpServletRequest request, String userId) {
        GrailsParameterMap queryParams = new GrailsParameterMap([:], request)
        Map parsed = parseParams(params)
        parsed.each{ key, value ->
            if(value != null && value){
                queryParams.put(key, value)
            }
        }

        queryParams.userId = userId
        queryParams.max = queryParams.max ?: 10
        queryParams.offset = queryParams.offset ?: 0
        queryParams.flimit = queryParams.flimit ?: 20
        queryParams.sort = queryParams.sort ?: 'lastUpdated'
        queryParams.order = queryParams.order ?: 'DESC'
        queryParams.fq = queryParams.fq ?: ''
        queryParams.searchTerm = queryParams.searchTerm ?: ''

        queryParams
    }

}
