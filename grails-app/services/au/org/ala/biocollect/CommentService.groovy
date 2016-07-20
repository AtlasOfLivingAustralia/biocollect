package au.org.ala.biocollect

class CommentService {

    def webService
    def grailsApplication
    def userService
    def authService

    def addComment(data) {
        webService.doPost(grailsApplication.config.ecodata.service.url + "/comment",data)
    }

    def getComment(data){
        webService.doGet(grailsApplication.config.ecodata.service.url + "/comment/${data['id']}", null);
    }

    def deleteComment(data){
        Boolean isALAAdmin = userService.userIsAlaAdmin();
        webService.deleteWrapper(grailsApplication.config.ecodata.service.url + "/comment/${data['id']}?userId=${data['userId']}&isALAAdmin=${isALAAdmin}")
    }

    def updateComment(data){
        data['isALAAdmin'] = userService.userIsAlaAdmin();
        webService.doPost(grailsApplication.config.ecodata.service.url + "/comment/${data['id']}",data)
    }

    def listComments(data) {
        Boolean admin = userService.userIsAlaAdmin();
        def response = webService.doGet(grailsApplication.config.ecodata.service.url + "/comment", data)
        if(response?.resp){
            response.resp['userId'] = authService.getUserId()
            Map privilege = webService.doGet(grailsApplication.config.ecodata.service.url + "/comment/canUserEditOrDeleteComment",
                [userId:response.resp['userId'], entityId:data['entityId'], entityType: data['entityType']] ).resp;
            // this is used by knockout to decide if edit/delete should be shown.
            response.resp['admin'] = privilege?.isAdmin || admin
        }
        response
    }

}
