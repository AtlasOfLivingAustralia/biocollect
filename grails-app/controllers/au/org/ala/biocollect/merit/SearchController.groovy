package au.org.ala.biocollect.merit
import grails.converters.JSON
import org.apache.commons.lang.StringUtils

class SearchController {
    def searchService, webService, speciesService, grailsApplication, commonService, projectActivityService

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

    def searchSpeciesList(String sort, Integer max, Integer offset, String guid){
        render speciesService.searchSpeciesList(sort, max, offset, guid) as JSON
    }

    //Search species by project activity species constraint.
    def searchSpecies(String id, String q, Integer limit){

        def result = projectActivityService.searchSpecies(id, q, limit)
        render result as JSON
    }

}
