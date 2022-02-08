package au.org.ala.biocollect.merit

import grails.testing.services.ServiceUnitTest
import spock.lang.Specification

class CollectoryServiceSpec extends Specification implements ServiceUnitTest<CollectoryService> {

    def webServiceStub = Mock(WebService)
    def cacheServiceStub = Mock(CacheService)

    void setup() {
        service.webService = webServiceStub
        service.cacheService = cacheServiceStub
    }

    void "should be able to get licences when collectory is available"() {
        given:
        def collectoryResponse = [
                [url: 'https://creativecommons.org/publicdomain/zero/1.0/', name: 'zero'],
                [url: 'https://creativecommons.org/licenses/by-nc/2.5/', name: 'by-nc-2.5'],
                [url: 'https://creativecommons.org/licenses/by/4.0/', name: 'by'],
                [url: 'https://creativecommons.org/licenses/by-nc/3.0/au/', name: 'by-nc-3.0'],
        ]

        when:
        def licences = service.licence()

        then:
        1 * cacheServiceStub.get('collectory-licence-names', _, _) >> collectoryResponse
        0 * _
        licences.size() == 4
        licences.every { l ->
            def found = collectoryResponse.find { f ->
                f.url == l.url
            }
            l.url && l.logo && l.description && l.name == found.name
        }
    }

    void "should be able to get licences when collectory is not available"() {
        when:
        def licences = service.licence()

        then:
        1 * cacheServiceStub.get('collectory-licence-names', _, _) >> []
        0 * _
        licences.size() == 4
        licences.every { it.url && it.logo && it.description && !it.name }
    }

    void "should return an empty list when the web service call fails"() {
        given:
        def oldCacheService = service.cacheService
        service.cacheService = new CacheService()

        when:
        def licences = service.licence()

        then:
        1 * webServiceStub.getJson("${grailsApplication.config.collectory.service.url}/licence/") >> []
        0 * _
        licences.size() == 4
        licences.every { it.url && it.logo && it.description && !it.name }

        cleanup:
        service.cacheService = oldCacheService
    }
}
