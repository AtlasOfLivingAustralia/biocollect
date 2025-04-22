package au.org.ala.biocollect.merit

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
    ActivityService service

    def setup() {
        grailsApplication.config.ecodata.service.url = ''
        service.webService = webService
        service.grailsApplication = grailsApplication
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
}
