package au.org.ala.biocollect.merit

import au.org.ala.biocollect.OrganisationController
import au.org.ala.biocollect.OrganisationService
import grails.converters.JSON
import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * Tests the OrganisationController class.
 */
@TestFor(OrganisationController)
class OrganisationControllerSpec extends Specification {

    def organisationService = Mock(OrganisationService)
    def searchService = Mock(SearchService)
    def documentService = Mock(DocumentService)
    def roleService = Stub(RoleService)
    def userService = Stub(UserService)

    def setup() {
        controller.organisationService = organisationService
        controller.searchService = searchService
        controller.documentService = documentService
        controller.roleService = roleService
        controller.userService = userService

    }

    def "retrieve an organisation by id"() {

        given:
        def testOrg = testOrganisation()
        organisationService.get(_) >> testOrg
        searchService.dashboardReport(_) >> [:]

        when:
        def model = controller.index('id')

        then:
        model.organisation == testOrg
        model.dashboard == [:]
    }

    def "retrieve an organisation that doesn't exist"() {
        given:
        organisationService.get(_) >> null

        when:
        controller.index('missing id')

        then:
        response.redirectedUrl == '/home'
        flash.message != null
    }

    def "edit an organisation"() {
        given:
        def testOrg = testOrganisation()
        organisationService.get(_) >> testOrg

        when:
        def model = controller.edit('id')

        then:
        model.organisation == testOrg
    }

    def "edit an organisation that doesn't exist"() {
        given:
        organisationService.get(_) >> null

        when:
        controller.edit('missing id')

        then:
        response.redirectedUrl == '/home'
        flash.message != null
    }


    def "soft delete an organisation"() {
        when:
        setupOrganisationAdmin()
        request.method = 'POST'
        controller.ajaxDelete('id')
        then:
        1 * organisationService.update('id', [status:'deleted'])
    }

    def "update an organisation successfully"() {

        setup:
        def document = [organisationId: 'id', name:'name', description:'description']
        def organisation = testOrganisation()
        organisation.documents = [document]
        request.method = 'POST'
        request.json = (organisation as JSON).toString()
        request.addHeader('Accept', 'application/json')
        request.format = 'json'

        when:
        controller.ajaxUpdate()
        println response.status

        then:

        1 * organisationService.update('id', _) >> [resp:[organisationId:'id']]
        1 * documentService.saveStagedImageDocument(document) >> [:]
        response.json.organisationId == 'id'
    }

    def "only the organisation projects should be viewable anonymously"() {
        setup:
        setupAnonymousUser()
        def testOrg = testOrganisation()
        organisationService.get(_) >> testOrg

        when:
        def model = controller.index('id')

        then:
        model.organisation == testOrg
        model.content.about.visible == true
        model.content.sites.visible == false
        model.content.admin.visible == false
    }

    def "all tabs except the admin tabs are viewable by a user with read only access"() {
        setup:
        setupReadOnlyUser()
        def testOrg = testOrganisation()
        organisationService.get(_) >> testOrg

        when:
        def model = controller.index('id')

        then:
        model.organisation == testOrg
        model.content.about.visible == true
        model.content.sites.visible == true
        model.content.admin.visible == false
    }

    def "all tabs are visible to fc admins"() {
        setup:
        def testOrg = testOrganisation()
        organisationService.get(_) >> testOrg
        setupFcAdmin()

        when:
        def model = controller.index('id')

        then:
        model.organisation == testOrg
        model.content.about.visible == true
        model.content.sites.visible == true
        model.content.admin.visible == true
    }

    def "all tabs are visible to organisation admins"() {
        setup:
        def testOrg = testOrganisation()
        organisationService.get(_) >> testOrg
        setupOrganisationAdmin()

        when:
        def model = controller.index('id')

        then:
        model.organisation == testOrg
        model.content.about.visible == true
        model.content.sites.visible == true
        model.content.admin.visible == true
    }

    def "all tabs expect the admin tab are visible to organisation editors"() {
        setup:
        def testOrg = testOrganisation()
        organisationService.get(_) >> testOrg
        setupOrganisationEditor()

        when:
        def model = controller.index('id')

        then:
        model.organisation == testOrg
        model.content.about.visible == true
        model.content.sites.visible == true
        model.content.admin.visible == false
    }

    def "the about tab is the default"() {
        setup:
        def testOrg = testOrganisation()
        organisationService.get(_) >> testOrg
        setupOrganisationEditor()

        when:
        def model = controller.index('id')

        then:
        model.content.about.default == true
        def numDefault = 0
        model.content.each { k, v ->
            if (v.default) {
                numDefault ++
            }
        }
        numDefault == 1
    }

    private Map testOrganisation() {
        def org = [organisationId:'id', name:'name', description:'description']

        return org
    }

    private void setupAnonymousUser() {
        userService.getUser() >> null
        userService.userHasReadOnlyAccess() >> false
        userService.userIsAlaOrFcAdmin() >> false
        organisationService.getMembersOfOrganisation(_) >> [[userId:'1234', role:RoleService.PROJECT_ADMIN_ROLE]]
        organisationService.isUserAdminForOrganisation(_) >> false
    }

    private void setupFcAdmin() {
        userService.getUser() >> [userId:'1345']
        userService.userHasReadOnlyAccess() >> false
        userService.userIsAlaOrFcAdmin() >> true
        organisationService.getMembersOfOrganisation(_) >> []
        organisationService.isUserAdminForOrganisation(_) >> true
    }

    private void setupReadOnlyUser() {
        userService.getUser() >> [userId:'1345']
        userService.userHasReadOnlyAccess() >> true
        userService.userIsAlaOrFcAdmin() >> false
        organisationService.getMembersOfOrganisation(_) >> []
        organisationService.isUserAdminForOrganisation(_) >> false
    }

    private void setupOrganisationAdmin() {
        def userId = '1234'
        userService.getUser() >> [userId:userId]
        userService.userHasReadOnlyAccess() >> false
        userService.userIsAlaOrFcAdmin() >> false
        organisationService.getMembersOfOrganisation(_) >> [[userId:userId, role:RoleService.PROJECT_ADMIN_ROLE]]
        organisationService.isUserAdminForOrganisation(_) >> true
    }

    private void setupOrganisationEditor() {
        def userId = '1234'
        userService.getUser() >> [userId:userId]
        userService.userHasReadOnlyAccess() >> false
        userService.userIsAlaOrFcAdmin() >> false
        organisationService.getMembersOfOrganisation(_) >> [[userId:userId, role:RoleService.PROJECT_EDITOR_ROLE]]
        organisationService.isUserAdminForOrganisation(_) >> false
    }


}
