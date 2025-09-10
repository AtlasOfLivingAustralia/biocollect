package au.org.ala.biocollect

import asset.pipeline.grails.AssetMethodTagLib
import asset.pipeline.grails.AssetProcessorService
import asset.pipeline.grails.AssetsTagLib
import grails.converters.JSON
import grails.testing.web.GrailsWebUnitTest
import grails.testing.web.taglib.TagLibUnitTest
import groovy.json.JsonSlurper
import org.grails.web.converters.marshaller.json.CollectionMarshaller
import org.grails.web.converters.marshaller.json.MapMarshaller
import spock.lang.Specification

class TemplateTagLibSpec extends Specification implements TagLibUnitTest<TemplateTagLib>, GrailsWebUnitTest {
    AssetProcessorService assetProcessorServiceEx

    def setup() {
        JSON.registerObjectMarshaller(new MapMarshaller())
        JSON.registerObjectMarshaller(new CollectionMarshaller())
        mockTagLibs(AssetsTagLib, AssetMethodTagLib)
    }

    def "test getFilesToPreCacheForPWA"() {
        given:
        assetProcessorServiceEx = Mock(AssetProcessorService)
        assetProcessorServiceEx.assetBaseUrl(_, _) >> { "" }
        assetProcessorServiceEx.getAssetPath(_, _) >> { args -> args[0] }
        def attrs = [:] // Add any required attributes here
        def g = grailsApplication.mainContext.getBean(AssetsTagLib)
        def asset = grailsApplication.mainContext.getBean(AssetMethodTagLib)
        g.assetProcessorService = assetProcessorServiceEx
        asset.assetProcessorService = assetProcessorServiceEx

        and:
        grailsApplication.config.pwa.serviceWorkerConfig.filesToPreCache = ['ala.svg']

        when:
        def result = tagLib.getFilesToPreCacheForPWA(attrs)
        result = result.toString()

        then:
        result != null
        result instanceof String

        and:
        def json = new JsonSlurper().parseText(result)
        json instanceof List

        and:
        json[0].contains("ala.svg")
    }
    
    void "isUrlActivePage returns true when url matches request URI with query string"() {
        setup:
        setupRequest()
        String testUrl = "/current/page?id=123"

        expect:
        tagLib.isUrlActivePage(testUrl)
    }

    void "isUrlActivePage returns false when query string does not match"() {
        setup:
        setupRequest()
        String testUrl = "/current/page?id=1y1"

        expect:
        !tagLib.isUrlActivePage(testUrl)
    }

    void "isUrlActivePage returns false when url does not match"() {
        setup:
        setupRequest()
        String testUrl = "/other/page?id=123"

        expect:
        !tagLib.isUrlActivePage(testUrl)
    }

    void "isUrlActivePage ignores query string when ignoreQueryString is true"() {
        setup:
        setupRequest()
        String testUrl = "current/page?id=xyz"

        expect:
        tagLib.isUrlActivePage(testUrl, true)
    }

    void "isUrlActivePage handles malformed URL gracefully"() {
        setup:
        setupRequest()
        String testUrl = "invalid url"

        expect:
        !tagLib.isUrlActivePage(testUrl)
    }

    void "isUrlActivePage returns false when url is null"() {
        setup:
        setupRequest()

        expect:
        !tagLib.isUrlActivePage(null)
    }

    private void setupRequest() {
        request.method = 'GET'
        request.requestURI = '/current/page'
        request.forwardURI = '/current/page'
        request.contextPath = ''
        request.setParameter('id', '123')
    }
}
