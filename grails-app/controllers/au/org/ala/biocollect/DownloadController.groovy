package au.org.ala.biocollect

import au.org.ala.biocollect.merit.CommonService
import au.org.ala.biocollect.merit.UserService
import au.org.ala.biocollect.merit.WebService
class DownloadController {

    WebService webService
    CommonService commonService
    UserService userService

    def downloadProjectDataFile() {
        if (!params.id) {
            response.setStatus(400)
            render "A download ID is required"
        } else {
            String fileExtension = params.fileExtension ?: 'zip'
            webService.proxyGetRequest(response, "${grailsApplication.config.ecodata.service.url}/search/downloadProjectDataFile/${params.id}?fileExtension=${fileExtension}", true, true)
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
