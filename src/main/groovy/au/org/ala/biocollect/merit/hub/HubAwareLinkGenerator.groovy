package au.org.ala.biocollect.merit.hub

import asset.pipeline.grails.AssetProcessorService
import asset.pipeline.grails.AssetSupportingCachingLinkGenerator
import org.grails.web.servlet.mvc.GrailsWebRequest

/**
 * Overrides the grails CachingLinkGenerator to always add the hub parameter (if the user is viewing a hub)
 * to the call to generate the link.  This is to allow the URLMappings containing the hub to be selected in
 * preference to the defaults.
 *
 * Extends asset-pipeline's {@link AssetSupportingCachingLinkGenerator} (rather than the plain
 * CachingLinkGenerator) because BioCollect registers this class as the {@code grailsLinkGenerator} bean,
 * overriding the one asset-pipeline registers. That asset-pipeline generator's constructor is what wires
 * {@code AssetProcessorService.grailsLinkGenerator}; extending it preserves that wiring so the
 * {@code <asset:*>} tags can resolve the context path.
 */
class HubAwareLinkGenerator extends AssetSupportingCachingLinkGenerator {

    HubAwareLinkGenerator(String serverBaseUrl, AssetProcessorService assetProcessorService) {
        super(serverBaseUrl, assetProcessorService)
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
