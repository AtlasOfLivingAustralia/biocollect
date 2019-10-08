package au.org.ala.biocollect

import au.org.ala.biocollect.merit.PreAuthorise
import au.org.ala.biocollect.merit.ProjectController
import grails.converters.JSON
import org.springframework.http.HttpStatus




class AclFilterInterceptor {
    def userService, projectService, roleService

    def roles = []

    def dependsOn = [HubConfigurationInterceptor]

    AclFilterInterceptor() {
        matchAll()
    }



    boolean before() {
        if (!controllerName)
            return true
        def controller = grailsApplication.getArtefactByLogicalPropertyName("Controller", controllerName)
        Class controllerClass = controller?.clazz
        if (!controllerClass)
            return true


        def method = controllerClass.getMethod(actionName?:"index", [] as Class[])

        def roles = roleService.getAugmentedRoles()
        def userId = userService.getCurrentUserId(request)
        def projectId = params.projectId

        if(!projectId){
            if(controllerClass == ProjectController){
                projectId = params.id
            }
        }

        if(userService.userInRole(grailsApplication.config.security.cas.alaAdminRole)){
            params.userIsAlaAdmin = true
        } else {
            params.userIsAlaAdmin = false
        }

        if (controllerClass.isAnnotationPresent(PreAuthorise) || method.isAnnotationPresent(PreAuthorise)) {
            PreAuthorise pa = method.getAnnotation(PreAuthorise)?:controllerClass.getAnnotation(PreAuthorise)
            if ((controllerClass != ProjectController) && (!pa.projectIdParam()?.equals('id'))) {
                projectId = params[pa.projectIdParam()]
            }

            def accessLevel = pa.accessLevel()

            def errorMsg

            if (!roles.contains(accessLevel)) {
                //throw new IllegalArgumentException("Unknown accessLevel requested: ${accessLevel}. Must be one of ${roles.join(', ')}")
                errorMsg = "Unknown accessLevel requested: <code>${accessLevel}</code> from <code>${method}</code>. Must be one of ${roles.join(', ')}"
                log.error errorMsg
            }

            switch (accessLevel) {
                case 'alaAdmin':
                    if (!userService.userInRole(grailsApplication.config.security.cas.alaAdminRole)) {
                        errorMsg = "Access denied: User does not have <b>alaAdmin</b> permission"
                    }
                    break
                case 'siteAdmin':
                    if (!(userService.userInRole(grailsApplication.config.security.cas.alaAdminRole) || userService.userInRole(grailsApplication.config.security.cas.adminRole))) {
                        errorMsg = "Access denied: User does not have <b>admin</b> permission"
                    }
                    break
                case 'siteReadOnly':
                    if (!(userService.userInRole(grailsApplication.config.security.cas.alaAdminRole) || userService.userInRole(grailsApplication.config.security.cas.adminRole) || userService.userInRole(grailsApplication.config.security.cas.readOnlyOfficerRole))) {
                        errorMsg = "Access denied: User does not have <b>admin</b> permission"
                    }
                    break
                case 'officer':
                    if (!(userService.userInRole(grailsApplication.config.security.cas.alaAdminRole) || userService.userInRole(grailsApplication.config.security.cas.adminRole) || userService.userInRole(grailsApplication.config.security.cas.officerRole))) {
                        errorMsg = "Access denied: User does not have <b>admin</b> permission"
                    }
                    break
                case 'caseManager':
                    if (!projectService.isUserCaseManagerForProject(userId, projectId)) {
                        errorMsg = "Access denied: User does not have <b>grant manager</b> permission ${projectId?'for project':''}"
                    }
                    break
                case 'admin':
                    if (!projectService.isUserAdminForProject(userId, projectId)) {
                        errorMsg = "Access denied: User does not have <b>admin</b> permission ${projectId?'for project':''}"
                    }
                    break
                case 'moderator':
                    if (!projectService.canUserModerateProjects(userId, projectId)) {
                        errorMsg = "Access denied: User does not have <b>moderator</b> permission ${projectId?'for project(s)':''}"
                    }
                    break
                case 'editor':
                    if (!projectService.canUserEditProject(userId, projectId)) {
                        errorMsg = "Access denied: User does not have <b>editor</b> permission ${projectId?'for project':''}"
                    }
                    break
                case 'loggedInUser':
                    if(!userId){
                        errorMsg = "Access denied: You are not logged in."
                    }
                    break;
                case 'editSite':
                    if (!userId) {
                        errorMsg = "Access denied: You are not logged in."
                    } else {
                        def site = request.JSON?.site
                        if (site) {
                            boolean privateSite = site['visibility'] ? (site['visibility'] == 'private' ? true : false) : false
                            if (!privateSite) {
                                if (site && site.projects) {
                                    // Converting to list since JSONArray.join is adding Quotes in joined string
                                    // example - '"abc","cdf"'
                                    String projectIds = site.projects.toList().join(',')
                                    if (!projectService.isUserEditorForProjects(userId, projectIds)) {
                                        errorMsg = "Access denied: User is not an editor for all the projects this site is associated with."
                                    }
                                } else {
                                    errorMsg = "Access denied: Site must be associated with at least one project"
                                }
                            }
                        }
                    }
                    break;
                default:
                    log.warn "Unexpected role: ${accessLevel}"
            }

            if (errorMsg) {
                flash.message = errorMsg
                if (params.returnTo) {
                    redirect(url: params.returnTo)
                } else if (projectId){
                    redirect(controller: pa.redirectController(), action: pa.redirectAction(), id: projectId)
                } else {
                    render text: [error: errorMsg] as JSON, status: HttpStatus.UNAUTHORIZED
                }
                return false
            }
        }

        // get the permissions of the user with respect to a project.
        if(userId && projectId){
            if (projectService.isUserCaseManagerForProject(userId, projectId)) {
                params.userIsProjectCaseManager = true
            } else {
                params.userIsProjectCaseManager = false
            }

            if (projectService.isUserAdminForProject(userId, projectId)) {
                params.userIsProjectAdmin = true
            } else {
                params.userIsProjectAdmin = false
            }

            if(projectService.canUserEditProject(userId, projectId)){
                params.userCanEditProject = true
            } else {
                params.userCanEditProject = false
            }

            if (projectService.isUserEditorForProject(userId, projectId)) {
                params.userIsProjectEditor = true
            } else {
                params.userIsProjectEditor = false
            }

            if (projectService.isUserParticipantForProject(userId, projectId)) {
                params.userIsProjectParticipant = true
            } else {
                params.userIsProjectParticipant = false
            }
        } else {
            params.userIsProjectAdmin = false
            params.userIsProjectCaseManager = false
            params.userIsProjectEditor = false
            params.userIsProjectParticipant = false
            params.userCanEditProject = false
        }
        true
    }

    boolean after() {
        true
    }

    void afterView() {
        // no-op
    }
}
