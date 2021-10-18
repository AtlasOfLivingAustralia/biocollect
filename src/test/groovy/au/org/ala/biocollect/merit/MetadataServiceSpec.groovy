package au.org.ala.biocollect.merit

import grails.testing.spring.AutowiredTest
import spock.lang.Specification

/**
 * Tests for the MetadataServiceSpec
 */
public class MetadataServiceSpec extends Specification implements AutowiredTest{
    Closure doWithSpring() {{ ->
        service MetadataService
    }}

    MetadataService service

    def webServiceStub = Mock(WebService)

    void setup() {
        service.webService = webServiceStub
        service.grailsApplication = grailsApplication
        grailsApplication.config.ecodata.service.url = "http://test"
    }

    def "clear metadata cache"() {
        given:
        def response = [resp: "done", statusCode: "200"]

        when:
        def methodResponse = service.clearEcodataCache()

        then:
        1 * webServiceStub.doGet('http://test/admin/clearMetadataCache', null) >> response
        methodResponse.resp == "done"
        methodResponse.statusCode == "200"

    }
}
