package au.org.ala.biocollect.merit

import grails.converters.JSON

class ProjectActivityController {
    def projectActivityService,  speciesService, documentService
    static ignore = ['action','controller','id']

    @PreAuthorise(accessLevel = 'admin', projectIdParam = "projectId")
    def ajaxCreate() {

        def postBody = request.JSON
        log.debug "Body: " + postBody
        log.debug "Params:"
        params.each { println it }
        def values = [:]
        postBody.each { k, v ->
            if (!(k in ignore)) {
                values[k] = v
            }
        }
        log.debug "values: " + (values as JSON).toString()
        def result = projectActivityService.create(values)

        if(result.error){
            response.status = 500
        } else {
            render result as JSON
        }
    }

    @PreAuthorise(accessLevel='admin', projectIdParam = "projectId")
    def ajaxUpdate(String id) {
        def postBody = request.JSON
        def values = [:]
        postBody.each { k, v ->
            if (!(k in ignore)) {
                values[k] = v
            }
        }
        def documents = values.remove('documents')
        def result = projectActivityService.update(id, values)
        def projectActivityId = values.projectActivityId?:result.resp?.projectActivityId

        if (documents && !result.error) {
            documents.each { doc ->
                if(doc.status == "deleted"){
                    result.doc  = documentService.updateDocument(doc)
                }else if(!doc.documentId){
                    doc.projectActivityId = projectActivityId
                    result.doc = documentService.saveStagedImageDocument(doc)
                }
            }
        }

        if(result.error){
            response.status = 500
        } else {
            render result as JSON
        }
    }

    @PreAuthorise(accessLevel = 'admin', projectIdParam = "projectId")
    def ajaxAddNewSpeciesLists(){

        def postBody = request.JSON
        log.debug "Body: " + postBody
        log.debug "Params:"
        params.each { println it }

        def values = [:]
        postBody.each { k, v ->
            if (!(k in ignore)) {
                values[k] = v
            }
        }
        log.debug "values: " + (values as JSON).toString()
        def response = speciesService.addSpeciesList(postBody);
        def result
        if(response?.resp?.druid){
            result =  [status: "ok", id: response.resp.druid]
        } else {
            result = [status: 'error', error: "Error creating new species lists, please try again later."]
        }
        render result as JSON
    }
}
