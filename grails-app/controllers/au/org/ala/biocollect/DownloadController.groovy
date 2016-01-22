package au.org.ala.biocollect

import au.org.ala.biocollect.merit.WebService
import groovyx.net.http.ContentType
import org.apache.commons.io.FilenameUtils

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

    def file() {
        if (params.id) {
            webService.proxyGetRequest(response, "${grailsApplication.config.ecodata.service.url}/document/${params.id}/file", true, true)
        } else if (params.filename) {
            String path = grailsApplication.config.upload.images.path
            File file = new File(FileUtils.fullPath(params.filename, path))
            if (file.exists()) {
                response.setHeader('Content-Disposition', "Attachment;Filename=\"${params.filename}\"")
                if (params.forceDownload?.toBoolean()) {
                    // set the content type to octet-stream to stop the browser from auto playing known types
                    response.setContentType('application/octet-stream')
                }
                response.outputStream << new FileInputStream(file)
                response.outputStream.flush()
            } else {
                response.status = 404
            }
        }
    }
}
