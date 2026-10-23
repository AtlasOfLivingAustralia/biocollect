package au.org.ala.biocollect.merit

import grails.converters.JSON
import org.springframework.http.HttpStatus

class BaseController {

    def handle (resp) {
        if (resp.statusCode != HttpStatus.OK.value()) {
            log.debug "Response status ${resp.statusCode} returned from operation"
            response.status = resp.statusCode
            response.sendError(resp.statusCode, resp.error ?: "")
        } else {
            response.setContentType('application/json')
            render resp.resp as JSON
        }
    }


}
