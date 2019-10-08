package au.org.ala.biocollect.merit

import au.org.ala.biocollect.merit.ActivityService
import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * Tests for the ActivityService
 */
@TestFor(ActivityService)
public class ActivityServiceSpec extends Specification {

    def "progress can be compared correctly"() {

        expect:
        ['started', 'finished', 'planned'].max(service.PROGRESS_COMPARATOR) == 'finished'
        ['started', 'finished', 'planned'].min(service.PROGRESS_COMPARATOR) == 'planned'

    }
}
