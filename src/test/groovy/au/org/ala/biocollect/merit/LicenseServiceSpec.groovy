package au.org.ala.biocollect.merit

import grails.testing.services.ServiceUnitTest
import spock.lang.Specification

class LicenseServiceSpec extends Specification implements ServiceUnitTest<LicenseService> {

    void "should return current licences from most to least permissive"() {
        when:
        def licences = service.licences().findAll { it.current }

        then:
        licences.description == [
                'CC0 1.0',
                'CC BY 4.0',
                'CC BY-SA 4.0',
                'CC BY-ND 4.0',
                'CC BY-NC 4.0',
                'CC BY-NC-SA 4.0',
                'CC BY-NC-ND 4.0'
        ]
    }

    void "should expose survey, photo point and species list subsets"() {
        expect:
        service.surveyLicences().every { it.survey }
        service.photoPointLicences().every { it.photoPoint }
        service.speciesListLicences().every { it.speciesList }
        service.surveyLicences().url.contains('https://creativecommons.org/licenses/by/4.0/')
        service.surveyLicences().url.contains('https://creativecommons.org/licenses/by-nc/4.0/')
        service.surveyLicences().url.contains('https://creativecommons.org/publicdomain/zero/1.0/')
        !service.surveyLicences().url.contains('https://creativecommons.org/licenses/by-nc/3.0/au/')
        !service.surveyLicences().url.contains('https://creativecommons.org/licenses/by-nc/2.5/')
        service.licences().url.contains('https://creativecommons.org/licenses/by-nc/3.0/au/')
        service.licences().url.contains('https://creativecommons.org/licenses/by-nc/2.5/')
        service.photoPointLicences().code == ['CC0', 'CC BY', 'CC BY-SA', 'CC BY-NC', 'CC BY-NC-SA']
    }

    void "should compose licences from official Creative Commons icon SVGs"() {
        expect:
        service.licences().find { it.url.contains('/zero/') }.icons == ['cc', 'zero']
        service.licences().find { it.url == 'https://creativecommons.org/licenses/by/4.0/' }.icons == ['cc', 'by']
        service.licences().find { it.url.contains('/by-sa/') }.icons == ['cc', 'by', 'sa']
        service.licences().find { it.url.contains('/by-nd/') }.icons == ['cc', 'by', 'nd']
        service.licences().find { it.url == 'https://creativecommons.org/licenses/by-nc/4.0/' }.icons == ['cc', 'by', 'cc-nc']
        service.licences().find { it.url.contains('/by-nc-sa/') }.icons == ['cc', 'by', 'cc-nc', 'sa']
        service.licences().find { it.url.contains('/by-nc-nd/') }.icons == ['cc', 'by', 'cc-nc', 'nd']
    }

    void "should map imported licence names to stored codes"() {
        expect:
        service.codeForName('Creative Commons Attribution') == 'CC BY'
        service.codeForName('Creative Commons Attribution 4.0 International') == 'CC BY'
        service.codeForName('Creative Commons Attribution-Noncommercial') == 'CC BY-NC'
        service.codeForName('Creative Commons Attribution-Share Alike') == 'CC BY-SA'
        service.codeForName('Creative Commons Attribution-Noncommercial-Share Alike') == 'CC BY-NC-SA'
        service.codeForName('CC-BY') == 'CC BY'
        service.codeForName(null) == null
    }

    void "should return independent copies so callers cannot mutate the supported list"() {
        when:
        def licences = service.licences()
        licences.first().name = 'mutated'

        then:
        service.licences().first().name != 'mutated'
    }
}
