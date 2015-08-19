package au.org.ala.biocollect.merit

import grails.converters.JSON

/**
 * Controller to display User page (My Profile) as well as some webservices
 */
class UserController {
    def userService, authService, projectService, organisationService

    /**
     * Default view for user controller - show user dashboard page.
     *
     * @return
     */
    def index() {
        def user = userService.getUser()
        if (!user) {
            flash.message = "User Profile Error: user not logged in."
            redirect(controller: 'home', model: [error: flash.message])
        } else {
            log.debug('Viewing my dashboard :  ' + user)
            assembleUserData(user)
        }
    }

    private assembleUserData(user) {
        def recentEdits = userService.getRecentEditsForUserId(user.userId)
        def memberOrganisations = userService.getOrganisationsForUserId(user.userId)
        def memberProjects = userService.getProjectsForUserId(user.userId)
        def starredProjects = userService.getStarredProjectsForUserId(user.userId)

        [user: user, recentEdits: recentEdits, memberProjects: memberProjects, memberOrganisations:memberOrganisations, starredProjects: starredProjects]
    }

    @PreAuthorise(accessLevel = 'admin', redirectController = "home", projectIdParam = "projectId")
    def show(String id) {
        if (id) {
            def user = userService.getUser() // getUserForUserId(id)

            if (user) {
                render view: "index", model: assembleUserData(user)
            } else {
                flash.message = "No user found for id: ${id}"
                redirect(controller: 'home')
            }
        } else {
            flash.message = "No user id specified"
            forward(controller: 'home')
        }
    }

    // webservices

    /**
     * Add userId with role to requested projectId
     *
     * @return
     */
    def addUserAsRoleToProject() {
        String userId = params.userId
        String projectId = params.entityId
        String role = params.role
        def adminUser = authService.userDetails()

        if (adminUser && userId && projectId && role) {
            if (role == 'caseManager' && !userService.userIsSiteAdmin()) {
                render status:403, text: 'Permission denied - ADMIN role required'
            } else if (projectService.isUserAdminForProject(adminUser.userId, projectId)) {
                render userService.addUserAsRoleToProject(userId, projectId, role) as JSON
            } else {
                render status:403, text: 'Permission denied'
            }
        } else {
            render status:400, text: 'Required params not provided: userId, role, projectId'
        }
    }

    def addUserAsRoleToOrganisation() {
        String userId = params.userId
        String organisationId = params.entityId
        String role = params.role
        def adminUser = authService.userDetails()

        if (adminUser && userId && organisationId && role) {
            if (role == 'caseManager' && !userService.userIsSiteAdmin()) {
                render status:403, text: 'Permission denied - ADMIN role required'
            } else if (organisationService.isUserAdminForOrganisation(organisationId)) {
                render userService.addUserAsRoleToOrganisation(userId, organisationId, role) as JSON
            } else {
                render status:403, text: 'Permission denied'
            }
        } else {
            render status:400, text: 'Required params not provided: userId, role, projectId'
        }
    }

    /**
     * Remove userId with role from requested projectId
     *
     * @return
     */
    def removeUserWithRoleFromProject() {
        String userId = params.userId
        String role = params.role
        String projectId = params.entityId
        def adminUser = authService.userDetails()

        if (adminUser && projectId && role && userId) {
            if (projectService.isUserAdminForProject(adminUser.userId, projectId)) {
                render userService.removeUserWithRole(projectId, userId, role) as JSON
            } else {
                render status:403, text: 'Permission denied'
            }
        } else {
            render status:400, text: 'Required params not provided: userId, projectId, role'
        }
    }

    /**
     * Remove userId with role from requested organisationId
     *
     * @return
     */
    def removeUserWithRoleFromOrganisation() {
        String userId = params.userId
        String role = params.role
        String organisationId = params.entityId
        def adminUser = authService.userDetails()

        if (adminUser && organisationId && role && userId) {
            if (organisationService.isUserAdminForOrganisation(organisationId)) {
                render userService.removeUserWithRoleFromOrganisation(organisationId, userId, role) as JSON
            } else {
                render status:403, text: 'Permission denied'
            }
        } else {
            render status:400, text: 'Required params not provided: userId, organisationId, role'
        }
    }

    /**
     * Get a list of projects and roles for a given userId
     *
     * @return
     */
    def viewPermissionsForUserId() {
        String userId = params.userId

        if (authService.userDetails() && (authService.userInRole(grailsApplication.config.security.cas.alaAdminRole) || authService.userInRole(grailsApplication.config.security.cas.officerRole)) && userId) {
            render userService.getProjectsForUserId(userId) as JSON
        } else if (!userId) {
            render status:400, text: 'Required params not provided: userId, role, projectId'
        } else {
            render status:403, text: 'Permission denied'
        }
    }

    /**
     * Check if an email address exists in AUTH and return the userId (number) if true,
     * otherwise return an empty String
     *
     * @return userId
     */
    def checkEmailExists() {
        String email = params.email

        if (email) {
            render userService.checkEmailExists(email)
        } else {
            render status:400, text: 'Required param not provided: email'
        }
    }

}
