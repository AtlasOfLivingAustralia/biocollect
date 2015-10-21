package au.org.ala.biocollect

import au.org.ala.biocollect.merit.ActivityService
import au.org.ala.biocollect.merit.DocumentService
import au.org.ala.biocollect.merit.MetadataService
import au.org.ala.biocollect.merit.ProjectService
import au.org.ala.biocollect.merit.SiteService
import au.org.ala.biocollect.merit.UserService
import au.org.ala.biocollect.sightings.BieService
import grails.converters.JSON
import org.apache.http.HttpStatus
import org.codehaus.groovy.grails.web.json.JSONArray

class BioActivityController {

    public static final String BIOCOLLECT_SIGHTINGS_PLUGIN_NAME = "biocollectSightings"
    ProjectService projectService
    MetadataService metadataService
    SiteService siteService
    ProjectActivityService projectActivityService
    UserService userService
    DocumentService documentService
    ActivityService activityService
    BieService bieService

    /**
     * Update Activity by activityId or
     * Create Activity by projectActivity
     * @param id activity id
     * @param pActivityId project activity Id
     * @return
     */
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

        // Check user has admin/editor permission.
        String userId = userService.getCurrentUserId()
        if (!userId) {
            flash.message = "Access denied: User has not been authenticated."
            response.status = 401
            result = [status: 401, error: flash.message]
        } else if (!activity && !pActivity.publicAccess && !projectService.canUserEditProject(userId, projectId, false)) {
            flash.message = "Access denied: User does not have <b>editor</b> permission for projectId ${projectId}"
            response.status = 401
            result = [status: 401, error: flash.message]
        } else if (activity && !pActivity.publicAccess && !projectService.canUserEditActivity(userId, activity)) {
            flash.message = "Access denied: User is not an owner of this activity ${activity?.activityId}"
            response.status = 401
            result = [status: 401, error: flash.message]
        } else {
            boolean projectEditor = projectService.canUserEditProject(userId, projectId, false)
            Map userAlreadyInRole = userService.isUserInRoleForProject(userId, projectId, "projectParticipant")
            if (!userAlreadyInRole.statusCode || userAlreadyInRole.statusCode == HttpStatus.SC_OK) {
                if (!projectEditor && pActivity.publicAccess && !userAlreadyInRole.inRole.toBoolean()) {
                    userService.addUserAsRoleToProject(userId, projectId, "projectParticipant")
                }

                def photoPoints = postBody.remove('photoPoints')
                postBody.projectActivityId = pActivity.projectActivityId
                postBody.userId = userId
                result = activityService.update(id, postBody)

                String activityId = id ?: result?.resp?.activityId
                if (photoPoints && activityId) {
                    updatePhotoPoints(activityId, photoPoints)
                }
            } else {
                flash.message = userAlreadyInRole.error
                response.status = userAlreadyInRole.statusCode
                result = userAlreadyInRole
            }
        }

