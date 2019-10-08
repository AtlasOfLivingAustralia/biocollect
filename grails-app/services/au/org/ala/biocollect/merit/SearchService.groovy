package au.org.ala.biocollect.merit

import groovy.json.JsonSlurper
import org.apache.commons.lang.StringUtils
import grails.web.servlet.mvc.GrailsParameterMap

import javax.annotation.PostConstruct
import javax.servlet.http.HttpServletResponse
/**
 * Service for ElasticSearch running on ecodata
 */
class SearchService {
    def webService, commonService, cacheService, metadataService
    SettingService settingService
    def grailsApplication
    def elasticBaseUrl

    @PostConstruct
    private void init() {
        elasticBaseUrl = grailsApplication.config.ecodata.service.url + '/search/elastic'
    }

    def addDefaultFacetQuery(params) {
        def defaultFacetQuery = SettingService.getHubConfig().defaultFacetQuery
        if (defaultFacetQuery) {
            params.hubFq = defaultFacetQuery
        }
    }

    def fulltextSearch(params, skipDefaultFacetQuery = false) {
        if(!skipDefaultFacetQuery){
            addDefaultFacetQuery(params)
        }
        params.offset = params.offset?:0
        params.max = params.max?:10
        params.query = params.query?:"*:*"
        params.highlight = params.highlight?:true
        params.flimit = 999
        def url = elasticBaseUrl + commonService.buildUrlParamsFromMap(params)
        log.debug "url = $url"
        webService.getJson(url)
    }

    def allGeoPoints(params) {
        addDefaultFacetQuery(params)
        params.max = 9999
        params.flimit = 999
        params.fsort = "term"
        params.offset = 0
        params.query = "geo.loc.lat:*"
        params.facets = "stateFacet,nrmFacet,lgaFacet,mvgFacet"
        def url = elasticBaseUrl + commonService.buildUrlParamsFromMap(params)
        log.debug "allGeoPoints - $url with $params"
        webService.getJson(url)
    }

    def allProjects(params, String searchTerm = null) {
        addDefaultFacetQuery(params)
        //params.max = 9999
        params.flimit = params.flimit?:999
        params.fsort = params.fsort?:"term"
        //params.offset = 0

        params.query = "docType:project"
        if (searchTerm) {
            params.query += " AND " + searchTerm
        }

        params.facets = params.facets?:"statesFacet,lgasFacet,nrmsFacet,organisationFacet,mvgsFacet"
        //def url = elasticBaseUrl + commonService.buildUrlParamsFromMap(params)
        def url = grailsApplication.config.ecodata.service.url + '/search/elasticHome' + commonService.buildUrlParamsFromMap(params)
        log.debug "url = $url"
        webService.getJson(url)
    }

    /**
     * Queries the homepage index for projects.
     * @param params the query parameters
     * @param skipDefaultFacetQuery true if the default query filters defined by the hub should be ommitted.
     * @return a map containing the search results.
     */
    Map findProjects(GrailsParameterMap params, boolean skipDefaultFacetQuery = false){
        if (!skipDefaultFacetQuery) {
            addDefaultFacetQuery(params)
        }
        String url = grailsApplication.config.ecodata.service.url + '/search/elasticHome' + commonService.buildUrlParamsFromMap(params)
        log.debug "url = $url"
        webService.getJson(url)
    }

    def downloadProjectData(HttpServletResponse response, Map params) {
        webService.proxyGetRequest(response, "${grailsApplication.config.ecodata.service.url}/search/downloadAllData${commonService.buildUrlParamsFromMap(params)}", true, true)
    }

    Map searchProjectActivity(GrailsParameterMap params, String q = null){
        String url = grailsApplication.config.ecodata.service.url + '/search/elasticProjectActivity' + commonService.buildUrlParamsFromMap(params)
        log.debug "url = $url"
        webService.getJson(url, null, true)
    }

    /**
     * Execute elastic search for site with given parameters.
     * @param params
     * @return
     * @throws SocketTimeoutException
     * @throws Exception
     */
    Map searchForSites(GrailsParameterMap params) throws SocketTimeoutException, Exception{
        String url = grailsApplication.config.ecodata.service.url + '/search/elasticPost'
        log.debug "url = $url"
        Map response = webService.doPost(url, params)
        if(response.error){
            if(response.error.contains('Timed out')){
                throw new SocketTimeoutException(response.error)
            } else {
                throw  new Exception(response.error);
            }

        }

        response?.resp
    }

    def allProjectsInHub(request) {
        String hubId = settingService.getHubConfig().hubId
        cacheService.get('projects-in-hub-'+ hubId, {
            GrailsParameterMap params = new GrailsParameterMap([flimit: 1000000, facets: "projectId", size: 0], request)
            Map searchHits = allProjects(params)
            searchHits?.facets?.projectId?.terms?.collect { it.term }
        })
    }

    def clearCachedProjectsInHubs() {
        cacheService.clearCacheMatchingPattern("^projects-in-hub-.+")
    }

    def clearCachedProjectsInHub(String hubId) {
        String key = "projects-in-hub-" + hubId
        cacheService.clear(key)
    }

    def allProjectsWithSites(params, String searchTerm = null) {
        addDefaultFacetQuery(params)
        params.flimit =  params.flimit ?: 999
        params.fsort =  params.fsort ?: "term"

        if(!params.query) {
            params.query = "docType:project"
            if (searchTerm) {
                params.query += " AND " + searchTerm
            }
        }

        def url = grailsApplication.config.ecodata.service.url + '/search/elasticGeo' + commonService.buildUrlParamsFromMap(params)
        log.debug "url = $url"
        webService.getJson(url)
    }

