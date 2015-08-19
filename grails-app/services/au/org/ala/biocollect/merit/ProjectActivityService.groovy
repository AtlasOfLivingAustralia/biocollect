package au.org.ala.biocollect.merit

import grails.transaction.Transactional


class ProjectActivityService {

    def webService, grailsApplication

    def getAllByProject(projectId){
        webService.getJson(grailsApplication.config.ecodata.service.url + '/projectActivity/getAllByProject/'+ projectId).list
    }

    def get(projectActivityId){
        webService.getJson(grailsApplication.config.ecodata.service.url + '/projectActivity/get/'+ projectActivityId)
    }

    def create(pActivity) {
        update('', pActivity)
    }

    def update(id, body) {
        webService.doPost(grailsApplication.config.ecodata.service.url + '/projectActivity/' + id, body)
    }
}
