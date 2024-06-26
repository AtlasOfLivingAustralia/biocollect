package au.org.ala.biocollect.merit

import grails.testing.web.controllers.ControllerUnitTest
import org.apache.http.HttpStatus
import spock.lang.Specification
/**
 * Tests the ProxyController class.
 */
class ProxyControllerSpec extends Specification implements ControllerUnitTest<ProxyController> {

    def webServiceStub = Mock(WebService)

    def setup() {
        controller.webService = webServiceStub
        controller.grailsApplication.config.ecodata.service.url = "http://test"
    }


    def "Get an excel template that can be used to populate a table of data in an output form"() {
        when:
        params.expandList = 'true'
        params.listName = 'test'
        params.type = 'test'
        controller.excelOutputTemplate()

        then:
        1 * webServiceStub.proxyGetRequest(response, "http://test/metadata/excelOutputTemplate?type=test&expandList=true&includeDataPathHeader=false&listName=test")
        response.status == HttpStatus.SC_OK
    }

    def "Get an excel template without listName"() {
        when:
        params.expandList = 'true'
        params.listName = null
        params.type = 'test'
        controller.excelOutputTemplate()

        then:
        1 * webServiceStub.proxyGetRequest(response, "http://test/metadata/excelOutputTemplate?type=test&expandList=true&includeDataPathHeader=false")
        response.status == HttpStatus.SC_OK
    }
}
