package au.org.ala.biocollect.merit.hub

import au.org.ala.biocollect.merit.SettingService

import javax.servlet.*

/**
 * Exposes some thread local configuration based on the URL.
 * Grails filters haven't been used as the hub configuration needs to be available during page rendering.
 */
class HubConfigurationFilter implements Filter {

    void init(FilterConfig config) {}

    void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) {

        try {
            chain.doFilter(request, response)
        }
        finally {
            SettingService.clearHubConfig()
        }
    }

    void destroy() {}
}
