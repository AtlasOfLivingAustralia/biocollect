package au.org.ala.biocollect

import au.org.ala.biocollect.merit.*
import au.org.ala.biocollect.merit.hub.HubSettings
import au.org.ala.biocollect.swagger.model.*
import au.org.ala.ecodata.forms.ActivityFormService
import au.org.ala.ecodata.forms.UserInfoService
import au.org.ala.plugins.openapi.Path
import au.org.ala.web.AuthService
import au.org.ala.web.SSO
import au.org.ala.web.UserDetails
import grails.converters.JSON
import grails.web.mapping.LinkGenerator
import grails.web.servlet.mvc.GrailsParameterMap
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.Parameter
import io.swagger.v3.oas.annotations.enums.ParameterIn
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType
import io.swagger.v3.oas.annotations.headers.Header
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.parameters.RequestBody
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import io.swagger.v3.oas.annotations.security.SecurityScheme
import org.apache.commons.io.FilenameUtils
import org.apache.http.HttpStatus
import org.apache.http.entity.ContentType
import org.grails.web.converters.exceptions.ConverterException
import org.grails.web.json.JSONArray
import org.grails.web.json.JSONObject
import org.springframework.context.MessageSource
import org.springframework.web.multipart.MultipartFile

import javax.ws.rs.Produces

import static org.apache.http.HttpStatus.SC_BAD_REQUEST
import static org.apache.http.HttpStatus.SC_OK
import static org.apache.http.HttpStatus.SC_INTERNAL_SERVER_ERROR

@SecurityScheme(name = "auth",
        type = SecuritySchemeType.HTTP,
        scheme = "bearer"
)
class BioActivityController {
    ProjectService projectService
    MetadataService metadataService
    SiteService siteService
    ProjectActivityService projectActivityService
    UserService userService
    DocumentService documentService
    ActivityService activityService
    CommonService commonService
    SearchService searchService
    MessageSource messageSource
    RecordService recordService
    SpeciesService speciesService
    LinkGenerator grailsLinkGenerator
    SettingService settingService
    AuthService authService
    UtilService utilService
    ActivityFormService activityFormService
    UserInfoService userInfoService

    static int MAX_FLIMIT = 500
    static allowedMethods = ['bulkDelete': 'POST', bulkRelease: 'POST', bulkEmbargo: 'POST']

