package au.org.ala.biocollect.merit.hub

import org.grails.web.mapping.CachingLinkGenerator
import org.grails.web.servlet.mvc.GrailsWebRequest

/**
 * Overrides the grails CachingLinkGenerator to always add the hub parameter (if the user is viewing a hub)
 * to the call to generate the link.  This is to allow the URLMappings containing the hub to be selected in
 * preference to the defaults.
 */
class HubAwareLinkGenerator extends CachingLinkGenerator {

    public HubAwareLinkGenerator(String serverBaseUrl) {
        super(serverBaseUrl)
    }

    @Override
    public String link(Map attrs, String encoding) {
        addHubToParams(attrs)
        super.link(attrs, encoding)
    }

    private void addHubToParams(attrs) {
        GrailsWebRequest request = GrailsWebRequest.lookup()
        if (request && request.params.hub) {
            def params = attrs.params ?:[:]
            if (!params.hub) {
                params.hub = request.params.hub
                attrs.params = params
            }
        }
    }
}
