package au.org.ala.biocollect

import grails.test.mixin.TestFor
import org.apache.http.HttpStatus
import spock.lang.Specification

import java.nio.charset.StandardCharsets

@TestFor(DownloadController)
class DownloadControllerSpec extends Specification {

    File scriptsPath
    File temp
    File hubPath
    File modelPath

    void setup() {

        temp = File.createTempDir("tmp", "")
        scriptsPath = new File(temp, "scripts")
        scriptsPath.mkdir()
        hubPath = new File(scriptsPath, "tempHub")
        hubPath.mkdir()
        modelPath = new File(hubPath, "tempModel")
        modelPath.mkdir()

        controller.grailsApplication.config.app.file.script.path = scriptsPath.getAbsolutePath()

        // Setup three files, one that should be accessible, and others that should not
        File validFile =  new File(modelPath, "validFile.js")
        validFile.createNewFile()

        File validImageFile =  new File(modelPath, "validPng.png")
        validImageFile.createNewFile()

        File txtFile =  new File(modelPath, "validFile.txt")
        txtFile.createNewFile()

        File privateFile = new File(temp, "privateFile.js")
        privateFile.createNewFile()
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
        new File(modelPath, params.filename).exists()
        response.status == HttpStatus.SC_NOT_FOUND
    }

    void "Tyring to read a file with extension which are not allowed to read"() {
        when:
        params.hub = "tempHub"
        params.filename = "validFile.txt"
        params.model = "tempModel"
        controller.getScriptFile()

        then:
        new File(modelPath, params.filename).exists()
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
}
