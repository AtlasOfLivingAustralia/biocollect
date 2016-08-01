package au.org.ala.biocollect.merit

import au.org.ala.biocollect.ProjectActivityService
import grails.converters.JSON
import org.apache.poi.ss.usermodel.Workbook
import org.apache.poi.ss.usermodel.WorkbookFactory
import org.apache.poi.ss.util.CellReference
import org.codehaus.groovy.grails.web.json.JSONArray
import org.grails.plugins.excelimport.ExcelImportService

class ActivityController {

    ActivityService activityService
    SiteService siteService
    ProjectService projectService
    MetadataService metadataService
    UserService userService
    ExcelImportService excelImportService
    WebService webService
    def grailsApplication
    SpeciesService speciesService
    DocumentService documentService
    ProjectActivityService projectActivityService


    static ignore = ['action','controller','id']

    private Map activityModel(activity, projectId) {
        // pass the activity
        def model = [activity: activity, returnTo: params.returnTo, projectStages:projectStages()]

        // the site
        model.site = model.activity?.siteId ? siteService.get(model.activity.siteId, [view:'brief']) : null
        model.mapFeatures = model.site ? siteService.getMapFeatures(model.site) : "{}"

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
            model.themes = metadataService.getThemesForProject(model.project)
        }

        model.user = userService.getUser()

