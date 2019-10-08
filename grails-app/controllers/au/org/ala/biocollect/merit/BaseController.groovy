package au.org.ala.biocollect.merit

import grails.converters.JSON

import static org.apache.http.HttpStatus.SC_OK

class BaseController {


    def sendError = {int status, String msg = null ->
        response.status = status
        response.sendError(status, msg)
    }

    def handle (resp) {
        if (resp.statusCode != SC_OK) {
            log.debug "Response status ${resp.statusCode} returned from operation"
            response.status = resp.statusCode
            sendError(resp.statusCode, resp.error ?: "")
        } else {
            response.setContentType('application/json')
            render resp.resp as JSON
        }
    }


}
