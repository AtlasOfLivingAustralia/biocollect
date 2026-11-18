package au.org.ala.biocollect.merit

import au.org.ala.ecodata.forms.EcpWebService
import au.org.ala.ecodata.forms.LicenceService
import grails.testing.services.ServiceUnitTest
import spock.lang.Specification

class CacheServiceSpec extends Specification implements ServiceUnitTest<CacheService> {
    def cleanup() {
        service.clear()
        grailsApplication.config.licences.allowlist = null
    }

    void "the host cache supports repeated plugin catalogue lookups"() {
        given:
        EcpWebService webService = Mock()
        def licenceService = new LicenceService(grailsApplication: grailsApplication,
                ecpWebService: webService, cacheService: service)
        Map licence = [name: 'Attribution', acronym: 'CC-BY 4.0 (Int)',
                url: LicenceService.DEFAULT_LICENCE, imageUrl: '', version: '4.0']
        grailsApplication.config.licences.allowlist = [licence.url]

        when:
        def first = licenceService.licences
        def defaultLicence = licenceService.defaultLicence

        then:
        1 * webService.getJson2(_, 5000) >> [statusCode: 200, resp: [licence]]
        first.contains(licence)
        defaultLicence == LicenceService.DEFAULT_LICENCE
    }

    void "expired cache entries are refreshed"() {
        given:
        service.cache['licences:test'] = [resp: ['old'], time: new Date(0)]

        expect:
        service.get('licences:test', { ['new'] }) == ['new']
        service.get('licences:test', { throw new AssertionError('Should use cache') }) == ['new']
    }
}
