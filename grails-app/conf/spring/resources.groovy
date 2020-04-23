import au.org.ala.biocollect.merit.hub.HubAwareLinkGenerator

// Place your Spring DSL code here
beans = {
    // Overriding the default grailsLinkGenerator with our class that can include the hub path in generated URLs
    grailsLinkGenerator(HubAwareLinkGenerator, grailsApplication.config.server.serverURL?:"http://localhost:8087/biocollect")
}
