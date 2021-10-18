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

    ActivityService service

    def "progress can be compared correctly"() {

        expect:
        ['started', 'finished', 'planned'].max(service.PROGRESS_COMPARATOR) == 'finished'
        ['started', 'finished', 'planned'].min(service.PROGRESS_COMPARATOR) == 'planned'

    }
}
