package au.org.ala.biocollect.merit

class OrganisationService {

    def grailsApplication, webService, metadataService, projectService, userService


    def get(String id, view = '') {

        def url = "${grailsApplication.config.ecodata.service.url}organisation/$id?view=$view"
        webService.getJson(url)
    }

    def getByName(orgName) {
        // The result of the service call will be a JSONArray if it's successful
        return list().list.find({ it.name == orgName })
    }

    def getNameFromId(orgId) {
        // The result of the service call will be a JSONArray if it's successful
        return orgId ? list().list.find({ it.organisationId == orgId })?.name : ''
    }

    def list() {
        metadataService.organisationList()
    }

    def update(id, organisation) {

        def url = "${grailsApplication.config.ecodata.service.url}organisation/$id"
        def result = webService.doPost(url, organisation)
        metadataService.clearOrganisationList()
        result

    }

    def isUserAdminForOrganisation(organisationId) {
        def userIsAdmin

        if (!userService.user) {
            return false
        }
        if (userService.userIsSiteAdmin()) {
            userIsAdmin = true
        } else {
            userIsAdmin = userService.isUserAdminForOrganisation(userService.user.userId, organisationId)
        }

        userIsAdmin
    }

    def isUserGrantManagerForOrganisation(organisationId) {
        def userIsAdmin

        if (!userService.user) {
            return false
        }
        if (userService.userIsSiteAdmin()) {
            userIsAdmin = true
        } else {
            userIsAdmin = userService.isUserGrantManagerForOrganisation(userService.user.userId, organisationId)
        }

        userIsAdmin
    }

    /**
     * Get the list of users (members) who have any level of permission for the requested organisationId
     *
     * @param organisationId the organisationId of interest.
     */
    def getMembersOfOrganisation(organisationId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/getMembersForOrganisation/${organisationId}"
        webService.getJson(url)
    }

    /**
     * Adds a user with the supplied role to the identified organisation.
     * Adds the same user with the same role to all of the organisation's projects.
     *
     * @param userId the id of the user to add permissions for.
     * @param organisationId the organisation to add permissions for.
     * @param role the role to assign to the user.
     */
    def addUserAsRoleToOrganisation(String userId, String organisationId, String role) {

        def organisation = get(organisationId, 'flat')
        def resp = userService.addUserAsRoleToOrganisation(userId, organisationId, role)
        organisation.projects.each {
            userService.addUserAsRoleToProject(userId, it.projectId, role)
        }
        resp
    }

    /**
     * Removes the user access with the supplied role from the identified organisation.
     * Removes the same user from all of the organisation's projects.
     *
     * @param userId the id of the user to remove permissions for.
     * @param organisationId the organisation to remove permissions for.

     */
    def removeUserWithRoleFromOrganisation(String userId, String organisationId, String role) {
        def organisation = get(organisationId, 'flat')
        userService.removeUserWithRoleFromOrganisation(userId, organisationId, role)
        organisation.projects.each {
            userService.removeUserWithRole(it.projectId, userId, role)
        }
    }

}
