package au.org.ala.biocollect

import au.org.ala.biocollect.merit.ActivityService
import au.org.ala.biocollect.merit.CommonService
import au.org.ala.biocollect.merit.SearchService
import au.org.ala.biocollect.merit.UserService
import au.org.ala.ecodata.forms.UserInfoService
import grails.testing.web.controllers.ControllerUnitTest
import spock.lang.Specification

class BioActivityControllerSpec extends Specification implements ControllerUnitTest<BioActivityController> {

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

    def "authkey and userName are added to model"() {
        given:
        def activityId = "activity-123"
        controller.userService = Mock(UserService)
        controller.userInfoService = Mock(UserInfoService)
        controller.userInfoService.getUserFromAuthKey(_, _) >> { [id: "1"] }
        controller.userInfoService.getUserFromJWT(_) >> {  [id: "1"] }
        controller.activityService = Mock(ActivityService)
        controller.activityService.get(_) >> [projectId: "project1"]
        controller.userService.getCurrentUserId(_) >> null
        request.addHeader('userName', 'abc@abc.com')
        request.addHeader('authKey', 'abc')
        request.addHeader('Authorization', 'Bearer abcxyz')

        when:
        controller.mobileEdit(activityId)

        then:
        model[UserService.AUTH_KEY_HEADER_FIELD] == 'abc'
        model[UserService.USER_NAME_HEADER_FIELD] == 'abc@abc.com'
        model[UserInfoService.AUTHORIZATION_HEADER_FIELD] == 'Bearer abcxyz'
    }

}
