package au.org.ala.biocollect

import au.org.ala.biocollect.merit.MetadataService
import au.org.ala.biocollect.merit.ProjectService
import au.org.ala.biocollect.merit.SiteService
import au.org.ala.biocollect.merit.SpeciesService
import au.org.ala.biocollect.merit.WebService

class ProjectActivityService {

    def grailsApplication
    WebService webService
    SpeciesService speciesService
    SiteService siteService
    ProjectService projectService
    MetadataService metadataService

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

    def validate(props, projectActivityId) {
        def error = null
        def creating = !projectActivityId
        def published = props?.published.toString().toBoolean()

        def attributesAdded = []
        if (!creating) {
            def act = get(projectActivityId)
            if (act?.error) {
                return "invalid projectActivityId"
            }

            //when publishing always validate species, sites and pActivityFormName
            if (published) {
                if (!props?.species) {
                    attributesAdded.add("species")
                    props.species = act.species
                }
                if (!props?.sites) {
                    attributesAdded.add("sites")
                    props.sites = act.sites
                }
                if (!props?.pActivityFormName) {
                    attributesAdded.add("pActivityFormName")
                    props.pActivityFormName = act.pActivityFormName
                }
            }
        }

        if (props?.projectId) {
            def proj = projectService.get(props.projectId)
            if (proj?.error) {
                return "\"${props.projectId}\" is not a valid projectId"
            }
        } else if (creating) {
            //error, no description
            return "projectId is missing"
        }

        if (creating && !props?.status) {
            //error, no status
            return "status is missing"
        }

        if (creating && !props?.description) {
            //error, no description
            return "description is missing"
        }

        if (creating && !props?.name) {
            //error, no name
            return "name is missing"
        }

        if (creating && !props?.attribution) {
            //error, no attribution
            return "attribution is missing"
        }

        if (creating && !props?.startDate) {
            //error, no start date
            return "startDate is missing"
        }

        //error, no species constraint
        if (props?.species) {
            if (!(props.species instanceof Map)) {
                return "species is not a map"
            }

            if (props.species?.type) {
                if (props.species.type == 'SINGLE_SPECIES') {
                    if (!props.species?.singleSpecies ||
                            !(props.species.singleSpecies instanceof Map) ||
                            !props.species.singleSpecies?.guid ||
                            !props.species.singleSpecies?.name) {
                        return "invalid single_species for species type SINGLE_SPECIES"
                    }
                } else if (props.species.type == 'GROUP_OF_SPECIES'){
                    if (!props.species?.speciesLists ||
                            !(props.species.speciesLists instanceof List)) {
                        return "invalid speciesLists for species type GROUP_OF_SPECIES"
                    }
                    if (props.species.speciesLists.size() == 0) {
                        return "no speciesLists defined for GROUP_OF_SPECIES"
                    }
                    props.species.speciesLists.each {
                        if (!(it instanceof Map) || !it?.listName || !it?.dataResourceUid) {
                            error = "invalid speciesLists item for species type GROUP_OF_SPECIES"
                        }
                    }
                } else if (props.species.type != 'ALL_SPECIES') {
                    return "\"${props.species.type}\" is not a vaild species type"
                }
            }
        } else if (published) {
            return "species is missing"
        }

        if (props?.pActivityFormName) {
            def match = metadataService.activitiesModel().activities.findAll {
                it.name == props.pActivityFormName
            }
            if (match.size() == 0) {
                return "\"${props.pActivityFormName}\" is not a valid pActivityFormName"
            }
        } else if (published) {
            //error, no pActivityFormName
            return "pActivityFormName is missing"
        }

        if (props?.sites) {
            if (!(props.sites instanceof List)) {
                return "sites is not a list"
            } else if (props.sites.size() == 0) {
                return "no sites defined"
            } else {
                props.sites.each {
                    def site = siteService.get(it)
                    if (site?.error) {
                        error = "\"${it}\" is not a valid siteId"
                    }
                }
            }
        } else if (published) {
            //error, no sites
            return "sites are missing"
        }

        attributesAdded.each {
            props.remove(it)
        }

        error
    }

    def create(pActivity) {
        update('', pActivity)
    }

    def update(id, body) {
        def result = [:]

        def error = validate(body, id)
        if (error) {
            result.error = error
            result.detail = ''
        } else {
            result = webService.doPost(grailsApplication.config.ecodata.service.url + '/projectActivity/' + id, body)
        }

        result
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

        // process according to setting
        formatSpeciesNameForSurvey(pActivity, result)
        result
    }

    List formatSpeciesNameForSurvey(Map pActivity, Map data){
        data?.autoCompleteList?.each{
            it.name = formatSpeciesName(pActivity.speciesDisplayFormat?:'SCIENTIFICNAME(COMMONNAME)', it)
        }
    }

    String formatSpeciesName(String type, Map data){
        String name
        switch (type){
            case 'COMMONNAME(SCIENTIFICNAME)':
                if(data.commonName){
                    name = "${data.commonName} (${data.scientificName})"
                } else {
                    name = "${data.scientificName}"
                }
                break;
            case 'SCIENTIFICNAME(COMMONNAME)':
                if(data.commonName){
                    name = "${data.scientificName} (${data.commonName})"
                } else {
                    name = "${data.scientificName}"
                }

                break;
            case 'COMMONNAME':
                if(data.commonName){
                    name = "${data.commonName}"
                } else {
                    name = "${data.scientificName}"
                }
                break;
            case 'SCIENTIFICNAME':
                name = "${data.scientificName}"
                break;
        }

        name
    }

    /*
     *  Look for SINGLE_SPECIES for the given project activity
     *  @param projectActivityId project activity identifier
     *  @return map containing species name, guid and isSingle field to indicate whether it's of a 'SINGLE_SPECIES' category.
     */

    Map getSingleSpecies(String projectActivityId) {
        def pActivity = get(projectActivityId)
        Map result = [isSingle: false]
        switch (pActivity?.species?.type) {
            case 'SINGLE_SPECIES':
                result.isSingle = true
                if (pActivity?.species?.singleSpecies?.name && pActivity?.species?.singleSpecies?.guid) {
                    result.name = pActivity?.species?.singleSpecies?.name
                    result.guid = pActivity?.species?.singleSpecies?.guid
                }
                break
        }

        result
    }

    boolean isEmbargoed(Map projectActivity) {
        projectActivity?.visibility?.embargoUntil && Date.parse("yyyy-MM-dd", projectActivity.visibility.embargoUntil).after(new Date())
    }
}
