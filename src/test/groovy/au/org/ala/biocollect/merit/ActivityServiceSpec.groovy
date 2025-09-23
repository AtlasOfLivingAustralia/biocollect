package au.org.ala.biocollect.merit

import au.org.ala.biocollect.ProjectActivityService
import grails.testing.spring.AutowiredTest
import spock.lang.Specification

/**
 * Tests for the ActivityService
 */
public class ActivityServiceSpec extends Specification implements AutowiredTest{
    Closure doWithSpring() {{ ->
        service ActivityService
    }}
    WebService webService = Mock(WebService)
    UserService userService = Mock(UserService)
    ProjectService projectService = Mock(ProjectService)
    ProjectActivityService projectActivityService = Mock(ProjectActivityService)
    ActivityService service

    def setup() {
        grailsApplication.config.ecodata.service.url = ''
        service.webService = webService
        service.grailsApplication = grailsApplication
        service.userService = userService
        service.projectService = projectService
        service.projectActivityService = projectActivityService
        userService.userIsSiteAdmin() >> false
    }

    def "progress can be compared correctly"() {

        expect:
        ['started', 'finished', 'planned'].max(service.PROGRESS_COMPARATOR) == 'finished'
        ['started', 'finished', 'planned'].min(service.PROGRESS_COMPARATOR) == 'planned'

    }

    def "addLinkedEntitiesToActivities should add linked entities to activities"() {
        given:
        grailsApplication.config.ecodata.baseURL = ""
        def activity = [activityId: 'activity1']
        def linkedEntity = [activityId: 'activity1', outputs: [[id: 'output1']], site: [id: 'site1'], documents: [[id: 'doc1']]]

        when:
        service.addLinkedEntitiesToActivities([activity])

        then:
        1 * webService.doPost('/reporting/activity/search/', [activityId: ['activity1']]) >> [resp: [activities: [linkedEntity]]]
        activity.outputs == linkedEntity.outputs
        activity.site == linkedEntity.site
        activity.documents == linkedEntity.documents
    }
    
    def "doesActivityHavePubliclyViewableVerificationStatus checks verification status"() {
        expect:
        service.doesActivityHavePubliclyViewableVerificationStatus(activity) == expected

        where:
        expected | activity
        true | [verificationStatus: ActivityService.VERIFICATION_APPROVED]
        true | [verificationStatus: ActivityService.VERIFICATION_NOT_APPLICABLE]
        true | [verificationStatus: '']
        true | [verificationStatus: null]
        false | [verificationStatus: ActivityService.VERIFICATION_NOT_APPROVED]
        false | [verificationStatus: ActivityService.VERIFICATION_NOT_VERIFIED]
        false | [verificationStatus: ActivityService.VERIFICATION_UNDER_REVIEW]
        false | null
    }

    def "returns access denied when user is not logged in"() {
        given:
        userService.getCurrentUserId() >> null

        expect:
        service.checkUserViewPermission([projectId: "p1"], [:], [:]).authorized == false
    }

    def "returns authorized when user is project editor"() {
        given:
        userService.getCurrentUserId() >> "u1"
        projectService.isUserEditorForProjects("u1", "p1") >> true

        expect:
        service.checkUserViewPermission([projectId: "p1"], [:], [:]).authorized == true
    }

    def "returns Activity not found when activity is null or has error"() {
        given:
        userService.getCurrentUserId() >> "u1"
        projectService.isUserEditorForProjects("u1", "p1") >> false

        expect:
        service.checkUserViewPermission([projectId: "p1"], [:], null).authorized == false

        service.checkUserViewPermission([projectId: "p1"], [:], [error: true]).authorized == false
    }

    def "returns authorized when user is owner of activity"() {
        given:
        userService.getCurrentUserId() >> "u1"
        projectService.isUserEditorForProjects("u1", "p1") >> false
        webService.doGet(*_) >> [resp: [userIsOwner: true]] // owner

        expect:
        service.checkUserViewPermission([projectId: "p1"], [:], [activityId: "owned"]).authorized == true
    }

    def "returns authorized when activity is publicly viewable and not embargoed"() {
        given:
        userService.getCurrentUserId() >> "u1"
        projectService.isUserEditorForProjects("u1", "p1") >> false
        projectActivityService.isEmbargoed(_) >> false
        webService.doGet(*_) >> [resp: [userIsOwner: false]] // not owner

        expect:
        service.checkUserViewPermission([projectId: "p1"], [:], [verificationStatus: "approved"]).authorized == true
    }

    def "returns authorized when survey is published, publicAccess is true"() {
        given:
        userService.getCurrentUserId() >> "u1"
        projectService.isUserEditorForProjects("u1", "p1") >> false
        projectActivityService.isEmbargoed(_) >> true  // embargoed
        0 * webService.doGet(*_) >> null // not owner
        def activity = null

        expect:
        service.checkUserViewPermission([projectId: "p1"], [published: true, publicAccess: true], activity).authorized == true
    }

    def "returns not authorized when survey is published and publicAccess is false"() {
        given:
        userService.getCurrentUserId() >> "u1"
        projectService.isUserEditorForProjects("u1", "p1") >> false
        projectActivityService.isEmbargoed(_) >> true  // embargoed
        0 * webService.doGet(*_) >> null // not owner
        def activity = null

        expect:
        service.checkUserViewPermission([projectId: "p1"], [published: true, publicAccess: false], activity).authorized == false
    }

    def "returns default denied when no conditions are met"() {
        given:
        userService.getCurrentUserId() >> "u1"
        projectService.isUserEditorForProjects("u1", "p1") >> false
        projectActivityService.isEmbargoed(_) >> true  // embargoed
        webService.doGet(*_) >> [resp: [userIsOwner: false]] // not owner
        def activity = [verificationStatus: "not approved", activityId: "other"]

        expect:
        service.checkUserViewPermission([projectId: "p1"], [published: true, publicAccess: false], activity).authorized == false
    }

}
