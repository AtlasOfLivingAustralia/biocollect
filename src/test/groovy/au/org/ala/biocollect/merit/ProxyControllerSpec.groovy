package au.org.ala.biocollect.merit

import grails.test.mixin.TestFor
import org.apache.http.HttpStatus
import spock.lang.Specification

import javax.servlet.http.HttpServletResponse

/**
 * Tests the ProxyController class.
 */
@TestFor(ProxyController)
class ProxyControllerSpec extends Specification {

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
        1 * webServiceStub.proxyGetRequest(response, "http://test/metadata/excelOutputTemplate?type=test&expandList=true&listName=test")
        response.status == HttpStatus.SC_OK
    }

    def "Get an excel template without listName"() {
        when:
        params.expandList = 'true'
        params.listName = null
        params.type = 'test'
        controller.excelOutputTemplate()

        then:
        1 * webServiceStub.proxyGetRequest(response, "http://test/metadata/excelOutputTemplate?type=test&expandList=true")
        response.status == HttpStatus.SC_OK
    }
}
