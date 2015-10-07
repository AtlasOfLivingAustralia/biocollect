package au.org.ala.biocollect

import grails.converters.JSON

class RecordController {
    def userService, projectActivityService, recordService

    def ajaxList(){
        render listUserRecords(params) as JSON
    }

    def ajaxListForProject(String id){
        def model = [:]
        def query = [pageSize: params.max ?: 10,
                     offset: params.offset ?: 0,
                     sort: params.sort ?: 'lastUpdated',
                     order: params.order ?: 'desc']
        def results = recordService.listProjectRecords(id, query)
        results?.list?.each{
            it.pActivity = projectActivityService.get(it.projectActivityId)
        }
        model.records = results?.list
        model.total = results?.total
        render model as JSON
    }

    private def listUserRecords(params){
        def model = [:]
        def query = [pageSize: params.max ?: 10,
                     offset: params.offset ?: 0,
                     sort: params.sort ?: 'lastUpdated',
                     order: params.order ?: 'desc']
        def results = recordService.listUserRecords(userService.getCurrentUserId(), query)
        results?.list?.each{
            it.pActivity = projectActivityService.get(it.projectActivityId)
        }
        model.records = results?.list
        model.total = results?.total
        model
    }

}
