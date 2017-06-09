package au.org.ala.biocollect.merit

import au.org.ala.biocollect.merit.hub.HubSettings
import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * Tests the HomeController class.
 */
@TestFor(HomeController)
class HomeControllerSpec extends Specification {

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


    def "a hub without a homePagePath property uses the default"() {

        given:
        HubSettings settings = new HubSettings()
        SettingService.setHubConfig(settings)

        when:
        def model = controller.index()

        then:
        model.containsKey('mapFacets')
        model.containsKey('results')
        model.containsKey('geographicFacets')
    }

    def "a hub with a valid homePagePath property overrides the hub homepage"() {

        given:
        HubSettings settings = new HubSettings([homePagePath:'/aController/anAction'])
        SettingService.setHubConfig(settings)

        when:
        controller.index()

        then:
        response.forwardedUrl == '/aController/anAction'
    }


}
