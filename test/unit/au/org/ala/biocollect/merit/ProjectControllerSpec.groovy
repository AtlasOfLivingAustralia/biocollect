package au.org.ala.biocollect.merit

import au.org.ala.web.AuthService
import grails.test.mixin.TestFor
import spock.lang.Specification

import static org.apache.http.HttpStatus.SC_OK
import static org.apache.http.HttpStatus.SC_REQUEST_TIMEOUT

/**
 * Specification for the ProjectController
 */
@TestFor(ProjectController)
class ProjectControllerSpec extends Specification {

    def userServiceStub = Stub(UserService)
    def metadataServiceStub = Stub(MetadataService)
    def projectServiceStub = Stub(ProjectService)
    def siteServiceMock = Mock(SiteService)
    def roleServiceStub = Stub(RoleService)
    def activityServiceStub = Stub(ActivityService)
    def commonServiceStub = Stub(CommonService)
    def auditServiceStub = Stub(AuditService)
    def authServiceStub = Stub(AuthService)
    def blogServiceStub = Stub(BlogService)

    void setup() {
        controller.userService = userServiceStub
        controller.metadataService = metadataServiceStub
        controller.projectService = projectServiceStub
        controller.siteService = siteServiceMock
        controller.roleService = roleServiceStub
        controller.activityService = activityServiceStub
        controller.commonService = commonServiceStub
        controller.auditService = auditServiceStub
        controller.authService = authServiceStub
        controller.blogService = blogServiceStub
        auditServiceStub.getAuditMessagesForProject(_) >> []
        metadataServiceStub.organisationList() >> [list:[buildOrganisation(), buildOrganisation(), buildOrganisation()]]
        metadataServiceStub.activitiesModel() >> [activities: []]
        userServiceStub.getOrganisationIdsForUserId(_) >> ['1']
        projectServiceStub.getMembersForProjectId(_) >> []
        metadataServiceStub.organisationList() >> [list:[]]
        userServiceStub.getOrganisationIdsForUserId(_) >> []
        userServiceStub.isProjectStarredByUser(_, _) >> [isProjectStarredByUser:true]
        roleServiceStub.getRoles() >> []
        authServiceStub.getUserId() >> ''
        blogServiceStub.get(_, _) >> []
    }

    void "creating a citizen science project should pre-populate the citizen science project type"() {

        when:
        userServiceStub.getUser() >> [userId:'1234']

        params.citizenScience = true
        def model = controller.create()

        then:
        model.project.isCitizenScience == true
        model.project.projectType == 'survey'
    }

    void "creating a project should pre-populate the organisation if the user is a member of exactly one organisation"() {
        when:
        userServiceStub.getUser() >> [userId:'1234']

        def model = controller.create()

        then:
        model.project.organisationId == '1'
    }

    void "the create method should split the organisations into two lists for the convenience of the page"() {
        when:
        userServiceStub.getUser() >> [userId:'1234']

        def model = controller.create()

        then:
        model.userOrganisations.size() == 1
        model.userOrganisations[0].organisationId == '1'

        model.organisations.size() == 2
        ["2", "3"].each { orgId ->
            model.organisations.find{it.organisationId == orgId}.organisationId == orgId
        }
    }

    void "the edit method should overwrite the project organisation if returning from the create organisation workflow"() {
        def siteId = 'site1'

        when:
        def projectId = 'project1'
        userServiceStub.getUser() >> [userId:'1234']
        projectServiceStub.get(projectId, _) >> [organisationId:'org1', projectId:projectId, name:'Test', projectSiteId:siteId]

        params.organisationId = 'org2'
        def model = controller.edit(projectId)

        then:
        1 * siteServiceMock.getRaw(siteId) >> [:]
        model.project.projectId == projectId
        model.project.organisationId == 'org2'
    }

