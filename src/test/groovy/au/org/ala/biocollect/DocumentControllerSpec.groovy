package au.org.ala.biocollect

import au.org.ala.biocollect.merit.DocumentService
import au.org.ala.biocollect.merit.WebService
import grails.testing.web.controllers.ControllerUnitTest
import org.apache.http.HttpStatus
import spock.lang.Specification

class DocumentControllerSpec extends Specification implements ControllerUnitTest<DocumentController> {

    DocumentService documentService = Mock(DocumentService)
    WebService webService = Mock(WebService)

    def setup() {
        controller.documentService = documentService
        controller.webService = webService
        controller.grailsApplication = grailsApplication
    }

    def "The document controller will ensure a document exists and the user has permission to view it before facilitating the download"() {
        setup:
        Map document = [documentId:'d1']

        when:
        request.requestURI = "/document/download/path/file.txt"
        def resp = controller.download()

        then:
        1 * documentService.search([filepath:"path", filename:"file.txt"]) >> [count: 1, documents:[document]]
        1 * documentService.canView(document) >> true
        1 * webService.proxyGetRequest(response, {it.endsWith('document/download/path/file.txt')}, false, false)
        resp == null
    }

    def "The document controller understands the thumbnail prefix assigned to a document path"() {
        setup:
        Map document = [documentId:'d1']

        when:
        request.requestURI = "/document/download/path/thumb_file.png"
        def resp = controller.download()

        then:
        1 * documentService.search([filepath:"path", filename:"file.png"]) >> [count: 1, documents:[document]]
        1 * documentService.canView(document) >> true
        1 * webService.proxyGetRequest(response, {it.endsWith('document/download/path/thumb_file.png')}, false, false)
        resp == null
    }

    def "The document controller will return an error if no document matches the path requested for a download"() {

        when:
        request.requestURI = "/document/download/path/file.txt"
        controller.download()

        then:
        1 * documentService.search([filepath:"path", filename:"file.txt"]) >> [count: 0, documents:[]]
        0 * documentService._
        0 * webService._
        response.status == HttpStatus.SC_NOT_FOUND
    }

    def "The document controller will return an error if the user cannot view the document associated with the path requested for a download"() {
        setup:
        Map document = [documentId:'d1']

        when:
        request.requestURI = "/document/download/path/file.txt"
        controller.download()

        then:
        1 * documentService.search([filepath:"path", filename:"file.txt"]) >> [count: 1, documents:[document]]
        1 * documentService.canView(document) >> false
        0 * webService._
        response.status == HttpStatus.SC_NOT_FOUND
    }

    def "The DocumentController encodes filenames used in URLs as required"() {
        expect:
        controller.buildDownloadUrl("2018-01", "Test with spaces").endsWith("/document/download/2018-01/Test%20with%20spaces")
        controller.buildDownloadUrl(null, "test").endsWith("/document/download/test")
        controller.buildDownloadUrl(null, "a&test").endsWith("/document/download/a&test")

    }

    def "The DocumentController can extract the path and filename from the URL"(String path, String filename, String expectedPath, String expectedFilename) {
        setup:
        String prefix = "/document/download/"
        String url
        if (path) {
            url = prefix + path + '/' + filename
        }
        else {
            url = prefix + filename
        }

        when:
        String[] result = controller.parsePathAndFilenameFromURL(url, "UTF-8")

        then:
        result[0] == expectedPath
        result[1] == expectedFilename

        where:
        path     | filename         | expectedPath | expectedFilename
        "2017-1" | "image.png"      | "2017-1"     | "image.png"
        "2017-1" | "im%20ge%3F.png" | "2017-1"     | "im ge?.png"
        ""       | "image.png"      | null         | "image.png"


    }

}
