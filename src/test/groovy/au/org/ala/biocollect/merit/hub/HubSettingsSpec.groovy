package au.org.ala.biocollect.merit.hub

import spock.lang.Specification

class HubSettingsSpec extends Specification {

    def "a hub without a home page path uses the default home page"() {
        given:
        HubSettings hubSettings = new HubSettings([urlPath: 'test'])

        expect:
        !hubSettings.overridesHomePage()
        hubSettings.getHomePageControllerAndAction() == [controller: 'home', action: 'index']
    }

    def "a hub with a home page path overrides the home page"() {
        given:
        HubSettings hubSettings = new HubSettings([urlPath: 'test', homePagePath: '/project/citizenScience'])

        expect:
        hubSettings.overridesHomePage()
        hubSettings.getHomePageControllerAndAction() == [controller: 'project', action: 'citizenScience']
    }
}
