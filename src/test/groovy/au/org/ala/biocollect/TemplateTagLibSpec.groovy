package au.org.ala.biocollect

import asset.pipeline.grails.AssetProcessorService
import asset.pipeline.grails.AssetsTagLib
import asset.pipeline.grails.AssetMethodTagLib
import grails.testing.web.taglib.TagLibUnitTest
import groovy.json.JsonSlurper
import spock.lang.Specification

class TemplateTagLibSpec extends Specification implements TagLibUnitTest<TemplateTagLib> {
    AssetProcessorService assetProcessorServiceEx
    @Override
    Closure doWithSpring() {
        {->
            assetProcessorServiceEx = Mock(AssetProcessorService)
            assetProcessorServiceEx.assetBaseUrl(_, _) >> { it }
            assetProcessorServiceEx.getAssetPath(_, _) >> { it }

            assetProcessorService assetProcessorServiceEx
        }
    }

    def setupSpec() {
        mockTagLibs(AssetsTagLib, AssetMethodTagLib)
    }

    def "test getFilesToPreCacheForPWA"() {
        given:
        def attrs = [:] // Add any required attributes here

        and:
        grailsApplication.config.pwa.serviceWorkerConfig.filesToPreCache = ['ala.svg']

        when:
        def result = tagLib.getFilesToPreCacheForPWA(attrs)

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
