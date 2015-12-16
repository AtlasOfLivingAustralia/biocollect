package au.org.ala.biocollect

import au.org.ala.biocollect.merit.WebService
import groovyx.net.http.ContentType

class DownloadController {

    WebService webService

    def downloadProjectDataFile() {
        if (!params.id) {
            response.setStatus(400)
            render "A download ID is required"
        } else {
            response.setContentType(ContentType.BINARY.toString())
            response.setHeader('Content-Disposition', 'Attachment;Filename="data.zip"')

            webService.proxyGetRequest(response, "${grailsApplication.config.ecodata.service.url}/search/downloadProjectDataFile/${params.id}", true, true)
        }
    }
}
