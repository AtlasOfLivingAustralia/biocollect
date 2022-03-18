package au.org.ala.biocollect.merit

import au.org.ala.biocollect.merit.hub.HubSettings
import grails.testing.spring.AutowiredTest
import spock.lang.Specification

class SettingServiceSpec extends Specification implements AutowiredTest {
    Closure doWithSpring() {{ ->
        service SettingService
    }}

    SettingService service
    File temp, uploadPath

    void setup() {
        temp = File.createTempDir("tmp", "")
        uploadPath = new File(temp, "bootstrap4")
        uploadPath.mkdir()

        URL resource = getClass().getResource("/data/test.scss")
        au.org.ala.biocollect.FileUtils.copyResourcesRecursively(resource, uploadPath)

        grailsApplication.config.temp.dir = uploadPath.getAbsolutePath()
        grailsApplication.config.bootstrap4 = [themeDirectory: "/",
                                               themeFileName: "test",
                                               themeExtension: "scss"]

        service.grailsApplication = grailsApplication
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
}