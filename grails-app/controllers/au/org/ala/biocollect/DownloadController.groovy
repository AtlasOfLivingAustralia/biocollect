package au.org.ala.biocollect

import au.org.ala.biocollect.merit.CommonService
import au.org.ala.biocollect.merit.UserService
import au.org.ala.biocollect.merit.WebService
import org.apache.commons.io.FilenameUtils

import java.nio.charset.StandardCharsets

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
            return null
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

    /***
     * This method is used to read custom Js files under /data/biocollect/scripts directory.
     * @return
     */
    def getScriptFile() {
        if (params.filename && params.hub && params.model) {
            log.debug("Script name: " + params.filename)
            log.debug("Hub: " + params.hub)
            log.debug("Model: " + params.model)
            String filename = FilenameUtils.getName(params.filename)
            String hub = FilenameUtils.getName(params.hub)
            String model = FilenameUtils.getName(params.model)
            String path = "${grailsApplication.config.app.file.script.path}${File.separator}${hub}${File.separator}${model}${File.separator}${filename}"
            log.debug("Script path: " + path)

            if (filename != params.filename || hub != params.hub || model != params.model || FilenameUtils.normalize(path) != path) {
                response.status = 404
                return
            }

            def extension = FilenameUtils.getExtension(filename)?.toLowerCase()
            if (extension && !grailsApplication.config.script.read.extensions.list.contains(extension)){
                response.status = 404
                return
            }

            File file = new File(path)

            if (!file.exists()) {
                response.status = 404
                return null
            }

            if(extension == 'js' || extension == 'min.js') {
                response.setContentType('text/javascript')
                response.setCharacterEncoding(StandardCharsets.UTF_8.toString())
            }
            else if(extension == 'png'){
                response.setContentType('image/png')
            }
            response.outputStream << new FileInputStream(file)
            response.outputStream.flush()

            return null

        } else {
            response.status = 400
            render status:400, text: 'filename, hub or model is missing'
        }
    }
}
