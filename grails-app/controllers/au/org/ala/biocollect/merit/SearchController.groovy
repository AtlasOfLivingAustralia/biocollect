package au.org.ala.biocollect.merit

import au.org.ala.ecodata.forms.SpeciesListService
import grails.converters.JSON
import org.apache.commons.lang.StringUtils
import org.springframework.http.HttpStatus

class SearchController {
    static responseFormats = ['json']
    def searchService, webService, speciesService, commonService, projectActivityService
    SpeciesListService speciesListService
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
        respond speciesService.searchForSpecies(q, limit, params.listId)
    }

    def searchSpeciesList(String sort, Integer max, Integer offset, String guid, String order, String searchTerm){
        respond speciesListService.searchSpeciesList(sort, max, offset, guid, order, searchTerm)
    }

    /**
     * Search species based on species field configuration of the project activity.
     * @param projectActivityId
     * @param q
     * @param limit
     * @param output
     * @param dataFieldName
     * @param offset
     * @return
     */
    def searchSpecies(String projectActivityId, String q, Integer limit, String output, String dataFieldName, Integer offset){
        try {
            // backward compatibility - id was replaced with projectActivityId
            projectActivityId = projectActivityId ?: params.id
            def result = projectActivityService.searchSpecies(projectActivityId, q, limit, output, dataFieldName, offset)
            render result as JSON
        } catch (Exception ex){
            log.error (ex.message.toString(), ex)
            render status: HttpStatus.INTERNAL_SERVER_ERROR, text: "An error occurred - ${ex.message}"
        }
    }

    def getCommonKeys(){
        if (params.druid) {
            List commonFields = speciesListService.getCommonKeys(params.druid)
            respond commonFields
        } else {
            render status: HttpStatus.BAD_REQUEST, text: 'Parameter druid is required.'
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
        SpeciesListService.SpeciesListItem items = speciesListService.allSpeciesListItems(listId) ?: []
        List kvp = []
        items.each {
            if (it.lsid == id) {
                kvp = it.kvpValues
            }
        }

        respond kvp
    }
}
