package au.org.ala.biocollect

import grails.interceptors.Matcher

class NoCacheFilterInterceptor {

    private static final String HEADER_PRAGMA = "Pragma";
    private static final String HEADER_EXPIRES = "Expires";
    private static final String HEADER_CACHE_CONTROL = "Cache-Control";
    private Matcher matcher
    int order = 1
    NoCacheFilterInterceptor() {
        matcher = matchAll().excludes(controller:'document', action:'download')
            .excludes(uri: '/proxy/speciesLists/.*').excludes(uri: '/proxy/speciesList/.*')
            .excludes(uri: '/proxy/speciesItemsForList/.*').excludes(uri: '/proxy/speciesProfile/.*')
    }


    boolean before() {
        if (grailsApplication.config.getProperty("app.view.nocache", Boolean)) {
            // exclude document downloads
            if (controllerName == 'document' && actionName == 'download') {
                return true
            }

            // Exclude by URI patterns
            def path = request.forwardURI ?: request.requestURI

            if (path ==~ /\/proxy\/speciesLists\/.*/ ||
                    path ==~ /\/proxy\/speciesList\/.*/ ||
                    path ==~ /\/proxy\/speciesItemsForList\/.*/ ||
                    path ==~ /\/proxy\/speciesProfile\/.*/) {
                return true
            }

            response.setHeader(HEADER_PRAGMA, "no-cache");
            response.setDateHeader(HEADER_EXPIRES, 1L);
            response.setHeader(HEADER_CACHE_CONTROL, "no-cache");
            response.addHeader(HEADER_CACHE_CONTROL, "no-store");
        }
        true
    }

    boolean after() {
        true
    }

    void afterView() {
        // no-op
    }
}
