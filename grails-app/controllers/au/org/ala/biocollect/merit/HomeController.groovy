package au.org.ala.biocollect.merit

import au.org.ala.biocollect.merit.hub.HubSettings
import grails.converters.JSON
import org.apache.commons.lang.StringUtils

class HomeController {

    def projectService
    def siteService
    def activityService
    def searchService
    def settingService
    def metadataService
    def userService

    @PreAuthorise(accessLevel = 'alaAdmin', redirectController = "admin")
    def advanced() {
        [
                projects   : projectService.list(),
                sites      : siteService.list(),
                //sites: siteService.injectLocationMetadata(siteService.list()),
                activities : activityService.list(),
                assessments: activityService.assessments(),
        ]
    }

    def index() {
        HubSettings hubSettings = SettingService.hubConfig
        if (hubSettings.overridesHomePage()) {
            if(hubSettings.isHomePagePathSimple()){
                Map result = hubSettings.getHomePageControllerAndAction()
                forward(result)
                return
            } else {
                redirect([uri: hubSettings['homePagePath'] ])
                return;
            }
        }
        return projectFinder()
    }

    def projectFinder() {
        def facetsList = SettingService.getHubConfig().availableFacets
        def mapFacets = SettingService.getHubConfig().availableMapFacets

        if(!userService.userIsAlaOrFcAdmin() && !userService.userHasReadOnlyAccess()) {
            def adminFacetList = SettingService.getHubConfig().adminFacets
            facetsList?.removeAll(adminFacetList)
            mapFacets?.removeAll(adminFacetList)
        }

        def fqList = params.getList('fq')
        def allFacets = fqList + (SettingService.getHubConfig().defaultFacetQuery?:[])
        def selectedGeographicFacets = findSelectedGeographicFacets(allFacets)

        def resp = searchService.HomePageFacets(params)

        [   facetsList: facetsList,
            mapFacets: mapFacets,
            geographicFacets:selectedGeographicFacets,
            description: settingService.getSettingText(SettingPageType.DESCRIPTION),
            results: resp,
            hubConfig: SettingService.getHubConfig()]
    }

    def citizenScience() {
    }

    def works() {
    }

    /**
     * The purpose of this method is to enable the display of the spatial object corresponding to a selected
     * value from a geographic facet (e.g. to display the polygon representing NSW on the map if the user has
     * selected NSW from the "state" facet list.
     *
     * First we check to see if we have a geographic facet configuration for any of the user's facet selections.
     * If so, we find the spatial object configuration matching the selected value and add that to the returned
     * model.  The selected polygon can then be requested by PID from geoserver.
     *
     * By convention, the facet field names in the search index have a suffix of "Facet" whereas the facet configuration
     * doesn't include the word "Facet" (although maybe it should).
     */
    private ArrayList findSelectedGeographicFacets(Collection allFacets) {

        def facetConfig = metadataService.getGeographicFacetConfig()
        def selectedGeographicFacets = []

        allFacets.each { facet ->
            def token = facet.split(':')
            if(token.size() == 2){
                def matchingFacet = facetConfig.find { token[0].startsWith(it.key) }
                if (matchingFacet) {
                    def matchingValue = matchingFacet.value.find { it.key == token[1] }
                    if (matchingValue) {
                        selectedGeographicFacets << matchingValue.value
                    }
                }
            }
        }

        selectedGeographicFacets
    }

    def tabbed() {
        [geoPoints: searchService.allGeoPoints(params)]
    }

    def geoService() {
        params.max = params.max?:9999
        if(params.geo){
            params.facets = StringUtils.join(SettingService.getHubConfig().availableFacets?:[],',')
            render searchService.allProjectsWithSites(params) as JSON
        } else {
            render searchService.allProjects(params) as JSON
        }
    }

    def getProjectsForIds() {
        render searchService.getProjectsForIds(params) as JSON
    }

    def myProfile() {
        redirect(controller: 'user')
    }

    def about() {
        renderStaticPage(SettingPageType.ABOUT, true)
    }

    def help() {
        renderStaticPage(SettingPageType.HELP, false)
    }

    def contacts() {
        renderStaticPage(SettingPageType.CONTACTS, false)
    }

    def gettingStarted(){
        renderStaticPage(SettingPageType.CITIZEN_SCIENCE_GETTING_STARTED, false)
    }

    def whatIsThis(){
        renderStaticPage(SettingPageType.CITIZEN_SCIENCE_WHAT_IS_THIS, false)
    }

    def worksScheduleIntro(){
        renderStaticPage(SettingPageType.WORKS_SCHEDULE_INTRO, false)
    }

    def close() {
        response.setContentType("text/html")
        render """<html><head><script type="text/javascript">window.close();</script></head><body/></html>"""
    }

    def staticPage(String id) {
        def settingType = SettingPageType.getForName(id)
        if (settingType) {
            renderStaticPage(settingType)
        } else {
            response.sendError(404)
            return
        }
    }

    private renderStaticPage(SettingPageType settingType, showNews = false) {
        def content = settingService.getSettingText(settingType)
        render view: 'about', model: [settingType: settingType, content: content, showNews: showNews]
    }
}
