package au.org.ala.biocollect.merit

import grails.core.GrailsApplication


/**
 * Licences provided by Collectory service are not fully supported by BioCollect.
 * Combine information from Biocollect and Collectory.
 */
class CollectoryService {

    private static List getSupported() {
        [
                [url: 'https://creativecommons.org/publicdomain/zero/1.0/', logo: "Cc-by-pd_icon.svg.png", description: "Public Domain Dedication"],
                [url: 'https://creativecommons.org/licenses/by-nc/2.5/', logo: "Cc-by-nc_icon.svg.png", description: "CC BY NC 2.5"],
                [url: 'https://creativecommons.org/licenses/by/4.0/', logo: "Cc-by_icon.svg.png", description: "CC BY 4.0"],
                [url: 'https://creativecommons.org/licenses/by-nc/3.0/au/', logo: "Cc-by-nc_icon.svg.png", description: "CC BY NC 3.0 AU"]
        ]
    }

    GrailsApplication grailsApplication
    WebService webService
    CacheService cacheService

    List licence() {
        List collectoryNames = cacheService.get('collectory-licence-names', {
            try {
                def url = "${grailsApplication.config.collectory.service.url}/licence/"
                def result = webService.getJson(url)
                if (result instanceof List) {
                    return result
                } else {
                    log.error("Could not get licences from collectory: '${result}'.")
                }
            } catch (Exception e) {
                log.error("Could not get licences from collectory.", e)
            }
            return []
        })

        supported.collect { supported ->
            def found = collectoryNames.find { retrieved ->
                supported.url == retrieved.url
            }
            if (found) {
                supported.name = found.name
            }
            supported
        }
    }


}