        model
    }

    private Map activityAndOutputModel(activity, projectId) {
        def model = activityModel(activity, projectId)
        addOutputModel(model)
        addProjectActivity(model,activity)
        model
    }

    void addProjectActivity(model, activity){
        if(activity.projectActivityId){
            model.projectActivity = projectActivityService.get(activity.projectActivityId);
        }
    }

    def addOutputModel(model) {
        // the activity meta-model
        model.metaModel = metadataService.getActivityModel(model.activity.type)
        // the array of output models
        model.outputModels = model.metaModel?.outputs?.collectEntries {
            [ it, metadataService.getDataModelFromOutputName(it)] }

    }

    def index(String id) {
        def activity = activityService.get(id)
        if (activity) {
            // permissions check  - can't use annotation as we have to know the projectId in order to redirect to the right page
            if (!projectService.canUserViewProject(userService.getCurrentUserId(), activity.projectId)) {
                flash.message = "Access denied: User does not have <b>editor</b> permission for projectId ${activity.projectId}"
                redirect(controller:'project', action:'index', id: activity.projectId)
            }

            activityAndOutputModel(activity, activity.projectId)
        } else {
            forward(action: 'list', model: [error: 'no such id'])
        }
    }

    /**
     * A page that simply edits the activity data.
     * @param id activity id
     */
    def edit(String id) {
        def activity = activityService.get(id)
        if (activity) {
            // permissions check
            def userId = userService.getCurrentUserId()
            if (!projectService.canUserEditProject(userId, activity.projectId)) {

                if (projectService.canUserViewProject(userId, activity.projectId)) {
                    chain(action:'index', id:id, model:[editInMerit:true])
                    return
                }

                flash.message = "Access denied: User does not have <b>editor</b> permission for projectId ${activity.projectId}"
                redirect(controller:'project', action:'index', id: activity.projectId)
                return
            }
            else if (activity.publicationStatus == 'published' || activity.publicationStatus == 'pendingApproval') {
                chain(action:'index', id:id)
                return
            }
            def model = activityModel(activity, activity.projectId)

            model.activityTypes = metadataService.activityTypesList()
            model.hasPhotopointData = activity.documents?.find {it.poiId}
            model
        } else {
            forward(action: 'list', model: [error: 'no such id'])
        }
    }

    /**
     * A page for entering output data for an activity. Limited activity data can also be updated.
     * @param id activity id
     */
    def enterData(String id) {
        def activity = activityService.get(id)
        if (activity) {
            // permissions check
            def userId = userService.getCurrentUserId()
            if (!projectService.canUserEditProject(userId, activity.projectId)) {

                if (projectService.canUserViewProject(userId, activity.projectId)) {
                    chain(action:'index', id:id,  model:[editInMerit: true])
                    return
                }

                flash.message = "Access denied: User does not have <b>editor</b> permission for projectId ${activity.projectId}"
                redirect(controller:'project', action:'index', id: activity.projectId)
            }
            else if (activity.publicationStatus == 'published' || activity.publicationStatus == 'pendingApproval') {
                chain(action:'index', id:id)
                return
            }
            // pass the activity
            if (params.progress) {
                activity.progress = params.progress
            }

            activityAndOutputModel(activity, activity.projectId)

        } else {
            forward(action: 'list', model: [error: 'no such id'])
        }
    }

    def print(String id) {
        def activity = activityService.get(id)
        if (activity) {
            // permissions check
            if (!projectService.canUserViewProject(userService.getCurrentUserId(), activity.projectId)) {
                flash.message = "Access denied: User does not have <b>editor</b> permission for projectId ${activity.projectId}"
                redirect(controller:'project', action:'index', id: activity.projectId)
            }
            // pass the activity
            def model = activityAndOutputModel(activity, activity.projectId)
            model.printView = true
            render view: 'enterData', model: model
        } else {
            forward(action: 'list', model: [error: 'no such id'])
        }

    }


    /**
     * Displays page(s) to create an activity.
     */
    @PreAuthorise(projectIdParam = 'projectId')
    def create(String siteId, String projectId, String type) {

        def activity = [activityId: "", siteId: siteId, projectId: projectId]
        def model = activityModel(activity, projectId)
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


        render model:model, view:activity.type?'enterData':'create'
    }

    /**
     * Displays page to create an activity in planning mode.
     *
     * Depending on where this is called from, either the site or the project or neither is known.
     * If neither is known, then the full list of projects and sites is injected for selection.
     * If project is known (created from a project page) then the list of sites associated with
     * that project is injected. The project cannot be changed.
     * If the site is known (created from a site page) then the list of projects associated with
     * that site is injected. The site cannot be changed.
     *
     * @param siteId may be null
     * @param projectId may be null
     * @return
     */
    @PreAuthorise(projectIdParam = 'projectId')
    def createPlan(String siteId, String projectId) {
        def activity = [activityId: "", siteId: siteId, projectId: projectId]
        def model = [activity: activity, returnTo: params.returnTo, create: true,
                     projectStages:projectStages()]
        model.project = projectId ? projectService.get(projectId) : null
        model.activityTypes = metadataService.activityTypesList(model.project.associatedProgram)
        model.site = siteId ? siteService.get(siteId) : null
        if (projectId) {
            model.themes = metadataService.getThemesForProject(model.project)
        }
        if (!model.project && !model.site) {
            model.sites = siteService.list().collect({[name:it.name,siteId:it.siteId]})
            model.projects = projectService.list().collect({[name:it.name,projectId:it.projectId]})
        }
        model
    }

    /**
     * Updates existing or creates new activity.
     *
     * Also updates/creates any outputs that are passed in the 'outputs' property of the activity.
     * For updates, the activity itself is optional, ie the payload may simply be a list of outputs
     * to update/create.
     *
     * If id is blank, a new activity will be created and added to the site. Outputs are ignored
     * in this case.
     *
     * @param id activityId - may be null or blank
     * @return
     */
    def ajaxUpdate(String id) {
        def postBody = request.JSON
        if (!id) {
            id = postBody.remove('activityId')
            if (!id) {id=''}
        }
        //log.debug "Body: " + postBody
        //log.debug "Params:"
        //params.each { log.debug it }

        def values = [:]
        // filter params to remove keys in the ignore list - MEW don't know if this is required
        postBody.each { k, v ->
            if (!(k in ignore)) {
                values[k] = v
            }
        }
        log.debug (values as JSON).toString()

        def result = [:]

        def projectId
        if (id) {
            def activity = activityService.get(id)
            projectId = activity.projectId
        }
        else {
            projectId = values.projectId
        }
        if (!projectId) {
            response.status = 400
            flash.message = "No project id supplied for activity: ${id}"
            result = [status: 400, error: flash.message]
        }

        // check user has permissions to edit/update site - user must have 'editor' access to
        // ALL linked projects to proceed.
        if (!projectService.canUserEditProject(userService.getCurrentUserId(), projectId)) {
            flash.message = "Error: access denied: User does not have <b>editor</b> permission for projectId ${projectId}"
            response.status = 401
            result = [status:401, error: flash.message]
            //render result as JSON
        }

        if (!result) {
            def photoPoints = values.remove('photoPoints')
            result = activityService.update(id, values)
            if (photoPoints) {
                updatePhotoPoints(id ?: result.activityId, photoPoints)
            }

        }
        //log.debug "result is " + result

        if (result.error) {
            render result as JSON
        } else {
            //log.debug "json result is " + (result as JSON)
            render result.resp as JSON
        }
    }

    private def updatePhotoPoints(activityId, photoPoints) {

        def allPhotos = photoPoints.photos?:[]

        // If new photo points were defined, add them to the site.
        if (photoPoints.photoPoints) {
            photoPoints.photoPoints.each { photoPoint ->
                def photos = photoPoint.remove('photos')
                def result = siteService.addPhotoPoint(photoPoints.siteId, photoPoint)

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

    def delete(String id) {
        log.debug "deleting ${id}"
        def respCode = activityService.delete(id)
        if (params.returnTo) {
            redirect(url: params.returnTo)
        } else {
            redirect(controller: 'home')
        }
    }

    def ajaxDelete(String id) {
        log.debug "deleting ${id}"
        def respCode = activityService.delete(id)
        def resp = [code: respCode.toString()]
        //log.debug "response = ${resp}"
        render resp as JSON
    }

    def list() {
        // will show a list of activities
        // but for now just go home
        log.debug('redirecting to home')
        redirect(controller: 'home')
    }

    def projectStages() {
        return ["Stage 1", "Stage 2", "Stage 3", "Stage 4", "Stage 5", "Stage 6", "Stage 7", "Stage 8", "Stage 9", "Stage 10"]
    }

    /* Parse the xlsx output data and pass it back to the client. */
    def ajaxBulkUpload(){
        if (request.respondsTo('getFile')) {
            def file = request.getFile('templateFile')
            if (file) {
                def activityType = params.type
                def activityModel = metadataService.activitiesModel().activities.find { it.name == activityType }
                def outputModels = activityModel.outputs.collect { metadataService.annotatedOutputDataModel(it) }

                int index = 0;
                def columnMap = [:]
                columnMap << [(CellReference.convertNumToColString(index++)):"grantId"]
                columnMap << [(CellReference.convertNumToColString(index++)):"projectName"]
                outputModels.collectEntries { entry ->
                    entry.each{
                        def colString = CellReference.convertNumToColString(index++)
                        columnMap << [(colString):it.name]
                    }
                }

                def config = [
                        sheet:"${activityModel?.outputs?.first()}",
                        startRow:1,
                        columnMap:columnMap
                ]
                Workbook workbook = WorkbookFactory.create(file.inputStream)
                def data = excelImportService.convertColumnMapConfigManyRows(workbook, config)
                def result
                if (!data) {
                    response.status = 400
                    result = [status:400, error:'No data was found that matched the columns in this table, please check the template you used to upload the data. ']
                }
                else {
                    result = [status: 200, data:data]
                }

                // This is returned to the browswer as a text response due to workaround the warning
                // displayed by IE8/9 when JSON is returned from an iframe submit.
                response.setContentType('text/plain;charset=UTF8')
                def resultJson = result as JSON
                render resultJson.toString()
            }
        }
        else {
            response.status = 400
            def result = [status: 400, error:'No file attachment found']
            // This is returned to the browswer as a text response due to workaround the warning
            // displayed by IE8/9 when JSON is returned from an iframe submit.
            response.setContentType('text/plain;charset=UTF8')
            def resultJson = result as JSON
            render resultJson.toString()
        }

    }

    def ajaxUpload() {
        if (request.respondsTo('getFile')) {
            def file = request.getFile('data')
            if (file) {

                def outputName = params.type
                def listName = params.listName

                def model = metadataService.annotatedOutputDataModel(outputName)
                if (listName) {
                    model = model.find { it.name == listName }?.columns
                }
                int index = 0;
                def columnMap = model.collectEntries {
                    def colString = CellReference.convertNumToColString(index++)
                    [(colString):it.name]
                }
                def config = [
                        sheet:sheetNameFromOutput(outputName),
                        startRow:1,
                        columnMap:columnMap
                ]
                Workbook workbook = WorkbookFactory.create(file.inputStream)

                def data = excelImportService.convertColumnMapConfigManyRows(workbook, config)

                // Do species lookup
                def species = model.find {it.dataType == 'species'}
                if (species) {
                    data.each { row ->
                        def scientificName = row[species.name]

                        def result = speciesService.searchByScientificName(scientificName)
                        if (result) {
                            row[species.name] = [name:result.name, listId:result.listId, guid:result.guid]
                        }
                        else {
                            row[species.name] = [name:scientificName, listId:'unmatched', guid:null]
                        }

                    }
                }

                def result
                if (!data) {
                    response.status = 400
                    result = [status:400, error:'No data was found that matched the columns in this table, please check the template you used to upload the data. ']
                }
                else {
                    result = [status: 200, data:data]
                }

                // This is returned to the browswer as a text response due to workaround the warning
                // displayed by IE8/9 when JSON is returned from an iframe submit.
                response.setContentType('text/plain;charset=UTF8')
                def resultJson = result as JSON
                render resultJson.toString()
            }
        }
        else {
            response.status = 400
            def result = [status: 400, error:'No file attachment found']
            // This is returned to the browswer as a text response due to workaround the warning
            // displayed by IE8/9 when JSON is returned from an iframe submit.

            response.setContentType('text/plain;charset=UTF8')
            def resultJson = result as JSON
            render resultJson.toString()
        }
    }

    static final int MAX_SHEET_NAME_LENGTH = 31
    private String sheetNameFromOutput(outputName) {
        def end = Math.min(outputName.length(), MAX_SHEET_NAME_LENGTH)-1
        def shortName = outputName[0..end]
        shortName = shortName.replaceAll('[^a-zA-z0-9 ]', '')

        shortName
    }
}
