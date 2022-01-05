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

    def "optional project content must have bushfireCategores and industries facet" (){
        given:
        HubSettings settings = new HubSettings()
        SettingService.setHubConfig(settings)

        when:
        def model = controller.index()

        then:
        HubSettings.OPTIONAL_PROJECT_CONTENT?.find{it == 'bushfireCategories'}
        HubSettings.OPTIONAL_PROJECT_CONTENT?.find{it == 'industries'}
        model.containsKey('hubConfig')
    }

}
