package au.org.ala.biocollect.merit.hub

import org.codehaus.groovy.grails.web.json.JSONObject

/**
 * The configuration for a hub.
 */
class HubSettings extends JSONObject {

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
     * List all facet names.
     * @return
     */
    public List getFacets(){
        List facets = getConfigForFacets()
        facets?.collect { it.name }
    }

    /**
     * List facets and their configuration settings
     * @return
     */
    public List getConfigForFacets(){
        if(this.facets){
            this.facets;
        }
    }

    /**
     * Check if the hub has selected configurable template as its skin.
     * @return
     */
    public boolean isFacetListConfigured(){
        Boolean flag = false;
        if(this.facets && this.facets.size()){
            flag = true
        }

        flag
    }
}
