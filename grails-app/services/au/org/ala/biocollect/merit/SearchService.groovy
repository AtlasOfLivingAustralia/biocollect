package au.org.ala.biocollect.merit
import groovy.json.JsonSlurper
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap

import javax.annotation.PostConstruct
import javax.servlet.http.HttpServletResponse

/**
 * Service for ElasticSearch running on ecodata
 */
class SearchService {
    def webService, commonService, cacheService, metadataService
    def grailsApplication
    def elasticBaseUrl

    @PostConstruct
    private void init() {
        elasticBaseUrl = grailsApplication.config.ecodata.service.url + '/search/elastic'
    }

    private def addDefaultFacetQuery(params) {
        def defaultFacetQuery = SettingService.getHubConfig().defaultFacetQuery
        if (defaultFacetQuery) {
            def fq = new HashSet(defaultFacetQuery)
            def paramFq = params.fq

            if (paramFq) {
                if (paramFq instanceof List) {
                    fq.addAll(paramFq)
                }
                else {
                    fq.add(paramFq)
                }
            }
            params.fq = fq.asList()
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
        params.flimit = 999
        params.fsort = "term"
        //params.offset = 0

        params.query = "docType:project"
        if (searchTerm) {
            params.query += " AND " + searchTerm
        }

        params.facets = "statesFacet,lgasFacet,nrmsFacet,organisationFacet,mvgsFacet"
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

    def allProjectsWithSites(params, String searchTerm = null) {
        addDefaultFacetQuery(params)
        //params.max = 9999
        params.flimit = 999
        params.fsort = "term"
        //params.offset = 0

        params.query = "docType:project"
        if (searchTerm) {
            params.query += " AND " + searchTerm
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
        params.facets = params.facets ?: SettingService.getHubConfig().availableFacets.join(',')

        addDefaultFacetQuery(params)

        def url = grailsApplication.config.ecodata.service.url + '/search/elasticHome' + commonService.buildUrlParamsFromMap(params)
        log.debug "url = $url"
        def jsonstring = webService.get(url)
        try {
            def jsonObj = new JsonSlurper().parseText(jsonstring)
            jsonObj
        } catch(Exception e){
            log.error(e.getMessage(), e)
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
}
