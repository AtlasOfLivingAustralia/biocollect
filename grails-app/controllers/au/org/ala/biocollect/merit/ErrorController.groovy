package au.org.ala.biocollect.merit

class ErrorController {

    def settingService, cookieService
    def response404() {
        loadRecentHub()
        render view:'/404'
    }

    def response500() {
        loadRecentHub()
        render view:'/error'
    }

    /**
     * Loads the most recently accessed hub configuration so the error pages have access to the skin. (In the
     * case of a 404 error, the hub may not be available for the current request).
     */
    private void loadRecentHub() {
        def hub = cookieService.getCookie(SettingService.LAST_ACCESSED_HUB)
        settingService.loadHubConfig(hub)
    }
}
