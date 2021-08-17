package au.org.ala.biocollect.merit

import au.org.ala.biocollect.merit.ActivityService
import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * Tests for the MetadataServiceSpec
 */
@TestFor(MetadataService)
public class MetadataServiceSpec extends Specification {

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
