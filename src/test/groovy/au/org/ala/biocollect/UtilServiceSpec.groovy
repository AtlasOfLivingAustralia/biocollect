package au.org.ala.biocollect

import grails.testing.services.ServiceUnitTest
import spock.lang.Specification
import au.org.ala.ecodata.forms.EcpWebService

class UtilServiceSpec extends Specification implements ServiceUnitTest<UtilService> {

    EcpWebService ecpWebService = Mock(EcpWebService)

    void setup() {
        service.FILE_BLACKLIST = ['exe', 'bat', 'cmd']
        service.ecpWebService = ecpWebService
    }

    void "returns true when file extension is not blacklisted"() {
        expect:
        service.isFileNameSafe('photo.png')
    }

    void "returns true for file names with multiple dots when final extension is not blacklisted"() {
        expect:
        service.isFileNameSafe('archive.backup.final.pdf')
    }

    void "returns false when file extension is blacklisted"() {
        expect:
        !service.isFileNameSafe('installer.exe')
    }

    void "returns false when file extension is blacklisted regardless of case"() {
        expect:
        !service.isFileNameSafe('script.CMD')
    }

    void "returns false when file name has no extension"() {
        expect:
        !service.isFileNameSafe('README')
    }

    void "returns false when file name is null"() {
        expect:
        !service.isFileNameSafe(null)
    }

    void "returns true for relative redirect URL"() {
        expect:
        service.isRedirectSafe('/project/123')
    }

    void "returns true for absolute redirect URL when domain is valid"() {
        given:
        ecpWebService.isValidDomain('example.org') >> true

        expect:
        service.isRedirectSafe('https://example.org/path')
    }

    void "returns false for absolute redirect URL when domain is not valid"() {
        given:
        ecpWebService.isValidDomain('malicious.example') >> false

        expect:
        !service.isRedirectSafe('https://malicious.example/path')
    }

    void "returns false for malformed redirect URL"() {
        expect:
        !service.isRedirectSafe('http://[invalid')
    }

    void "returns false for null redirect URL"() {
        expect:
        !service.isRedirectSafe(null)
    }

    void "returns false for blank redirect URL"() {
        expect:
        !service.isRedirectSafe('')
    }
}
