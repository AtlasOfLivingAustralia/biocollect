package au.org.ala.biocollect.merit

class OutputService {

    def webService, grailsApplication
    DocumentService documentService

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

    List getOutputForActivity(String activityId){
        webService.getJson(grailsApplication.config.ecodata.service.url + "/output?activityId=${activityId}")
    }

    /**
     * iterates over output data and saves images into ecodata
     * @param activityId
     * @param outputs
     * @return
     */
    List updateImages(activityId, outputs){
        List result = [], activityOutputs;
        Map document, savedOutput
        String documentId

        if(activityId && outputs.size() > 0){
            activityOutputs = getOutputForActivity(activityId);
            outputs.each { output ->
                savedOutput = null;
                activityOutputs.each{
                    if(it.name==output.name){
                        savedOutput = it
                    }
                }

                if(savedOutput){
                    output.outputId = savedOutput.outputId;
                }

                output.data.each{ key, value ->
                    if(key == 'imageList'){
                        value?.each{
                            if(!it.documentId){
                                it.activityId = activityId
                                it.remove('staged')
                                it.role = 'surveyImage'
                                it.type = 'image'
                                document = documentService.saveStagedImageDocument(it);
                                documentId = document?.content?.documentId;
                                if(documentId){
                                    result.push(documentId);
                                }
                            } else {
                                documentService.updateDocument(it);
                                // if deleted ignore the document
                                if(it.status != 'deleted'){
                                    result.push(it.documentId);
                                }
                            }
                        }
                        output.data[key] = result;
                    }
                }
            }
        }

        outputs
    }

    /**
     * Get Output Species Identifier
     *
     * @return output species identifier.
     */
    def getOutputSpeciesId() {
        webService.getJson(grailsApplication.config.ecodata.service.url + "/output/getOutputSpeciesUUID")
    }
}