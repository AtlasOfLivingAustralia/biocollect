package au.org.ala.biocollect.merit


/**
 * Grails Filter to check for controller methods annotated with <code>@{@link PreAuthorise}</code>
 *
 * @see au.org.ala.biocollect.merit.PreAuthorise
 */
class AclFilterFilters {
    def grailsApplication, userService, projectService, roleService

    def roles = []

    def dependsOn = [HubConfigurationFilters]

    def filters = {
        all(controller:'*', action:'*') {
            before = {
                def controller = grailsApplication.getArtefactByLogicalPropertyName("Controller", controllerName)
                Class controllerClass = controller?.clazz
                def method = controllerClass.getMethod(actionName?:"index", [] as Class[])
                def roles = roleService.getAugmentedRoles()
                def userId = userService.getCurrentUserId()
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
                    projectId = params[pa.projectIdParam()]
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
                        case 'editor':
                            if (!projectService.canUserEditProject(userId, projectId)) {
                                errorMsg = "Access denied: User does not have <b>editor</b> permission ${projectId?'for project':''}"
                            }
                            break
                        case 'loggedInUser':
                            if(!userId){
                                errorMsg = "Access denied: You are not logged in."
                            }
                        default:
                            log.warn "Unexpected role: ${accessLevel}"
                    }

                    if (errorMsg) {
                        flash.message = errorMsg
                        if (params.returnTo) {
                            redirect(url: params.returnTo)
                        } else {
                            redirect(controller: pa.redirectController(), action: pa.redirectAction(), id: projectId)
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

                return true
            }

            after = { Map model ->

            }

            afterView = { Exception e ->

            }
        }
    }
}
