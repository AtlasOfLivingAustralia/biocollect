package au.org.ala.biocollect

import au.org.ala.biocollect.merit.SpeciesService
import au.org.ala.biocollect.merit.WebService

class ProjectActivityService {

    def grailsApplication
    WebService webService
    SpeciesService speciesService

    def getAllByProject(projectId, levelOfDetail = ""){
        def params = '?'
        params += levelOfDetail ? "view=${levelOfDetail}&" : ''
        webService.getJson(grailsApplication.config.ecodata.service.url + '/projectActivity/getAllByProject/'+ projectId + params).list
    }

    def get(projectActivityId, levelOfDetail = ""){
        def params = '?'
        params += levelOfDetail ? "view=${levelOfDetail}&" : ''
        webService.getJson(grailsApplication.config.ecodata.service.url + '/projectActivity/get/'+ projectActivityId + params)
    }

    def create(pActivity) {
        update('', pActivity)
    }

    def update(id, body) {
        webService.doPost(grailsApplication.config.ecodata.service.url + '/projectActivity/' + id, body)
    }

    def delete(id) {
        webService.doDelete(grailsApplication.config.ecodata.service.url + '/projectActivity/' + id)
    }

    /**
     * Searches for a species name taking into account the species constraints setup for the survey.
     * @param id the id of the ProjectActivity (survey) being completed
     * @param q query string to search for
     * @param limit the maximum number of results to return
     * @return json structure containing search results suitable for use by the species autocomplete widget on a survey form.
     */
    def searchSpecies(String id, String q, Integer limit){
        def pActivity = get(id)
        def result
        switch(pActivity?.species?.type){
            case 'SINGLE_SPECIES':
                result = speciesService.searchForSpecies(pActivity?.species?.singleSpecies?.name, 1)
                break

            case 'ALL_SPECIES':
                result = speciesService.searchForSpecies(q, limit)
                break

            case 'GROUP_OF_SPECIES':
                def lists = pActivity?.species?.speciesLists
                result = speciesService.searchSpeciesInLists(q, lists, limit)
                break
            default:
                result = [autoCompleteList: []]
                break
        }
        result
    }

    boolean isEmbargoed(Map projectActivity) {
        projectActivity?.visibility?.embargoUntil && Date.parse("yyyy-MM-dd", projectActivity.visibility.embargoUntil).after(new Date())
    }
}
