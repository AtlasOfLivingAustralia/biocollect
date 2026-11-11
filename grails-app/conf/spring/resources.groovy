import au.org.ala.biocollect.ExternalReloadableMessageSource
import au.org.ala.biocollect.merit.hub.HubAwareLinkGenerator

import java.time.Duration

// Place your Spring DSL code here
beans = {
    // Overriding the default grailsLinkGenerator with our class that can include the hub path in generated URLs.
    // The assetProcessorService (registered by asset-pipeline's AutoConfiguration) is passed through so the
    // super constructor wires AssetProcessorService.grailsLinkGenerator = this, keeping <asset:*> tags working.
    grailsLinkGenerator(HubAwareLinkGenerator, grailsApplication.config.getProperty('server.serverURL', String, "http://localhost:8087/biocollect"), ref('assetProcessorService'))

    // Replaces Boot's classpath-only message source. External files are listed first so they override
    // the basenames the Grails i18n plugin composed into spring.messages.basename.
    messageSource(ExternalReloadableMessageSource,
            ExternalReloadableMessageSource.basenames(
                    ['file:///var/opt/atlas/i18n/biocollect/messages',
                     'file:///opt/atlas/i18n/biocollect/messages'],
                    grailsApplication.config.getProperty('spring.messages.basename', String, 'messages')),
            grailsApplication.config.getProperty('spring.messages.encoding', String, 'UTF-8'),
            grailsApplication.config.getProperty('spring.messages.fallback-to-system-locale', Boolean, Boolean.FALSE),
            grailsApplication.config.getProperty('spring.messages.cache-duration', Duration, null))
}
