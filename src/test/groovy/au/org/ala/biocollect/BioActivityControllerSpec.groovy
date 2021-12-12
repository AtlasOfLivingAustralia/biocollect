package au.org.ala.biocollect

import au.org.ala.biocollect.merit.CommonService
import au.org.ala.biocollect.merit.SearchService
import au.org.ala.biocollect.merit.UserService
import grails.test.mixin.TestFor
import spock.lang.Specification

@TestFor(BioActivityController)
class BioActivityControllerSpec extends Specification {

    UserService userService = Mock(UserService)
    CommonService commonService = Mock(CommonService)
    SearchService searchService = Mock(SearchService)

    def setup() {
        controller.userService = userService
        controller.commonService = commonService
        controller.searchService = searchService
    }

    def "The getProjectActivitiesRecordsForMapping action only requests data it needs from elasticsearch"() {
        setup:
        List searchResults =[[_source:[projectId:'p1', projectActivity:[:]]]]
        def searchParams = null

        when:
        controller.getProjectActivitiesRecordsForMapping()

        then: "The search is performed using the searchService"
        1 * commonService.parseParams(params) >> [fq:"test:test"]
        1 * userService.getCurrentUserId() >> 'u1'
        1 * userService.userIsAlaOrFcAdmin() >> false
        1 * searchService.searchProjectActivity(_) >> {searchParams = it;  [hits:[hits:searchResults]] }

        and: "The query has specified the include parameter to limit the results to only the fields required"
        searchParams.include.size() > 0
    }
}
