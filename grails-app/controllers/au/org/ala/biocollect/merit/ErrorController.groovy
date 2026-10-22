package au.org.ala.biocollect.merit

import grails.converters.JSON
import org.grails.web.util.WebUtils

class ErrorController {

    def settingService
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
        def wrapper = request.getAttribute(WebUtils.EXCEPTION_ATTRIBUTE)
        def exception = wrapper?.cause ?: wrapper
        try {
            if (exception instanceof IllegalArgumentException && params.format == 'json') {
                response.status = 500
                render([message: exception.message, status: 'error'] as JSON)
                return
            }
            loadRecentHub()
        }
        catch (Throwable ex) {
            log.error("An error occurred when loading recent hub - ${ex.message}", ex)
        }
        response.status = 500
        render view: '/error', model: [exception: wrapper]
    }

    /**
     * Loads the most recently accessed hub configuration so the error pages have access to the skin. (In the
     * case of a 404 error, the hub may not be available for the current request).
     */
    private void loadRecentHub() {
        def hub = request.cookies?.find { it.name == SettingService.LAST_ACCESSED_HUB }?.value
        settingService.loadHubConfig(hub)
    }
}
