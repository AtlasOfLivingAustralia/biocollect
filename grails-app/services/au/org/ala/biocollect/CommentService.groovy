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
        Boolean alaAdmin = authService.userInRole(grailsApplication.config.security.cas.adminRole)
        webService.deleteWrapper(grailsApplication.config.ecodata.service.url + "/comment/${data['id']}?userId=${data['userId']}&isALAAdmin=${alaAdmin}")
    }

    def updateComment(data){
        data['isALAAdmin'] = authService.userInRole(grailsApplication.config.security.cas.adminRole)
        webService.doPost(grailsApplication.config.ecodata.service.url + "/comment/${data['id']}",data)
    }

    def listComments(data) {
        String userId = authService.getUserId()
        Boolean admin = authService.userInRole(grailsApplication.config.security.cas.adminRole)
        def response = webService.doGet(grailsApplication.config.ecodata.service.url + "/comment", data)
        if(response?.resp){
            response.resp['userId'] = authService.getUserId()
            Map privilege = webService.doGet(grailsApplication.config.ecodata.service.url + "/comment/doesUserHavePrivilege",
                [userId:response.resp['userId'], entityId:data['entityId'], entityType: data['entityType']] ).resp;

            response.resp['admin'] = privilege?.isAdmin || admin
        }
        response
    }

}
