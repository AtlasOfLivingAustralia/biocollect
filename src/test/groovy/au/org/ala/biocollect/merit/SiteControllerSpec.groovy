package au.org.ala.biocollect.merit

import au.org.ala.biocollect.UtilService
import org.springframework.http.HttpStatus


import grails.testing.web.controllers.ControllerUnitTest
import grails.web.servlet.mvc.GrailsParameterMap
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
        response.status == HttpStatus.BAD_REQUEST.value()
    }

    void "getImages: when no image is returned"() {
        given:
        commonService.parseParams(params) >> [id:'1', userId: '1']
        siteService.getImages(new GrailsParameterMap([id:'1', userId: '1'], request)) >> []
        params.id = '1'
        when:
        controller.getImages();
        then:
        response.status == HttpStatus.OK.value()
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
        response.status == HttpStatus.REQUEST_TIMEOUT.value()
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
        response.status == HttpStatus.OK.value()
        response.json.size() == 1
        response.json[0].poi[0].docs.documents.size() == 1
    }

    void "test createSitesFromShapefile - success"() {
        given:
        def siteData = [
                shapeFileId: 1,
                projectId  : 1,
                sites      : [
                        [id: 1, externalId: "ext1", name: "Site 1", description: "Description 1"],
                        [id: 2, externalId: "ext2", name: "Site 2", description: "Description 2"]
                ]
        ]
        request.JSON = siteData

        when:
        siteService.createSiteFromUploadedShapefile(_, _, _, _, _, _, _) >> null
        controller.createSitesFromShapefile()

        then:
        response.json.message == 'success'
        response.json.progress.total == 2
        response.json.progress.uploaded == 2
        response.json.progress.finished == true
    }

    void "test createSitesFromShapefile - partial success"() {
        given:
        def siteData = [
                shapeFileId: 1,
                projectId  : 1,
                sites      : [
                        [id: 1, externalId: "ext1", name: "Site 1", description: "Description 1"],
                        [id: 2, externalId: "ext2", name: "Site 2", description: "Description 2"]
                ]
        ]
        request.JSON = siteData

        when:
        siteService.createSiteFromUploadedShapefile(_, _, _, _, _, _, _) >>> [null, "Error creating site"]
        controller.createSitesFromShapefile()

        then:
        response.json.message == 'error'
        response.json.progress.total == 2
        response.json.progress.uploaded == 1
        response.json.progress.finished == false
        response.json.error == "Error creating site"
    }

    void "test createSitesFromShapefile - exception"() {
        given:
        def siteData = [
                shapeFileId: 1,
                projectId  : 1,
                sites      : [
                        [id: 1, externalId: "ext1", name: "Site 1", description: "Description 1"],
                        [id: 2, externalId: "ext2", name: "Site 2", description: "Description 2"]
                ]
        ]
        request.JSON = siteData

        when:
        siteService.createSiteFromUploadedShapefile(_, _, _, _, _, _, _) >> { throw new Exception("Unexpected error") }
        controller.createSitesFromShapefile()

        then:
        response.json.message == 'error'
        response.json.progress.total == 2
        response.json.progress.uploaded == 0
        response.json.progress.finished == false
        response.json.error == "Error uploading sites, please try again later"
    }

    void "ajaxDeleteSitesFromProject only removes the posted sites that belong to the project"() {
        given:
        ProjectService projectService = Mock(ProjectService)
        SiteService sites = Mock(SiteService)
        controller.projectService = projectService
        controller.siteService = sites
        request.JSON = [siteIds: ['s1', 'other']]

        when:
        controller.ajaxDeleteSitesFromProject('p1')

        then:
        1 * projectService.canUserEditSitesForProject('1', 'p1') >> true
        1 * projectService.get('p1', 'all') >> [sites: [[siteId: 's1'], [siteId: 's2']]]
        1 * sites.canRemoveProjectFromSite('s1', 'p1') >> true
        1 * sites.get('s1', [raw: 'true']) >> [projects: ['p1']]
        1 * sites.update('s1', [projects: []])
        1 * sites.canDeleteSite('s1') >> false
        0 * sites.canRemoveProjectFromSite('s2', _)
        response.json.warnings.size() == 1
    }

    void "ajaxDeleteSitesFromProject rejects a request without siteIds"() {
        given:
        ProjectService projectService = Stub(ProjectService)
        controller.projectService = projectService
        projectService.canUserEditSitesForProject('1', 'p1') >> true
        request.JSON = [:]

        when:
        controller.ajaxDeleteSitesFromProject('p1')

        then:
        response.status == HttpStatus.BAD_REQUEST.value()
    }

    void "bulkCreate does not redirect to an unsafe returnTo"() {
        given:
        ProjectService projectService = Stub(ProjectService)
        UtilService utilService = Stub(UtilService)
        controller.projectService = projectService
        controller.utilService = utilService
        projectService.canUserEditSitesForProject('1', 'p1') >> false
        utilService.isRedirectSafe('javascript:alert(1)') >> false
        params.projectId = 'p1'
        params.returnTo = 'javascript:alert(1)'

        when:
        controller.bulkCreate()

        then:
        response.redirectedUrl
        !response.redirectedUrl.contains('javascript')
    }

    void "ajaxUpdate responds with a 500 when the site cannot be saved"() {
        given:
        request.JSON = [site: [name: 'Site', visibility: 'private']]
        siteService.updateRaw(_, _, '1') >> [status: 'error', message: 'boom']

        when:
        controller.ajaxUpdate(null)

        then:
        response.status == HttpStatus.INTERNAL_SERVER_ERROR.value()
        response.text == 'boom'
    }
}
