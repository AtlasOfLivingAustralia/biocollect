package au.org.ala.biocollect.merit

import grails.testing.web.controllers.ControllerUnitTest
import spock.lang.Specification

class ErrorControllerSpec extends Specification implements ControllerUnitTest<ErrorController> {

    def settingService = Stub(SettingService)

    def setup() {
        controller.settingService = settingService
    }

    def "json requests receive the IllegalArgumentException message"() {
        given:
        params.format = 'json'
        request.setAttribute('exception', new RuntimeException(new IllegalArgumentException('Provided projectId is invalid')))

        when:
        controller.response500()

        then:
        response.status == 500
        response.json.status == 'error'
        response.json.message == 'Provided projectId is invalid'
    }

    def "html requests render the error page"() {
        given:
        params.format = 'html'
        def wrapper = new RuntimeException(new IllegalArgumentException('Provided projectId is invalid'))
        request.setAttribute('exception', wrapper)

        when:
        controller.response500()

        then:
        response.status == 500
        view == '/error'
        model.exception.is(wrapper)
    }
}
