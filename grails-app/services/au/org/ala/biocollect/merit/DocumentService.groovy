package au.org.ala.biocollect.merit

import grails.converters.JSON
import org.springframework.context.MessageSource

/**
 * Proxies to the ecodata DocumentController/DocumentService.
 */
class DocumentService {
    public String ROLE_LOGO = "logo"

    def webService, grailsApplication
    MessageSource messageSource

    def get(String id) {
        def url = "${grailsApplication.config.ecodata.service.url}/document/${id}"
        return webService.getJson(url)
    }

    def delete(String id) {
        def url = "${grailsApplication.config.ecodata.service.url}document/${id}"
        return webService.doDelete(url)
    }

    def createTextDocument(doc, content) {
        doc.content = content
        updateDocument(doc)
    }

    def updateDocument(doc) {
        def url = "${grailsApplication.config.ecodata.service.url}/document/${doc.documentId?:''}"

        return webService.doPost(url, doc)
    }

    def createDocument(doc, contentType, inputStream) {

        def url = grailsApplication.config.ecodata.service.url + "/document"

        def params = [document:doc as JSON]
        return webService.postMultipart(url, params, inputStream, contentType, doc.filename)
    }

    def getDocumentsForSite(id) {
        def url = "${grailsApplication.config.ecodata.service.url}/site/${id}/documents"
        return webService.doPost(url, [:])
    }

    /**
     * This method saves a document that has been staged (the image uploaded, but the document object not
     * created).  The purpose of this is to support atomic create / edits of objects that include document
     * references, e.g. activities containing photo point photos and organisations.
     * @param document the document to save.
     */
    def saveStagedImageDocument(document) {
        def result
        if (!document.documentId) {
            document.remove('url')
            def file = new File(grailsApplication.config.upload.images.path, document.filename)
            // Create a new document, supplying the file that was uploaded to the ImageController.
            result = createDocument(document, document.contentType, new FileInputStream(file))
            if (!result.error) {
                file.delete()
            }
        }
        else {
            // Just update the document.
            result = updateDocument(document)
        }
        result
    }

    def saveLink(link) {
        link.public = true
        link.type = "link"
        link.externalUrl = link.remove('url')
        updateDocument(link)
    }

    Map search(Map params) {
        def url = "${grailsApplication.config.ecodata.baseURL}/ws/document/search"
        def resp = webService.doPost(url, params)
        if (resp && !resp.error) {
            return resp.resp
        }
        return resp
    }

    /**
     * de reference licence code and adds the value to licenceDescription property
     * @param documents
     * @return
     */
    public List addLicenceDescription (List documents){
        documents?.each{ document ->
            if(document.licence){
                document.licenceDescription = messageSource.getMessage('licence.' + document.licence.replace(' ', '_'), [].toArray(), '', Locale.default);
            }
        }

        documents;
    }
}
