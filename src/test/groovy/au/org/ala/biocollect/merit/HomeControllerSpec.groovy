package au.org.ala.biocollect.merit

import au.org.ala.biocollect.merit.hub.HubSettings
import grails.testing.web.controllers.ControllerUnitTest
import spock.lang.Specification
/**
 * Tests the HomeController class.
 */
class HomeControllerSpec extends Specification implements ControllerUnitTest<HomeController> {

    def userService = Stub(UserService)
    def searchService = Stub(SearchService)
    def settingService = Stub(SettingService)
    def metadataService = Stub(MetadataService)

    def setup() {
        controller.userService = userService
        controller.searchService = searchService
        controller.settingService = settingService
        controller.metadataService = metadataService
    }


    def "home's index action should forward all requests to hub's index action"() {

        given:
        HubSettings settings = new HubSettings()
        SettingService.setHubConfig(settings)

        when:
        controller.index()

        then:
        response.forwardedUrl == '/hub/index?'
    }
}
