package au.org.ala.biocollect


import au.org.ala.biocollect.merit.ActivityService
import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * Tests for the DateUtils class.
 */
@TestFor(ActivityService.CollectoryService)
class CollectoryServiceSpec extends Specification {


    def cleanup() {

    }

    def  "parsing supports ISO8601"() {
        expect:
        def mockConfig = new ConfigObject()
        mockConfig.collectory.service.url = 'https://collections.ala.org.au'f

        ActivityService.CollectoryService cs =  new ActivityService.CollectoryService();
        cs.grailsApplication = [config:mockConfig];
        Map ls = cs.licence();
        ls.count() ==13;

    }

}