package au.org.ala.biocollect.merit

import grails.converters.JSON
import grails.test.mixin.TestFor
import org.apache.commons.io.FileUtils
import org.grails.web.converters.marshaller.json.CollectionMarshaller
import org.grails.web.converters.marshaller.json.MapMarshaller
import spock.lang.Specification

/**
 * Tests the document service.
 */
@TestFor(DocumentService)
class DocumentServiceSpec extends Specification {
    Closure doWithSpring() {{ ->
        service DocumentService
    }}

    DocumentService service

    UserService userService = Mock(UserService)
    WebService webService = Mock(WebService)

    def setup() {
        JSON.registerObjectMarshaller(new MapMarshaller())
        JSON.registerObjectMarshaller(new CollectionMarshaller())
        service.userService = userService
        service.webService = webService
        service.grailsApplication = grailsApplication
    }


    def "only project members can edit or delete project documents"() {
        setup:
        Map document = [documentId:'d1', projectId:'p1']
        String userId = '1234'

        when:
        boolean canEdit = service.canEdit(document)
        boolean canDelete = service.canDelete(document.documentId)

        then:
        canEdit == false
        canDelete == false
        2 * webService.getJson(_) >> [documentId:'d1', projectId:'p2']
        2 * userService.getCurrentUserId() >> userId
        2 * userService.canUserEditProject(userId, 'p2') >> false

        when:
        canEdit = service.canEdit(document)
        canDelete = service.canDelete(document.documentId)

        then:
        canEdit == true
        canDelete == true
        2 * webService.getJson(_) >> [documentId:'d1', projectId:'p2']
        2 * userService.getCurrentUserId() >> userId
        2 * userService.canUserEditProject(userId, 'p2') >> true
    }

    def "only organisation members can edit or delete an organisation document"() {
        setup:
        Map document = [documentId:'d1', organisationId:'o1']
        String userId = '1234'

        when:
        boolean canEdit = service.canEdit(document)
        boolean canDelete = service.canDelete(document.documentId)

        then:
        canEdit == false
        canDelete == false
        2 * webService.getJson(_) >> [documentId:'d1', organisationId:'o2']
        2 * userService.getCurrentUserId() >> userId
        2 * userService.isUserAdminForOrganisation(userId, 'o2') >> false

        when:
        canEdit = service.canEdit(document)
        canDelete = service.canDelete(document.documentId)

        then:
        canEdit == true
        canDelete == true
        2 * webService.getJson(_) >> [documentId:'d1', organisationId:'o2']
        2 * userService.getCurrentUserId() >> userId
        2 * userService.isUserAdminForOrganisation(userId, 'o2') >> true
    }

    def "only administrators edit or delete a read only document, regardless of ownership"() {
        setup:
        Map document = [documentId:'d1', projectId:'p1']

        when:
        boolean canEdit = service.canEdit(document)
        boolean canDelete = service.canDelete(document.documentId)

        then:
        canEdit == false
        canDelete == false
        2 * webService.getJson(_) >> [documentId:'d1', projectId:'p2', readOnly:true]
        2 * userService.userIsAlaOrFcAdmin() >> false

        when:
        canEdit = service.canEdit(document)
        canDelete = service.canDelete(document.documentId)

        then:
        canEdit == true
        canDelete == true
        2 * webService.getJson(_) >> [documentId:'d1', projectId:'p2', readOnly:true]
        2 * userService.userIsAlaOrFcAdmin() >> true
    }

    def "editors and admins are allowed to create a read only document, but not edit it"() {
        Map document = [readOnly:true, projectId:'p1']
        String userId = 'u1'

        when:
        boolean canEdit = service.canEdit(document)

        then:
        canEdit == true
        1 * userService.getCurrentUserId() >> userId
        1 * userService.canUserEditProject(userId, document.projectId) >> true
    }

    def "logo and mainImage documents will be marked as public when creating a document from a staged image"(String role, boolean expectedPublic) {
        setup:
        Map document = [filename:"test.jpg", projectId:'p1', role:role, public: false]
        File temp = File.createTempDir("documentService", "Spec")
        grailsApplication.config.upload = [images:[path: temp.path], extensions:[blacklist:[]]]
        grailsApplication.config.ecodata = [baseUrl: '']
        File testStagedImage = new File(temp, document.filename)
        FileUtils.copyInputStreamToFile(getClass().getResourceAsStream("/expectedMeriPlan.json"), testStagedImage)
        testStagedImage.deleteOnExit()
        Map capturedDocument = document

        when:
        service.saveStagedImageDocument(document)

        then:

        1 * userService.getCurrentUserId()
        1 * userService.canUserEditProject(_, document.projectId) >> true
        1 * webService.postMultipart({it.endsWith("document")}, {
            JSON.parse(it.document.toString())
            true
        }, _, _, _) >> [resp:[:]]

        and:
        capturedDocument.filename == document.filename
        capturedDocument.projectId == document.projectId
        capturedDocument.role == document.role
        capturedDocument['public'] == expectedPublic

        where:
        role                            | expectedPublic
        DocumentService.ROLE_LOGO       | true
        DocumentService.ROLE_MAIN_IMAGE | true
        "information"                   | false
        "contractAssurance"             | false
    }

    def "A document marked publiclyViewable can be viewed by anyone"() {
        setup:
        Map document = [documentId:'d1', projectId:'o1', publiclyViewable:true]

        expect:
        service.canView(document)
    }

    def "A user with read only access to MERIT can view all documents"() {
        setup:
        Map document = [documentId:'d1', projectId:'o1']

        when:
        boolean canView = service.canView(document)

        then:
        1 * userService.userHasReadOnlyAccess() >> true
        canView
    }
}
