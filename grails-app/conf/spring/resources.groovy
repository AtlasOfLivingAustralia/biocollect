import au.org.ala.biocollect.merit.hub.HubAwareLinkGenerator

// Place your Spring DSL code here
beans = {
    // Overriding the default grailsLinkGenerator with our class that can include the hub path in generated URLs.
    // The assetProcessorService (registered by asset-pipeline's AutoConfiguration) is passed through so the
    // super constructor wires AssetProcessorService.grailsLinkGenerator = this, keeping <asset:*> tags working.
    grailsLinkGenerator(HubAwareLinkGenerator, grailsApplication.config.getProperty('server.serverURL', String, "http://localhost:8087/biocollect"), ref('assetProcessorService'))
}
