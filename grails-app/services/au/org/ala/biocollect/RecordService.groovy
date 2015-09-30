package au.org.ala.biocollect

class RecordService {

    def webService, grailsApplication

    def listUserRecords(userId, query){
        def params = '?'+ query.collect { k,v -> "$k=$v" }.join('&')
        webService.getJson(grailsApplication.config.ecodata.service.url + '/record/listForUser/' + userId + params)
    }

}
