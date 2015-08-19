package au.org.ala.biocollect.merit

/**
 * Adds cache control headers to all requests to prevent caching of the responses.
 */
class NoCacheFilterFilters {

    def grailsApplication

    private static final String HEADER_PRAGMA = "Pragma";
    private static final String HEADER_EXPIRES = "Expires";
    private static final String HEADER_CACHE_CONTROL = "Cache-Control";

    def filters = {
        all(controller: '*', action: '*') {
            before = {

                if (grailsApplication.config.app.view.nocache) {

                    response.setHeader(HEADER_PRAGMA, "no-cache");
                    response.setDateHeader(HEADER_EXPIRES, 1L);
                    response.setHeader(HEADER_CACHE_CONTROL, "no-cache");
                    response.addHeader(HEADER_CACHE_CONTROL, "no-store");
                }
            }
            after = { Map model ->

            }
            afterView = { Exception e ->

            }
        }
    }
}