    /**
     * Update Activity by activityId or
     * Create Activity by projectActivity
     * @param id activity id
     * @param pActivityId project activity Id
     * @return
     */
    @Operation(
            method = "POST",
            tags = "biocollect",
            operationId = "bioactivityajaxupdate",
            summary = "Create or edit an activity",
            requestBody = @RequestBody(
                    description = "JSON body",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(
                                        implementation = ActivityAjaxUpdate.class
                                )
                    )
            ),
            parameters = [
                    @Parameter(
                            name = "id",
                            in = ParameterIn.QUERY,
                            description = "Activity id. Leave blank if creating new activity."
                    ),
                    @Parameter(
                            name = "pActivityId",
                            in = ParameterIn.QUERY,
                            description = "Project activity id (survey id)"
                    )
            ],
            responses = [
                    @ApiResponse(
                            responseCode = "200",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(
                                            implementation = ActivitySaveResponse.class
                                    )
                            ),
                            headers = [
                                    @Header(name = 'Access-Control-Allow-Headers', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Methods', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Origin', description = "CORS header", schema = @Schema(type = "String"))
                            ]
                    ),
                    @ApiResponse(
                            responseCode = "401",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(
                                            implementation = ErrorResponse.class
                                    )
                            ),
                            headers = [
                                    @Header(name = 'Access-Control-Allow-Headers', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Methods', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Origin', description = "CORS header", schema = @Schema(type = "String"))
                            ]
                    )
            ],
            security = @SecurityRequirement(name="auth")
    )
    @Path("ws/bioactivity/save")
    def ajaxUpdate(String id, String pActivityId) {
        def postBody = request.JSON
        def activity = null
        def pActivity = null
        String projectId = null

        id = id ?: ''

        if (id) {
            activity = activityService.get(id)
            projectId = activity?.projectId
            pActivity = projectActivityService.get(activity?.projectActivityId)
        } else if (pActivityId) {
            pActivity = projectActivityService.get(pActivityId)
            projectId = pActivity?.projectId
        }

        Map result

        log.debug("pActivityId = ${pActivityId}")
        log.debug("id = ${id}")
        log.debug("projectId = ${projectId}")
        log.debug((postBody as JSON).toString())

        String userId = userService.getCurrentUserId()
        if (!userId) {
            flash.message = "Access denied: User has not been authenticated."
            response.status = 401
            result = [status: 401, error: flash.message]
        } else if (!activity && !pActivity.publicAccess && !projectService.canUserEditProject(userId, projectId, false)) {
            flash.message = "Access denied: User does not have <b>editor</b> permission for projectId ${projectId}"
            response.status = 401
            result = [status: 401, error: flash.message]
        } else if (!activity && isProjectActivityClosed(pActivity)) {
            flash.message = "Access denied: This survey is closed."
            response.status = 401
            result = [status: 401, error: flash.message]
        } else if (activity && !pActivity.publicAccess && !projectService.canUserEditActivity(userId, activity)) {
            flash.message = "Access denied: User is not an owner of this activity ${activity?.activityId}"
            response.status = 401
            result = [status: 401, error: flash.message]
        } else {
            boolean projectEditor = projectService.canUserEditProject(userId, projectId, false)
            Map userAlreadyInRole = userService.isUserInRoleForProject(userId, projectId, "projectParticipant")

            if (!userAlreadyInRole.statusCode || userAlreadyInRole.statusCode == SC_OK) {
                if (!projectEditor && pActivity.publicAccess && !userAlreadyInRole.inRole.toBoolean()) {
                    userService.addUserAsRoleToProject(userId, projectId, "projectParticipant")
                }

                def photoPoints = postBody.remove('photoPoints')
                postBody.projectActivityId = pActivity.projectActivityId
                postBody.userId = userId
                pActivity?.visibility?.alaAdminEnforcedEmbargo ? postBody.embargoed = true : null

                result = activityService.update(id, postBody)

                String activityId = id ?: result?.resp?.activityId
                if (photoPoints && activityId) {
                    updatePhotoPoints(activityId, photoPoints)
                }

                postBody.outputs?.each {
                    it.data?.multimedia?.each {
                        String filename
                        if (it.filename) {
                            filename = it.filename
                        } else if (it.identifier) {
                            filename = it.identifier.substring(it.identifier.lastIndexOf("/") + 1)
                        }

                        if (filename) {
                            Map document = [
                                    activityId       : activityId,
                                    projectId        : projectId,
                                    projectActivityId: pActivityId,
                                    contentType      : it.format,
                                    filename         : filename,
                                    name             : it.title,
                                    type             : "image",
                                    role             : "image",
                                    license          : it.license
                            ]
                            documentService.saveStagedImageDocument(document)
                        }
                    }

                }

            } else {
                flash.message = userAlreadyInRole.error
                response.status = userAlreadyInRole.statusCode
                result = userAlreadyInRole
            }
        }
        result.error = flash.message
        render result as JSON
    }

    def getProjectActivityCount(String id) {
        def result = activityService.getProjectActivityCount(id)
        render result as JSON
    }

    /**
     * Create activity for the given project activity
     * Users with project edit permission can create new activity for the projectActivity
     * @param id project activity
     * @return
     */
    @SSO
    def create(String id) {
        Map model = addActivity(id)
        model?.title = messageSource.getMessage('record.create.title', [].toArray(), '', Locale.default)

        model
    }

    def pwaCreateOrEdit(String projectActivityId) {
        Map model = [projectActivityId: projectActivityId, activityId: ""]
        if(projectActivityId) {
            Map pActivity = projectActivityService.get(projectActivityId, "all", params?.version)

            if(!pActivity.error) {
                model.title = messageSource.getMessage('pwa.record.create.title', [].toArray(), '', Locale.default)
                String projectId = model.projectId = pActivity.projectId
                Map project = projectService.get(projectId, "brief", params?.version)
                if (!project.error) {
                    model.project = project
                    model.pActivity = pActivity
                    model.type = pActivity.pActivityFormName
                    // disable showing verification status on pwa
                    model.isUserAdminModeratorOrEditor = false
                    render view: "pwaBioActivityCreateOrEdit", model: model
                    return
                } else {
                    flash.message = "Project associated with project activity not found"
                    render status: HttpStatus.SC_NOT_FOUND
                    return
                }
            } else {
                flash.message = "Project Activity not found"
                render status: HttpStatus.SC_NOT_FOUND
                return
            }
        } else {
            flash.message = "Project Activity Id must be provided"
            render status: HttpStatus.SC_BAD_REQUEST
        }
    }

    @PreAuthorise(accessLevel = "loggedInUser")
    def pwaCreateOrEditFragment(String projectActivityId) {
        Map model = [projectActivityId: projectActivityId, activityId: ""]
        if(projectActivityId) {
            Map pActivity = projectActivityService.get(projectActivityId, "all", params?.version)

            if(!pActivity.error) {
                model.title = messageSource.getMessage('pwa.record.create.title', [].toArray(), '', Locale.default)
                String projectId = model.projectId = pActivity.projectId
                Map project = projectService.get(projectId, "brief", params?.version)
                if (!project.error) {
                    model.project = project
                    model.pActivity = pActivity
                    model.type = pActivity.pActivityFormName
                    // disable showing verification status on pwa
                    model.isUserAdminModeratorOrEditor = false
                    addOutputModel(model, model.type)
                    render view: "pwaBioActivityCreateOrEditFragment", model: model
                    return
                } else {
                    flash.message = "Project associated with project activity not found"
                    render status: HttpStatus.SC_NOT_FOUND
                    return
                }
            } else {
                flash.message = "Project Activity not found"
                render status: HttpStatus.SC_NOT_FOUND
                return
            }
        } else {
            flash.message = "Project Activity Id must be provided"
            render status: HttpStatus.SC_BAD_REQUEST
        }
    }

    def getProjectActivityMetadata (String projectActivityId, String activityId) {
        Map activity
        String userId = userService.getCurrentUserId()
        Map pActivity = projectActivityService.get(projectActivityId, "all")
        if (pActivity.error) {
            render text: [message: "An error occurred when accessing project activity"] as JSON, status: HttpStatus.SC_INTERNAL_SERVER_ERROR, contentType: ContentType.APPLICATION_JSON
            return
        }

        String projectId = pActivity?.projectId
        String type = pActivity.pActivityFormName
        Map project = projectService.get(projectId)
        if(project.error) {
            render text: [message: "An error occurred when accessing project"] as JSON, status: HttpStatus.SC_INTERNAL_SERVER_ERROR, contentType: ContentType.APPLICATION_JSON
            return
        }

        if (activityId) {
            activity = activityService.get(activityId, params?.version, userId, true)
            if(activity.error) {
                render text: [message: "An error occurred when accessing activity"] as JSON, status: HttpStatus.SC_INTERNAL_SERVER_ERROR, contentType: ContentType.APPLICATION_JSON
                return
            }
        } else {
            activity = [activityId: '', siteId: '', projectId: projectId, type: type]
        }

        Map userPermission = checkUserPermission(project, pActivity, activityId ? activity : null)
        if (!userPermission.authorized) {
            render text: [message: userPermission.message] as JSON, status: HttpStatus.SC_UNAUTHORIZED, contentType: ContentType.APPLICATION_JSON
            return
        }

        Map model = activityAndOutputModel(activity, projectId, 'view', params?.version, pActivity?.pActivityFormName)
        model.pActivity = pActivity
        model.project = project
        model.speciesConfig = [surveyConfig: [speciesFields: pActivity?.speciesFields]]
        model.projectName = project.name
        model.isUserAdminModeratorOrEditor = false

        render text:  model as JSON, status: HttpStatus.SC_OK, contentType: ContentType.APPLICATION_JSON
    }

    @PreAuthorise(accessLevel = "loggedInUser")
    def pwaIndexFragment(String projectActivityId) {
        String projectId
        def model = [:]
        def pActivity = projectActivityService.get(projectActivityId, "all", params?.version)
        if(pActivity.error) {
            render text: [message: "An error occurred when accessing project activity"] as JSON, contentType: ContentType.APPLICATION_JSON, status: HttpStatus.SC_INTERNAL_SERVER_ERROR
            return
        }

        model.pActivity = pActivity
        model.projectActivityId = projectActivityId
        projectId = model.projectId = pActivity?.projectId
        String type = pActivity.pActivityFormName
        Map project = projectService.get(projectId)
        if (project.error) {
            render text: [message: "An error occurred when accessing project"] as JSON, status: HttpStatus.SC_INTERNAL_SERVER_ERROR, contentType: ContentType.APPLICATION_JSON
            return
        }

        addOutputModel(model, type)
        model.project = project
        model.id = projectActivityId
        render view: 'pwaBioActivityIndexFragment', model: model
    }

    def pwaIndex(String projectActivityId) {
        String projectId
        def model = [:]
        def pActivity = projectActivityService.get(projectActivityId, "all", params?.version)
        if(pActivity.error) {
            render text: [message: "An error occurred when accessing project activity"] as JSON, contentType: ContentType.APPLICATION_JSON, status: HttpStatus.SC_INTERNAL_SERVER_ERROR
            return
        }

        model.pActivity = pActivity
        model.projectActivityId = projectActivityId
        projectId = model.projectId = pActivity?.projectId
        String type = pActivity.pActivityFormName
        Map project = projectService.get(projectId)
        if (project.error) {
            render text: [message: "An error occurred when accessing project"] as JSON, status: HttpStatus.SC_INTERNAL_SERVER_ERROR, contentType: ContentType.APPLICATION_JSON
            return
        }

        model.project = project
        model.id = projectActivityId
        render view: 'pwaBioActivityIndex', model: model
    }

    def pwaOfflineList() {
    }

    def pwa () {
    }

    def pwaConfig () {
    }

    def pwaSettings () {
    }

    /**
     * Preview activity survey form template
     * @param formName Survey form name
     * @param projectId project id
     * @return populated model
     */
    def previewActivity() {

        String type = params.formName
        String projectId = params.projectId

        Map pActivity = [:]
        pActivity.sites = []

        Map model = [:]
        model.user = userService.getUser()
        Map activity = [activityId: '', siteId: '', projectId: projectId, type: type]
        Map project = projectService.get(projectId)
        model = activityModel(activity, projectId)
        model.pActivity = pActivity
        model.projectName = project.name

        addOutputModel(model)
        model.preview = true;

        model

    }

    /**
     * Edit activity for the given activityId
     * Project Site Admin / activity owner can edit the activity
     * @param id activity id
     * @return
     */
    @SSO
    def edit(String id) {
        Map model = editActivity(id)
        model?.title = messageSource.getMessage('record.edit.title', [].toArray(), '', Locale.default)
        //May relates to the known grails.converter.JSON issue
        //Remove this seem-useless statement may causes issue
        model.toString()
        model
    }

    def mobileCreate(String id) {
        if(grailsApplication.config.app.mobile.hub) {
            settingService.loadHubConfig(grailsApplication.config.app.mobile.hub)
            params.hub = grailsApplication.config.app.mobile.hub
        }

        addXFrameOptionsHeader()
        Map model = addActivity(id, true)
        model.mobile = true
        validateAndAddMobileUserCredentials(model)
        model.bulkUpload = params.getBoolean('bulkUpload', false)
        render (view: model.error ? 'error' : 'edit', model: model)
    }

    def mobileEdit(String id) {
        if(grailsApplication.config.app.mobile.hub) {
            settingService.loadHubConfig(grailsApplication.config.app.mobile.hub)
            params.hub = grailsApplication.config.app.mobile.hub
        }

        addXFrameOptionsHeader()
        Map model = editActivity(id, true)
        model.mobile = true
        validateAndAddMobileUserCredentials(model)
        render (view: model.error ? 'error' : 'edit', model: model)
    }


    private Map validateAndAddMobileUserCredentials(Map model) {
        def user
        String userName = request.getHeader(UserService.USER_NAME_HEADER_FIELD)
        String authKey = request.getHeader(UserService.AUTH_KEY_HEADER_FIELD)
        String authorization = request.getHeader(UserInfoService.AUTHORIZATION_HEADER_FIELD)
        if (authKey && userName) {
            user = userInfoService.getUserFromAuthKey(userName, authKey)
            if (user) {
                model[UserService.USER_NAME_HEADER_FIELD] = userName
                model[UserService.AUTH_KEY_HEADER_FIELD] = authKey
            }
        }

        if (authorization) {
            user = userInfoService.getUserFromJWT(authorization)
            if (user) {
                model[UserInfoService.AUTHORIZATION_HEADER_FIELD] = authorization
            }
        }

        model
    }


    private def addActivity(String id, boolean mobile = false) {
        String userId = userService.getCurrentUserId()
        Map pActivity = projectActivityService.get(id, "all")
        String projectId = pActivity?.projectId
        String type = pActivity?.pActivityFormName
        Map model = [:]

        if (!pActivity.publicAccess && !projectService.canUserEditProject(userId, projectId, false)) {
            flash.message = "Only members associated to this project can submit record. For more information, please contact ${grailsApplication.config.biocollect.support.email.address}"
            if (!mobile) redirect(controller: 'project', action: 'index', id: projectId)
        } else if (!type) {
            flash.message = "Invalid activity type"
            if (!mobile) redirect(controller: 'project', action: 'index', id: projectId)
        } else if (isProjectActivityClosed(pActivity)) {
            flash.message = "Access denied: This survey is closed."
            if (!mobile) redirect(controller: 'project', action: 'index', id: projectId)
        } else {
            Map activity = [activityId: '', siteId: '', projectId: projectId, type: type]
            Map project = projectService.get(projectId)
            model = activityModel(activity, projectId)
            model.pActivity = pActivity
            model.speciesConfig = [surveyConfig: [speciesFields: pActivity?.speciesFields]]
            model.projectName = project.name
            model.returnTo = params.returnTo ? params.returnTo : g.createLink(controller: 'project', id: projectId)
            model.autocompleteUrl = "${request.contextPath}/search/searchSpecies?projectActivityId=${pActivity.projectActivityId}&limit=10"
            model.isUserAdminModeratorOrEditor = projectService.isUserAdminForProject(userId, projectId) || projectService.isUserModeratorForProject(userId, projectId) || projectService.isUserEditorForProject(userId, projectId)
            addOutputModel(model)
            addDefaultSpecies(activity)
        }

        if (mobile && flash.message) {
            model?.error = flash.message
        }

        model
    }

    /**
     * Check if user can create an activity or edit an activity
     */
    private Map checkUserCreatePermission (Map project, Map pActivity) {
        Map result = [ message: "Access denied: You are not allowed to create activity", authorized: false ]
        String userId = userService.getCurrentUserId()
        String projectId = project?.projectId

        if (!userId) {
            result.message = "Access denied: You are not logged in."
        }
        else if (isProjectActivityClosed(pActivity)) {
            result.message = "Access denied: This survey is closed."
        }
        else if (!pActivity.publicAccess && !projectService.canUserEditProject(userId, projectId, false)) {
            result.message = "Access denied: Only members associated to this project can submit record. For more information, please contact ${grailsApplication.config.biocollect.support.email.address}"
        }
        else if (projectService.canUserEditProject(userId, projectId, false) ||
                (pActivity.publicAccess && userId)) {
            result.message = "User is authorized to create or edit activity"
            result.authorized = true
        }

        return result
    }

    private Map checkUserEditPermission (Map project, Map activity) {
        Map result = [ message: "Access denied: You are not allowed to edit activity", authorized: false ]
        String userId = userService.getCurrentUserId()
        String projectId = project?.projectId

        if (!userId) {
            result.message =  "Only members associated to this project can submit record. For more information, please contact ${grailsApplication.config.biocollect.support.email.address}"
        } else if (!activity || activity.error) {
            result.message =  "Invalid activity - ${id}"
        } else if (projectService.canUserModerateProjects(userId, projectId) || activityService.isUserOwnerForActivity(userId, activity?.activityId)) {
            result.message = "User is authorized to edit activity"
            result.authorized = true
        }

        return result
    }

    private Map checkUserViewPermission (Map project, Map pActivity, Map activity) {
        Map result = [ message: "Access denied: You are not allowed to edit activity", authorized: false ]
        String userId = userService.getCurrentUserId()
        String projectId = project?.projectId
        Boolean embargoed = (activity.embargoed == true) || projectActivityService.isEmbargoed(pActivity)

        if (!userId) {
            result.message =  "Only members associated to this project can submit record. For more information, please contact ${grailsApplication.config.biocollect.support.email.address}"
        } else if (!activity || activity.error) {
            result.message =  "Invalid activity - ${id}"
        } else if (embargoed) {
            result.message = "Access denied: This activity is embargoed."
        } else if (projectService.isUserEditorForProjects(userId, projectId) || activityService.isUserOwnerForActivity(userId, activity?.activityId)) {
            result.message = "User is authorized to edit activity"
            result.authorized = true
        }

        return result
    }

    private Map checkUserPermission (Map project, Map pActivity, Map activity) {
        if (activity) {
            return checkUserViewPermission(project, pActivity, activity)
        } else {
            return checkUserCreatePermission(project, pActivity)
        }
    }

    private editActivity(String id, boolean mobile = false){
        String userId = userService.getCurrentUserId()
        def activity = activityService.get(id)
        String projectId = activity?.projectId
        def model = [:]

        if (!userId) {
            flash.message = "Only members associated to this project can submit record. For more information, please contact ${grailsApplication.config.biocollect.support.email.address}"
            if(!mobile) redirect(controller: 'project', action: 'index', id: projectId)
        } else if (!activity || activity.error) {
            flash.message = "Invalid activity - ${id}"
            if(!mobile)  redirect(controller: 'project', action: 'index', id: projectId)
        } else if (projectService.canUserModerateProjects(userId, projectId) || activityService.isUserOwnerForActivity(userId, activity?.activityId)) {
            def pActivity = projectActivityService.get(activity?.projectActivityId, "all")
            model = activityAndOutputModel(activity, activity.projectId)
            model.pActivity = pActivity
            model.projectActivityId = pActivity.projectActivityId
            model.id = id
            model.speciesConfig = [surveyConfig: [speciesFields: pActivity?.speciesFields]]
            model.isUserAdminModeratorOrEditor = projectService.isUserAdminForProject(userId, projectId) || projectService.isUserModeratorForProject(userId, projectId) || projectService.isUserEditorForProject(userId, projectId)
            model.returnTo = params.returnTo ? params.returnTo : g.createLink(controller: 'bioActivity', action: 'index') + "/" + id
        } else {
            flash.message = "Access denied: User is not an owner of this activity ${activity?.activityId}"
            if(!mobile)  redirect(controller: 'project', action: 'index', id: projectId)
        }

        if(mobile && flash.message) {
            model?.error = flash.message
        }

        model
    }


    /**
     * Delete activity for the given activityId
     * @param id activity identifier
     * @return
     */
    @Operation(
            method = "GET",
            tags = "biocollect",
            operationId = "bioactivitydelete",
            summary = "Delete an activity",
            parameters = [
                    @Parameter(
                            name = "id",
                            in = ParameterIn.PATH,
                            description = "Activity id"
                    )
            ],
            responses = [
                    @ApiResponse(
                            responseCode = "200",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(
                                            implementation = DeleteActivityResponse.class
                                    )
                            ),
                            headers = [
                                    @Header(name = 'Access-Control-Allow-Headers', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Methods', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Origin', description = "CORS header", schema = @Schema(type = "String"))
                            ]
                    ),
                    @ApiResponse(
                            responseCode = "401",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(
                                            implementation = DeleteActivityResponse.class
                                    )
                            ),
                            headers = [
                                    @Header(name = 'Access-Control-Allow-Headers', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Methods', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Origin', description = "CORS header", schema = @Schema(type = "String"))
                            ]
                    )
            ],
            security = @SecurityRequirement(name="auth")
    )
    @Path("/ws/bioactivity/delete/{id}")
    def delete(String id) {
        def activity = activityService.get(id)
        String userId = userService.getCurrentUserId()

        Map result

        if (!userId) {
            response.status = 401
            result = [status: 401, error: "Access denied: User has not been authenticated."]
        } else if (projectService.canUserModerateProjects(userId, activity?.projectId) || activityService.isUserOwnerForActivity(userId, activity?.activityId)) {
            def resp = activityService.delete(id)
            if (resp == SC_OK) {
                result = [status: resp, text: 'deleted']
            } else {
                response.status = resp
                result = [status: resp, error: "Error deleting the survey, please try again later."]
            }
        } else {
            response.status = 401
            result = [status: 401, error: "Access denied: User is not an admin, moderator or owner of this activity - ${id}"]
        }

        render result as JSON
    }

    @PreAuthorise(accessLevel = 'moderator', projectIdParam = 'projectIds')
    def bulkDelete() {
        List ids = params.ids?.split(',')
        if ( ids ) {
            Map result = activityService.bulkDelete(ids)
            Map resp = result?.resp
            render text: (resp as JSON), status: result.statusCode
        } else {
            render (text: "Missing parameter 'ids'", status: HttpStatus.SC_BAD_REQUEST)
        }
    }

    @PreAuthorise(accessLevel = 'moderator', projectIdParam = 'projectIds')
    def bulkEmbargo() {
        List ids = params.ids?.split(',')
        if ( ids ) {
            Map result = activityService.bulkEmbargo(ids)
            Map resp = result?.resp
            render text: (resp as JSON), status: result.statusCode
        } else {
            render (text: "Missing parameter 'ids'", status: HttpStatus.SC_BAD_REQUEST)
        }
    }

    @PreAuthorise(accessLevel = 'moderator', projectIdParam = 'projectIds')
    def bulkRelease() {
        List ids = params.ids?.split(',')
        if ( ids ) {
            Map result = activityService.bulkRelease(ids)
            Map resp = result?.resp
            render text: (resp as JSON), status: result.statusCode
        } else {
            render (text: "Missing parameter 'ids'", status: HttpStatus.SC_BAD_REQUEST)
        }
    }

    /**
     * View Activity Survey Details.
     * @param id activity id
     * @return
     */
    def index(String id) {
        String userId = userService.getCurrentUserId()
        def activity = activityService.get(id, params?.version, userId, true)
        if (activity.error){
            redirect(controller: "error", action:'response404', params: [status: 404, errMsg: activity.error])
            return
        }
        def pActivity = projectActivityService.get(activity?.projectActivityId, "all", params?.version)

        boolean embargoed = (activity.embargoed == true) || projectActivityService.isEmbargoed(pActivity)
        boolean userIsOwner = userId && activityService.isUserOwnerForActivity(userId, id)
        boolean userIsModerator = userId && projectService.canUserModerateProjects(userId, pActivity?.projectId)
        boolean userIsAlaAdmin = userService.userIsAlaOrFcAdmin()

        boolean userIsProjectMember =  userIsAlaAdmin || projectService.isUserMemberOfProject(userId, activity?.projectId)

        if (activity && pActivity) {
            if (embargoed && !userIsModerator && !userIsOwner && !userIsAlaAdmin) {
                flash.message = "Access denied: You do not have permission to access the requested resource."
                redirect(controller: 'project', action: 'index', id: activity.projectId)
            } else {
                Map model = activityAndOutputModel(activity, activity.projectId, 'view', params?.version)
                model.speciesConfig = [surveyConfig: [speciesFields: pActivity?.speciesFields]]
                model.pActivity = pActivity
                model.id = pActivity.projectActivityId
                model.userIsProjectMember = userIsProjectMember
                model.hasEditRights = userIsOwner || userIsModerator
                model.returnTo = params.returnTo ? params.returnTo : g.createLink(controller: 'project', action: 'index', id: pActivity?.projectId)
                params.mobile ? model.mobile = true : ''

                model

            }
        } else {
            forward(action: 'list', model: [error: 'no such id'])
        }
    }

    def ajaxGet(String id) {
        String userId = userService.getCurrentUserId()
        def activity = activityService.get(id, params?.version, userId, true)
        if (activity.error) {
            render status: HttpStatus.SC_INTERNAL_SERVER_ERROR, text: [message: activity.error] as JSON, contentType: ContentType.APPLICATION_JSON
            return
        }

        def pActivity = projectActivityService.get(activity?.projectActivityId, "all", params?.version)
        boolean embargoed = (activity.embargoed == true) || projectActivityService.isEmbargoed(pActivity)
        boolean userIsOwner = userId && activityService.isUserOwnerForActivity(userId, id)
        boolean userIsModerator = userId && projectService.canUserModerateProjects(userId, pActivity?.projectId)
        boolean userIsAlaAdmin = userService.userIsAlaOrFcAdmin()

        if (activity && pActivity) {
            if (embargoed && !userIsModerator && !userIsOwner && !userIsAlaAdmin) {
                def payload = [message: "Access denied: You do not have permission to access the requested resource."]
                render status: HttpStatus.SC_UNAUTHORIZED, text: payload as JSON, contentType: ContentType.APPLICATION_JSON
            } else {
                render text: activity as JSON, contentType: ContentType.APPLICATION_JSON
            }
        } else {
            render status: HttpStatus.SC_NOT_FOUND, text: [message: "Activity not found"] as JSON, contentType: ContentType.APPLICATION_JSON
        }
    }

    /**
     * List all activity associated to the user based on their role.
     * @param id activity id
     * @return
     */
    @SSO
    def list() {
        Boolean userIsAdmin = userService.userIsAlaOrFcAdmin()
        render(view: 'list',
                model: [
                        view: 'myrecords',
                        contentURI: '/bioActivity/list',
                        user: userService.user,
                        userIsAdmin: userIsAdmin,
                        title: messageSource.getMessage('myrecords.title', [].toArray(), '', Locale.default),
                        returnTo: g.createLink(controller: 'bioActivity', action: 'list')
                ]
        )
    }

    /**
     * List all activity recorded in biocollect.
     * @param id activity id
     * @return
     */
    def allRecords() {
        Boolean userIsAdmin = userService.userIsAlaOrFcAdmin()
        render(view: 'list',
                model: [
                        view: 'allrecords',
                        contentURI: '/bioActivity/allRecords',
                        title: messageSource.getMessage('allrecords.title', [].toArray(), '', Locale.default),
                        userIsAdmin: userIsAdmin,
                        returnTo: g.createLink(controller: 'bioActivity', action: 'allRecords')
                ]
        )
    }

    /**
     * List all activities uploaded by an import.
     * @param id activity id
     * @return
     */
    def bulkImport(String id) {
        Boolean userIsAdmin = userService.userIsAlaOrFcAdmin()
        render(view: 'list',
                model: [
                        view: 'bulkimport',
                        bulkImportId: id,
                        contentURI: '/bioActivity/bulkimport',
                        title: messageSource.getMessage('bulkimport.title', [].toArray(), '', Locale.default),
                        userIsAdmin: userIsAdmin,
                        returnTo: g.createLink(controller: 'bulkImport', action: 'index', params: [id: id])
                ]
        )
    }

    /**
     * List all activity associated to a project.
     * @param id activity id
     * @return
     */
    def projectRecords(String id) {
        String view = 'projectrecords'
        Map project = projectService.get(id)
        String occurrenceUrl = projectService.getOccurrenceUrl(project, view)
        String spatialUrl = projectService.getSpatialUrl(project, view)
        Boolean isProjectContributingDataToALA = projectService.isProjectContributingDataToALA(project)
        render(view: 'list',
                model: [
                        view: view,
                        contentURI: '/bioActivity/projectRecords',
                        projectId: id,
                        project: project,
                        title: messageSource.getMessage('project.records.title', [].toArray(), '', Locale.default),
                        occurrenceUrl: occurrenceUrl,
                        spatialUrl: spatialUrl,
                        isProjectContributingDataToALA: isProjectContributingDataToALA,
                        returnTo: g.createLink(controller: 'bioActivity', action: 'projectRecords') + '/' + id,
                        doNotStoreFacetFilters: true
                ]
        )
    }

    /**
     * List activities of the current user in a project.
     * @param id activity id
     * @return
     */
    def myProjectRecords(String id) {
        if(userService.user){
            String view = 'myprojectrecords'
            Map project = projectService.get(id)
            Boolean isProjectContributingDataToALA = projectService.isProjectContributingDataToALA(project)
            String occurrenceUrl = projectService.getOccurrenceUrl(project, view)
            String spatialUrl = projectService.getSpatialUrl(project, view)
            render(view: 'list',
                    model: [
                            view: view,
                            contentURI: '/bioActivity/myProjectRecords',
                            user:  userService.user,
                            projectId: id,
                            project: project,
                            title: messageSource.getMessage('project.myrecords.title', [].toArray(), '', Locale.default),
                            occurrenceUrl: occurrenceUrl,
                            spatialUrl: spatialUrl,
                            isProjectContributingDataToALA: isProjectContributingDataToALA,
                            returnTo: g.createLink(controller: 'bioActivity', action: 'myProjectRecords') + '/' + id,
                            doNotStoreFacetFilters: true
                    ]
            )
        } else {
            flash.message = "You need to be logged in to view your records"
            forward(action: 'projectRecords', params: params)
        }
    }

    /**
     * List activities of a user (not current user) in a project.
     * @param id activity id
     * @return
     */
    def listRecordsForUser() {
        if(params.spotterId && params.projectActivityId){
            String view = 'userprojectactivityrecords'
            Map projectActivity = projectActivityService.get(params.projectActivityId)
            String projectId = projectActivity?.projectId
            Map project = projectService.get(projectId)
            String occurrenceUrl = projectService.getOccurrenceUrl(project, view, params.spotterId)
            String spatialUrl = projectService.getSpatialUrl(project, view, params.spotterId)
            Boolean isProjectContributingDataToALA = projectService.isProjectContributingDataToALA(project)
            UserDetails user = authService.getUserForUserId(params.spotterId, false)
            if(user){
                render(view: 'list',
                        model: [
                                view: view,
                                contentURI: '/bioActivity/listRecordsForUser',
                                spotterId:  params.spotterId,
                                projectActivityId: params.projectActivityId,
                                pActivity: projectActivity,
                                project: project,
                                title: "${messageSource.getMessage('project.userrecords.title', [].toArray(), '', Locale.default)} ${user.getDisplayName()}",
                                occurrenceUrl: occurrenceUrl,
                                spatialUrl: spatialUrl,
                                isProjectContributingDataToALA: isProjectContributingDataToALA,
                                returnTo: g.createLink(controller: 'bioActivity', action: 'myProjectRecords') + '/' + params.projectId,
                                doNotStoreFacetFilters: true
                        ]
                )
            } else {
                render view: '../error', status: SC_BAD_REQUEST, model : [errorMessage: "No user found for id - ${params.spotterId}"]
            }
        } else {
            render view: '../error', status: SC_BAD_REQUEST, model : [errorMessage: "Missing parameter - spotterId or projectActivityId"]
        }
    }

    def ajaxList() {
        render listUserActivities(params) as JSON
    }

    def aekosSubmission() {
        def postBody = request.JSON
        log.info "aekosSubmission Body: " + postBody

        def jsonBody = new grails.web.JSONBuilder().build {postBody?.submissionBody}

        params["max"] = "10"
        params["offset"] = "0"
        params["sort"] = "lastUpdated"
        params["order"] = "DESC"
        params["flimit"] = "15"
        params["view"] = "project"
        params["projectId"] = postBody?.aekosActivityRec?.projectId
        params["fq"] = "projectActivityNameFacet:" + URLEncoder.encode(postBody?.aekosActivityRec?.activityName, "UTF-8")

        String downloadDataUrl = grailsLinkGenerator.link(uri: "/bioActivity/downloadProjectData?projectId=" + postBody?.aekosActivityRec?.projectId + "&fq=projectActivityNameFacet:" + URLEncoder.encode(postBody?.aekosActivityRec?.activityName, "UTF-8") + "&max=10&offset=0&sort=lastUpdated&order=DESC&flimit=15&view=project&searchTerm", absolute: true)

        def response = projectActivityService.sendAekosDataset(downloadDataUrl, jsonBody.toString())

        def result = [:]
        if (response?.status == 200 && response.content?.submissionid) {
            result = [status: "ok", submissionId: response.content?.submissionid]
            log.info ("Submission to Aekos is successful: " + result)
        } else {
            result = [status: 'error', error: "Error submitting data to AEKOS. Return code: " +  response?.status + ". Reason: " + response?.content?:"Unknown"]
            log.info ("Submission to Aekos has failed: " + result)
        }
        render result as JSON
    }

    def downloadProjectData() {
        response.setContentType("application/zip")
        response.setHeader('Content-Disposition', 'Attachment;Filename="data.zip"')
        Map queryParams = constructDefaultSearchParams(params)
        queryParams.isMerit = false
        searchService.downloadProjectData(response, queryParams)
        return null
    }

    private GrailsParameterMap constructDefaultSearchParams(Map params) {
        GrailsParameterMap queryParams = new GrailsParameterMap([:], request)
        Map parsed = commonService.parseParams(params)
        parsed.userId = userService.getCurrentUserId()

        parsed.each { key, value ->
            if (value != null && value) {
                queryParams.put(key, value)
            }
        }

        queryParams.max = queryParams.max ?: 10
        queryParams.offset = queryParams.offset ?: 0
        queryParams.flimit = queryParams.flimit ?: 20
        if(queryParams.flimit ==  "-1"){
            queryParams.flimit = MAX_FLIMIT;
            queryParams.max = 0;
        }

        queryParams.sort = queryParams.sort ?: 'lastUpdated'
        queryParams.order = queryParams.order ?: 'DESC'
        queryParams.fq = queryParams.fq ?: ''
        queryParams.rfq = queryParams.rfq ?: ''
        queryParams.searchTerm = queryParams.searchTerm ?: ''

        HubSettings hubSettings = SettingService.hubConfig
        List facetConfig = hubSettings.getFacetConfigForPage(projectActivityService.getDataPagePropertyFromViewName(params.view)) ?: activityService.getDefaultFacets()

        if(!queryParams.facets){
            String facets = HubSettings.getFacetConfigForElasticSearch(facetConfig)?.collect{ it.name }?.join(',')
            queryParams.facets = facets
        }

        List presenceAbsenceFacets = HubSettings.getFacetConfigWithPresenceAbsenceSetting(facetConfig)
        if(presenceAbsenceFacets){
            if(!queryParams.rangeFacets){
                queryParams.rangeFacets =[]
            }

            presenceAbsenceFacets?.each {
                queryParams.rangeFacets.add("${it.name}:[* TO 1}")
                queryParams.rangeFacets.add("${it.name}:[1 TO *}")
            }
        }

        if(!queryParams.histogramFacets){
            String facets = HubSettings.getFacetConfigWithHistogramSetting(facetConfig)?.collect{ "${it.name}:${it.interval}" }?.join(',')
            queryParams.histogramFacets = facets
        }

        queryParams
    }

    /*
     * Search project activities and records
     */
    @Operation(
            method = "GET",
            tags = "biocollect",
            operationId = "bioactivitydelete",
            summary = "Search activities",
            parameters = [
                    @Parameter(
                            name = "hub",
                            in = ParameterIn.QUERY,
                            description = "The hub context this request will be executed in. Visibility of activities depends on hub configuration. If no hub is specified, system defined default hub is used."
                    ),
                    @Parameter(
                            name = "searchTerm",
                            in = ParameterIn.QUERY,
                            description = "Searches for terms in this parameter.",
                            schema = @Schema(
                                    type = "string"
                            )
                    ),
                    @Parameter(
                            name = "max",
                            in = ParameterIn.QUERY,
                            description = "Maximum number of returned activities per page.",
                            schema = @Schema(
                                    name = "max",
                                    type = "integer",
                                    minimum = "0",
                                    defaultValue = "10"
                            )
                    ),
                    @Parameter(
                            name = "offset",
                            in = ParameterIn.QUERY,
                            description = "Offset search result by this parameter",
                            schema = @Schema(
                                    name = "offset",
                                    type = "integer",
                                    minimum = "0",
                                    defaultValue = "0"
                            )
                    ),
                    @Parameter(
                            name = "view",
                            in = ParameterIn.QUERY,
                            description = "Page on which activities will be rendered. To get all activities for a hub use 'allrecords'. To get activities belonging to a project use 'project'. etc. ",
                            schema = @Schema(
                                    type = "string",
                                    allowableValues = ['myrecords', 'project', 'projectrecords', 'myprojectrecords', 'userprojectactivityrecords', 'allrecords', 'bulkimport']
                            )
                    ),
                    @Parameter(
                            name = "bulkImportId",
                            in = ParameterIn.QUERY,
                            description = "Get activities generated from a bulk import. Access is only provided to user with project admin access or higher.",
                            schema = @Schema(
                                    type = "string"
                            )
                    ),
                    @Parameter(
                            name = "fq",
                            in = ParameterIn.QUERY,
                            description = "Restrict search results to these filter queries.",
                            schema = @Schema(
                                            type = "string"
                            )
                    ),
                    @Parameter(
                            name = "sort",
                            in = ParameterIn.QUERY,
                            description = "Sort by attribute",
                            schema = @Schema(
                                    type = "string",
                                    defaultValue = "lastUpdated"
                            )
                    ),
                    @Parameter(
                            name = "order",
                            in = ParameterIn.QUERY,
                            description = "Order sort item by this parameter",
                            schema = @Schema(
                                    type = "string",
                                    defaultValue = "DESC"
                            )
                    ),
                    @Parameter(
                            name = "facets",
                            in = ParameterIn.QUERY,
                            description = "Comma seperated list of facets the search should return. If left empty, facet list is populated from hub configuration.",
                            schema = @Schema(
                                    name = "facets",
                                    type = "string"
                            )
                    ),
                    @Parameter(
                            name = "flimit",
                            in = ParameterIn.QUERY,
                            description = "Maximum number of facets to be returned.",
                            schema = @Schema(
                                    name = "flimit",
                                    type = "integer",
                                    minimum = "0",
                                    maximum = "500",
                                    defaultValue = "20"
                            )
                    )
            ],
            responses = [
                    @ApiResponse(
                            responseCode = "200",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(
                                            implementation = SearchProjectActivitiesResponse.class
                                    )
                            ),
                            headers = [
                                    @Header(name = 'Access-Control-Allow-Headers', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Methods', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Origin', description = "CORS header", schema = @Schema(type = "String"))
                            ]
                    )
            ],
            security = @SecurityRequirement(name="auth")
    )
    @Path("ws/bioactivity/search")
    def searchProjectActivities() {
        GrailsParameterMap queryParams = constructDefaultSearchParams(params)

        Map searchResult = searchService.searchProjectActivity(queryParams)

        List activities = searchResult?.hits?.hits
        List facets
        Map userCanModerateForProjects = [:]
        List additionalPropertyConfig = SettingService.hubConfig.getDataColumns(grailsApplication)?.findAll {
            it.type == 'property'
        }

        activities = activities?.collect {
            Map doc = it._source
            if ( !userCanModerateForProjects.hasProperty ( doc.projectId ) ) {
                userCanModerateForProjects[doc.projectId] = projectService.canUserModerateProjects(queryParams.userId, doc.projectId)
            }

            Map result =
            [
                    activityId       : doc.activityId,
                    projectActivityId: doc.projectActivityId,
                    type             : doc.type,
                    status           : doc.status,
                    lastUpdated      : doc.lastUpdated,
                    userId           : doc.userId,
                    siteId           : doc.siteId,
                    name             : doc.projectActivity?.name,
                    activityOwnerName: doc.projectActivity?.activityOwnerName,
                    embargoed        : doc.projectActivity?.embargoed,
                    embargoUntil     : doc.projectActivity?.embargoUntil,
                    records          : doc.projectActivity?.records,
                    endDate          : doc.projectActivity?.endDate,
                    projectName      : doc.projectActivity?.projectName,
                    projectType      : doc.projectActivity?.projectType,
                    projectId        : doc.projectActivity?.projectId,
                    thumbnailUrl     : doc.thumbnailUrl,
                    showCrud         : (doc.userId == queryParams.userId) ||
                                        (queryParams.userId && doc.projectId && (userCanModerateForProjects[doc.projectId])),
                    userCanModerate  : userCanModerateForProjects[doc.projectId]
            ]

            activityService.addAdditionalProperties(additionalPropertyConfig, doc, result)
            result
        }

        HubSettings hubSettings = SettingService.hubConfig
        String alternativeViewName = projectActivityService.getDataPagePropertyFromViewName(queryParams.view)
        List allFacetConfig = hubSettings.getFacetConfigForPage(alternativeViewName)?: activityService.getDefaultFacets()
        List facetConfig = HubSettings.getFacetConfigMinusSpecialFacets(allFacetConfig)

        facets = searchService.standardiseFacets (searchResult.facets, facetConfig.collect{ it.name })

        List presenceAbsenceFacetConfig = HubSettings.getFacetConfigWithPresenceAbsenceSetting(allFacetConfig)
        if(presenceAbsenceFacetConfig){
            facets = searchService.standardisePresenceAbsenceFacets(facets, presenceAbsenceFacetConfig)
        }

        List histogramFacetConfig = HubSettings.getFacetConfigWithHistogramSetting(allFacetConfig)
        if(histogramFacetConfig){
            facets = searchService.standardiseHistogramFacets(facets, histogramFacetConfig)
        }

        List specialFacetConfig = HubSettings.getFacetConfigWithSpecialFacets(allFacetConfig)
        if(specialFacetConfig){
            facets = projectActivityService.addSpecialFacets(facets, allFacetConfig)
        }

        facets = utilService.getDisplayNamesForFacets(facets, allFacetConfig)
        facets = projectService.addFacetState(facets, allFacetConfig)
        render([activities: activities, facets: facets, total: searchResult.hits?.total ?: 0] as JSON)
    }

    /**
     * map points are generated from this function. It requires some client side code to convert the output of this
     * function to points.
     */
    @Operation(
            method = "GET",
            tags = "biocollect",
            operationId = "bioactivitydelete",
            summary = "Get sites associated with activities to draw points on map",
            parameters = [
                    @Parameter(
                            name = "hub",
                            in = ParameterIn.QUERY,
                            description = "The hub context this request will be executed in. Visibility of activities depends on hub configuration. If no hub is specified, system defined default hub is used."
                    ),
                    @Parameter(
                            name = "searchTerm",
                            in = ParameterIn.QUERY,
                            description = "Searches for terms in this parameter.",
                            schema = @Schema(
                                    type = "string"
                            )
                    ),
                    @Parameter(
                            name = "max",
                            in = ParameterIn.QUERY,
                            description = "Maximum number of returned activities per page.",
                            schema = @Schema(
                                    name = "max",
                                    type = "integer",
                                    minimum = "0",
                                    defaultValue = "10"
                            )
                    ),
                    @Parameter(
                            name = "offset",
                            in = ParameterIn.QUERY,
                            description = "Offset search result by this parameter",
                            schema = @Schema(
                                    name = "offset",
                                    type = "integer",
                                    minimum = "0",
                                    defaultValue = "0"
                            )
                    ),
                    @Parameter(
                            name = "view",
                            in = ParameterIn.QUERY,
                            description = "Page on which activities will be rendered. To get all activities for a hub use 'allrecords'. To get activities belonging to a project use 'project'. etc. ",
                            schema = @Schema(
                                    type = "string",
                                    allowableValues = ['myrecords', 'project', 'projectrecords', 'myprojectrecords', 'userprojectactivityrecords', 'allrecords']
                            )
                    ),
                    @Parameter(
                            name = "fq",
                            in = ParameterIn.QUERY,
                            description = "Restrict search results to these filter queries.",
                            schema = @Schema(
                                    type = "string"
                            )
                    ),
                    @Parameter(
                            name = "sort",
                            in = ParameterIn.QUERY,
                            description = "Sort by attribute",
                            schema = @Schema(
                                    type = "string",
                                    defaultValue = "lastUpdated"
                            )
                    ),
                    @Parameter(
                            name = "order",
                            in = ParameterIn.QUERY,
                            description = "Order sort item by this parameter",
                            schema = @Schema(
                                    type = "string",
                                    defaultValue = "DESC"
                            )
                    )
            ],
            responses = [
                    @ApiResponse(
                            responseCode = "200",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(
                                            implementation = GetProjectActivitiesRecordsForMappingResponse.class
                                    )
                            ),
                            headers = [
                                    @Header(name = 'Access-Control-Allow-Headers', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Methods', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Origin', description = "CORS header", schema = @Schema(type = "String"))
                            ]
                    )
            ],
            security = @SecurityRequirement(name="auth")
    )
    @Path("ws/bioactivity/map")
    def getProjectActivitiesRecordsForMapping() {
        GrailsParameterMap queryParams = new GrailsParameterMap([:], request)
        Map parsed = commonService.parseParams(params)
        parsed.userId = userService.getCurrentUserId()
        parsed.each { key, value ->
            if (value != null && value) {
                queryParams.put(key, value)
            }
        }

        queryParams.max = queryParams.max ?: 10
        queryParams.offset = queryParams.offset ?: 0
        queryParams.flimit = queryParams.flimit ?: 20
        queryParams.sort = queryParams.sort ?: 'lastUpdated'
        queryParams.order = queryParams.order ?: 'DESC'
        queryParams.fq = queryParams.fq ?: ''
        queryParams.searchTerm = queryParams.searchTerm ?: ''
        queryParams.view = queryParams.view
        // Only include the data in the response that we need to return to the client.
        queryParams.include = ['activityId', 'projectActivity.name',
                               'projectActivity.records.coordinates', 'projectActivity.records.individualCount',
                               'projectActivity.records.multimedia.identifier', 'projectActivity.records.name',
                               'projectActivity.projectId', 'projectActivity.projectName', 'coordinates', 'sites', 'type', 'projectActivityId']

        Map searchResult = searchService.searchProjectActivity(queryParams)
        List activities = searchResult?.hits?.hits
        List projectIds = parsed.userId ? userService.getProjectsForUserId(parsed.userId)?.collect {
            it.project?.projectId
        } : []

        Boolean userIsAlaOrFcAdmin = userService.userIsAlaOrFcAdmin()

        activities = activities?.collect {
            Map doc = it._source

            //Sensitive species coordinate adjustments.

            if (!userIsAlaOrFcAdmin ) {
                boolean projectMember = projectIds && projectIds.find { it == doc?.projectId }
                if(!projectMember) {
                    doc.projectActivity?.records?.each {
                        if (it.generalizedCoordinates) {
                            it.coordinates = it.generalizedCoordinates
                        }
                    }
                }
            }

            Map result = [
                    activityId       : doc.activityId,
                    projectActivityId: doc.projectActivityId,
                    type             : doc.type,
                    name             : doc.projectActivity?.name,
                    activityOwnerName: doc.projectActivity?.activityOwnerName,
                    records          : doc.projectActivity?.records,
                    projectName      : doc.projectActivity?.projectName,
                    projectId        : doc.projectActivity?.projectId,
                    sites            : doc.sites,
                    coordinates      : doc.coordinates
            ]

            if (doc.sites && doc.sites.size() > 0) {
                if (doc.sites[0] instanceof String) result.coordinates = siteService.get(doc.sites[0])?.extent?.geometry?.centre
                else result.coordinates = doc.sites[0]?.extent?.geometry?.centre
            }

            result
        }

        render([activities: activities, total: searchResult.hits?.total ?: activities?.size()] as JSON)
    }

    def ajaxListForProject(String id) {

        def model = [:]
        def query = [pageSize: params.max ?: 10,
                     offset  : params.offset ?: 0,
                     sort    : params.sort ?: 'lastUpdated',
                     order   : params.order ?: 'desc']
        def results = activityService.activitiesForProject(id, query)
        String userId = userService.getCurrentUserId()
        boolean isAdmin = userId ? projectService.isUserAdminForProject(userId, id) : false
        results?.activities?.each {
            it.pActivity = projectActivityService.get(it.projectActivityId)
            it.showCrud = isAdmin ?: (userId == it.userId)
        }
        model.activities = results?.activities
        model.total = results?.total

        render model as JSON
    }

    private def listUserActivities(params) {
        Map model = [:]
        def query = [pageSize: params.max ?: 10,
                     offset  : params.offset ?: 0,
                     sort    : params.sort ?: 'lastUpdated',
                     order   : params.order ?: 'desc']
        def results = activityService.activitiesForUser(userService.getCurrentUserId(), query)
        String userId = userService.getCurrentUserId()
        results?.activities?.each {
            it.pActivity = projectActivityService.get(it.projectActivityId)
            it.showCrud = true
        }
        model.activities = results?.activities
        model.total = results?.total
        model
    }


    private def updatePhotoPoints(activityId, photoPoints) {
        List allPhotos = photoPoints.photos ?: []

        // If new photo points were defined, add them to the site.
        if (photoPoints.photoPoints) {
            photoPoints.photoPoints.each { photoPoint ->
                def photos = photoPoint.remove('photos')
                def result = siteService.addPhotoPoint(photoPoints.siteId, photoPoint)
                log.debug(result.toString())
                if (!result.error) {
                    photos.each { photo ->
                        photo.poiId = result?.resp?.poiId
                        allPhotos << photo
                    }
                }
            }
        }

        allPhotos.each { photo ->
            photo.activityId = activityId
            documentService.saveStagedImageDocument(photo)
        }
    }

    private Map activityModel(activity, projectId, mode = '', version = null) {
        Map model = [activity: activity, returnTo: params.returnTo, mode: mode]
        model.site = model.activity?.siteId ? siteService.get(model.activity.siteId, [view: 'brief', version: version]) : null
        model.project = projectId ? projectService.get(projectId, null, false, version) : null
        model.projectSite = model.project?.sites?.find { it.siteId == model.project.projectSiteId }

        // Add the species lists that are relevant to this activity.
        model.speciesLists = new JSONArray()
        if (model.project) {
            model.project.speciesLists?.each { list ->
                if (list.purpose == activity.type) {
                    model.speciesLists.add(list)
                }
            }
            model.themes = metadataService.getThemesForProject(model.project)
        }

        model.user = userService.getUser()

        generalizeCoordinates(model)

        model.mapFeatures = model.site ? siteService.getMapFeatures(model.site) : []

        if(model.activity?.documents){
            documentService.addLicenceDescription(model.activity?.documents);
        }

        model
    }

    private Map activityAndOutputModel(activity, projectId, mode = '', version = null, type = null) {
        def model = activityModel(activity, projectId, mode, version)
        addOutputModel(model, type)

        model
    }

    private def addOutputModel(model ,type = null) {
        type = type ?: model.activity.type
        model.putAll(activityFormService.getActivityAndOutputMetadata(type))
        model
    }

    @SSO
    def convertExcelToOutputData() {
        String pActivityId = params.pActivityId
        String type = params.type
        def file
        if (request.respondsTo('getFile')) {
            file = request.getFile('data')
        }

        if (pActivityId && type && file) {
            def content = activityService.convertExcelToOutputData(pActivityId, type, file)
            def status = SC_OK
            if (content.error) {
                status = SC_INTERNAL_SERVER_ERROR
            }
            render text: content as JSON, status: status
        }
        else {
            render text: [message: "Missing required parameters - pActivityId, type & data (excel file)"] as JSON, status: SC_BAD_REQUEST
        }
    }

    def extractDataFromExcelTemplate() {

        def result
        if (request.respondsTo('getFile')) {
            def file = request.getFile('data')
            if (file) {
                def data = metadataService.extractOutputDataFromExcelOutputTemplate(params, file)

                if (data && !data.error) {
                    activityService.lookupSpeciesInOutputData(params.pActivityId, params.type, params.listName, data.data)
                    result = [status: SC_OK, data: data.data]
                } else {
                    result = data
                }

                // iframe no longer supported
                response.setContentType('application/json')
                def resultJson = result as JSON
                render resultJson.toString()
            }
        } else {
            response.status = SC_BAD_REQUEST
            result = [status: SC_BAD_REQUEST, error: 'No file attachment found']
            // iframe no longer supported
            response.setContentType('application/json')
            def resultJson = result as JSON
            render resultJson.toString()
        }
    }

    def uploadFile() {
        String stagingDirPath = grailsApplication.config.upload.path
        Map result = [:]
        if (request.respondsTo('getFile')) {
            MultipartFile multipartFile = request.getFile('files')

            if (multipartFile?.size) {  // will only have size if a file was selected
                String filename = multipartFile.getOriginalFilename().replaceAll(' ', '_')
                String ext = FilenameUtils.getExtension(filename)
                filename = FileUtils.nextUniqueFileName(FilenameUtils.getBaseName(filename) + '.' + ext, stagingDirPath)

                File stagingDir = new File(stagingDirPath)
                stagingDir.mkdirs()
                File file = new File(FileUtils.fullPath(filename, stagingDirPath))
                multipartFile.transferTo(file)

                Map metadata = [
                        name       : filename,
                        size       : multipartFile.size,
                        contentType: multipartFile.contentType,
                        url        : FileUtils.encodeUrl(grailsApplication.config.grails.serverURL + "/download/file?filename=", filename),
                        attribution: '',
                        notes      : '',
                        status     : "active"
                ]
                result = [files: [metadata]]
            }
        }

        response.addHeader('Content-Type', 'text/plain')
        def resultJson = result as JSON
        render resultJson.toString()
    }

    private static boolean isProjectActivityClosed(Map projectActivity) {
        projectActivity?.endDate && Date.parse("yyyy-MM-dd", projectActivity?.endDate)?.before(new Date())
    }

    /**
     * Generalise coordinates for sensitive species.
     * Supports only point based coordinates.
     * @param model model with activity and site object
     */
    private void generalizeCoordinates(Map model) {

        // don't overwrite coordinates:
        // 1. if user is a project member or admin ?
        // 2. if request comes from create or edit page.
        if (model.mode != 'view' || (model?.user && !activityService.applySensitiveSpeciesCoordinates(model.user?.userId, model.activity?.projectId))) {
            return
        }

        def records = recordService.listActivityRecords(model.activity?.activityId)?.records
        def sensitiveRecord = records?.find { it.generalizedDecimalLatitude && it.generalizedDecimalLongitude }

        if (sensitiveRecord) {

            //Embedded maps - Single and Multi species
            model?.activity?.outputs?.each {
                if (it.data?.locationLatitude && it.data?.locationLongitude) {
                    it.data?.locationLatitude = sensitiveRecord.generalizedDecimalLatitude
                    it.data?.locationLongitude = sensitiveRecord.generalizedDecimalLongitude
                }
            }

            //External site associated with activity
            modifyCoordinates(sensitiveRecord, model.site);

            //Project site associated with activity
            modifyCoordinates(sensitiveRecord, model.projectSite);

            model.project?.sites = null
        }
    }

    private modifyCoordinates(sensitiveRecord, site) {

        if (site?.extent?.geometry?.decimalLatitude && site?.extent?.geometry?.decimalLongitude) {
            site.extent.geometry.decimalLatitude = sensitiveRecord.generalizedDecimalLatitude
            site.extent.geometry.decimalLongitude = sensitiveRecord.generalizedDecimalLongitude
            if (site.extent.geometry.coordinates && site.extent.geometry.coordinates.size() == 2) {
                site.extent.geometry.coordinates[0] = sensitiveRecord.generalizedDecimalLongitude
                site.extent.geometry.coordinates[1] = sensitiveRecord.generalizedDecimalLatitude
            }
            if (site.extent.geometry.centre && site.extent.geometry.centre.size() == 2) {
                site.extent.geometry.centre[0] = sensitiveRecord.generalizedDecimalLongitude
                site.extent.geometry.centre[1] = sensitiveRecord.generalizedDecimalLatitude
            }
            if (site.geoIndex?.coordinates && site.geoIndex?.coordinates.size() == 2) {
                site.geoIndex.coordinates[0] = sensitiveRecord.generalizedDecimalLongitude
                site.geoIndex.coordinates[1] = sensitiveRecord.generalizedDecimalLatitude
            }
        }
    }

    /*
     * Get data/output for an activity
     * Handles both session and non session based request.
     *
     * @param id activityId
     *
     * @return activity
     *
     */
    @Operation(
            method = "GET",
            tags = "biocollect",
            operationId = "activityoutputs",
            summary = "Get data for an activity",
            deprecated = true,
            parameters = [
                    @Parameter(
                            name = "id",
                            in = ParameterIn.PATH,
                            required = true,
                            description = "Activity id"
                    )
            ],
            responses = [
                    @ApiResponse(
                            responseCode = "200",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(
                                            implementation = GetOutputForActivityResponse.class
                                    )
                            ),
                            headers = [
                                    @Header(name = 'Access-Control-Allow-Headers', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Methods', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Origin', description = "CORS header", schema = @Schema(type = "String"))
                            ]
                    ),
                    @ApiResponse(
                            responseCode = "401",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(
                                            implementation = ErrorResponse.class
                                    )
                            ),
                            headers = [
                                    @Header(name = 'Access-Control-Allow-Headers', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Methods', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Origin', description = "CORS header", schema = @Schema(type = "String"))
                            ]
                    )
            ],
            security = @SecurityRequirement(name="auth")
    )
    @Path("ws/bioactivity/data/{id}")
    def getOutputForActivity(String id){
        String userId = userService.getCurrentUserId()
        def activity = activityService.get(id)
        String projectId = activity?.projectId
        def model = [:]

        if (!userId) {
            response.status = 401
            model.error = "Access denied: User has not been authenticated."
        } else if (!activity) {
            model.error = "Invalid activity id"
        } else if (!activity) {
            model.error = "Invalid activity - ${id}"
        } else if (!projectId) {
            model.error = "No project associated with the activity"
        } else if (projectService.isUserAdminForProject(userId, projectId) || activityService.isUserOwnerForActivity(userId, activity?.activityId)) {
            def pActivity = projectActivityService.get(activity?.projectActivityId, "all")
            model = activityAndOutputModel(activity, activity.projectId)
            model.pActivity = pActivity
            model.projectActivityId = pActivity.projectActivityId
            model.id = id
        } else {
            response.status = 401
            model.error = "Access denied: User is not an owner of this activity ${activity?.activityId}"
        }

        render model as JSON
    }

    @Operation(
            method = "GET",
            tags = "biocollect",
            operationId = "listrecords",
            summary = "List records associated with the given project",
            parameters = [
                    @Parameter(
                            name = "projectId",
                            in = ParameterIn.QUERY,
                            required = true,
                            description = "Project id"
                    ),
                    @Parameter(
                            name = "max",
                            in = ParameterIn.QUERY,
                            description = "Maximum number of returned activities per page.",
                            schema = @Schema(
                                    name = "max",
                                    type = "integer",
                                    minimum = "0",
                                    defaultValue = "10"
                            )
                    ),
                    @Parameter(
                            name = "offset",
                            in = ParameterIn.QUERY,
                            description = "Offset search result by this parameter",
                            schema = @Schema(
                                    name = "offset",
                                    type = "integer",
                                    minimum = "0",
                                    defaultValue = "0"
                            )
                    ),
                    @Parameter(
                            name = "sort",
                            in = ParameterIn.QUERY,
                            description = "Sort by attribute",
                            schema = @Schema(
                                    type = "string",
                                    defaultValue = "lastUpdated"
                            )
                    ),
                    @Parameter(
                            name = "order",
                            in = ParameterIn.QUERY,
                            description = "Order sort item by this parameter",
                            schema = @Schema(
                                    type = "string",
                                    defaultValue = "desc"
                            )
                    ),
                    @Parameter(
                            name = "status",
                            in = ParameterIn.QUERY,
                            description = "Project status",
                            schema = @Schema(
                                    type = "string",
                                    defaultValue = "active"
                            )
                    )
            ],
            responses = [
                    @ApiResponse(
                            responseCode = "200",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(
                                            implementation = Map.class
                                    )
                            ),
                            headers = [
                                    @Header(name = 'Access-Control-Allow-Headers', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Methods', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Origin', description = "CORS header", schema = @Schema(type = "String"))
                            ]
                    ),
                    @ApiResponse(responseCode = "400", description = "Bad request"),
                    @ApiResponse(responseCode = "401", description = "Unauthorized"),
                    @ApiResponse(responseCode = "500", description = "Internal server error")
            ],
            security = @SecurityRequirement(name = "auth")
    )
    @Path("ws/bioactivity/data/records")
    def listRecordsForDataResourceId(){
        String userId = userService.getCurrentUserId()
        GrailsParameterMap queryParams = constructDefaultSearchParams(params)

        if (!userId) {
            render text: [message: "Access denied: User not authorised."] as JSON, status: HttpStatus.SC_UNAUTHORIZED, contentType: ContentType.APPLICATION_JSON
        } else if (!queryParams.projectId) {
            render text: [message: "No project associated with the activity."] as JSON, status: HttpStatus.SC_BAD_REQUEST, contentType: ContentType.APPLICATION_JSON
        } else if (projectService.canUserEditProject(userId, queryParams.projectId, false)) {
            Map project = projectService.get(queryParams.projectId)
            if (!project.dataResourceId) {
                render text: [message: "Only data of ALA harvested projects can be accessed."] as JSON, status: HttpStatus.SC_BAD_REQUEST, contentType: ContentType.APPLICATION_JSON
            } else {
                queryParams.id = project.dataResourceId
                def result = activityService.listRecordsForDataResourceId(queryParams)
                if (!result.error) {
                    render text: result as JSON, contentType: ContentType.APPLICATION_JSON
                } else {
                    render text: [message: "An error occurred while fetching data."] as JSON, status: result.statusCode, contentType: ContentType.APPLICATION_JSON
                }
            }
        } else {
            render text: "Access denied: User not authorised.", status: HttpStatus.SC_UNAUTHORIZED
        }
    }

    @Operation(
            method = "GET",
            tags = "biocollect",
            summary = "Generate darwin core archive",
            description = "Returns a ZIP file containing darwin core archive",
            parameters = [
                    @Parameter(
                            name = "projectId",
                            in = ParameterIn.PATH,
                            required = true,
                            description = "Project id"
                    ),
                    @Parameter(
                        name = "force",
                        in = ParameterIn.QUERY,
                        description = "Set to true to generate Darwin Core Archive on demand (slow) or false to get the pre-generated file (might not have the latest data)",
                        schema = @Schema(type = "boolean", defaultValue = "false")
                    )
            ],
            responses = [
                    @ApiResponse(
                            responseCode = "200",
                            description = "Successful response with ZIP file",
                            content = [@Content(mediaType = "application/zip", schema = @Schema(type = "string", format = "binary"))]
                    ),
                    @ApiResponse(responseCode = "400", description = "Bad request"),
                    @ApiResponse(responseCode = "401", description = "Unauthorized"),
                    @ApiResponse(responseCode = "500", description = "Internal server error")
            ],
            security = @SecurityRequirement(name = "auth")
    )
    @Path("ws/bioactivity/data/archive/{projectId}")
    @Produces("application/zip")
    def getDarwinCoreArchiveForProject(String projectId){
        log.debug("projectId = ${projectId}")

        String userId = userService.getCurrentUserId()
        Map project = projectService.get(projectId)
        if (!userId) {
            render text: [message: "Access denied: User not authorised."] as JSON, status: HttpStatus.SC_UNAUTHORIZED, contentType: ContentType.APPLICATION_JSON
        } else if (!projectId) {
            render text: "Project Id is required.", status: SC_BAD_REQUEST
        }else if (project.error) {
            render text: [message: "An error occurred when accessing project."] as JSON, status: HttpStatus.SC_INTERNAL_SERVER_ERROR, contentType: ContentType.APPLICATION_JSON
        } else {
            if (projectService.canUserEditProject(userId, projectId, false)) {
                try {
                    activityService.getDarwinCoreArchiveForProject(projectId, response, params.force)
                    response.outputStream.flush()
                    return null
                } catch (Exception e) {
                    log.error (e.message.toString(), e)
                    render text: [message: "An error occurred when accessing project."] as JSON, status: HttpStatus.SC_INTERNAL_SERVER_ERROR, contentType: ContentType.APPLICATION_JSON
                }
            } else {
                render text: [message: "Access denied: User not authorised."] as JSON, status: HttpStatus.SC_UNAUTHORIZED, contentType: ContentType.APPLICATION_JSON
            }
        }
    }

    /*
     * Simplified version to get data/output for an activity
     * Handles both session and non session based request.
     *
     * @param id activityId
     *
     * @return activity
     *
     */
    @Operation(
            method = "GET",
            tags = "biocollect",
            operationId = "simplifiedactivityoutputs",
            summary = "Get data for an activity",
            parameters = [
                    @Parameter(
                            name = "id",
                            in = ParameterIn.PATH,
                            required = true,
                            description = "Activity id"
                    ),
                    @Parameter(
                            name = "includeSiteData",
                            in = ParameterIn.QUERY,
                            description = "Include site data",
                            schema = @Schema(type = "boolean", defaultValue = "false")
                    )
            ],
            responses = [
                    @ApiResponse(
                            responseCode = "200",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(
                                            implementation = GetOutputForActivitySimplifiedResponse.class
                                    )
                            ),
                            headers = [
                                    @Header(name = 'Access-Control-Allow-Headers', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Methods', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Origin', description = "CORS header", schema = @Schema(type = "String"))
                            ]
                    ),
                    @ApiResponse(
                            responseCode = "401",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(
                                            implementation = ErrorResponse.class
                                    )
                            ),
                            headers = [
                                    @Header(name = 'Access-Control-Allow-Headers', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Methods', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Origin', description = "CORS header", schema = @Schema(type = "String"))
                            ]
                    )
            ],
            security = @SecurityRequirement(name="auth")
    )
    @Path("ws/bioactivity/data/simplified/{id}")
    def getOutputForActivitySimplified(String id, boolean includeSiteData){
        log.debug("id = ${id}")
        log.debug("includeSiteData = ${includeSiteData}")

        String userId = userService.getCurrentUserId()
        def activity = activityService.get(id, null, userId, false,includeSiteData)
        String projectId = activity?.projectId
        def model = [:]

        if (!userId) {
            response.status = 401
            model.error = "Access denied: User has not been authenticated."
        } else if (!activity) {
            model.error = "Invalid activity id"
        } else if (!activity) {
            model.error = "Invalid activity - ${id}"
        } else if (!projectId) {
            model.error = "No project associated with the activity"
        } else if (projectService.isUserAdminForProject(userId, projectId) || activityService.isUserOwnerForActivity(userId, activity?.activityId)) {
            if (includeSiteData) {
                activity.site = new JSONObject([siteId:activity.site.siteId, name:activity.site.name, geoJson:activity.site.geoIndex])
            }
            model = [activity: activity]
        } else {
            response.status = 401
            model.error = "Access denied: User is not an owner of this activity ${activity?.activityId}"
        }

        render model as JSON
    }

    /*
     * Get activity model for a survey/projectActivity
     * Handles both session and non session based request.
     *
     * @param id projectActivityId
     *
     * @return activity model
     *
     */
    @Operation(
            method = "GET",
            tags = "biocollect",
            operationId = "projectactivitymodel",
            summary = "Get survey's data model",
            parameters = [
                    @Parameter(
                            name = "id",
                            in = ParameterIn.PATH,
                            required = true,
                            description = "Survey id or project activity id"
                    )
            ],
            responses = [
                    @ApiResponse(
                            responseCode = "200",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(
                                            implementation = GetActivityModelResponse.class
                                    )
                            ),
                            headers = [
                                    @Header(name = 'Access-Control-Allow-Headers', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Methods', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Origin', description = "CORS header", schema = @Schema(type = "String"))
                            ]
                    ),
                    @ApiResponse(
                            responseCode = "401",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(
                                            implementation = ErrorResponse.class
                                    )
                            ),
                            headers = [
                                    @Header(name = 'Access-Control-Allow-Headers', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Methods', description = "CORS header", schema = @Schema(type = "String")),
                                    @Header(name = 'Access-Control-Allow-Origin', description = "CORS header", schema = @Schema(type = "String"))
                            ]
                    )
            ],
            security = @SecurityRequirement(name="auth")
    )
    @Path("ws/bioactivity/model/{id}")
    def getActivityModel(String id){
        String userId = userService.getCurrentUserId()
        Map model = [:]

        if(userId){
            Map pActivity = projectActivityService.get(id, "all")
            String projectId = pActivity?.projectId
            String type = pActivity?.pActivityFormName
            if (!pActivity.publicAccess && !projectService.canUserEditProject(userId, projectId, false)) {
                model.error = "Access denied: User does not have <b>editor</b> permission for projectId ${projectId}"
                response.status = 401
            } else if (isProjectActivityClosed(pActivity)) {
                model.error = "Access denied: This survey is closed."
                response.status = 401
            }  else if (!pActivity) {
                model.error = "Invalid survey - ${id}"
            } else if (!projectId) {
                model.error = "No project associated with the survey"
            } else if (!type) {
                model.error = "Invalid activity type"
            } else {
                Map activity = [activityId: '', siteId: '', projectId: projectId, type: type]
                model = activityModel(activity, projectId)
                model.pActivity = pActivity
                model.returnTo = params.returnTo ? params.returnTo : g.createLink(controller: 'project', id: projectId)
                model.autocompleteUrl = "${request.contextPath}/search/searchSpecies?projectActivityId=${pActivity.projectActivityId}&limit=10"

                addOutputModel(model)
            }
        } else {
            model.error = "Invalid user"
        }

        render model as JSON
    }

    /**
     * Biocollect has a special URL for prefilling species information. The format is
     * http://biocollect.ala.org.au/sight/http://id.biodiversity.org.au/node/apni/9443092 . The function does the
     * species prefilling. This call is done from BIE's species page. Biocollect records it in ALA's
     * species sightings survey.
     * @param activity
     * @return
     */
    private addDefaultSpecies (Map activity) {
        if (params.taxonId) {
            String speciesModelName = grailsApplication.config.individualSightings.dataTypeName
            String outputName = grailsApplication.config.individualSightings.outputName
            String speciesDisplayFormat
            Map species = [:]
            Map result = speciesService.getSpeciesDetailsForTaxonId(params.taxonId, false);
            Map pActivityDetails = projectActivityService.get(params.id)
            if (!pActivityDetails.error) {
                Map speciesConfig = projectActivityService.getSpeciesConfigForProjectActivity(pActivityDetails, outputName, speciesModelName)
                speciesDisplayFormat = speciesConfig?.speciesDisplayFormat
            }

            species.scientificName = result?.scientificName
            species.commonName = result.commonName
            species.guid = params.taxonId
            species.name = speciesService.formatSpeciesName(speciesDisplayFormat ?: 'SCIENTIFICNAME(COMMONNAME)', species)
            Map output = [:]
            output.name = outputName
            output?.data = output?.data ?: [:]
            output.data[speciesModelName] = species
            activity.outputs = [ output ]
        }
    }

    /**
     * Get all sites that this project activity has record against.
     * @param id
     * @return
     */
    public getSitesWithDataForProjectActivity(String id){
        def result = activityService.getSitesWithDataForProjectActivity(id)
        render result as JSON
    }

    /**
     * Get all sites that this project activity has record against.
     * @param id
     * @return
     */
    public getSitesWithDataForProject (String id) {
        def result = activityService.getSitesWithDataForProject(id)
        render result as JSON
    }


    /**
     * This controller is used to pre-fill the species details if a taxon id is passed in the url.
     * @return
     */
    public spotter(){
        if(params.spotterId){
            String pActivity = grailsApplication.config.individualSightings.pActivity,
                   hub = grailsApplication.config.individualSightings.hub;

            params.projectActivityId = pActivity
            params.hub = hub

            forward(action: 'listRecordsForUser')
        } else {
            render status: SC_BAD_REQUEST, text: "You need to provide user id"
        }
    }

    def getFacets () {
        List facets = activityService.getFacets()
        render text: [facets: facets] as JSON, contentType: 'application/json'
    }

    def getDataColumns () {
        List columns = grailsApplication.config.datapage.allColumns
        columns += activityService.getDynamicIndexNamesAsColumnConfig()
        render text: [columns: columns] as JSON, contentType: 'application/json'
    }

    private addXFrameOptionsHeader() {
        if(params.embedded == 'true'){
            response.setHeader("X-Frame-Options", "SAMEORIGIN")
        }
    }

    private String getMessage(Map resp) {
        String errorMessage
        if (resp.detail) {
            try {
                errorMessage = JSON.parse(resp?.detail)
            } catch (ConverterException ce) {
                errorMessage = resp.error
            }
        }

        errorMessage ?: resp.error
    }
}