    void "the edit method should split the organisations into two lists for the convenience of the page"() {
        def siteId = 'site1'

        when:
        def projectId = 'project1'
        userServiceStub.getUser() >> [userId:'1234']
        projectServiceStub.get(projectId, _) >> [organisationId:'org1', projectId:projectId, name:'Test', projectSiteId:siteId]
        def model = controller.edit(projectId)

        then:
        1 * siteServiceMock.getRaw(siteId) >> [:]
        model.userOrganisations.size() == 1
        model.userOrganisations[0].organisationId == '1'

        model.organisations.size() == 2
        ["2", "3"].each { orgId ->
            model.organisations.find{it.organisationId == orgId}.organisationId == orgId
        }
        model.project.projectId == projectId
        model.project.organisationId == 'org1'
        model.project.name == 'Test'
    }

    void "an external citizen science project viewed anonymously should have a single page only"() {
        setup:
        def projectId = 'project1'
        def siteId = 'site1'
        def citizenScience = true
        def external = true
        userServiceStub.getUser() >> null
        projectServiceStub.get(projectId, _, _, _) >> [organisationId:'org1', projectId:projectId, name:'Test', projectSiteId:siteId, citizenScience:citizenScience, projectType:'survey', isExternal:external]

        when:
        controller.index(projectId)

        then:
        view == '/project/externalCSProjectTemplate'
        model.projectContent.about.visible == true
        model.projectContent.documents.visible == false
        model.projectContent.activities.visible == false
        model.projectContent.admin.visible == false
    }

    void "an external citizen science project viewed by an admin should have the overview and admin tabs"() {
        setup:
        def projectId = 'project1'
        def siteId = 'site1'
        def citizenScience = true
        def external = true
        stubProjectAdmin('1234', projectId)

        projectServiceStub.get(projectId, _, _, _) >> [organisationId:'org1', projectId:projectId, name:'Test', projectSiteId:siteId, citizenScience:citizenScience, projectType:'survey', isExternal:external]

        when:
        controller.index(projectId)

        then:
        view == '/project/externalCSProjectTemplate'
        model.projectContent.about.visible == true
        model.projectContent.documents.visible == false
        model.projectContent.activities.visible == false
        model.projectContent.admin.visible == true
    }

    void "an ALA managed citizen science project should have most content available to anonymous users"() {
        setup:
        def projectId = 'project1'
        def siteId = 'site1'
        def citizenScience = true
        def external = false
        userServiceStub.getUser() >> null
        projectServiceStub.get(projectId, _, _, _) >> [organisationId:'org1', projectId:projectId, name:'Test', projectSiteId:siteId, citizenScience:citizenScience, projectType:'survey', isExternal:external]

        when:
        controller.index(projectId)

        then:
        view == '/project/csProjectTemplate'
        model.projectContent.about.visible == true
        model.projectContent.documents.visible == true
        model.projectContent.activities.visible == true
        model.projectContent.admin.visible == false
    }

    void "an ALA managed citizen science project should not display the admin tab to project editors"() {
        setup:
        def projectId = 'project1'
        def siteId = 'site1'
        def citizenScience = true
        def external = false
        stubProjectEditor('1234', projectId)
        projectServiceStub.get(projectId, _, _, _) >> [organisationId:'org1', projectId:projectId, name:'Test', projectSiteId:siteId, citizenScience:citizenScience, projectType:'survey', isExternal:external]

        when:
        controller.index(projectId)

        then:
        view == '/project/csProjectTemplate'
        model.projectContent.about.visible == true
        model.projectContent.documents.visible == true
        model.projectContent.activities.visible == true
        model.projectContent.admin.visible == false
    }



    void "an ALA managed citizen science project should display the admin tab to project admins"() {
        setup:
        def projectId = 'project1'
        def siteId = 'site1'
        def citizenScience = true
        def external = false
        stubProjectAdmin('1234', projectId)
        projectServiceStub.get(projectId, _, _, _) >> [organisationId:'org1', projectId:projectId, name:'Test', projectSiteId:siteId, citizenScience:citizenScience, projectType:'survey', isExternal:external]

        when:
        controller.index(projectId)

        then:
        view == '/project/csProjectTemplate'
        model.projectContent.about.visible == true
        model.projectContent.documents.visible == true
        model.projectContent.activities.visible == true
        model.projectContent.admin.visible == true
    }

