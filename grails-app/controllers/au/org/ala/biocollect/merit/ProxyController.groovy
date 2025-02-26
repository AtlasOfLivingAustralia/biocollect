package au.org.ala.biocollect.merit

import au.org.ala.ecodata.forms.SpeciesListService
import grails.converters.JSON
import org.apache.commons.io.FilenameUtils
import au.org.ala.web.SSO

class ProxyController {
    static responseFormats = ['json']
    def webService, commonService, projectService
    SpeciesService speciesService

    def geojsonFromPid(String pid) {
        def shpUrl = "${grailsApplication.config.spatial.layersUrl}/shape/geojson/${pid}"
        log.debug "requesting pid ${pid} URL: ${shpUrl}"
        def resp = webService.get(shpUrl, false)
        //log.debug resp
        render resp as String
    }

    def speciesLists() {
        respond speciesListService.searchSpeciesList(params.sort, params.max, params.offset, params.guid, params.order, params.searchTerm)
    }

    def speciesList() {
        SpeciesListService.SpeciesList speciesList = speciesListService.getSpeciesListMetadata(params.druid)
        // it is possible for old species list to return list of species list when druid is not found
        if (!speciesList.isValid())
            speciesList = null

        respond speciesList
    }

    def speciesItemsForList() {
        respond speciesListService.allSpeciesListItems(params.druid)
    }

    def intersect(){
        render webService.get("${grailsApplication.config.spatial.layersUrl}/intersect/${params.layerId}/${params.lat}/${params.lng}", false)
    }

    def features(){
        render webService.get("${grailsApplication.config.spatial.layersUrl}/objects/${params.layerId}", false)
    }

    def feature(){
        render webService.get("${grailsApplication.config.spatial.layersUrl}/object/${params.featureId}", false)
    }

    def speciesProfile(String id) {
        Map result = speciesService.getSpeciesDetailsForTaxonId(id)
        render result
    }

    @SSO
    def speciesListPost() {
        def postBody = request.JSON
        def postResponse = speciesService.addSpeciesList(postBody)
        String druid = postResponse?.druid
        if (druid) {
            postBody.druid = druid
            def result = projectService.update(postBody.projectId, [listId: druid, listReason: postBody.reason])

            if (result.error) {
                render result as JSON
            }
            render postBody as JSON
        } else {
            render status: 500, text: postResponse.error?:"Error calling webservice"
        }
    }

    /**
     * Proxies to the ecodata document controller.
     * @param id the id of the document to update (if not supplied, a create operation will be assumed).
     * @return the result of the update.
     */
    @SSO
    def documentUpdate(String id) {

        def url = grailsApplication.config.ecodata.service.url + "/document" + (id ? "/" + id : '')
        if (request.respondsTo('getFile')) {
            def f = request.getFile('files')
            def originalFilename = f.getOriginalFilename()
            if(originalFilename){
                def extension = FilenameUtils.getExtension(originalFilename)?.toLowerCase()
                if (extension && !grailsApplication.config.upload.extensions.blacklist.contains(extension)){
                    def result =  webService.postMultipart(url, [document:params.document], f).content as JSON
                    // iframe submit no longer supported.
                    response.setContentType('application/json')
                    render result.toString();
                } else {
                    response.setStatus(400)
                    //flag error for extension
                    def error = [error: "Files with the extension '.${extension}' are not permitted.",
                    statusCode: "400",
                    detail: "Files with the extension ${extension} are not permitted."] as JSON
                    response.setContentType('application/json')
                    render error.toString()
                }
            } else {
                //flag error for extension
                response.setStatus(400)
                def error = [error: "Unable to retrieve the file name.",
                statusCode: "400",
                detail: "Unable to retrieve the file name."] as JSON
                response.setContentType('application/json')
                render error.toString()
            }
        } else {
            // iframe submit no longer supported.
            def result = webService.doPost(url, JSON.parse(params.document)) as JSON;
            response.setContentType('application/json')

            render result.toString()
        }
    }

    /**
     * Proxies to the eco data document controller to delete the document with the supplied id.
     * @param id the id of the document to delete.
     * @return the result of the deletion.
     */
    @SSO
    def deleteDocument(String id) {
        println 'deleting doc with id:'+id
        def url = grailsApplication.config.ecodata.service.url + "/document/" + id
        def responseCode = webService.doDelete(url)
        render status: responseCode
    }

    /**
     * Returns an excel template that can be used to populate a table of data in an output form.
     */
    def excelOutputTemplate() {
        String url =  "${grailsApplication.config.ecodata.service.url}/metadata/excelOutputTemplate"
        String expandList = params.expandList?:""
        String listName = params.listName?:null
        String includeDataPathHeader = params.includeDataPathHeader ?: false

        if (params.data) {
            webService.proxyPostRequest(response, url,
                    [listName:params.listName, type:params.type, data:params.data, editMode:params.editMode, allowExtraRows:params.allowExtraRows, autosizeColumns:false, expandList: expandList, includeDataPathHeader: includeDataPathHeader])
        }
        else {
            url += "?type=${params.type?.encodeAsURL()}&expandList=${expandList?.encodeAsURL()}&includeDataPathHeader=${includeDataPathHeader}"
            if(listName){
                url += "&listName=${params.listName.encodeAsURL()}"
            }
            webService.proxyGetRequest(response, url)
        }

        return null
    }

    /**
     * Returns an excel template that can be used to populate the bulk activity table
     */
    def excelBulkActivityTemplate() {

        String url =  "${grailsApplication.config.ecodata.service.url}/metadata/excelBulkActivityTemplate"

        webService.proxyPostRequest(response, url, params)
        return null
    }

    /** Proxies the ALA image service as the development server doesn't support SSL. */
    def getImageInfo(String id) {
        def detailsUrl = "${grailsApplication.config.images.baseURL}/ws/getImageInfo?id=${id}"
        def result = webService.getJson(detailsUrl) as JSON

        if (params.callback) {
            result = "${params.callback}(${result.toString()})"
            response.setContentType('text/plain;charset=UTF8')

            render result.toString()
        }
        else {
            render result
        }

    }
}
