package au.org.ala.biocollect.merit

import grails.converters.JSON
import grails.test.mixin.TestFor
import org.grails.web.converters.marshaller.json.CollectionMarshaller
import org.grails.web.converters.marshaller.json.MapMarshaller
import spock.lang.Specification

/**
 * Tests the document service.
 */
@TestFor(DocumentService)
class DocumentServiceSpec extends Specification {

    UserService userService = Mock(UserService)
    WebService webService = Mock(WebService)
    ActivityService activityService = Mock(ActivityService)

    def setup() {
        JSON.registerObjectMarshaller(new MapMarshaller())
        JSON.registerObjectMarshaller(new CollectionMarshaller())
        service.userService = userService
        service.webService = webService
        service.activityService = activityService
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
        2 * userService.userIsAlaOrFcAdmin() >> false
        2 * webService.getJson(_) >> [documentId:'d1', projectId:'p2']
        2 * userService.getCurrentUserId() >> userId
        2 * userService.canUserEditProject(userId, 'p2') >> false

        when:
        canEdit = service.canEdit(document)
        canDelete = service.canDelete(document.documentId)

        then:
        canEdit == true
        canDelete == true
        2 * userService.userIsAlaOrFcAdmin() >> false
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
        2 * userService.userIsAlaOrFcAdmin() >> false
        2 * webService.getJson(_) >> [documentId:'d1', organisationId:'o2']
        2 * userService.getCurrentUserId() >> userId
        2 * userService.isUserAdminForOrganisation(userId, 'o2') >> false

        when:
        canEdit = service.canEdit(document)
        canDelete = service.canDelete(document.documentId)

        then:
        canEdit == true
        canDelete == true
        2 * userService.userIsAlaOrFcAdmin() >> false
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
        1 * userService.userIsAlaOrFcAdmin() >> false
        1 * userService.getCurrentUserId() >> userId
        1 * userService.canUserEditProject(userId, document.projectId) >> true
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

    def "users can edit an activity document if they can edit the project associated with the activity"(boolean canEditActivity) {
        setup:
        Map document = [documentId:'d1', activityId:'a1']
        String userId = 'u1'

        when:
        boolean canEdit = service.canEdit(document)
        boolean canDelete = service.canDelete(document.documentId)

        then:
        canEdit == canEditActivity
        canDelete == canEditActivity
        2 * userService.userIsAlaOrFcAdmin() >> false
        2 * webService.getJson(_) >> [documentId:'d1', activityId:document.activityId]
        2 * activityService.get(document.activityId) >> [projectId:'p1', activityId:document.activityId]
        2 * userService.getCurrentUserId() >> userId
        2 * userService.canUserEditProject(userId, 'p1') >> canEditActivity

        where:
        canEditActivity | _
        true | _
        false | _

    }
}
