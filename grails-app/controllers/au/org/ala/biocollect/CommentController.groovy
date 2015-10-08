package au.org.ala.biocollect
import grails.converters.JSON

import static org.apache.http.HttpStatus.SC_OK

class CommentController {

    def commonService
    def commentService
//    def userService
    def authService

    def index(){
        log.debug('testing')
    }

    def create() {
        Map json = commonService.parseParams(params)
        json['userId'] = authService.getUserId()
        if (!json.userId|| !json.entityId || !json.entityType || !json.text){
            response.sendError(400, 'Missing userId, text, entityId and/or entityType')
        } else {
            def response = commentService.addComment(json)
            handle response
        }
    }


    def update() {
        def json = commonService.parseParams(params);
        json['userId'] = authService.getUserId()
        if (!json.userId|| !json.entityId || !json.entityType || !json.text){
            response.sendError(400, 'Missing userId, text, entityId and/or entityType')
        }  else if (json) {
            def response = commentService.updateComment(json)
            handle response
        }
    }

    def delete() {
        def json = commonService.parseParams(params);
        json['userId'] = authService.getUserId()
        if (!json.id){
            response.sendError(400, 'Missing userId, text, entityId and/or entityType')
        }  else if (json) {
            def response = commentService.deleteComment(json)
            handle response
        }
    }

    def list() {
        Map json = commonService.parseParams(params)
        if (!json.entityId || !json.entityId) {
            response.sendError(400, 'Missing entityId and/or entityType')
        } else {
            def response = commentService.listComments(json)

            handle response
        }
    }

    def get(){
        Map json = commonService.parseParams(params);
        if (!json.id ){
            response.sendError(400, "Missing id");
        } else {
            def response = commentService.getComment(json)
            handle response
        }
    }

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
