package au.org.ala.biocollect.merit

import javax.annotation.PostConstruct

class UserService {
   def grailsApplication, authService, webService
    def auditBaseUrl = ""

    @PostConstruct
    private void init() {
        try {
            auditBaseUrl = grailsApplication.config.ecodata.service.url + '/audit'
        } catch (e) {
            log.debug("This configuration property does not get initialized in test environment", e)
        }
    }

    def getCurrentUserDisplayName() {
        getUser()?.displayName?:"" //?:"mark.woolston@csiro.au"
    }

    def getCurrentUserId() {
        getUser()?.userId?:""
    }

    public UserDetails getUser() {
        def u = authService.userDetails()
        def user

        if (u?.userId) {
            user = new UserDetails(u.userDisplayName, u.email, u.userId)
        }

        return user
    }

    def userInRole(role) {
        authService.userInRole(role)
    }

    def userIsSiteAdmin() {
        authService.userInRole(grailsApplication.config.security.cas.officerRole) || authService.userInRole(grailsApplication.config.security.cas.adminRole) || authService.userInRole(grailsApplication.config.security.cas.alaAdminRole)
    }

    def userIsAlaOrFcAdmin() {
        authService.userInRole(grailsApplication.config.security.cas.adminRole) || authService.userInRole(grailsApplication.config.security.cas.alaAdminRole)
    }

    def userHasReadOnlyAccess() {
        authService.userInRole(grailsApplication.config.security.cas.readOnlyOfficerRole)
    }

    def getRecentEditsForUserId(userId) {
        def url = auditBaseUrl + "/getRecentEditsForUserId/${userId}"
        webService.getJson(url)
    }

    def getProjectsForUserId(userId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/getProjectsForUserId/${userId}"
        webService.getJson(url)
    }

    def getOrganisationIdsForUserId(userId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/getOrganisationIdsForUserId/${userId}"
        webService.getJson(url)
    }

    def getOrganisationsForUserId(userId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/getOrganisationsForUserId/${userId}"
        webService.getJson(url)
    }

    def getStarredProjectsForUserId(userId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/getStarredProjectsForUserId/${userId}"
        webService.getJson(url)
    }

    def isProjectStarredByUser(String userId, String projectId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/isProjectStarredByUser?userId=${userId}&projectId=${projectId}"
        webService.getJson(url)
    }

    def addStarProjectForUser(String userId, String projectId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/addStarProjectForUser?userId=${userId}&projectId=${projectId}"
        webService.getJson(url)
    }

    def removeStarProjectForUser(String userId, String projectId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/removeStarProjectForUser?userId=${userId}&projectId=${projectId}"
        webService.getJson(url)
    }

    def addUserAsRoleToProject(String userId, String projectId, String role) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/addUserAsRoleToProject?userId=${userId}&projectId=${projectId}&role=${role}"
        webService.getJson(url)
    }

    def removeUserWithRole(projectId, userId, role) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/removeUserWithRoleFromProject?projectId=${projectId}&userId=${userId}&role=${role}"
        webService.getJson(url)
    }

    def addUserAsRoleToOrganisation(String userId, String organisationId, String role) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/addUserAsRoleToOrganisation?userId=${userId}&organisationId=${organisationId}&role=${role}"
        webService.getJson(url)
    }

    def removeUserWithRoleFromOrganisation(String userId, String organisationId, String role) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/removeUserWithRoleFromOrganisation?organisationId=${organisationId}&userId=${userId}&role=${role}"
        webService.getJson(url)
    }

    def isUserAdminForProject(userId, projectId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/isUserAdminForProject?projectId=${projectId}&userId=${userId}"
        def results = webService.getJson(url)
        return results?.userIsAdmin
    }

    def isUserCaseManagerForProject(userId, projectId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/isUserCaseManagerForProject?projectId=${projectId}&userId=${userId}"
        def results = webService.getJson(url)
        return results?.userIsCaseManager
    }

    def isUserAdminForOrganisation(userId, organisationId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/isUserAdminForOrganisation?organisationId=${organisationId}&userId=${userId}"
        def results = webService.getJson(url)
        return results?.userIsAdmin
    }

    def isUserGrantManagerForOrganisation(userId, organisationId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/isUserGrantManagerForOrganisation?organisationId=${organisationId}&userId=${userId}"
        def results = webService.getJson(url)
        return results?.userIsGrantManager
    }

    def checkEmailExists(String email) {
        def user = authService.getUserForEmailAddress(email)
        return user?.userId
    }
}
