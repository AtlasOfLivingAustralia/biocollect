package au.org.ala.biocollect.merit

import grails.converters.JSON

class ErrorController {

    def settingService, cookieService
    def response404() {
        try {
            loadRecentHub()
        }
        catch (Throwable ex) {
            log.error("An error occurred when loading recent hub - ${ex.getMessage()}", ex)
        }

        render view:'/404'
    }

    def response500() {
        // handle IllegalArugmentException and send a JSON message back with 500 status code
        def exception = request.exception?.cause?.target
        if ((exception instanceof IllegalArgumentException) && (params.format == 'json')) {
            response.status = 500
            render([message: exception.message, status: 'error'] as JSON)
            return
        } else {
            try {
                loadRecentHub()
            }
            catch (Throwable ex) {
                log.error("An error occurred when loading recent hub - ${ex.getMessage()}", ex)
            }

            render view:'/error'
        }
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
