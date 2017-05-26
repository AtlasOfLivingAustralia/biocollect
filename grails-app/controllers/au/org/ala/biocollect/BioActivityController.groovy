package au.org.ala.biocollect

import au.org.ala.biocollect.merit.*
import grails.converters.JSON
import groovyx.net.http.ContentType
import org.apache.commons.io.FilenameUtils
import org.codehaus.groovy.grails.web.json.JSONArray
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import org.springframework.context.MessageSource
import org.springframework.web.multipart.MultipartFile

import static org.apache.http.HttpStatus.SC_BAD_REQUEST
import static org.apache.http.HttpStatus.SC_OK

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

    static int MAX_FLIMIT = 500

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

        String userId = userService.getCurrentUserId(request)
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
    def create(String id) {
        Map model = addActivity(id)
        model?.title = messageSource.getMessage('record.create.title', [].toArray(), '', Locale.default)

        model
    }

    /**
     * Edit activity for the given activityId
     * Project Site Admin / activity owner can edit the activity
     * @param id activity id
     * @return
     */
    def edit(String id) {
        Map model = editActivity(id)
        model?.title = messageSource.getMessage('record.edit.title', [].toArray(), '', Locale.default)
        model
    }

    def mobileCreate(String id) {
        Map model = addActivity(id, true)
        model.mobile = true
        model.userName = request.getHeader(UserService.USER_NAME_HEADER_FIELD)
        model.authKey = request.getHeader(UserService.AUTH_KEY_HEADER_FIELD)
        render (view: 'create', model: model)
    }

    def mobileEdit(String id) {
        Map model = editActivity(id, true)
        model.mobile = true
        model.userName = request.getHeader(UserService.USER_NAME_HEADER_FIELD)
        model.authKey = request.getHeader(UserService.AUTH_KEY_HEADER_FIELD)
        render (view: 'edit', model: model)
    }

    private def addActivity(String id, boolean mobile = false) {
        String userId = userService.getCurrentUserId(request)
        Map pActivity = projectActivityService.get(id, "all")
        String projectId = pActivity?.projectId
        String type = pActivity?.pActivityFormName
        Map model = [:]

        if (!pActivity.publicAccess && !projectService.canUserEditProject(userId, projectId, false)) {
            flash.message = "Access denied: User does not have <b>editor</b> permission for projectId ${projectId}"
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
            model.projectName = project.name
            model.returnTo = params.returnTo ? params.returnTo : g.createLink(controller: 'project', id: projectId)
            model.autocompleteUrl = "${request.contextPath}/search/searchSpecies/${pActivity.projectActivityId}?limit=10"
            addOutputModel(model)
            model.defaultData = metadataService.getDefaultData(model.outputModels)

            // added to override default values. This will enable pre-populating values in fields like species
            // whereby passing taxon id will populate species field value. for example, look at action preFillSpeciesName
            // on this controller.
            if(params.overrideDefaultData){
                model.defaultData = model.defaultData ?: [:]
                model.defaultData.putAll(params.overrideDefaultData);
            }
        }

        if (mobile && flash.message) {
            model?.error = flash.message
        }

        model
    }

    private editActivity(String id, boolean mobile = false){
        String userId = userService.getCurrentUserId(request)
        def activity = activityService.get(id)
        String projectId = activity?.projectId
        def model = [:]

        if (!userId) {
            flash.message = "Access denied: User has not been authenticated."
            if(!mobile) redirect(controller: 'project', action: 'index', id: projectId)
        } else if (!activity) {
            flash.message = "Invalid activity - ${id}"
            if(!mobile)  redirect(controller: 'project', action: 'index', id: projectId)
        } else if (projectService.isUserAdminForProject(userId, projectId) || activityService.isUserOwnerForActivity(userId, activity?.activityId)) {
            def pActivity = projectActivityService.get(activity?.projectActivityId, "all")
            model = activityAndOutputModel(activity, activity.projectId)
            model.pActivity = pActivity
            model.projectActivityId = pActivity.projectActivityId
            model.id = id
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
    def delete(String id) {
        def activity = activityService.get(id)
        String userId = userService.getCurrentUserId()

        Map result

        if (!userId) {
            response.status = 401
            result = [status: 401, error: "Access denied: User has not been authenticated."]
        } else if (projectService.isUserAdminForProject(userId, activity?.projectId) || activityService.isUserOwnerForActivity(userId, activity?.activityId)) {
            def resp = activityService.delete(id)
            if (resp == SC_OK) {
                result = [status: resp, text: 'deleted']
            } else {
                response.status = resp
                result = [status: resp, error: "Error deleting the survey, please try again later."]
            }
        } else {
            response.status = 401
            result = [status: 401, error: "Access denied: User is not an admin or owner of this activity - ${id}"]
        }

        render result as JSON
    }

    /**
     * View Activity Survey Details.
     * @param id activity id
     * @return
     */
    def index(String id) {
        def activity = activityService.get(id, params?.version)
        def pActivity = projectActivityService.get(activity?.projectActivityId, "all", params?.version)

        String userId = userService.getCurrentUserId()

        boolean embargoed = projectActivityService.isEmbargoed(pActivity)
        boolean userIsOwner = userId && activityService.isUserOwnerForActivity(userId, id)
        boolean userIsAdmin = userId && projectService.isUserAdminForProject(userId, id)
        boolean userIsAlaAdmin = userService.userIsAlaOrFcAdmin()

        if (activity && pActivity) {
            if (embargoed && !userIsAdmin && !userIsOwner && !userIsAlaAdmin) {
                flash.message = "Access denied: You do not have permission to access the requested resource."
                redirect(controller: 'project', action: 'index', id: activity.projectId)
            } else {
                Map model = activityAndOutputModel(activity, activity.projectId, 'view', params?.version)
                model.pActivity = pActivity
                model.id = pActivity.projectActivityId
                params.mobile ? model.mobile = true : ''
                model

            }
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
        render(view: 'list',
                model: [
                        view: 'myrecords',
                        user: userService.user,
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
        render(view: 'list',
                model: [
                        view: 'allrecords',
                        title: messageSource.getMessage('allrecords.title', [].toArray(), '', Locale.default),
                        returnTo: g.createLink(controller: 'bioActivity', action: 'allRecords')
                ]
        )
    }

    /**
     * List all activity associated to a project.
     * @param id activity id
     * @return
     */
    def projectRecords(String id) {
        render(view: 'list',
                model: [
                        view: 'projectrecords',
                        projectId: id,
                        title: messageSource.getMessage('project.records.title', [].toArray(), '', Locale.default),
                        returnTo: g.createLink(controller: 'bioActivity', action: 'projectRecords') + '/' + id,
                        doNotStoreFacetFilters: true
                ]
        )
    }

    /**
     * List all activity associated to a project by a user.
     * @param id activity id
     * @return
     */
    def myProjectRecords(String id) {
        if(userService.user){
            render(view: 'list',
                    model: [
                            view: 'myprojectrecords',
                            user:  userService.user,
                            projectId: id,
                            title: messageSource.getMessage('project.myrecords.title', [].toArray(), '', Locale.default),
                            returnTo: g.createLink(controller: 'bioActivity', action: 'myProjectRecords') + '/' + id,
                            doNotStoreFacetFilters: true
                    ]
            )
        } else {
            flash.message = "You need to be logged in to view your records"
            forward(action: 'projectRecords', params: params)
        }
    }

    def ajaxList() {
        render listUserActivities(params) as JSON
    }

    def downloadProjectData() {
        response.setContentType(ContentType.BINARY.toString())
        response.setHeader('Content-Disposition', 'Attachment;Filename="data.zip"')

        Map queryParams = constructDefaultSearchParams(params)
        queryParams.isMerit = false
        searchService.downloadProjectData(response, queryParams)
    }

    private GrailsParameterMap constructDefaultSearchParams(Map params) {
        GrailsParameterMap queryParams = new GrailsParameterMap([:], request)
        Map parsed = commonService.parseParams(params)
        parsed.userId = userService.getCurrentUserId(parsed.mobile ? request : null)

        if (params?.hub == 'ecoscience') {
            queryParams.searchTerm = (queryParams?.searchTerm ? queryParams.searchTerm + ' AND ' : '') + "projectActivity.projectType:ecoscience"
        }

        if (params?.hub == 'works') {
            queryParams.searchTerm = (queryParams?.searchTerm ? queryParams.searchTerm + ' AND ' : '') + "projectActivity.projectType:works"
        }

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
        queryParams.searchTerm = queryParams.searchTerm ?: ''

        if(!queryParams.facets){
            String facets = "projectNameFacet,organisationNameFacet,projectActivityNameFacet,recordNameFacet,activityOwnerNameFacet,embargoedFacet,activityLastUpdatedMonthFacet,activityLastUpdatedYearFacet"

            switch (params.view) {

                case 'myrecords':
                    facets = "projectNameFacet,organisationNameFacet,projectActivityNameFacet,recordNameFacet,embargoedFacet,activityLastUpdatedMonthFacet,activityLastUpdatedYearFacet"
                    break

                case 'project':
                    facets = "projectActivityNameFacet,recordNameFacet,activityOwnerNameFacet,embargoedFacet,activityLastUpdatedMonthFacet,activityLastUpdatedYearFacet"
                    break

                case 'projectrecords':
                    facets = "projectActivityNameFacet,recordNameFacet,activityOwnerNameFacet,embargoedFacet,activityLastUpdatedMonthFacet,activityLastUpdatedYearFacet"
                    break

                case 'myprojectrecords':
                    facets = "projectActivityNameFacet,recordNameFacet,embargoedFacet,activityLastUpdatedMonthFacet,activityLastUpdatedYearFacet"
                    break

                case 'allrecords':
                default:
                    break
            }

            queryParams.facets = facets
        }

        queryParams
    }

    /*
     * Search project activities and records
     */

    def searchProjectActivities() {
//        long startTime = System.currentTimeMillis()

        GrailsParameterMap queryParams = constructDefaultSearchParams(params)

        Map searchResult = searchService.searchProjectActivity(queryParams)

//        long searchStarttime = System.currentTimeMillis()
//        long searchTime = searchStarttime - startTime

        List activities = searchResult?.hits?.hits
        List facets = []
        activities = activities?.collect {
            Map doc = it._source

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
                                        (queryParams.userId && doc.projectId && (projectService.isUserAdminForProject(queryParams.userId, doc.projectId)))

            ]
            result
        }

//        long permissionCheckTime = System.currentTimeMillis() - searchStarttime

        if(queryParams.facets){
            String[] facetList = queryParams.facets.split(',')
            facets = searchService.standardiseFacets (searchResult.facets, Arrays.asList(facetList))
        }

        facets = projectActivityService.getDisplayNamesForFacets(facets);
        render([activities: activities, facets: facets, total: searchResult.hits?.total ?: 0] as JSON)

//        long totalTime = System.currentTimeMillis() - startTime
//
//        log.debug ("Activities: ${activities?.size()} ")
//        log.debug ("Total time: ${totalTime}ms")
//        log.debug ("Search time: ${searchTime}ms")
//        log.debug ("Permission time: ${permissionCheckTime}ms")

    }

    /**
     * map points are generated from this function. It requires some client side code to convert the output of this
     * function to points.
     */
    def getProjectActivitiesRecordsForMapping() {
//        long startTime = System.currentTimeMillis()

        GrailsParameterMap queryParams = new GrailsParameterMap([:], request)
        Map parsed = commonService.parseParams(params)
        parsed.userId = userService.getCurrentUserId()
        parsed.each { key, value ->
            if (value != null && value) {
                queryParams.put(key, value)
            }
        }

        if (params?.hub == 'ecoscience') {
            queryParams.searchTerm = (queryParams?.searchTerm ? queryParams.searchTerm + ' AND ' : '') + "projectActivity.projectType:ecoscience"
        }

        if (params?.hub == 'works') {
            queryParams.searchTerm = (queryParams?.searchTerm ? queryParams.searchTerm + ' AND ' : '') + "projectActivity.projectType:works"
        }

        queryParams.max = queryParams.max ?: 10
        queryParams.offset = queryParams.offset ?: 0
        queryParams.flimit = queryParams.flimit ?: 20
        queryParams.sort = queryParams.sort ?: 'lastUpdated'
        queryParams.order = queryParams.order ?: 'DESC'
        queryParams.fq = queryParams.fq ?: ''
        queryParams.searchTerm = queryParams.searchTerm ?: ''
        queryParams.view = queryParams.view

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

        render([activities: activities, total: searchResult.hits?.total ?: activities.size()] as JSON)

//        long totalTime = System.currentTimeMillis() - startTime
//        log.debug("getProjectActivitiesRecordsForMapping time ${totalTime}ms")
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

    private Map activityModel(activity, projectId, mode = '', version = null) {
        Map model = [activity: activity, returnTo: params.returnTo, mode: mode]
        model.site = model.activity?.siteId ? siteService.get(model.activity.siteId, [view: 'brief', version: version]) : null
         model.project = projectId ? projectService.get(model.activity.projectId, version) : null
        model.projectSite = model.project.sites?.find { it.siteId == model.project.projectSiteId }

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

    private Map activityAndOutputModel(activity, projectId, mode = '', version = null) {
        def model = activityModel(activity, projectId, mode, version)
        addOutputModel(model)

        model
    }

    def addOutputModel(model) {
        model.metaModel = metadataService.getActivityModel(model.activity.type)
        model.outputModels = model.metaModel?.outputs?.collectEntries {
            [it, metadataService.getDataModelFromOutputName(it)]
        }
    }

    def defaultData

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

                // This is returned to the browswer as a text response due to workaround the warning
                // displayed by IE8/9 when JSON is returned from an iframe submit.
                response.setContentType('text/plain;charset=UTF8')
                def resultJson = result as JSON
                render resultJson.toString()
            }
        } else {
            response.status = SC_BAD_REQUEST
            result = [status: SC_BAD_REQUEST, error: 'No file attachment found']
            // This is returned to the browswer as a text response due to workaround the warning
            // displayed by IE8/9 when JSON is returned from an iframe submit.

            response.setContentType('text/plain;charset=UTF8')
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
    def getOutputForActivity(String id){
        String userId = userService.getCurrentUserId(request)
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

    /*
     * Get activity model for a survey/projectActivity
     * Handles both session and non session based request.
     *
     * @param id projectActivityId
     *
     * @return activity model
     *
     */
    def getActivityModel(String id){
        String userId = userService.getCurrentUserId(request)
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
                model.autocompleteUrl = "${request.contextPath}/search/searchSpecies/${pActivity.projectActivityId}?limit=10"

                addOutputModel(model)
            }
        } else {
            model.error = "Invalid user"
        }

        render model as JSON
    }

    /**
     * This controller is used to pre-fill the species details if a taxon id is passed in the url.
     * @return
     */
    public preFillSpeciesName(){
        if(params.taxonId){
            String pActivity = grailsApplication.config.individualSightings.pActivity,
                speciesModelName = grailsApplication.config.individualSightings.dataTypeName,
                hub = grailsApplication.config.individualSightings.hub,
                output = grailsApplication.config.individualSightings.outputName,
                speciesDisplayFormat;

            Map species = [:]
            Map result = speciesService.getSpeciesDetailsForTaxonId(params.taxonId, false);
            Map pActivityDetails = projectActivityService.get(pActivity)
            if(!pActivityDetails.error){
                Map speciesConfig = projectActivityService.getSpeciesConfigForProjectActivity(pActivityDetails, output, speciesModelName)
                speciesDisplayFormat = speciesConfig?.speciesDisplayFormat
            }

            species.scientificName = result?.scientificName
            species.commonName = result.commonName
            species.guid = params.taxonId
            species.name = projectActivityService.formatSpeciesName(speciesDisplayFormat?:'SCIENTIFICNAME(COMMONNAME)', species)

            params.id = pActivity
            params.hub = hub
            params.overrideDefaultData = [ : ]
            params.overrideDefaultData[speciesModelName] = species

            forward(action: 'create')
        } else {
            render status: SC_BAD_REQUEST, text: "You need to provide taxon id"
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
}
