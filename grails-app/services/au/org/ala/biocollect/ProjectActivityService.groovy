package au.org.ala.biocollect

class ProjectActivityService {

    def webService, grailsApplication

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

}
