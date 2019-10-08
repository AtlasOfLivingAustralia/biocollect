package au.org.ala.biocollect.merit
import grails.converters.JSON
import org.apache.commons.lang.StringUtils
import org.springframework.http.HttpStatus

class SearchController {
    def searchService, webService, speciesService, commonService, projectActivityService
    grails.core.GrailsApplication grailsApplication

    /**
     * Main search page that takes its input from the search bar in the header
     * @param query
     * @return resp
     */
    def index(String query) {
        params.facets = StringUtils.join(SettingService.getHubConfig().availableFacets,',')+',className'
        [facetsList: params.facets.tokenize(","), results: searchService.fulltextSearch(params)]
    }

    /**
     * Handles queries to support autocomplete for species fields.
     * @param q the typed query.
     * @param limit the maximum number of results to return
     * @return
     */
    def species(String q, Integer limit) {
        render speciesService.searchForSpecies(q, limit, params.listId) as JSON
    }

    def searchSpeciesList(String sort, Integer max, Integer offset, String guid, String order, String searchTerm){
        render speciesService.searchSpeciesList(sort, max, offset, guid, order, searchTerm) as JSON
    }

    //Search species by project activity species constraint.
    def searchSpecies(String id, String q, Integer limit, String output, String dataFieldName){
        try {
            def result = projectActivityService.searchSpecies(id, q, limit, output, dataFieldName)
            render result as JSON
        } catch (Exception ex){
            log.error( ex.message )
            render status: HttpStatus.INTERNAL_SERVER_ERROR, text: "An error occurred - ${ex.message}"
        }
    }

    def getCommonKeys(){
        try {
            if(params.druid){
                def resp = webService.getJson("${grailsApplication.config.lists.baseURL}/ws/listCommonKeys?druid=${params.druid}")?:[]
                if(resp instanceof List){
                    if(grailsApplication.config.lists.commonFields){
                        resp?.addAll(grailsApplication.config.lists.commonFields)
                    }

                    resp.sort()
                    render text: resp as JSON, contentType: 'application/json'
                } else {
                    render text: resp.error, status: resp.statusCode?:HttpStatus.INTERNAL_SERVER_ERROR
                }
            } else {
                render status: HttpStatus.BAD_REQUEST, text: 'Parameter druid is required.'
            }
        } catch (Exception ex){
            log.error( ex )
            render status: HttpStatus.INTERNAL_SERVER_ERROR, text: "An error occurred - ${ex.message}"
        }
    }

    def getAllProjectsInHub () {
        def projects = searchService.allProjectsInHub(request)
        render( text: projects as JSON, contentType: 'application/json')
    }

   /*
    * Returns Lists KVP values
    * @param id unique species guid
    * @param listId unique list id
    *
    * Example: /search/getSpeciesTranslation?id=urn:lsid:biodiversity.org.au:afd.taxon:4136b6d0-b5be-45d4-8323-e96e03d94218&listId=dr8016
    * */
    def getSpeciesTranslation(String id, String listId) {
        def items = webService.getJson("${grailsApplication.config.lists.baseURL}/ws/speciesListItems/${listId}?includeKVP=true")?:[]
        def kvp = [:]
        if(items instanceof List){
            items.each {
                if("${it.lsid}" == "${id}") {
                    kvp = it.kvpValues
                }
            }
        }
        render kvp as JSON
    }
}
