package au.org.ala.biocollect.merit


import au.org.ala.web.UserDetails
import grails.async.PromiseFactory
import grails.async.Promises
import grails.testing.web.controllers.ControllerUnitTest
import grails.web.servlet.mvc.GrailsParameterMap
import org.apache.http.HttpStatus
import org.grails.async.factory.SynchronousPromiseFactory
import spock.lang.Specification

class SiteControllerSpec extends Specification implements ControllerUnitTest<SiteController> {

    SiteService siteService = Stub(SiteService)
    CommonService commonService = Stub(CommonService)
    UserService userService = Stub(UserService)
    PromiseFactory originalPromiseFactory

    def setup() {
        originalPromiseFactory = Promises.promiseFactory
        Promises.promiseFactory = new SynchronousPromiseFactory()
        controller.siteService = siteService
        controller.commonService = commonService
        controller.userService = userService
        userService.getCurrentUserId() >> '1'
        userService.getUser() >> new UserDetails(1, '', '', '', '', '1', false, true, null)
        userService.withUser(_, _) >> { UserDetails user, Closure work -> work.call() }
    }

    def cleanup() {
        Promises.promiseFactory = originalPromiseFactory
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

    void "test createSitesFromShapefile - success"() {
        given:
        request.JSON = shapefilePayload()
        siteService.createSiteFromUploadedShapefile(_, _, _, _, _, _, _) >> null

        when:
        controller.createSitesFromShapefile()

        then:
        response.json.message == 'success'
        session.uploadProgress.total == 2
        session.uploadProgress.uploaded == 2
        session.uploadProgress.finished == true
        session.uploadProgress.error == null
    }

    void "test createSitesFromShapefile - service error"() {
        given:
        request.JSON = shapefilePayload()
        siteService.createSiteFromUploadedShapefile(_, _, _, _, _, _, _) >>> [null, "Error creating site"]

        when:
        controller.createSitesFromShapefile()

        then:
        response.json.message == 'success'
        session.uploadProgress.total == 2
        session.uploadProgress.uploaded == 1
        session.uploadProgress.finished == true
        session.uploadProgress.error == "Error creating site"
    }

    void "test createSitesFromShapefile - exception"() {
        given:
        request.JSON = shapefilePayload()
        siteService.createSiteFromUploadedShapefile(_, _, _, _, _, _, _) >> { throw new Exception("Unexpected error") }

        when:
        controller.createSitesFromShapefile()

        then:
        response.json.message == 'success'
        session.uploadProgress.total == 2
        session.uploadProgress.uploaded == 0
        session.uploadProgress.finished == true
        session.uploadProgress.error == "Error uploading sites, please try again later"
    }

    private static Map shapefilePayload() {
        [
                shapeFileId: 1,
                projectId  : 1,
                sites      : [
                        [id: 1, externalId: "ext1", name: "Site 1", description: "Description 1"],
                        [id: 2, externalId: "ext2", name: "Site 2", description: "Description 2"]
                ]
        ]
    }
}
