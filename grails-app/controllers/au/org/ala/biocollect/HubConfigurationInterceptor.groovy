package au.org.ala.biocollect


class HubConfigurationInterceptor {
    def settingService

    HubConfigurationInterceptor() {
        //match(controller:"*", action:"*") // using strings
        matchAll()
    }

    boolean before() {
        settingService.loadHubConfig(params.hub)
        true
    }

    boolean after() { true }

    void afterView() {
        // no-op
    }
}


