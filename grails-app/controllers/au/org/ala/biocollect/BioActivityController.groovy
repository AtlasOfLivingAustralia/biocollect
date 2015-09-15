package au.org.ala.biocollect

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONArray

class BioActivityController {

    def activityModel, projectService, metadataService, siteService, projectActivityService, userService, documentService, activityService

    /**
     * Update Activity by activityId or
     * Create Activity by projectActivity
     * @param id activity id
     * @param pActivityId project activity Id
     * @return
     */
    def ajaxUpdate(String id, String pActivityId){
        def postBody = request.JSON
        def activity, pActivity, projectId
        id = id?:''

        if(id){
            activity = activityService.get(id)
            projectId = activity?.projectId
            pActivity = projectActivityService.get(activity?.projectActivityId)
        }else if(pActivityId){
            pActivity = projectActivityService.get(pActivityId)
            projectId = activity?.projectId
        }

        // Check user has admin/editor permission.
        def userId = userService.getCurrentUserId()
        def result = [:]
        if (!activity && !projectService.canUserEditProject(userId, projectId, false)) {
            flash.message = "Access denied: User does not have <b>editor</b> permission for projectId ${projectId}"
            response.status = 401
            result = [status:401, error: flash.message]
        }else if(activity && !projectService.canUserEditActivity(userId, activity)){
            flash.message = "Access denied: User is not an owner of this activity ${activity?.activityId}"
            response.status = 401
            result = [status:401, error: flash.message]
        }else{
            def photoPoints = postBody.remove('photoPoints')
            postBody.projectActivityId = pActivity.projectActivityId
            postBody.userId = userId
            result = activityService.update(id, postBody)
            def activityId = id ?: result?.resp?.activityId
            if (photoPoints && activityId) {
                updatePhotoPoints(activityId, photoPoints)
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
    def edit(String id){

        def activity = activityService.get(id)
        def projectId = activity?.projectId
        def model
        if (!activity) {
            flash.message = "Invalid activity - ${id}"
            redirect(controller:'project', action:'index', id: projectId)
        }else if(!projectService.canUserEditActivity(userService.getCurrentUserId(), activity)){
            flash.message = "Access denied: User is not an owner of this activity ${activity?.activityId}"
            redirect(controller:'project', action:'index', id: projectId)
        }else{
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

        def userId = userService.getCurrentUserId()
        def pActivity = projectActivityService.get(id, "all")
        def projectId = pActivity?.projectId
        def type = pActivity?.pActivityFormName
        def model

        if (!projectService.canUserEditProject(userId, projectId, false)) {
            flash.message = "Access denied: User does not have <b>editor</b> permission for projectId ${projectId}"
            redirect(controller:'project', action:'index', id: projectId)
        }else if(!type){
            flash.message = "Invalid activity type"
            redirect(controller:'project', action:'index', id: projectId)
        }else{
            def activity = [activityId: '', siteId: '', projectId: projectId, type: type]
            model = activityModel(activity, projectId)
            model.pActivity = pActivity
            model.returnTo = g.createLink(controller:'project', id:projectId)
            addOutputModel(model)
        }

        model
    }

    /**
     * View Activity Survey Details.
     * @param id activity id
     * @return
     */
    def index(String id){

        def activity = activityService.get(id)
        def pActivity =  projectActivityService.get(activity?.projectActivityId, "all")

        if (activity && pActivity) {
            def model = activityAndOutputModel(activity, activity.projectId)
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
    def list(String filter){
        def model = [:]
        def activities = activityService.activitiesForUser(userService.getCurrentUserId())
        activities?.each{
            it.pActivity = projectActivityService.get(it.projectActivityId)
        }
        model.activities = activities
        model.displayName = userService.getCurrentUserDisplayName()
        model
    }


    private def updatePhotoPoints(activityId, photoPoints) {

        def allPhotos = photoPoints.photos?:[]

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

        def model = [activity: activity, returnTo: params.returnTo]
        model.site = model.activity?.siteId ? siteService.get(model.activity.siteId, [view:'brief']) : null
        model.mapFeatures = model.site ? siteService.getMapFeatures(model.site) : []
        model.project = projectId ? projectService.get(model.activity.projectId) : null

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
            [ it, metadataService.getDataModelFromOutputName(it)]
        }
    }

}
