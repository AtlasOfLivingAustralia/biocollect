package au.org.ala.biocollect.merit

import grails.test.mixin.TestFor
import grails.test.mixin.TestMixin
import grails.test.mixin.support.GrailsUnitTestMixin
import org.apache.commons.httpclient.HttpStatus
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.support.GrailsUnitTestMixin} for usage instructions
 */
@TestMixin(GrailsUnitTestMixin)
@TestFor(SiteController)
class SiteControllerSpec extends Specification {

    SiteService siteService = Stub(SiteService);

    def setup() {
        controller.siteService = siteService
    }

    def cleanup() {
    }

    void "getImages: when site id is not passed"() {
        when:
        controller.getImages();
        then:
        response.status == HttpStatus.SC_BAD_REQUEST
    }

    void "getImages: when no image is returned"() {
        given:
        siteService.getImages(new GrailsParameterMap([id:'1'], request)) >> []
        params.id = '1'
        when:
        controller.getImages();
        then:
        response.status == HttpStatus.SC_OK
        response.json.size() == 0
    }

    void "getImages: when webservice throws exception"() {
        given:
        siteService.getImages(new GrailsParameterMap([id: '1', max:5, offset:0], request)) >> {throw new SocketTimeoutException('Timed out!')}
        params.max = 5
        params.offset= 0
        params.id = '1'
        when:
        controller.getImages();
        then:
        response.status == HttpStatus.SC_REQUEST_TIMEOUT
        response.text.contains('Timed out!')
    }

    void "getImages: when working perfectly"() {
        given:
        siteService.getImages(new GrailsParameterMap([id: '1', max:5, offset:0], request)) >> [["siteId": "1", "name": "Rubicon Sanctuary, Port Sorell, Tasmania",
                                                                      "poi": [[poiId:'2',docs:[documents:[[role:'photoPoint',type:'image']],count:1]]]
                                                                     ]]
        params.max = 5
        params.offset= 0
        params.id = '1'
        when:
        controller.getImages();
        then:
        response.status == HttpStatus.SC_OK
        response.json.size() == 1
        response.json[0].poi[0].docs.documents.size() == 1
    }
}
