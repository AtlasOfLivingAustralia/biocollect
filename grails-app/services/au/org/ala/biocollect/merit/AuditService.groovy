package au.org.ala.biocollect.merit

class AuditService {

    def webService
    def grailsApplication

    def getAuditMessagesForProject(String projectId) {
        String url = grailsApplication.config.ecodata.service.url + '/audit/ajaxGetAuditMessagesForProject?projectId=' + projectId
        return webService.getJson(url)
    }

    def getAuditMessage(String messageId) {
        String url = grailsApplication.config.ecodata.service.url + '/audit/ajaxGetAuditMessage/' + messageId
        return webService.getJson(url)
    }

    def getUserDetails(String userId) {
        String url = grailsApplication.config.ecodata.service.url + '/audit/ajaxGetUserDetails/' + userId
        return webService.getJson(url)
    }

    def getAuditMessagesForProjectPerPage(String projectId, Integer start, Integer size, String sort, String orderBy, String q){
        String url = grailsApplication.config.ecodata.service.url + "/audit/getAuditMessagesForProjectPerPage/${projectId}?start=${start}&size=${size}&sort=${sort}&orderBy=${orderBy}&q=${q}"
        return webService.getJson(url, 80000);
    }

    def getAutoCompareAuditMessage(String id){
        String url = grailsApplication.config.ecodata.service.url + "/audit/getAutoCompareAuditMessage?auditId=${id}";
        return webService.getJson(url);
    }
}
