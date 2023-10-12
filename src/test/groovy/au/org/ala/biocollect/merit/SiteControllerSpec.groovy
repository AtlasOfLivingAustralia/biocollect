package au.org.ala.biocollect.merit


import grails.testing.web.controllers.ControllerUnitTest
import grails.web.servlet.mvc.GrailsParameterMap
import org.apache.http.HttpStatus
import spock.lang.Specification

class SiteControllerSpec extends Specification implements ControllerUnitTest<SiteController> {

    SiteService siteService = Stub(SiteService)
    CommonService commonService = Stub(CommonService)
    UserService userService = Stub(UserService)

    def setup() {
        controller.siteService = siteService
        controller.commonService = commonService
        controller.userService = userService
        userService.getCurrentUserId() >> '1'
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
        commonService.parseParams(params) >> [id:'1', userId: '1']
        siteService.getImages(new GrailsParameterMap([id:'1', userId: '1'], request)) >> []
        params.id = '1'
        when:
        controller.getImages();
        then:
        response.status == HttpStatus.SC_OK
        response.json.size() == 0
    }

    void "getImages: when webservice throws exception"() {
        given:
        params.max = 5
        params.offset= 0
        params.id = '1'
        commonService.parseParams(params) >> [id: '1', max:5, offset:0, userId: '1']
        siteService.getImages(new GrailsParameterMap([id: '1', max:5, offset:0, userId: '1'], request)) >> {throw new SocketTimeoutException('Timed out!')}
        when:
        controller.getImages();
        then:
        response.status == HttpStatus.SC_REQUEST_TIMEOUT
        response.text.contains('Timed out!')
    }

    void "getImages: when working perfectly"() {
        given:
        params.max = 5
        params.offset= 0
        params.id = '1'
        commonService.parseParams(params) >> [id: '1', max:5, offset:0, userId: '1']
        siteService.getImages(new GrailsParameterMap([id: '1', max:5, offset:0, userId: '1'], request)) >> [["siteId": "1", "name": "Rubicon Sanctuary, Port Sorell, Tasmania",
                                                                                                             "poi": [[poiId:'2',docs:[documents:[[role:'photoPoint',type:'image']],count:1]]]
                                                                                                            ]]
        when:
        controller.getImages();
        then:
        response.status == HttpStatus.SC_OK
        response.json.size() == 1
        response.json[0].poi[0].docs.documents.size() == 1
    }
}
