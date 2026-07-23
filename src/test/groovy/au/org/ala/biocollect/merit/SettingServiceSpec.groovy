package au.org.ala.biocollect.merit

import asset.pipeline.AssetPipelineConfigHolder
import au.org.ala.biocollect.merit.hub.HubSettings
import grails.testing.services.ServiceUnitTest
import grails.testing.web.controllers.ControllerUnitTest
import org.grails.web.servlet.mvc.GrailsWebRequest
import spock.lang.Specification

class SettingServiceSpec extends Specification implements ControllerUnitTest, ServiceUnitTest<SettingService> {
    File temp, uploadPath

    void setup() {
        temp = File.createTempDir("tmp", "")
        uploadPath = new File(temp, "bootstrap5")
        uploadPath.mkdir()

        URL resource = getClass().getResource("/data/test.scss")
        au.org.ala.biocollect.FileUtils.copyResourcesRecursively(resource, uploadPath)

        grailsApplication.config.temp.dir = uploadPath.getAbsolutePath()
        grailsApplication.config.bootstrap5 = [themeDirectory: "/",
                                               themeFileName: "test",
                                               themeExtension: "scss"]

        service.grailsApplication = grailsApplication
    }

    def "should preserve the Bootstrap resource directory in exploded and packaged applications"() {
        given:
        File extractedResourceDir = new File(temp, "bootstrap5")

        expect:
        SettingService.copyDestinationForResource(resource, extractedResourceDir) ==
                (copyToParent ? extractedResourceDir.parentFile : extractedResourceDir)

        where:
        resource                                              | copyToParent
        new URL("file:/application/data/bootstrap5")          | true
        new URL("jar:file:/application.jar!/data/bootstrap5") | false
    }

    def "should copy exploded Bootstrap resources to the configured theme path"() {
        given:
        URL resource = getClass().getResource("/data/bootstrap5")
        File destination = SettingService.copyDestinationForResource(resource, uploadPath)

        when:
        boolean copied = au.org.ala.biocollect.FileUtils.copyResourcesRecursively(resource, destination)

        then:
        copied
        new File(uploadPath, "scss/styles.scss").isFile()
    }

    def "should initialize Bootstrap resources under temp dir"() {
        given:
        List originalResolvers = new ArrayList(AssetPipelineConfigHolder.resolvers)
        grailsApplication.config.temp.dir = temp.absolutePath
        grailsApplication.config.bootstrap5.copyFromDir = "bootstrap5"

        when:
        service.initService()

        then:
        new File(temp, "bootstrap5/scss/styles.scss").isFile()

        cleanup:
        AssetPipelineConfigHolder.resolvers.clear()
        AssetPipelineConfigHolder.resolvers.addAll(originalResolvers)
    }

    def "should generate basic style when template configuration is missing"() {
        setup:
        def hub = new HubSettings([urlPath: 'abc'])

        when:
        service.generateStyleSheetForHub(hub)
        def result = new File(uploadPath, "test.abc.css")
        then:
        result.exists()
        result.text.contains("blue")
    }

    def "should generate style when template configuration is present"() {
        setup:
        def hub = new HubSettings([urlPath: 'abc', templateConfiguration: [styles: [primaryColor: 'black']],
                                   lastUpdated: "2021-01-01T00:00:00Z"])
        Long lastUpdated = au.org.ala.biocollect.DateUtils.parse(hub.lastUpdated).toDate().getTime()

        when:
        service.generateStyleSheetForHub(hub)
        def result = new File(uploadPath, "test.abc.${lastUpdated}.css")

        then:
        result.exists()
        result.text.contains("black")
    }

    def "should not load invalid value to cookie"() {
        setup:
        grailsApplication.config.app.default.hub = "xyz"
        service.cacheService = new CacheService()
        service.webService = Mock(WebService)

        when:
        service.webService.getJson(*_) >> [:]
        service.loadHubConfig(hub)

        then:
        service.getHubConfig().urlPath == expected
        GrailsWebRequest.lookup().params.hub == expected
        response.getCookie(service.LAST_ACCESSED_HUB) == null

        where:
        hub       | expected
        "ab=!*cd" | "xyz"
    }
}