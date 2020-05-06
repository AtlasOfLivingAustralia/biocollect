package au.org.ala.biocollect


class HubConfigurationInterceptor {
    def settingService
    int order = 0

    HubConfigurationInterceptor() {
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


