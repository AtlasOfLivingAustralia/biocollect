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
        webService.deleteWrapper(grailsApplication.config.ecodata.service.url + "/comment/${data['id']}?userId=${data['userId']}")
    }

    def updateComment(data){
        webService.doPost(grailsApplication.config.ecodata.service.url + "/comment/${data['id']}",data)
    }

    def listComments(data) {
        def response = webService.doGet(grailsApplication.config.ecodata.service.url + "/comment", data)
        if(response?.resp){
            response.resp['userId'] = authService.getUserId()
        }
        response
    }

}
