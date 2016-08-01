package au.org.ala.biocollect.merit

import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * Specification for the ProjectService
 */
@TestFor(ProjectService)
class ProjectServiceSpec extends Specification {
    def metadataServiceStub = Mock(MetadataService)

    void setup() {
        service.metadataService = metadataServiceStub
    }

    void "activity types should be contained by the project program"() {
        given:
        def project = [projectId:'test', associatedProgram:'test program']

        when:
        List activityTypes = service.supportedActivityTypes(project)

        then:
        1 * metadataServiceStub.activityTypesList('test program') >> [[category:'testing', list:[[name:'1'], [name:'2']]], [category:'cat 2', list:[[name:'3']]]]
        activityTypes == [[name:'1'], [name:'2'], [name:'3']]
    }

    void "activity types already in use by a project should always be returned"() {
        given:
        def project = [projectId:'test', associatedProgram:'test program']
        def projectActivities = [[pActivityForm:'4']]

        when:
        List activityTypes = service.supportedActivityTypes(project, projectActivities)

        then:
        1 * metadataServiceStub.activityTypesList('test program') >> [[category:'testing', list:[[name:'1'], [name:'2']]], [category:'cat 2', list:[[name:'3']]]]
        activityTypes == [[name:'1'], [name:'2'], [name:'3'], [name:'4']]
    }

    void "duplicate types already should not be returned"() {
        given:
        def project = [projectId:'test', associatedProgram:'test program']
        def projectActivities = [[pActivityForm:'3']]

        when:
        List activityTypes = service.supportedActivityTypes(project, projectActivities)

        then:
        1 * metadataServiceStub.activityTypesList('test program') >> [[category:'testing', list:[[name:'1'], [name:'2']]], [category:'cat 2', list:[[name:'3']]]]
        activityTypes == [[name:'1'], [name:'2'], [name:'3']]
    }

}