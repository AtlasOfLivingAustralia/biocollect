package au.org.ala.biocollect.merit.hub

import org.grails.web.json.JSONObject

import groovy.util.logging.Slf4j
/**
 * The configuration for a hub.
 */

@Slf4j
class HubSettings extends JSONObject {

    static List SPECIAL_FACET_DATA_TYPES = ['Date', 'GeoMap']
    static Map ALL_DATA_TYPES = [
                                          presenceAbsence: "PresenceOrAbsence",
                                          default: "Default",
                                          histogram: "Histogram",
                                          date: 'Date',
                                          geoMap: 'GeoMap',
                                          activeCompleted: 'ActiveOrCompleted'
                                  ]

    /** Keys for checking sections of supported optional content.  Note these keys are used as javascript variables so shouldn't contain spaces etc. */
    static final String CONTENT_INDUSTRIES = 'industries'
    static final List OPTIONAL_PROJECT_CONTENT = [CONTENT_INDUSTRIES]

    public HubSettings() {
        super()
    }

    public HubSettings(Map settings) {
        super()
        putAll(settings)
    }

    public boolean overridesHomePage() {
        return optString('homePagePath', null) as boolean
    }

    /**
     * Check if homePagePath is simple url (/controller/action) or complicated
     * @return
     */
    public boolean isHomePagePathSimple(){
        String path = optString('homePagePath', '')
        List portions = path.split('/')
        if(portions.size() == 3){
            return true
        } else if(portions.size() > 3) {
            return false
        }
    }

    /**
     * Returns a map [controller: , action: ] based on parsing the homePathPage.  If the homePathPath property
     * isn't set or doesn't match the expected pattern, the default home index page will be returned..
     */
    public Map getHomePageControllerAndAction() {
        if (overridesHomePage()) {
            def regexp = "\\/(.*)\\/(.*)"
            def matcher = (optString('homePagePath', '') =~ regexp)
            if (matcher.matches()) {
                def controller = matcher[0][1]
                def action = matcher[0][2]
                return [controller:controller, action:action]
            }
        }
        return [controller:'home', action:'index']
    }

    /**
     * List facets and their configuration settings
     * @return
     */
    public List getFacetsForProjectFinderPage(){
        getFacetConfigForPage('projectFinder')
    }

    /**
     * Check if the hub has selected configurable template as its skin.
     * @return
     */
    public boolean isFacetListConfigured(String page){
        Boolean flag = false;
        if(this.pages?.get(page)){
            flag = true
        }

        flag
    }

    /**
     * Get facet configuration for a data page
     * @param view
     * @return
     */
    List getFacetConfigForPage(String view){
        if(this.pages?.has(view)){
            this.pages?.get(view)?.facets
        } else {
            []
        }
    }

    /**
     * Returns true if this hub supports a particular type of optional content.
     * Industry types are the only current optional content.
     * @param contentKey the type of optional content.
     * @return
     */
    Boolean supportsOptionalContent(String contentKey) {
        this['content'] && this['content'][contentKey]
    }

    /**
     * Get hub's dataColumn value. If not present, return default value from grailApplication bean.
     */
    List getDataColumns (def grailsApplication) {
        this['dataColumns'] ?: grailsApplication.config.datapage.defaultColumns
    }

    /**
     * The configuration for a Hub can specify that the hub homepage be buttons or the project finder.
     */
    String getHubHomePageType() {
        this.templateConfiguration?.homePage?.homePageConfig
    }

    /**
     * Hubs can elect to display a button on the project finder (and my projects) to download an excel file
     * with project details.
     */
    boolean showProjectFinderDownloadButton() {
        this.templateConfiguration?.homePage?.projectFinderConfig?.showProjectDownloadButton ?: false
    }

    String findLabelOverrideForIndex (int i, List defaults) {
        List overrides = this.content?.overriddenLabels ?: defaults
        Map config = overrides?.grep { it.id == i }?.get(0)
        if (config?.showCustomText) {
            config.customText
        } else {
            config?.defaultText
        }
    }

    String getTextForShowingProjects (List defaults) {
        findLabelOverrideForIndex(1, defaults)
    }

    String getTextForAboutTheProject (List defaults) {
        findLabelOverrideForIndex(2, defaults)
    }

    String getTextForAim (List defaults) {
        findLabelOverrideForIndex(3, defaults)
    }
    String getTextForDescription (List defaults) {
        findLabelOverrideForIndex(4, defaults)
    }

    String getTextForProjectInformation (List defaults) {
        findLabelOverrideForIndex(5, defaults)
    }

    String getTextForProgramName (List defaults) {
        findLabelOverrideForIndex(6, defaults)
    }

    String getTextForSubprogramName (List defaults) {
        findLabelOverrideForIndex(7, defaults)
    }

    String getTextForProjectArea (List defaults) {
        findLabelOverrideForIndex(8, defaults)
    }

    /**
     * Get facets without special meaning like 'date', 'geoMap' etc.
     * @param facets
     * @return
     */
    public static List getFacetConfigMinusSpecialFacets(List facets){
        facets?.grep({
            !(it.facetTermType in SPECIAL_FACET_DATA_TYPES)
        })
    }

    public static List getFacetConfigWithSpecialFacets(List facets){
        facets?.grep({
            (it.facetTermType in SPECIAL_FACET_DATA_TYPES)
        })
    }

    public static List getFacetConfigWithPresenceAbsenceSetting(List facetConfig){
        facetConfig?.grep{ it.facetTermType in [ALL_DATA_TYPES.presenceAbsence] }
    }

    public static List getFacetConfigWithActiveCompletedSetting(List facetConfig){
        facetConfig?.grep{ it.facetTermType in [ALL_DATA_TYPES.activeCompleted] }
    }


    public static List getFacetConfigWithHistogramSetting(List facetConfig){
        facetConfig?.grep{ it.facetTermType in [ALL_DATA_TYPES.histogram] }
    }

    public static List getFacetConfigForElasticSearch(List facetConfig){
        facetConfig?.grep{ !( it.facetTermType in [ALL_DATA_TYPES.presenceAbsence, ALL_DATA_TYPES.histogram, ALL_DATA_TYPES.date, ALL_DATA_TYPES.activeCompleted]) }
    }

    public static Boolean isFacetConfigSpecial(Map config){
        config?.facetTermType in SPECIAL_FACET_DATA_TYPES
    }
}