        render result as JSON
    }

    /**
     * Edit activity for the given activityId
     * Project Site Admin / activity owner can edit the activity
     * @param id activity id
     * @return
     */
    def edit(String id) {

        def activity = activityService.get(id)
        def projectId = activity?.projectId
        def model = null

        if (!activity) {
            flash.message = "Invalid activity - ${id}"
            redirect(controller: 'project', action: 'index', id: projectId)
        } else if (!projectService.canUserEditActivity(userService.getCurrentUserId(), activity)) {
            flash.message = "Access denied: User is not an owner of this activity ${activity?.activityId}"
            redirect(controller: 'project', action: 'index', id: projectId)
        } else {
            def pActivity = projectActivityService.get(activity?.projectActivityId, "all")
            model = activityAndOutputModel(activity, activity.projectId)
            model.pActivity = pActivity
            model.projectActivityId = pActivity.projectActivityId
            model.id = id
        }

        model
    }

    /**
     * Create activity for the given project activity
     * Users with project edit permission can create new activity for the projectActivity
     * @param id project activity
     * @return
     */
    def create(String id) {
        String userId = userService.getCurrentUserId()
        Map pActivity = projectActivityService.get(id, "all")
        String projectId = pActivity?.projectId
        String type = pActivity?.pActivityFormName
        Map model = null

        if (!pActivity.publicAccess && !projectService.canUserEditProject(userId, projectId, false)) {
            flash.message = "Access denied: User does not have <b>editor</b> permission for projectId ${projectId}"
            redirect(controller: 'project', action: 'index', id: projectId)
        } else if (!type) {
            flash.message = "Invalid activity type"
            redirect(controller: 'project', action: 'index', id: projectId)
        } else {
            Map activity = [activityId: '', siteId: '', projectId: projectId, type: type]
            model = activityModel(activity, projectId)
            model.pActivity = pActivity
            model.returnTo = params.returnTo ? params.returnTo : g.createLink(controller: 'project', id: projectId)
            model.autocompleteUrl = "${request.contextPath}/search/searchSpecies/${pActivity.projectActivityId}?limit=10"

            addOutputModel(model)
            addConfigToOutputModels(pActivity, model)
        }

        model
    }

    /**
     * Some view models can accept additional configuration options, based on the config of the Project Activity.
     *
     * For example, the Sightings model (from the {@value #BIOCOLLECT_SIGHTINGS_PLUGIN_NAME}) allows the map section to
     * be configured based on the location constraints in the Project Activity.
     *
     */
    private static addConfigToOutputModels(Map pActivity, Map model) {
        model?.outputModels?.each { String name, Map outputModel ->
            outputModel?.viewModel?.each { Map viewModel ->
                if (viewModel.plugin == BIOCOLLECT_SIGHTINGS_PLUGIN_NAME) {
                    if (!viewModel.config) {
                        viewModel.config = [:]
                    }
                    viewModel.config.allowGeospatialSpeciesSuggestion = !(pActivity?.species?.speciesLists || pActivity?.species?.singleSpecies)
                }
            }
        }
    }

    /**
     * View Activity Survey Details.
     * @param id activity id
     * @return
     */
    def index(String id) {
        def activity = activityService.get(id)
        def pActivity = projectActivityService.get(activity?.projectActivityId, "all")

        if (activity && pActivity) {
            Map model = activityAndOutputModel(activity, activity.projectId)
            model.pActivity = pActivity
            model.id = pActivity.projectActivityId
            model
        } else {
            forward(action: 'list', model: [error: 'no such id'])
        }
    }

    /**
     * List all activity associated to the user based on their role.
     * @param id activity id
     * @return
     */
    def list() {

    }

    def ajaxList() {
        render listUserActivities(params) as JSON
    }

    def ajaxListForProject(String id){

        def model = [:]
        def query = [pageSize: params.max ?: 10,
                     offset: params.offset ?: 0,
                     sort: params.sort ?: 'lastUpdated',
                     order: params.order ?: 'desc']
        def results = activityService.activitiesForProject(id, query)
        results?.activities?.each{
            it.pActivity = projectActivityService.get(it.projectActivityId)
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
        results?.activities?.each {
            it.pActivity = projectActivityService.get(it.projectActivityId)
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
                log.debug(result)
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

    private Map activityModel(activity, projectId) {
        Map model = [activity: activity, returnTo: params.returnTo]
        model.site = model.activity?.siteId ? siteService.get(model.activity.siteId, [view: 'brief']) : null
        model.mapFeatures = model.site ? siteService.getMapFeatures(model.site) : []
        model.project = projectId ? projectService.get(model.activity.projectId) : null

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

        model.speciesGroupsMap = bieService.getSpeciesGroupsMap()
        model.user = userService.getUser()

        model
    }

    private Map activityAndOutputModel(activity, projectId) {
        def model = activityModel(activity, projectId)
        addOutputModel(model)

        model
    }

    def addOutputModel(model) {
        model.metaModel = metadataService.getActivityModel(model.activity.type)
        model.outputModels = model.metaModel?.outputs?.collectEntries {
            [it, metadataService.getDataModelFromOutputName(it)]
        }
    }
}
