package au.org.ala.biocollect.merit

class OutputService {

    def webService, grailsApplication

    def list() {
        def resp = webService.getJson(grailsApplication.config.ecodata.service.url + '/output/')
        resp.list
    }

    def get(id) {
        def record = webService.getJson(grailsApplication.config.ecodata.service.url + '/output/' + id)
        record
    }

    def update(id, body) {
        webService.doPost(grailsApplication.config.ecodata.service.url + '/output/' + id, body)
    }

    def delete(id) {
        webService.doDelete(grailsApplication.config.ecodata.service.url + '/output/' + id)
    }

}
