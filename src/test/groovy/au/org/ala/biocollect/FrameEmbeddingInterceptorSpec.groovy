package au.org.ala.biocollect

import grails.testing.web.interceptor.InterceptorUnitTest
import spock.lang.Specification

class FrameEmbeddingInterceptorSpec extends Specification implements InterceptorUnitTest<FrameEmbeddingInterceptor> {

    def "only the pwa actions are matched"() {
        when:
        withRequest(controller: controllerName, action: actionName)

        then:
        interceptor.doesMatch() == matches

        where:
        controllerName | actionName    || matches
        'bioActivity'  | 'pwa'         || true
        'bioActivity'  | 'pwaSettings' || true
        'bioActivity'  | 'mobileEdit'  || false
        'project'      | 'pwaSettings' || false
    }

    def "configured origins are added to frame-ancestors"() {
        given:
        grailsApplication.config.app.embedding.allowedOrigins = ['http://localhost:5173', ' https://example.org/ ']
        withRequest(controller: 'bioActivity', action: 'pwaSettings')

        expect:
        interceptor.before()
        response.getHeader('Content-Security-Policy') == "frame-ancestors 'self' http://localhost:5173 https://example.org"
    }

    def "invalid origins are ignored"() {
        given:
        grailsApplication.config.app.embedding.allowedOrigins = ['*', 'http://a.com; script-src *', 'ftp://b.com', 'localhost:5173']
        withRequest(controller: 'bioActivity', action: 'pwaSettings')

        expect:
        interceptor.before()
        response.getHeader('Content-Security-Policy') == null
    }

    def "no header is added when no origins are configured"() {
        given:
        withRequest(controller: 'bioActivity', action: 'pwaSettings')

        expect:
        interceptor.before()
        response.getHeader('Content-Security-Policy') == null
    }
}
