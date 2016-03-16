package au.org.ala.biocollect

import au.org.ala.biocollect.merit.CacheService
import grails.converters.JSON
import groovy.json.JsonSlurper

class RegionsController {

    CacheService cacheService

    Map regionsList() {
        def regionsJson = cacheService.get('regions-list', {
            new JsonSlurper().parse(new File("/data/biocollect/config/regions.json"))
        })

        render regionsJson as JSON
    }
}
