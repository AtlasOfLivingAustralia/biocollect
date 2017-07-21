package au.org.ala.biocollect.merit

import au.org.ala.biocollect.merit.hub.HubSettings
import com.vaadin.sass.internal.ScssContext
import com.vaadin.sass.internal.ScssStylesheet
import com.vaadin.sass.internal.handler.SCSSDocumentHandlerImpl
import com.vaadin.sass.internal.handler.SCSSErrorHandler
import grails.converters.JSON
import grails.plugin.cache.Cacheable
import groovy.text.GStringTemplateEngine
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsWebRequest
import org.springframework.core.io.Resource
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

    def getSettingText(String type) {
        def key = localHubConfig.get().urlPath + ".${type}"

        get(key)

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
        String scssFilename = 'configurable-template-1.scss'
        SCSSErrorHandler errorHandler = new SCSSErrorHandler()
        errorHandler.setWarningsAreErrors(true);
        Resource input = grailsApplication.parentContext.getResource("css/template/${scssFilename}")
        String filename = input?.file?.absolutePath + "${scssFilename}.${urlPath}.scss"
        File writer = new File(filename)

        String config = """
        \$menu-background-color: ${styles?.menuBackgroundColor};
        \$menu-text-color: ${styles?.menuTextColor};
        \$banner-background-color: ${styles?.bannerBackgroundColor};
        \$inset-background-color: ${styles?.insetBackgroundColor};
        \$inset-text-color: ${styles?.insetTextColor};
        \$body-background-color: ${styles?.bodyBackgroundColor?:'#fff'};
        \$body-text-color: ${styles?.bodyTextColor?:'#637073'};
        \$footer-background-color: ${styles?.footerBackgroundColor};
        \$footer-text-color: ${styles?.footerTextColor};
        \$social-text-color: ${styles?.socialTextColor};
        \$title-text-color: ${styles?.titleTextColor};
        \$header-banner-space-background-color: ${styles?.headerBannerBackgroundColor};
        \$nav-background-color:  ${styles?.navBackgroundColor?:'#e5e6e7'};
        \$nav-text-color:  ${styles?.navTextColor?:'#5f5d60'};
        \$primary-background-color: ${styles?.primaryButtonBackgroundColor?:'#009080'};
        \$primary-text-color: ${styles?.primaryButtonTextColor?:'#fff'};
        \$default-background-color: ${styles?.defaultButtonBackgroundColor?:'#f5f5f5'};
        \$default-text-color: ${styles?.defaultButtonTextColor?:'#000'};
        \$href-color: ${styles?.hrefColor?:'#009080'};
        \$facet-background-color: ${styles?.facetBackgroundColor?: '#f5f5f5'};
        \$tile-background-color: ${styles?.tileBackgroundColor?: '#f5f5f5'};
        \$well-background-color: ${styles?.wellBackgroundColor?: '#f5f5f5'};
        \$default-btn-color-active: ${styles?.defaultButtonColorActive?: '#fff'};
        \$default-btn-background-color-active: ${styles?.defaultButtonBackgroundColorActive?: '#000'};
        \$bread-crumb-background-colour: ${styles?.breadCrumbBackGroundColour ?: '#E7E7E7'};
        \$primary-color: #009080;
        \$primary-color-hover: #007777;
        """;

        writer.write(config.toString())
        writer.append(input.inputStream.text)

        try {
            // Parse stylesheet
            ScssStylesheet scss = ScssStylesheet.get(filename, null,
                    new SCSSDocumentHandlerImpl(), errorHandler);
            if (scss == null) {
                System.err.println("The scss file " + input
                        + " could not be found.");
                System.exit(2);
            }

            // Compile scss -> css
            scss.compile(ScssContext.UrlMode.MIXED);

            return  [css: scss.printState(), status: 'success'];
        } catch (Exception e) {
            return  [css: "An error occurred during compilation of SCSS file", status: 'failed'];
        }
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
