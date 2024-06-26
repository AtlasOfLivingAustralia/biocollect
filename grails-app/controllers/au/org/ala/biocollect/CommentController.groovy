package au.org.ala.biocollect

import au.org.ala.biocollect.merit.BaseController
import au.org.ala.biocollect.merit.CommonService
import au.org.ala.biocollect.merit.UserService
import au.org.ala.web.NoSSO
import au.org.ala.web.SSO

import static org.apache.http.HttpStatus.SC_BAD_REQUEST

@SSO
class CommentController extends BaseController {

    CommonService commonService
    CommentService commentService
    UserService userService

    def create() {
        Map json = commonService.parseParams(params)
        json.userId = userService.getCurrentUserId()
        if (!json.userId|| !json.entityId || !json.entityType || !json.text){
            response.sendError(SC_BAD_REQUEST, 'Missing userId, text, entityId and/or entityType')
        } else {
            def response = commentService.addComment(json)
            handle response
        }
    }


    def update() {
        def json = commonService.parseParams(params);
        json.userId = userService.getCurrentUserId()
        if (!json.userId|| !json.entityId || !json.entityType || !json.text){
            response.sendError(SC_BAD_REQUEST, 'Missing userId, text, entityId and/or entityType')
        }  else if (json) {
            def response = commentService.updateComment(json)
            handle response
        }
    }

    def delete() {
        def json = commonService.parseParams(params);
        json.userId = userService.getCurrentUserId()
        if (!json.id || !json.userId){
            response.sendError(SC_BAD_REQUEST, 'Missing userId and/or comment id')
        }  else if (json) {
            def response = commentService.deleteComment(json)
            handle response
        }
    }

    @NoSSO
    def list() {
        Map json = commonService.parseParams(params)
        if (!json.entityId || !json.entityId) {
            response.sendError(SC_BAD_REQUEST, 'Missing entityId and/or entityType')
        } else {
            def response = commentService.listComments(json)
            handle response
        }
    }

    @NoSSO
    def get(){
        Map json = commonService.parseParams(params);
        if (!json.id ){
            response.sendError(SC_BAD_REQUEST, "Missing id");
        } else {
            def response = commentService.getComment(json)
            handle response
        }
    }
}
