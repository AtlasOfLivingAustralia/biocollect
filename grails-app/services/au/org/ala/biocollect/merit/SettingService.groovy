package au.org.ala.biocollect.merit

import au.org.ala.biocollect.merit.hub.HubSettings
import grails.converters.JSON
//import grails.plugin.cache.Cacheable
import org.springframework.cache.annotation.Cacheable
import groovy.text.GStringTemplateEngine
import org.grails.web.servlet.mvc.GrailsWebRequest
import org.springframework.web.context.request.RequestAttributes

class SettingService {

    private static def ThreadLocal localHubConfig = new ThreadLocal()
    private static final String HUB_LIST_CACHE_KEY = 'hubList'
    private static final String HUB_CACHE_KEY_SUFFIX = '_hub'
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
    boolean isValidHub(String hubUrlPath) {
        List hubs = listHubs()
        hubs.find{it.urlPath == hubUrlPath}
    }

    def loadHubConfig(hub) {

        if (!hub) {
            hub = grailsApplication.config.app.default.hub?:'default'
            GrailsWebRequest.lookup()?.params.hub = hub
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
                    availableFacets: ['isExternal','status', 'organisationFacet','associatedProgramFacet','associatedSubProgramFacet','mainThemeFacet','stateFacet','nrmFacet','lgaFacet','mvgFacet','ibraFacet','imcra4_pbFacet','otherFacet', 'gerSubRegionFacet','electFacet'],
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

    def getSettingText(String type) {
        def key = localHubConfig.get().urlPath + ".${type}"

        get(key)

    }

    def getSettingText(String urlPath, String path) {
        urlPath = urlPath?.trim()
        path = path?.trim()
        urlPath = urlPath ?: localHubConfig.get().urlPath
        if (path) {
            def key = urlPath + path
            get(key)
        }
    }

    def setSettingText(SettingPageType type, String content) {
        def key = localHubConfig.get().urlPath + type.key

        set(key, content)
    }

    def setSettingText(String type, String content) {
        def key = localHubConfig.get().urlPath + ".${type}"

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

    private String hubCacheKey(String prefix) {
        return prefix+HUB_CACHE_KEY_SUFFIX
    }

    HubSettings getHubSettings(String urlPath) {

        cacheService.get(hubCacheKey(urlPath), {
            String url = grailsApplication.config.ecodata.service.url + '/hub/findByUrlPath/' + urlPath
            Map json = webService.getJson(url, null, true)
            json.hubId ? new HubSettings(new HashMap(json)) : null
        })
    }

    void updateHubSettings(HubSettings settings) {
        cacheService.clear(HUB_LIST_CACHE_KEY)
        cacheService.clear(hubCacheKey(settings.urlPath))

        String url = grailsApplication.config.ecodata.service.url+'/hub/'+(settings.hubId?:'')
        webService.doPost(url, settings)
    }

    List listHubs() {
        cacheService.get(HUB_LIST_CACHE_KEY, {
            String url = grailsApplication.config.ecodata.service.url+'/hub/'
            Map resp = webService.getJson(url, null, true)
            resp.list ?: []
        })
    }

    @Cacheable("styleSheetCache")
    public Map getConfigurableHubTemplate1(String urlPath, Map styles) {
        Map config = [
        "menubackgroundcolor": styles?.menuBackgroundColor,
        "menutextcolor": styles?.menuTextColor,
        "bannerbackgroundcolor": styles?.bannerBackgroundColor,
        "insetbackgroundcolor": styles?.insetBackgroundColor,
        "insettextcolor": styles?.insetTextColor,
        "bodybackgroundcolor": styles?.bodyBackgroundColor?:'#fff',
        "bodytextcolor": styles?.bodyTextColor?:'#637073',
        "footerbackgroundcolor": styles?.footerBackgroundColor,
        "footertextcolor": styles?.footerTextColor,
        "socialtextcolor": styles?.socialTextColor,
        "titletextcolor": styles?.titleTextColor,
        "headerbannerspacebackgroundcolor": styles?.headerBannerBackgroundColor,
        "navbackgroundcolor":  styles?.navBackgroundColor?:'#e5e6e7',
        "navtextcolor":  styles?.navTextColor?:'#5f5d60',
        "primarybackgroundcolor": styles?.primaryButtonBackgroundColor?:'#009080',
        "primarytextcolor": styles?.primaryButtonTextColor?:'#fff',
        "gettingStartedButtonBackgroundColor": styles?.gettingStartedButtonBackgroundColor?:'',
        "gettingStartedButtonTextColor": styles?.gettingStartedButtonTextColor?:'',
        "whatIsThisButtonBackgroundColor": styles?.whatIsThisButtonBackgroundColor?:'',
        "whatIsThisButtonTextColor": styles?.whatIsThisButtonTextColor?:'',
        "addARecordButtonBackgroundColor": styles?.addARecordButtonBackgroundColor ?: '',
        "addARecordButtonTextColor": styles?.addARecordButtonTextColor ?: '',
        "viewRecordsButtonBackgroundColor": styles?.viewRecordsButtonBackgroundColor ?: '',
        "viewRecordsButtonTextColor": styles?.viewRecordsButtonTextColor ?: '',
        "primaryButtonOutlineTextHoverColor": styles?.primaryButtonOutlineTextHoverColor?:'#fff',
        "primaryButtonOutlineTextColor": styles?.primaryButtonOutlineTextColor?:'#000',
        "makePrimaryButtonAnOutlineButton": styles?.makePrimaryButtonAnOutlineButton?: false,
        "defaultbackgroundcolor": styles?.defaultButtonBackgroundColor?:'#f5f5f5',
        "defaulttextcolor": styles?.defaultButtonTextColor?:'#000',
        "makeDefaultButtonAnOutlineButton": styles?.makeDefaultButtonAnOutlineButton?: false,
        "defaultButtonOutlineTextColor": styles?.defaultButtonOutlineTextColor?:'#343a40',
        "defaultButtonOutlineTextHoverColor": styles?.defaultButtonOutlineTextHoverColor?:'#000',
        "tagBackgroundColor": styles?.tagBackgroundColor ?: 'orange',
        "tagTextColor": styles?.tagTextColor?: 'white',
        "hrefcolor": styles?.hrefColor?:'#009080',
        "facetbackgroundcolor": styles?.facetBackgroundColor?: '#f5f5f5',
        "tilebackgroundcolor": styles?.tileBackgroundColor?: '#f5f5f5',
        "wellbackgroundcolor": styles?.wellBackgroundColor?: '#f5f5f5',
        "defaultbtncoloractive": styles?.defaultButtonColorActive?: '#fff',
        "defaultbtnbackgroundcoloractive": styles?.defaultButtonBackgroundColorActive?: '#000',
        "breadcrumbbackgroundcolour": styles?.breadCrumbBackGroundColour ?: '#E7E7E7',
        "primarycolor": '#009080',
        "primarycolorhover": '#007777'
        ];

        return config
    }

    /**
     * Is the current hub a works hub
     * @return
     */
    public boolean isWorksHub() {
        hubConfig?.defaultFacetQuery?.contains('isWorks:true')
    }

    /**
     * Is the current hub a eco science hub
     * @return
     */
    public boolean isEcoScienceHub() {
        hubConfig?.defaultFacetQuery?.contains('isEcoScience:true')
    }

    /**
     * Is the current hub a citizen science hub
     * @return
     */
    public boolean isCitizenScienceHub() {
        hubConfig?.defaultFacetQuery?.contains('isCitizenScience:true')
    }

    /**
     *
     * @param controller
     * @param action
     * @return
     */
    public List getCustomBreadCrumbsSetForControllerAction(String controller, String action){
        List customBreadCrumbs = hubConfig?.customBreadCrumbs
        Map item = customBreadCrumbs?.find { page ->
            if(page.controllerName == controller && page.actionName == action){
                page.breadCrumbs
            }
        }

        item?.breadCrumbs
    }
}
