package au.org.ala.biocollect

import au.org.ala.biocollect.merit.RoleService
import au.org.ala.web.AuthService
import grails.converters.JSON
/**
 * Processes requests relating to organisations in field capture.
 */
class OrganisationController {

    static allowedMethods = [ajaxDelete: "POST", delete: "POST", ajaxUpdate: "POST"]

    def organisationService, searchService, documentService, userService, roleService, commonService, webService
    AuthService authService

    // Simply forwards to the list view
    def list() {}

    def index(String id) {
        def organisation = organisationService.get(id)

        if (!organisation || organisation.error) {
            organisationNotFound(id, organisation)
        } else {
            def roles = roleService.getRoles()
            // Get dashboard information for the response.
            def dashboard = searchService.dashboardReport([fq: 'organisationFacet:' + organisation.name])
            def members = organisationService.getMembersOfOrganisation(id)
            def user = userService.getUser()
            def userId = user?.userId

            def orgRole = members.find { it.userId == userId }

            [organisation  : organisation,
             dashboard     : dashboard,
             roles         : roles,
             user          : user,
             isAdmin       : orgRole?.role == RoleService.PROJECT_ADMIN_ROLE,
             isGrantManager: orgRole?.role == RoleService.GRANT_MANAGER_ROLE,
             content       : content(organisation)]
        }
    }

    protected Map content(organisation) {

        def user = userService.getUser()
        def members = organisationService.getMembersOfOrganisation(organisation.organisationId)
        def orgRole = members.find { it.userId == user?.userId } ?: [:]
        def hasAdminAccess = userService.userIsAlaOrFcAdmin() || orgRole.role == RoleService.PROJECT_ADMIN_ROLE

        def hasViewAccess = hasAdminAccess || userService.userHasReadOnlyAccess() || orgRole.role == RoleService.PROJECT_EDITOR_ROLE
        def includeProjectList = organisation.projects?.size() > 0

        [about   : [label: 'About', visible: true, stopBinding: false, type: 'tab', default: true, includeProjectList: includeProjectList],
         projects: [label: 'Projects', visible: true, stopBinding: true, type: 'tab', template: '/shared/projectFinder', model: [allowGeographicFilter: false]],
         sites   : [label: 'Map', visible: hasViewAccess, stopBinding: true, type: 'tab', projectCount: organisation.projects?.size() ?: 0, showShapefileDownload: hasAdminAccess],
         data    : [label: 'Data', visible: true, stopBinding: true, type: 'tab', template: '/bioActivity/activities', modalId: 'chooseMoreFacets'],
         admin   : [label: 'Admin', visible: hasAdminAccess, type: 'tab']]
    }

    def create() {
        [organisation: [:]]
    }

    def edit(String id) {
        def organisation = organisationService.get(id)

        if (!organisation || organisation.error) {
            organisationNotFound(id, organisation)
        } else {
            [organisation: organisation]
        }
    }

    def delete(String id) {
        if (organisationService.isUserAdminForOrganisation(id)) {
            organisationService.update(id, [status: 'deleted'])
        } else {
            flash.message = 'You do not have permission to perform that action'
        }
        redirect action: 'list'
    }

    def ajaxDelete(String id) {

        if (organisationService.isUserAdminForOrganisation(id)) {
            def result = organisationService.update(id, [status: 'deleted'])

            respond result
        } else {
            render status: 403, text: 'You do not have permission to perform that action'
        }
    }

    def ajaxUpdate() {
        def organisationDetails = request.JSON

        def documents = organisationDetails.remove('documents')
        def links = organisationDetails.remove('links')
        def result = organisationService.update(organisationDetails.organisationId ?: '', organisationDetails)

        def organisationId = organisationDetails.organisationId ?: result.resp?.organisationId
        if (documents && !result.error) {
            documents.each { doc ->
                doc.organisationId = organisationId
                documentService.saveStagedImageDocument(doc)
            }
        }
        if (links && !result.error) {
            links.each { link ->
                link.organisationId = organisationId
                documentService.saveLink(link)
            }
        }

        if (result.error) {
            render result as JSON
        } else {
            render result.resp as JSON
        }
    }

