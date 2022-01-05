package au.org.ala.biocollect

import au.org.ala.biocollect.merit.WebService
import grails.testing.web.controllers.ControllerUnitTest
import org.apache.http.HttpStatus
import spock.lang.Specification

import java.nio.charset.StandardCharsets

class DownloadControllerSpec extends Specification implements ControllerUnitTest<DownloadController> {

    File scriptsPath
    File temp
    File hubPath
    File modelPath
    File configPath
    WebService webService
    def webServiceStub = Mock(WebService)

    void setup() {

        controller.webService = webServiceStub
        controller.grailsApplication.config.ecodata.service.url = "http://test"

        temp = File.createTempDir("tmp", "")
        scriptsPath = new File(temp, "scripts")
        scriptsPath.mkdir()
        hubPath = new File(scriptsPath, "tempHub")
        hubPath.mkdir()
        modelPath = new File(hubPath, "tempModel")
        modelPath.mkdir()

        controller.grailsApplication.config.app.file.script.path = scriptsPath.getAbsolutePath()
        controller.grailsApplication.config.upload.images.path = modelPath

        configPath = new File(temp, "config")
        configPath.mkdir()

        controller.grailsApplication.config.app.file.script.path = scriptsPath.getAbsolutePath()
//        controller.grailsApplication.config.ecodata.service.url = ""

        // Setup three files, one that should be accessible, and others that should not
        File validFile =  new File(modelPath, "validFile.js")
        validFile.createNewFile()

        File validImageFile =  new File(modelPath, "validPng.png")
        validImageFile.createNewFile()

        File txtFile =  new File(modelPath, "validFile.txt")
        txtFile.createNewFile()

        File privateFile = new File(temp, "privateFile.js")
        privateFile.createNewFile()

        File privateFile2 = new File(configPath, "privateFile2.js")
        privateFile2.createNewFile()
    }

    void "Files can be retrieved from the temporary scripts directory by filename"() {
        when:
        params.hub = "tempHub"
        params.filename = "validFile.js"
        params.model = "tempModel"
        controller.getScriptFile()

        then:
        response.contentType == "text/javascript"
        response.status == HttpStatus.SC_OK
    }

    void "If a file doesn't exist, a 404 will be returned"() {
        when:
        params.hub = "tempHub"
        params.filename = "missingFile.js"
        params.model = "tempModel"
        controller.getScriptFile()

        then:
        response.status == HttpStatus.SC_NOT_FOUND
    }

    void "A file cannot be retrieved from outside the designated scripts directory"() {
        when:
        params.hub = "tempHub"
        params.filename = "../../../privateFile.js"
        params.model = "tempModel"
        controller.getScriptFile()

        then:
        new File("${scriptsPath}${File.separator}${params.hub}${File.separator}${params.model}", params.filename).exists()
        response.status == HttpStatus.SC_NOT_FOUND
    }

    void "Tyring to read a file with extension which are not allowed to read"() {
        when:
        params.hub = "tempHub"
        params.filename = "validFile.txt"
        params.model = "tempModel"
        controller.getScriptFile()

        then:
        new File("${scriptsPath}${File.separator}${params.hub}${File.separator}${params.model}", params.filename).exists()
        response.status == HttpStatus.SC_NOT_FOUND
    }

    void "Test images"() {
        when:
        params.hub = "tempHub"
        params.filename = "validPng.png"
        params.model = "tempModel"
        controller.getScriptFile()

        then:
        response.contentType == "image/png"
        response.status == HttpStatus.SC_OK
    }

    void "Test character encoding"() {
        when:
        params.hub = "tempHub"
        params.filename = "validFile.js"
        params.model = "tempModel"
        controller.getScriptFile()

        then:
        response.contentType == "text/javascript"
        response.characterEncoding == StandardCharsets.UTF_8.toString()
        response.status == HttpStatus.SC_OK
    }

    void "A file cannot be retrieved via hub property which is from outside the designated scripts directory"() {
        when:
        params.hub = ".."
        params.filename = "privateFile2.js"
        params.model = "config"
        controller.getScriptFile()

        then:
        new File("${scriptsPath}${File.separator}${params.hub}${File.separator}${params.model}", params.filename).exists()
        response.status == HttpStatus.SC_NOT_FOUND
    }

    void "A file cannot be retrieved via model property which is from outside the designated scripts directory"() {
        when:
        params.hub = "tempHub"
        params.filename = "privateFile2.js"
        params.model = "../../config"
        controller.getScriptFile()

        then:
        new File("${scriptsPath}${File.separator}${params.hub}${File.separator}${params.model}", params.filename).exists()
        response.status == HttpStatus.SC_NOT_FOUND
    }

    def "Data can be downloaded for a created file if id and file extension is provided"(String inputFormat, String expectedOutputFormat) {
        setup:
        String projectId = 'p1'
//        controller.webService = webService = Mock(WebService)

        when:
        params.id = projectId
        params.fileExtension = inputFormat
        Map result = controller.downloadProjectDataFile()

        then:
        1 * webServiceStub.proxyGetRequest(response, 'http://test/search/downloadProjectDataFile/'+projectId+'?fileExtension='+expectedOutputFormat, true, true)
        result == null

        where:
        inputFormat | expectedOutputFormat
        'zip'       | 'zip'
        ''          | 'zip'
    }

    void "Check mandatory params"() {
        when:
        params.filename = "validFile.js"
        params.model = "tempModel"
        controller.getScriptFile()

        then:
        response.status == HttpStatus.SC_BAD_REQUEST
        response.text == "filename, hub or model is missing"

        when:
        params.hub = "tempHub"
        params.model = "tempModel"
        controller.getScriptFile()

        then:
        response.status == HttpStatus.SC_BAD_REQUEST
        response.text == "filename, hub or model is missing"

        when:
        params.hub = "tempHub"
        params.filename = "validFile.js"
        controller.getScriptFile()

        then:
        response.status == HttpStatus.SC_BAD_REQUEST
        response.text == "filename, hub or model is missing"
    }

    void "Download Project Data File - missing mandatory"() {
        when:
        params.id = null
        controller.downloadProjectDataFile()

        then:
        response.status == HttpStatus.SC_BAD_REQUEST
        response.text == "A download ID is required"
    }

    void "Download Project Data File"() {
        when:
        params.id = '1'
        params.fileExtension = 'zip'
        controller.downloadProjectDataFile()

        then:
        1 * webServiceStub.proxyGetRequest(response, 'http://test/search/downloadProjectDataFile/1?fileExtension=zip', true, true)
        response.status == HttpStatus.SC_OK
    }

    void "Get File - using id"() {
        when:
        params.id = '1'
        controller.file()

        then:
        1 * webServiceStub.proxyGetRequest(response, 'http://test/document/1/file', true, true)
        response.status == HttpStatus.SC_OK
    }

    void "Get File - using filename - invalid file"() {
        when:
        params.filename = 'invalidFile.js'
        controller.file()

        then:
        response.status == HttpStatus.SC_NOT_FOUND
    }

    void "Get File - using filename - valid file"() {
        when:
        params.filename = 'validFile.js'
        controller.file()

        then:
        response.status == HttpStatus.SC_OK
        response.getHeader('Content-Disposition') == "Attachment;Filename=\"validFile.js\""
    }

    void "Get File - using filename - valid file - force download"() {
        when:
        params.filename = 'validFile.js'
        params.forceDownload = true
        controller.file()

        then:
        response.status == HttpStatus.SC_OK
        response.getHeader('Content-Disposition') == "Attachment;Filename=\"validFile.js\""
        response.contentType == "application/octet-stream"
    }
}
