package au.org.ala.biocollect

import asset.pipeline.grails.AssetProcessorService
import asset.pipeline.grails.AssetsTagLib
import asset.pipeline.grails.AssetMethodTagLib
import grails.converters.JSON
import grails.testing.web.taglib.TagLibUnitTest
import groovy.json.JsonSlurper
import org.grails.web.converters.marshaller.json.CollectionMarshaller
import org.grails.web.converters.marshaller.json.MapMarshaller
import spock.lang.Specification

class TemplateTagLibSpec extends Specification implements TagLibUnitTest<TemplateTagLib> {
    AssetProcessorService assetProcessorServiceEx

    def setupSpec() {
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
}
