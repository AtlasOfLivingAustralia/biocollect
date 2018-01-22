package au.org.ala.biocollect.merit

import au.org.ala.biocollect.OrganisationService
import au.org.ala.biocollect.VocabService
import au.org.ala.biocollect.merit.hub.HubSettings
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
    def organisationStub = Stub(OrganisationService)
    def vocabServiceStub = Stub(VocabService)
    def documentServiceStub = Stub(DocumentService)
    def settingServiceStub = Stub(SettingService)
    def collectoryServiceStub = Stub(CollectoryService)

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
        controller.organisationService = organisationStub
        controller.vocabService = vocabServiceStub
        controller.documentService = documentServiceStub
        controller.settingService = settingServiceStub
        controller.collectoryService = collectoryServiceStub
        auditServiceStub.getAuditMessagesForProject(_) >> []
        metadataServiceStub.activitiesModel() >> [activities: []]
        metadataServiceStub.getActivityModel(*_) >> [type:'Activity']
        userServiceStub.getOrganisationIdsForUserId(_) >> ['1']
        projectServiceStub.getMembersForProjectId(_) >> []
        
        userServiceStub.getOrganisationIdsForUserId(_) >> []
        userServiceStub.isProjectStarredByUser(_, _) >> [isProjectStarredByUser:true]
        roleServiceStub.getRoles() >> []
        authServiceStub.getUserId() >> ''
        blogServiceStub.get(_, _) >> []
        organisationStub.get(_) >> [organisationId: "ABC123", name: "organisation name"]
        vocabServiceStub.getVocabValues() >> []
        settingServiceStub.isWorksHub() >> false
        settingServiceStub.isEcoScienceHub() >> false
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
        model.project.organisationId == 'ABC123'
        model.project.organisationName == 'organisation name'
    }

    void "when creating a project, the current hub's default program should be assigned to the new project"() {
        when:
        userServiceStub.getUser() >> [userId:'1234']
        SettingService.setHubConfig(new HubSettings([defaultProgram:'my program']))

        def model = controller.create()

        then:
        model.project.associatedProgram == 'my program'
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

    void "an ALA managed citizen science project should have most content available to anonymous users"() {
        setup:
        def projectId = 'project1'
        def siteId = 'site1'
        def citizenScience = true
        def external = false
        userServiceStub.getUser() >> null
        projectServiceStub.isCitizenScience(_) >> true
        projectServiceStub.get(projectId, _, _, _) >>
                [organisationId:'org1', projectId:projectId, name:'Test', projectSiteId:siteId, citizenScience:citizenScience, projectType:'survey', isExternal:external]

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
        projectServiceStub.isCitizenScience(_) >> true
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
        projectServiceStub.isCitizenScience(_) >> true
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
        projectServiceStub.isCitizenScience(_) >> false
        projectServiceStub.isEcoScience(_) >> false
        params.userCanEditProject = true
        params.userIsProjectAdmin = true
        projectServiceStub.get(projectId, _, _, _) >> [organisationId:'org1', projectId:projectId, name:'Test', projectSiteId:siteId, citizenScience:citizenScience, projectType:'works', isExternal:external]
        activityServiceStub.activitiesForProject(projectId) >> [[type:'Activity 1']]

        when:
        controller.index(projectId)

        then:
        view == '/project/worksProjectTemplate'
        model.projectContent.overview.visible == true
        model.projectContent.documents.visible == true
        model.projectContent.activities.visible == true
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
        projectServiceStub.isCitizenScience(_) >> true
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
        payload.hub = params.hub = 'ala'
        projectServiceStub.listImages(payload, _) >> [count:1,documents:[[documentId:'124',licence: 'CC BY']]]
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
        payload.hub = params.hub = 'ala'
        projectServiceStub.listImages(payload, _) >> {throw new SocketTimeoutException('timed out')}
        when:
        request.method = "POST"
        request.json = '{"projectId":"abs"}'
        controller.listRecordImages()
        then:
        response.status == SC_REQUEST_TIMEOUT;
        response.text == 'timed out';
    }

    void "available survey types should be provided by the project service"() {
        setup:
        def projectId = 'project1'
        def siteId = 'site1'
        def citizenScience = true
        def external = false
        stubProjectAdmin('1234', projectId)
        projectServiceStub.get(projectId, _, _, _) >> [organisationId:'org1', projectId:projectId, name:'Test', projectSiteId:siteId, citizenScience:citizenScience, projectType:ProjectService.PROJECT_TYPE_CITIZEN_SCIENCE, isExternal:external]
        projectServiceStub.supportedActivityTypes(_) >> [[name:'1'], [name:'2'], [name:'3']]
        activityServiceStub.activitiesForProject(projectId) >> [[type:'Activity 1']]

        when:
        controller.index(projectId)

        then:
        model.pActivityForms == [[name:'1', images:null], [name:'2', images:null], [name:'3', images:null]]
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
