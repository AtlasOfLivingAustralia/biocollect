package au.org.ala.biocollect.sightings

import grails.plugin.cache.Cacheable
import org.codehaus.groovy.grails.web.json.JSONArray

class BieService {
    def grailsApplication, httpWebService

    @Cacheable('longTermCache')
    def Map getSpeciesGroupsMap() {
        JSONArray resp = httpWebService.getJson("${grailsApplication.config.bie.baseURL}/subgroups.json")
        Map groupsMap = [:]
        resp.each {
            groupsMap.put(it.speciesGroup, it.taxa)
        }
        groupsMap
    }
}
