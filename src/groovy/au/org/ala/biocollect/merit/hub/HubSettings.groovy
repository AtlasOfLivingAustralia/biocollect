package au.org.ala.biocollect.merit.hub

/**
 * The configuration for a hub.
 */
class HubSettings {

    /** Identifies this hub - should be a short string as it is used in the URL path */
    String id

    /** URL pointing to an image that will displayed as a background image header block of all pages in the hub */
    def bannerUrl

    /** URL pointing to an image that will displayed as a logo in the top left of the header block of all pages in the hub */
    def logoUrl

    /** The title of the hub - currently displayed on the home page */
    String title

    /** The (ordered) list of facets that will be displayed on the home and search pages */
    List<String> availableFacets

    /** Admin only facets */
    List<String> adminFacets

    /** All searches made in this hub will automatically include this (facet) query.  Should be of the form <facetName>:<value> */
    List<String> defaultFacetQuery

    /** Projects created within this hub will only be able to select from the programs configured here */
    List<String> supportedPrograms

    /** Home page map facets */
    List<String> availableMapFacets

    String skin = "nrm"

    /**
     * Path to this hub's home page - must be in the format /<controller>/<action>
     * This allows a hub to specify a different home page to the default.
     */
    String homePagePath = ""

    /**
     * Allows the property to be set using a JSONArray which has an implementation of join which is
     * incompatible with how this is used by the SearchService.
     */
    def setAvailableFacets(List<String> facets) {
        this.availableFacets = new ArrayList<String>(facets)
    }
    def setAvailableMapFacets(List<String> facets) {
        this.availableMapFacets = new ArrayList<String>(facets)
    }

    def setSupportedPrograms(List<String> supportedPrograms) {
        this.supportedPrograms = new ArrayList<String>(supportedPrograms)
    }

    public boolean overridesHomePage() {
        return homePagePath as boolean
    }

    /**
     * Returns a map [controller: , action: ] based on parsing the homePathPage.  If the homePathPath property
     * isn't set or doesn't match the expected pattern, the default home index page will be returned..
     */
    public Map getHomePageControllerAndAction() {
        if (overridesHomePage()) {
            def regexp = "\\/(.*)\\/(.*)"
            def matcher = (homePagePath =~ regexp)
            if (matcher.matches()) {
                def controller = matcher[0][1]
                def action = matcher[0][2]
                return [controller:controller, action:action]
            }
        }
        return [controller:'home', action:'index']
    }

    public void setHomePageControllerAndAction(Map unused) {
        // Do nothing - this method is here to allow us to construct this object using a Map without errors.
    }

}
