package au.org.ala.biocollect.merit

import au.org.ala.biocollect.merit.hub.HubSettings
import grails.converters.JSON
import groovy.text.GStringTemplateEngine
import org.codehaus.groovy.grails.web.servlet.GrailsFlashScope
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsWebRequest
import org.springframework.web.context.request.RequestAttributes

class SettingService {

    private static def ThreadLocal localHubConfig = new ThreadLocal()
    private static final String HUB_CONFIG_KEY_SUFFIX = '.hub.configuration'
    public static final String HUB_CONFIG_ATTRIBUTE_NAME = 'hubConfig'
    public static final String LAST_ACCESSED_HUB = 'recentHub'

    public static void setHubConfig(HubSettings hubSettings) {
        localHubConfig.set(hubSettings)
        GrailsWebRequest.lookup()?.setAttribute(HUB_CONFIG_ATTRIBUTE_NAME, hubSettings, RequestAttributes.SCOPE_REQUEST)
    }

    public static void clearHubConfig() {
        localHubConfig.remove()
    }

    public static HubSettings getHubConfig() {
        return localHubConfig.get()
    }

    def webService, cacheService, cookieService
    def grailsApplication

    /**
     * Checks if there is a configuration defined for the specified hub.
     */
    boolean isValidHub(hub) {
        def result = (getHubSettings(hub) != null)
        result
    }

    def loadHubConfig(hub) {

        if (!hub) {
            hub = grailsApplication.config.app.default.hub?:'default'
            String previousHub = cookieService.getCookie(LAST_ACCESSED_HUB)
            if (!previousHub) {
                cookieService.setCookie(LAST_ACCESSED_HUB, hub, -1 /* -1 means the cookie expires when the browser is closed */)
            }
        }
        else {
            // Store the most recently accessed hub in a cookie so that 404 errors can be presented with the
            // correct skin.
            cookieService.setCookie(LAST_ACCESSED_HUB, hub, -1 /* -1 means the cookie expires when the browser is closed */)
        }

        def settings = getHubSettings(hub)
        if (!settings) {
            log.warn("no settings returned for hub ${hub}!")
            settings = new HubSettings(
                    title:'Default',
                    skin:'ala2',
                    urlPath:grailsApplication.config.app.default.hub?:'default',
                    availableFacets: ['status', 'organisationFacet','associatedProgramFacet','associatedSubProgramFacet','mainThemeFacet','stateFacet','nrmFacet','lgaFacet','mvgFacet','ibraFacet','imcra4_pbFacet','otherFacet', 'gerSubRegionFacet','electFacet'],
                    adminFacets: ['electFacet'],
                    availableMapFacets: ['status', 'organisationFacet','associatedProgramFacet','associatedSubProgramFacet','stateFacet','nrmFacet','lgaFacet','mvgFacet','ibraFacet','imcra4_pbFacet','electFacet']
            )
        }

        SettingService.setHubConfig(settings)
    }

    def getSettingText(SettingPageType type) {
        def key = localHubConfig.get().urlPath + type.key

        get(key)

    }

    def setSettingText(SettingPageType type, String content) {
        def key = localHubConfig.get().urlPath + type.key

        set(key, content)
    }

    private def get(key) {
        String url = grailsApplication.config.ecodata.service.url + "/setting/ajaxGetSettingTextForKey?key=${key}"
        def res = cacheService.get(key,{ webService.getJson(url) })
        return res?.settingText?:""
    }

    private def getJson(key) {
        cacheService.get(key, {
            def settings = get(key)
            return settings ? JSON.parse(settings) : [:]
        })
    }

    private def set(key, settings) {
        cacheService.clear(key)
        String url = grailsApplication.config.ecodata.service.url + "/setting/ajaxSetSettingText/${key}"
        webService.doPost(url, [settingText: settings, key: key])
    }

    /**
     * Allows for basic GString style substitution into a Settings page.  If the saved template text includes
     * ${}, these will be substituted for values in the supplied model
     * @param type identifies the settings page to return.
     * @param substitutionModel values to substitute into the page.
     * @return the settings page after substitutions have been made.
     */
    def getSettingText(SettingPageType type, substitutionModel) {
        String templateText = getSettingText(type)
        GStringTemplateEngine templateEngine = new GStringTemplateEngine();
        return templateEngine.createTemplate(templateText).make(substitutionModel).toString()
    }

    private def projectSettingsKey(projectId) {
        return projectId+'.settings'
    }

    def getProjectSettings(projectId) {
        getJson(projectSettingsKey(projectId))
    }

    def updateProjectSettings(projectId, settings) {
        def key = projectSettingsKey(projectId)
        set(key, (settings as JSON).toString())
    }


    HubSettings getHubSettings(String urlPath) {

        String url = grailsApplication.config.ecodata.service.url+'/hub/findByUrlPath/'+urlPath
        Map json = webService.getJson(url, null, true)

        json.hubId ? new HubSettings(new HashMap(json)) : null
    }

    void updateHubSettings(HubSettings settings) {

        String url = grailsApplication.config.ecodata.service.url+'/hub/'+(settings.hubId?:'')
        webService.doPost(url, settings)
    }

    List listHubs() {
        String url = grailsApplication.config.ecodata.service.url+'/hub/'
        Map resp = webService.getJson(url, null, true)
        resp.list
    }


}
