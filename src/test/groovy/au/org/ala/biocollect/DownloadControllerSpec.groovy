package au.org.ala.biocollect

import grails.test.mixin.TestFor
import org.apache.http.HttpStatus
import spock.lang.Specification

@TestFor(DownloadController)
class DownloadControllerSpec extends Specification {

    File scriptsPath
    File temp
    File hubPath

    void setup() {

        temp = File.createTempDir("tmp", "")
        scriptsPath = new File(temp, "scripts")
        scriptsPath.mkdir()
        hubPath = new File(scriptsPath, "tempHub")
        hubPath.mkdir()

        controller.grailsApplication.config.app.file.script.path = scriptsPath.getAbsolutePath()

        // Setup two files, one that should be accessible, and one that should not
        File validFile =  new File(hubPath, "validFile.js")
        validFile.createNewFile()

        File privateFile = new File(temp, "privateFile.js")
        privateFile.createNewFile()
    }

    void "Files can be retrieved from the temporary scripts directory by filename"() {
        when:
        params.hub = "tempHub"
        params.filename = "validFile.js"
        controller.getScriptFile()

        then:
        response.contentType == "text/javascript"
        response.status == HttpStatus.SC_OK
    }

    void "If a file doesn't exist, a 404 will be returned"() {
        when:
        params.hub = "tempHub"
        params.filename = "missingFile.js"
        controller.getScriptFile()

        then:
        response.status == HttpStatus.SC_NOT_FOUND
    }

    void "A file cannot be retrieved from outside the designated scripts directory"() {
        when:
        params.hub = "tempHub"
        params.filename = "../../privateFile.js"
        controller.getScriptFile()

        then:
        new File(hubPath, params.filename).exists()
        response.status == HttpStatus.SC_NOT_FOUND
    }
}