    void "a works project should use the standard index page"() {
        def projectId = 'project1'
        def siteId = 'site1'
        def citizenScience = true
        def external = false
        stubProjectEditor('1234', projectId)
        projectServiceStub.get(projectId, _, _, _) >> [organisationId:'org1', projectId:projectId, name:'Test', projectSiteId:siteId, citizenScience:citizenScience, projectType:'works', isExternal:external]

        when:
        controller.index(projectId)

        then:
        view == '/project/index'
        model.projectContent.overview.visible == true
        model.projectContent.documents.visible == true
        model.projectContent.activities.visible == true
        model.projectContent.site.visible == true
        model.projectContent.dashboard.visible == true
        model.projectContent.admin.visible == false
    }

    void "a survey based project uses different language for sites and activities to a works project"() {
        setup:
        def projectId = 'project1'
        def siteId = 'site1'
        def citizenScience = true
        def external = false
        stubProjectEditor('1234', projectId)
        projectServiceStub.get(projectId, _, _, _) >> [organisationId:'org1', projectId:projectId, name:'Test', projectSiteId:siteId, citizenScience:citizenScience, projectType:'survey', isExternal:external]

        when:
        controller.index(projectId)

        then:
        view == '/project/csProjectTemplate'

        model.projectContent.activities.label == 'Surveys'
        model.projectContent.activities.wordForActivity == 'Survey'
    }

    void "list all images for a project"(){
        given:
        Map payload = [:]
        payload.max = 10;
        payload.offset = 0;
        payload.userId = ''
        payload.order = 'DESC';
        payload.sort = 'lastUpdated';
        payload.fq = ['surveyImage:true']
        payload.projectId = 'abs'
        projectServiceStub.listImages(payload, _) >> [count:1,documents:[[documentId:'124']]]
        when:
        request.method = "POST"
        request.json = '{"projectId":"abs"}'
        controller.listRecordImages()
        then:
        response.status == SC_OK;
        response.json.documents.size() == 1
        response.json.count == 1
        response.json.documents[0].documentId == '124'

    }

    void "list all images during timeout exception"(){
        given:
        Map payload = [:]
        payload.max = 10;
        payload.offset = 0;
        payload.userId = ''
        payload.order = 'DESC';
        payload.sort = 'lastUpdated';
        payload.fq = ['surveyImage:true']
        payload.projectId = 'abs'
        projectServiceStub.listImages(payload, _) >> {throw new SocketTimeoutException('timed out')}
        when:
        request.method = "POST"
        request.json = '{"projectId":"abs"}'
        controller.listRecordImages()
        then:
        response.status == SC_REQUEST_TIMEOUT;
        response.text == 'timed out';
    }

    int orgCount = 0;
    private Map buildOrganisation() {
        [organisationId:Integer.toString(++orgCount), name:"Organisation ${orgCount}"]
    }

    private def stubProjectAdmin(userId, projectId) {
        stubUserPermissions(userId, projectId, true, true, false, true)
    }

    private def stubProjectEditor(userId, projectId) {
        stubUserPermissions(userId, projectId, true, false, false, true)
    }

    private def stubUserPermissions(userId, projectId, editor, admin, grantManager, canView) {
        userServiceStub.getUser() >> [userId:userId]
        projectServiceStub.isUserAdminForProject(userId, projectId) >> admin
        projectServiceStub.isUserCaseManagerForProject(userId, projectId) >> grantManager
        projectServiceStub.canUserEditProject(userId, projectId) >> editor
        projectServiceStub.canUserViewProject(userId, projectId) >> canView

    }

}
