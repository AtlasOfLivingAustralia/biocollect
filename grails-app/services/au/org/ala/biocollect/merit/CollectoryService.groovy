package au.org.ala.biocollect.merit

import grails.core.GrailsApplication



/**
 * Licences provided by Collectory service are not fully supported by BioCollect,
 * Neither enough information for licences needed by BioCollect
 */
class CollectoryService {

    private static List BioCollectSupported =
            [[url: 'https://creativecommons.org/publicdomain/zero/1.0/', logo: "Cc-by-pd_icon.svg.png", description: "Public Domain Dedication"],
             [url: 'https://creativecommons.org/licenses/by-nc/2.5/', logo: "Cc-by-nc_icon.svg.png", description: "CC BY NC 2.5"],
             [url: 'https://creativecommons.org/licenses/by/4.0/', logo: "Cc-by_icon.svg.png", description: "CC BY 4.0"],
             [url: 'https://creativecommons.org/licenses/by-nc/3.0/au/', logo: "Cc-by-nc_icon.svg.png", description: "CC BY NC 3.0 AU"]
            ]


    GrailsApplication grailsApplication
    WebService webService

    List licence() {
        def url = "${grailsApplication.config.collectory.service.url}/licence/"
        List licences = webService.getJson(url);
        List bioSupported = this.BioCollectSupported;
        for (item in bioSupported) {
            String supported = item.url;
            def found = licences.find {
                supported == it.url
            }
            if (found) {
                item.name = found.name
            }
        }
        return bioSupported;
    }



}