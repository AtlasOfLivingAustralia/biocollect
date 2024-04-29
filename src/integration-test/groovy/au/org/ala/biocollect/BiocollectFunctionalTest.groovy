package au.org.ala.biocollect

import geb.Browser
import geb.spock.GebReportingSpec
import groovy.util.logging.Slf4j
import org.grails.config.NavigableMap
import org.grails.config.PropertySourcesConfig
import org.grails.config.yaml.YamlPropertySourceLoader
import org.springframework.core.io.FileSystemResource
import org.springframework.core.io.Resource
import pages.EntryPage
import spock.lang.Shared
/**
 * Helper class for functional tests in fieldcapture.
 */
@Slf4j
class BiocollectFunctionalTest extends GebReportingSpec {

    @Shared def testConfig

    def setupSpec() {
        testConfig = new NavigableMap()
        def propertySource = new YamlPropertySourceLoader()
        Resource resource = new FileSystemResource(getClass().getClassLoader().getResource('application.yml').getFile())
        def yamlPropertiesSource = propertySource.load('application.yml', resource)
        def ymlConfig = new PropertySourcesConfig(yamlPropertiesSource.first())
        testConfig.merge(ymlConfig)

        def filePath = getClass().getClassLoader().getResource('application.groovy').toURI().toURL()
        log.info(filePath.toString());
        def configSlurper = new ConfigSlurper(System.properties.get('grails.env'))
        testConfig.merge(configSlurper.parse(filePath), false)

        log.info("External ${testConfig.toString()}")

//        if (testConfig.grails.config.locations) {
//            def props = new Properties()
//            def externalConfigFile = new File(testConfig.grails.config.locations)
//            if (externalConfigFile.exists()) {
//                externalConfigFile.withInputStream {
//                    props.load(it)
//                    log.info("Added external properties")
//                }
//            }
//            testConfig.merge(configSlurper.parse(props))
            if (System.getenv('PROJECT_EDITOR_USERNAME')) {
                testConfig.projectEditorUsername = System.getenv('PROJECT_EDITOR_USERNAME')
            }
            if (System.getenv('PROJECT_EDITOR_PASSWORD')) {
                testConfig.projectEditorPassword = System.getenv('PROJECT_EDITOR_PASSWORD')
            }
            if (System.getenv('PROJECT_ADMIN_USERNAME')) {
                testConfig.projectAdminUsername = System.getenv('PROJECT_ADMIN_USERNAME')
            }
            if (System.getenv('PROJECT_ADMIN_PASSWORD')) {
                testConfig.projectAdminPassword = System.getenv('PROJECT_ADMIN_PASSWORD')
            }
            if (System.getenv('ALA_ADMIN_USERNAME')) {
                testConfig.alaAdminUsername = System.getenv('ALA_ADMIN_USERNAME')
            }
            if (System.getenv('ALA_ADMIN_PASSWORD')) {
                testConfig.alaAdminPassword = System.getenv('ALA_ADMIN_PASSWORD')
            }
//        }

        checkConfig()
    }

    def checkConfig() {

        if (!testConfig.projectEditorUsername) {
            log.warn("Missing test configuration: projectEditorUsername")
        }
        if (!testConfig.projectEditorPassword) {
            log.warn("Missing test configuration: projectEditorPassword")
        }
        if (!testConfig.projectAdminUsername) {
            log.warn("Missing test configuration: projectAdminUsername")
        }
        if (!testConfig.projectAdminPassword) {
            log.warn("Missing test configuration: projectAdminPassword")
        }
        if (!testConfig.alaAdminUsername) {
            log.warn("Missing test configuration: alaAdminUsername")
        }
        if (!testConfig.alaAdminPassword) {
            log.warn("Missing test configuration: alaAdminPassword")
        }
    }


    /**
     * This method will drop the ecodata-test database, then load the data stored in the
     * test/functional/resources/${dataSetName} directory.
     * It is intended to ensure the database is in a known state to facilitate functional testing.
     * If the loading script fails, an Exception will be thrown.
     *
     * N.B. Running the script requires the current working directory to be the root of the fieldcapture-hub project.
     * (Which should be the case unless the tests are being run via an IDE)
     *
     * @param dataSetName identifies the data set to load.
     *
     */
    void useDataSet(String dataSetName) {

        def dataSetPath = getClass().getResource("/"+dataSetName+"/").getPath()

        log.info("Using dataset from: ${dataSetPath}")
        def userName = System.getProperty('grails.mongo.username') ?: ""
        def password = System.getProperty('grails.mongo.password') ?: ""
        int exitCode = "./src/main/scripts/loadFunctionalTestData.sh ${dataSetPath} ${userName} ${password}".execute().waitFor()
        if (exitCode != 0) {
            throw new RuntimeException("Loading data set ${dataSetPath} failed.  Exit code: ${exitCode}")
        }
    }

    def logout(Browser browser, Class returnPage = EntryPage) {
        def logoutButton = browser.page.$('.custom-header-login-logout')
        if (logoutButton.displayed && logoutButton.text() == "Logout") {
            try {
                logoutButton.click();
                waitFor 25, { at returnPage }
            }
            catch (Exception e) {
                log.warn("Test ended during page reload or with a modal backdrop resulting in failure to click logout button - directly navigating browser")
                logoutViaUrl(browser)
            }
        }
        else {
            logoutViaUrl(browser)
        }

    }

    def logoutViaUrl(browser) {
        String serverUrl = (testConfig.baseUrl instanceof String) ? testConfig.baseUrl : testConfig.grails.serverURL
        String logoutUrl = "${serverUrl}/logout?appUrl=${serverUrl}"
        browser.go logoutUrl
    }

}
