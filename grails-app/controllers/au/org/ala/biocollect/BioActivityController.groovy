package au.org.ala.biocollect

import org.codehaus.groovy.grails.web.json.JSONArray

class BioActivityController {

    def activityModel, projectService, metadataService, siteService, projectActivityService, userService

    private Map activityModel(activity, projectId) {
        // pass the activity
        def model = [activity: activity, returnTo: params.returnTo]

        // the site
        model.site = model.activity?.siteId ? siteService.get(model.activity.siteId, [view:'brief']) : null
        model.mapFeatures = model.site ? siteService.getMapFeatures(model.site) : []

        // the project
        model.project = projectId ? projectService.get(model.activity.projectId) : null

        // Add the species lists that are relevant to this activity.
        model.speciesLists = new JSONArray()
        if (model.project) {
            model.project.speciesLists?.each { list ->
                if (list.purpose == activity.type) {
                    model.speciesLists.add(list)
                }
            }
        }
        model
    }

    private Map activityAndOutputModel(activity, projectId) {
        def model = activityModel(activity, projectId)
        addOutputModel(model)
        model
    }

    def addOutputModel(model) {
        // the activity meta-model
        model.metaModel = metadataService.getActivityModel(model.activity.type)
        // the array of output models
        model.outputModels = model.metaModel?.outputs?.collectEntries {
            [ it, metadataService.getDataModelFromOutputName(it)] }

    }

    def create(String id) {
        def userId = userService.getCurrentUserId()
        def pActivity = projectActivityService.get(id, "docs")
        def projectId = pActivity?.projectId

        if (!projectService.canUserEditProject(userId, projectId)) {
            flash.message = "Access denied: User does not have <b>editor</b> permission for projectId ${projectId}"
            redirect(controller:'project', action:'index', id: projectId)
            return
        }

        def type = pActivity?.pActivityFormName
        def siteId = null
        def activity = [activityId: "", siteId: siteId, projectId: projectId]
        def model = activityModel(activity, projectId)
        model.pActivity = pActivity
        model.create = true

        if (!type) {
            def availableTypes = projectService.activityTypesList(projectId)
            model.activityTypes = availableTypes
            def activityCount = availableTypes.collect {it.list}.flatten().size()
            if (activityCount == 1) {
                type = availableTypes[0].list[0].name
            }
        }
        if (type) {
            activity.type = type
            model.returnTo = g.createLink(controller:'project', id:projectId)
            addOutputModel(model)
        }

        render model:model, view:activity.type?'create':'create'
    }
}
