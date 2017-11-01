package au.org.ala.biocollect.merit

import org.codehaus.groovy.grails.commons.GrailsApplication
import au.org.ala.biocollect.merit.WebService

class CollectoryService {


    GrailsApplication grailsApplication
    WebService webService

    Map licence(String id) {
        def url = "${grailsApplication.config.collectory.service.url}/licence/" + id.encodeAsURL()
        webService.getJson(url)
    }

    List licence() {
        def url = "${grailsApplication.config.collectory.service.url}/licence/"
        List licences = webService.getJson(url);
        licences.removeAll({!(it.url in ALAsupported())});
        return licences.unique();
    }

    private ALAsupported(){
        List filter = ['https://creativecommons.org/publicdomain/zero/1.0/','https://creativecommons.org/licenses/by-nc/2.5/','https://creativecommons.org/licenses/by/4.0/','https://creativecommons.org/licenses/by-nc/3.0/au/']
    }

}