    /**
     * Responds with a download of a zipped shapefile containing all sites used by projects run
     * by an organisation.
     * @param id the organisationId of the organisation.
     */
    def downloadShapefile(String id) {

        def userId = userService.getCurrentUserId()

        if (id && userId) {
            if (organisationService.isUserAdminForOrganisation(id) || organisationService.isUserGrantManagerForOrganisation(id)) {
                def organisation = organisationService.get(id)
                def params = [fq: 'organisationFacet:' + organisation.name, query: "docType:project"]

                def url = grailsApplication.config.ecodata.service.url + '/search/downloadShapefile' + commonService.buildUrlParamsFromMap(params)
                def resp = webService.proxyGetRequest(response, url, true, true, 960000)
                if (resp.status != 200) {
                    render view: '/error', model: [error: resp.error]
                }
            } else {
                render status: 403, text: 'Permission denied'
            }
        } else {
            render status: 400, text: 'Missing parameter organisationId'
        }
    }

    def getMembersForOrganisation(String id) {
        def adminUserId = userService.getCurrentUserId()

        if (id && adminUserId) {
            if (organisationService.isUserAdminForOrganisation(id) || organisationService.isUserGrantManagerForOrganisation(id)) {
                render organisationService.getMembersOfOrganisation(id) as JSON
            } else {
                render status: 403, text: 'Permission denied'
            }
        } else if (adminUserId) {
            render status: 400, text: 'Required params not provided: id'
        } else if (id) {
            render status: 403, text: 'User not logged-in or does not have permission'
        } else {
            render status: 500, text: 'Unexpected error'
        }
    }

    def addUserAsRoleToOrganisation() {
        String userId = params.userId
        String organisationId = params.entityId
        String role = params.role
        def adminUser = userService.getUser()

        if (adminUser && userId && organisationId && role) {
            if (role == 'caseManager' && !userService.userIsSiteAdmin()) {
                render status: 403, text: 'Permission denied - ADMIN role required'
            } else if (organisationService.isUserAdminForOrganisation(organisationId)) {
                render organisationService.addUserAsRoleToOrganisation(userId, organisationId, role) as JSON
            } else {
                render status: 403, text: 'Permission denied'
            }
        } else {
            render status: 400, text: 'Required params not provided: userId, role, projectId'
        }
    }

    def removeUserWithRoleFromOrganisation() {
        String userId = params.userId
        String role = params.role
        String organisationId = params.entityId
        def adminUser = userService.getUser()

        if (adminUser && organisationId && role && userId) {
            if (organisationService.isUserAdminForOrganisation(organisationId)) {
                render organisationService.removeUserWithRoleFromOrganisation(userId, organisationId, role) as JSON
            } else {
                render status: 403, text: 'Permission denied'
            }
        } else {
            render status: 400, text: 'Required params not provided: userId, organisationId, role'
        }
    }

    /**
     * Redirects to the home page with an error message in flash scope.
     * @param response the response that triggered this method call.
     */
    private void organisationNotFound(id, response) {
        flash.message = "No organisation found with id: ${id}"
        if (response?.error) {
            flash.message += "<br/>${response.error}"
        }
        redirect(controller: 'home', model: [error: flash.message])
    }

    def search(Integer offset, Integer max, String searchTerm, String sort) {
        render organisationService.search(offset, max, searchTerm, sort) as JSON
    }

    /**
     * similar to search action above but adds user id to get organisations for current user.
     * @param offset
     * @param max
     * @param searchTerm
     * @param sort
     * @return
     */
    def searchMyOrg(Integer offset, Integer max, String searchTerm, String sort) {
        String userId = authService.getUserId()
        render organisationService.search(offset, max, searchTerm, sort, userId) as JSON
    }

    /**
     * render my organisation page
     */
    def myOrganisations(){

    }
}
