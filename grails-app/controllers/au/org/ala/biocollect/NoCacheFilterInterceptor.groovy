package au.org.ala.biocollect


class NoCacheFilterInterceptor {

    private static final String HEADER_PRAGMA = "Pragma";
    private static final String HEADER_EXPIRES = "Expires";
    private static final String HEADER_CACHE_CONTROL = "Cache-Control";

    NoCacheFilterInterceptor() {
        match(controller:"*", action:"*") // using strings
        //matchAll()
    }


    boolean before() {
        if (grailsApplication.config.app.view.nocache) {

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