    def allSites(params) {
        addDefaultFacetQuery(params)
        //params.max = 9999
        params.flimit = 999
        params.fsort = "term"
        //params.offset = 0
//        params.query = "docType:site"
        params.fq = "docType:site"
        //def url = elasticBaseUrl + commonService.buildUrlParamsFromMap(params)
        def url = grailsApplication.config.ecodata.service.url + '/search/elasticHome' + commonService.buildUrlParamsFromMap(params)
        log.debug "url = $url"
        webService.getJson(url)
    }

    def HomePageFacets(originalParams) {

        def params = originalParams.clone()
        params.flimit = 999
        params.fsort = "term"
        //params.offset = 0
        params.query = "docType:project"
        params.facets = params.facets ?: StringUtils.join(SettingService.getHubConfig().availableFacets,',')

        addDefaultFacetQuery(params)

        def url = grailsApplication.config.ecodata.service.url + '/search/elasticHome' + commonService.buildUrlParamsFromMap(params)
        log.debug "url = $url"
        def jsonstring = webService.get(url)
        try {
            def jsonObj = new JsonSlurper().parseText(jsonstring)
            jsonObj
        } catch(Exception e){
            log.error(e.getMessage(), e.toString())
            [error:'Problem retrieving home page facets from: ' + url]
        }
    }

    def getProjectsForIds(params) {
        addDefaultFacetQuery(params)
        //params.max = 9999
        params.remove("action");
        params.remove("controller");
        params.maxFacets = 100
        //params.offset = 0
        def ids = params.ids

        if (ids) {
            params.remove("ids");
            def idList = ids.tokenize(",")
            params.query = "_id:" + idList.join(" OR _id:")
            params.facets = "stateFacet,nrmFacet,lgaFacet,mvgFacet"
            def url = grailsApplication.config.ecodata.service.url + '/search/elasticPost'
            webService.doPost(url, params)
        } else if (params.query) {
            def url = elasticBaseUrl + commonService.buildUrlParamsFromMap(params)
            webService.getJson(url)
        } else {
            [error: "required param ids not provided"]
        }
    }

    def dashboardReport(params) {

        cacheService.get("dashboard-"+params, {
            addDefaultFacetQuery(params)
            params.query = 'docType:project'
            def url = grailsApplication.config.ecodata.service.url + '/search/dashboardReport' + commonService.buildUrlParamsFromMap(params)
            webService.getJson(url, 1200000)
        })


    }

    def report(params) {
        cacheService.get("dashboard-"+params, {
            addDefaultFacetQuery(params)
            params.query = 'docType:project'
            def url = grailsApplication.config.ecodata.service.url + '/search/report' + commonService.buildUrlParamsFromMap(params)
            webService.getJson(url, 1200000)
        })
    }

    /**
     * Standardise facet results
     */
    List standardiseFacets(Map facets, List orderList) {
        List results = []
        if(facets) {
            if(orderList){
                orderList.each { k ->
                    Map result = formatFacet(facets[k], k)
                    if(result){
                        results << result
                    }
                }
            } else {
                facets?.each { k, v ->
                    Map result = formatFacet(facets[k], k)
                    if(result){
                        results << result
                    }
                }
            }
        }

        results
    }

    Map formatFacet(Map item, String name){
        if(item){
            Map facet = [:]
            facet.name = name
            facet.total = item.total
            facet.terms = item.terms
            facet.ranges = item.ranges
            facet.entries = item.entries
            facet.type = item._type

            facet
        }
    }

    /**
     * Presence Absence is custom logic. This function is used to implement that custom logic.
     * @param facets
     * @param configs
     * @return
     */
    List standardisePresenceAbsenceFacets(List facets, List configs){
        facets?.each { facet ->
            Map facetConfig = configs?.find({ it.name == facet.name })
            if(facetConfig){
                if(facet.ranges.size() == 2){
                    if(facet.ranges[0].to == 1){
                        facet.ranges[0].title = 'Absence'
                    } else if(facet.ranges[1].to == 1) {
                        facet.ranges[1].title = 'Absence'
                    }

                    if(facet.ranges[1].from == 1){
                        facet.ranges[1].title = 'Presence'
                    } else if(facet.ranges[0].from == 1) {
                        facet.ranges[0].title = 'Presence'
                    }

                }
            }
        }
    }

    /**
     * Convert elastic search's histogram facet representation to range format. This makes it easy to render on browser
     * since range facet view model can be re-used.
     * @param facets
     * @param facetConfig
     * @return
     */
    List standardiseHistogramFacets(List facets, List histogramFacetConfig){
        histogramFacetConfig.each { histogramConfig ->
            Map facet = facets.find {it.name == histogramConfig.name }
            List entries = facet.remove('entries')
            facet.ranges = convertHistogramToRangeFormat(entries, Integer.parseInt(histogramConfig.interval?.toString()))
            facet.type = 'range'
        }

        facets
    }

    /**
     * Convert elastic search's histogram representation to range representation.
     * Range representation has two parameters - from and to. This function creates the number range using interval parameter.
     * @param entries
     * @param interval
     * @return
     */
    List convertHistogramToRangeFormat(List entries, Integer interval){
        List ranges = []

        entries?.eachWithIndex { entry, index ->
            ranges.add([ from: entry.key,  to: entry.key + interval, count: entry.count ])
        }

        ranges
    }


}
