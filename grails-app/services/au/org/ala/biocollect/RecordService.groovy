package au.org.ala.biocollect

class RecordService {

    def webService, grailsApplication

    def listUserRecords(userId, query){
        def params = '?'+ query.collect { k,v -> "$k=$v" }.join('&')
        webService.getJson(grailsApplication.config.ecodata.service.url + '/record/listForUser/' + userId + params)
    }

    def listProjectRecords(id, query){
        def params = '?'+ query.collect { k,v -> "$k=$v" }.join('&')
        webService.getJson(grailsApplication.config.ecodata.service.url + '/record/listForProject/' + id + params)
    }

    def get(id) {
        webService.getJson(grailsApplication.config.ecodata.service.url + '/record/' + id)
    }

    def delete(id) {
        webService.doDelete(grailsApplication.config.ecodata.service.url + '/record/' + id)
    }


}
