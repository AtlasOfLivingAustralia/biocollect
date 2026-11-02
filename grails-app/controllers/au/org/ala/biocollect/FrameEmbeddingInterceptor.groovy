package au.org.ala.biocollect

import java.util.regex.Pattern

/**
 * Lets the origins in app.embedding.allowedOrigins (e.g. the PWA dev server) embed the /pwa pages
 * in an iframe. Without any, the pages keep the default same-origin-only framing.
 */
class FrameEmbeddingInterceptor {
    // Plain origins only, so a configured value can't add CSP directives or a wildcard
    private static final Pattern ORIGIN = ~/https?:\/\/[A-Za-z0-9.\-]+(:\d+)?/

    int order = 2

    FrameEmbeddingInterceptor() {
        match(controller: 'bioActivity', action: ~/pwa.*/)
    }

    boolean before() {
        List<String> origins = []
        grailsApplication.config.getProperty('app.embedding.allowedOrigins', List, []).each {
            String origin = it.toString().trim().replaceAll(/\/+$/, '')
            if (origin ==~ ORIGIN) {
                origins << origin
            } else {
                log.warn("Ignoring invalid app.embedding.allowedOrigins entry: ${it}")
            }
        }

        // frame-ancestors takes precedence over any X-Frame-Options header in current browsers
        if (origins) {
            response.setHeader('Content-Security-Policy', "frame-ancestors 'self' ${origins.join(' ')}")
        }

        true
    }

    boolean after() { true }

    void afterView() {
        // no-op
    }
}
