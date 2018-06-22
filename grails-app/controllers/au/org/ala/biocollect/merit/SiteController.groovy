package au.org.ala.biocollect.merit

import au.org.ala.web.AuthService
import grails.converters.JSON
import org.apache.commons.lang.StringUtils
import org.apache.http.HttpStatus
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap

import static javax.servlet.http.HttpServletResponse.SC_CONFLICT
import static javax.servlet.http.HttpServletResponse.SC_NO_CONTENT


class SiteController {

    def siteService, projectService, projectActivityService, activityService, metadataService, userService,
            searchService, importService, webService

    AuthService authService
    CommonService commonService

    static defaultAction = "index"

    static ignore = ['action','controller','id']

    def search = {
        params.fq = "docType:site"

        String userId = userService.getCurrentUserId()

        if(userId) {
            def favouriteSiteIds = userService.getStarredSiteIdsForUserId(userId)
            if(params.remove('myFavourites') == "true"){
                def terms = [field: "siteId", values: favouriteSiteIds]
                params.terms = terms
            }
        }

        // remove hub param so that default filter query is not added when executing in ecodata
        params.remove('hub')
        def results = searchService.fulltextSearch(params, true)
        render results as JSON
    }

    def select(){
        // permissions check
        if (!projectService.canUserEditProject(userService.getCurrentUserId(), params.projectId)) {
            flash.message = "Access denied: User does not have <b>editor</b> permission for projectId ${params.projectId}"
            redirect(controller:'project', action:'index', id: params.projectId)
        }
        render view: 'select', model: [project:projectService.get(params.projectId)]
    }

    def create(){
        render view: 'edit', model: [create:true, documents:[]]
    }


    def createForProject(){
        def project = projectService.getRich(params.projectId)
        // permissions check
        if (!projectService.canUserEditSitesForProject(userService.getCurrentUserId(), params.projectId)) {
            flash.message = "Access denied: User is not en editor or is not allowed to manage sites for projectId ${params.projectId}"
            redirect(controller:'project', action:'index', id: params.projectId)
        }

        project.sites?.sort {it.name}
        project.projectSite = project.sites?.find{it.siteId == project.projectSiteId}


        render view: 'edit', model: [create:true, project:project, documents:[], projectSite:project.projectSite,
                                     pActivityId: params?.pActivityId]
    }

    def index(String id) {

        // Include activities only when biocollect starts supporting NRM based projects.
        def site = siteService.get(id, [view: 'projects'])
        if (site && site.status != 'deleted') {
            // inject the metadata model for each activity
            site.activities = site.activities ?: []
            site.activities?.each {
                it.model = metadataService.getActivityModel(it.type)
            }
            //siteService.injectLocationMetadata(site)
            def user = userService.getUser()

            def result = [site               : site,
             //activities: activityService.activitiesForProject(id),
             mapFeatures        : siteService.getMapFeatures(site),
             isSiteStarredByUser: userService.isSiteStarredByUser(user?.userId ?: "0", site.siteId)?.isSiteStarredByUser,
             user               : user
            ]

            if (params.format == 'json')
                render result as JSON
            else
                result

        } else {
            //forward(action: 'list', model: [error: 'no such id'])
            flash.message = "Site not found."
            redirect(controller: 'site', action: 'list')
        }
    }

    def edit(String id) {
        def result = siteService.getRaw(id)
        if (!result.site) {
            render 'no such site'
        } else if (!isUserMemberOfSiteProjects(result.site) && !userService.userIsAlaAdmin()) {
            // check user has permissions to edit - user must have edit access to
            // ALL linked projects to proceed.
            flash.message = "Access denied: User does not have <b>editor</b> permission to edit site: ${id}"
            redirect(controller:'home', action:'index')
        } else {
            result
        }
    }

    /**
     * Api: delete site which is not public and not related to a project anymore
     *
     * FORCE Delete without check if it is connected to a project
     *
     * @param id
     * @return
     */
    def forceDelete(String id) {
        try{
            // permissions check
            // rule ala admin can only delete a site on condition,
            // 1. site is not assoicated with an acitivity(s)
            if(!userService.userIsAlaAdmin()){
                return {status:HttpStatus.SC_UNAUTHORIZED; text: "Access denied: User not authorised to delete"} as JSON

            }
            def status = siteService.delete(id)
            if (status < 400) {
                def result = [status: 'deleted']
                return result as JSON
            } else {
                def result = [status: status]
                return result as JSON
            }
        } catch (SocketTimeoutException sTimeout){
            log.error(sTimeout.message)
            log.error(sTimeout.stackTrace)
            return {text: 'Webserive call timed out'; status: HttpStatus.SC_REQUEST_TIMEOUT} as JSON;
        } catch (Exception e){
            log.error(e.message)
            log.error(e.stackTrace)
            return {text: 'Internal server error'; status: HttpStatus.SC_INTERNAL_SERVER_ERROR} as JSON;
        }
    }



    def ajaxList(String id) {
        if(params.entityType == "projectActivity") {
            def pActivity = projectActivityService.get(id, 'all')
//        def sites = siteService.getSitesFromIdList(pActivity.sites, BRIEF)
            if (!pActivity) {
                response.sendError(404, "Couldn't find project activity $id")
                return
            }
            log.info(pActivity.sites)
            render pActivity.sites as JSON

        } else if (params.entityType == "project") {
            def project = projectService.get(id, "all")
            if (!project) {
                response.sendError(404, "Couldn't find project $id")
                return
            }

            render project?.sites  as JSON
        }

    }

    def ajaxDeleteSitesFromProject(String id){
        // permissions check - id is the projectId here
        if (!projectService.canUserEditSitesForProject(userService.getCurrentUserId(), id)) {
            render status:403, text: "Access denied: User does not have permission to edit sites for project: ${id}"
            return
        }
        def status = siteService.deleteSitesFromProject(id)
        if (status < 400) {
            def result = [status: 'deleted']
            render result as JSON
        } else {
            def result = [status: status]
            render result as JSON
        }
    }

    def ajaxDeleteSiteFromProject(String id) {
        def projectId = id
        def siteId = params.siteId
        if (!projectId || !siteId) {
            render status:400, text:'The siteId parameter is mandatory'
            return
        }
        if (!projectService.canUserEditSitesForProject(userService.getCurrentUserId(), projectId)) {
            render status:403, text: "Access denied: User does not have permission to edit sites for project: ${projectId}"
            return
        }

        def site = siteService.get(siteId, [raw:'true'])
        def projects = site.projects
        projects.remove(projectId)

        def result = siteService.update(siteId, [projects:projects])
        render result as JSON

    }

    def ajaxDelete(String id) {
        try{
            // permissions check
            // rule ala admin can only delete a site on condition,
            // 1. site is not assoicated with an acitivity(s)
            if(!userService.userIsAlaAdmin()){
                render status:HttpStatus.SC_UNAUTHORIZED, text: "Access denied: User not authorised to delete"
                return
            } else if(siteService.isSiteAssociatedWithProject(id) || siteService.isSiteAssociatedWithActivity(id)){
                render status: HttpStatus.SC_BAD_REQUEST, text: "Site ${id} has projects or activities associated with it. The site cannot be deleted."
                return
            }

            def status = siteService.delete(id)
            if (status < 400) {
                def result = [status: 'deleted']
                render result as JSON
            } else {
                def result = [status: status]
                render result as JSON
            }
        } catch (SocketTimeoutException sTimeout){
            log.error(sTimeout.message)
            log.error(sTimeout.stackTrace)
            render(text: 'Webserive call timed out', status: HttpStatus.SC_REQUEST_TIMEOUT);
        } catch (Exception e){
            log.error(e.message)
            log.error(e.stackTrace)
            render(text: 'Internal server error', status: HttpStatus.SC_INTERNAL_SERVER_ERROR);
        }
    }

    def ajaxAddToFavourites(String id) {
        try{

            def response = userService.addStarSiteForUser(userService.getCurrentUserId(), id)
            if (!response?.error) {
                def result = [status: 'added']
                render result as JSON
            } else {
                def result = [status: response.statusCode]
                render (text: response.error, status:  HttpStatus.SC_INTERNAL_SERVER_ERROR)
            }
        } catch (Exception e){
            log.error(e.message, e)
            render(text: 'Internal server error', status: HttpStatus.SC_INTERNAL_SERVER_ERROR);
        }
    }

    def ajaxRemoveFromFavourites(String id) {
        try{

            def response = userService.removeStarSiteForUser(userService.getCurrentUserId(), id)
            if (!response?.error) {
                def result = [status: 'removed']
                render result as JSON
            } else {
                render (text: response.error, status:  HttpStatus.SC_INTERNAL_SERVER_ERROR)
            }
        } catch (Exception e){
            log.error(e.message, e)
            render(text: 'Internal server error', status: HttpStatus.SC_INTERNAL_SERVER_ERROR);
        }
    }

    def update(String id) {

        log.debug("Updating site: " + id)

        // permissions check
        if (!isUserMemberOfSiteProjects(siteService.get(id))) {
            render status:403, text: "Access denied: User does not have permission to edit site: ${id}"
            return
        }

        //params.each { println it }
        //todo: need to detect 'cleared' values which will be missing from the params
        def values = [:]
        // filter params to remove:
        //  1. keys in the ignore list; &
        //  2. keys with dot notation - the controller will automatically marshall these into maps &
        //  3. keys in nested maps with dot notation
        removeKeysWithDotNotation(params).each { k, v ->
            if (!(k in ignore)) {
                values[k] = reMarshallRepeatingObjects(v);
            }
        }
        //log.debug (values as JSON).toString()
        siteService.update(id, values)
        chain(action: 'index', id:  id)
    }

    def uploadShapeFile() {
        if (!projectService.canUserEditSitesForProject(userService.getCurrentUserId(), params.projectId)) {
            flash.message = "Access denied: User is not en editor or is not allowed to manage sites for projectId ${params.projectId}"
            redirect(url: params.returnTo)
        }

        if (request.respondsTo('getFile')) {
            def f = request.getFile('shapefile')


            def result =  siteService.uploadShapefile(f)

            if (!result.error && result.content.size() > 1) {
                def content = result.content
                def shapeFileId = content.remove('shp_id')
                def firstShape = content["0"]
                def attributeNames = []
                firstShape.each {key, value ->
                    attributeNames << key
                }
                def shapes = content.collect {key, value ->
                    [id:(key), values:(value)]
                }
                JSON.use("nullSafe") // JSONNull is rendered as empty string.
                render view:'upload', model:[projectId: params.projectId, shapeFileId:shapeFileId, shapes:shapes, attributeNames:attributeNames]
            }

            else {
                //flag error for extension
                def message ='There was an error uploading the shapefile.  Please send an email to support for further assistance.'

                flash.message = "An error was encountered when processing the shapefile: ${message}"
                render view:'upload', model:[projectId: params.projectId, returnTo:params.returnTo]
            }

        } else {
            render view:'upload', model:[projectId: params.projectId, returnTo:params.returnTo]
        }
    }

    def createSitesFromShapefile() {
        def siteData = request.JSON
        def progress = [total:siteData.sites.size(), uploaded:0]

        try {
            session.uploadProgress = progress

            siteData.sites.each {
                siteService.createSiteFromUploadedShapefile(siteData.shapeFileId, it.id, it.externalId, it.name, it.description?:'No description supplied', siteData.projectId, true)
                progress.uploaded = progress.uploaded + 1
            }
        }
        finally {
            progress.finished = true
        }

        def result = [message:'success', progress:progress]
        render result as JSON
    }

    def siteUploadProgress() {
        def progress = session.uploadProgress?:[:]
        render progress as JSON
    }




    def createGeometryForGrantId(String grantId, String geometryPid, Double centroidLat, Double centroidLong) {
        def projects = importService.allProjectsWithGrantId(grantId)
        if (projects) {
            def sites = []
            projects.each {project ->
                def metadata = metadataService.getLocationMetadataForPoint(centroidLat, centroidLong)
                def strLat =  "" + centroidLat + ""
                def strLon = "" + centroidLong + ""
                def values = [extent: [source: 'pid', geometry: [pid: geometryPid, type: 'pid', state: metadata.state, nrm: metadata.nrm, lga: metadata.lga, locality: metadata.locality, centre: [strLon, strLat]]], projects: [project.projectId], name: "Project area for " + grantId]
                sites << siteService.create(values)
            }
            def result = [result:sites]
            render result as JSON
        } else {
            render "EMPTY"
        }
    }

    def createPointForGrantId(String grantId, String geometryPid, Double lat, Double lon) {
        def projects = importService.allProjectsWithGrantId(grantId)
        if (projects) {
            def sites = []
            projects.each {project ->
                def metadata = metadataService.getLocationMetadataForPoint(lat, lon)
                def strLat =  "" + lat + ""
                def strLon = "" + lon + ""
                def values = [extent: [source: 'point', geometry: [pid: geometryPid, type: 'point', decimalLatitude: strLat, decimalLongitude: strLon, centre: [strLon, strLat], coordinates: [strLon, strLat], datum: "WGS84", state: metadata.state, nrm: metadata.nrm, lga: metadata.lga, locality: metadata.locality, mvg: metadata.mvg, mvs: metadata.mvs]], projects: [project.projectId], name: "Project area for " + grantId]
                sites << siteService.create(values)
            }
            def result = [result:sites]
            render result as JSON
        } else {
            render "EMPTY"
        }
    }

    def updateSiteCentrePoint(String grantId, Double lat, Double lon) {
        def project = importService.findProjectByGrantId(grantId)
        if (project) {
            def site = importService.findProjectSiteByName(project, grantId)
            if (site) {
                def strLat =  "" + lat + ""
                def strLon = "" + lon + ""
                site.extent.geometry.centre = [strLon, strLat]
                siteService.update(site.siteId, site)
                render site as JSON
            } else {
                render "COULD NOT FIND SITE"
            }
        } else {
            render "EMPTY"
        }
    }

    def ajaxUpdateProjects() {
        def postBody = request.JSON
        log.debug "Body: " + postBody
        log.debug "Params:"
        params.each { println it }
        //todo: need to detect 'cleared' values which will be missing from the params - implement _destroy
        def values = [:]
        // filter params to remove:
        //  1. keys in the ignore list; &
        //  2. keys with dot notation - the controller will automatically marshall these into maps &
        //  3. keys in nested maps with dot notation
        postBody.each { k, v ->
            if (!(k in ignore)) {
                values[k] = v //reMarshallRepeatingObjects(v);
            }
        }
        log.debug "values: " + (values as JSON).toString()
        Map project = projectService.get(values.projectId)
        def result = siteService.updateProjectAssociations(values)
        if (values.sites && !project.error) {
            List projectSites = project.sites?.collect { it.siteId }
            List toAdd = values.sites.minus(projectSites)
            siteService.addSitesToSiteWhiteListInWorksProjects(toAdd, [values.projectId], true)
        }

        if(result.error){
            response.status = 500
        } else {
            render result as JSON
        }
    }

    def ajaxUpdate(String id) {
        def result = [:]
        String userId = userService.getCurrentUserId(request)



        if (!userId) {
            Map error  = [status: 401, error:"Access denied: User has not been authenticated."]
            response.status = 401
            render error as JSON
        } else {
            def postBody = request.JSON
            Boolean isCreateSiteRequest = !id
            log.debug "Body: " + postBody
            log.debug "Params:"
            params.each { println it }
            //todo: need to detect 'cleared' values which will be missing from the params - implement _destroy
            def values = [:]
            postBody.site?.each { k, v ->
                if (!(k in ignore)) {
                    values[k] = v //reMarshallRepeatingObjects(v);
                }
            }
            log.debug(values as JSON).toString()
            //Compatible with previous records without visibility field
            boolean privateSite = values['visibility'] ? (values['visibility'] == 'private' ? true : false) : false;

            if(privateSite){
                //Do not check permission if site is private
                //This design is specially for sightings
                result = siteService.updateRaw(id, values,userId)
            }else{

                values.projects?.each { projectId ->
                    if (!projectService.canUserEditSitesForProject(userId, projectId)) {
                        log.error("Error: Access denied: User is not en editor or is not allowed to manage sites for projectId ${params.projectId}")
                        render status: 401, error: 'Error: Access denied: User is not en editor or is not allowed to manage sites';
                    }
                }

                result = siteService.updateRaw(id, values, userId)
                String siteId = result.id
                if(siteId) {
                    if(isCreateSiteRequest){
                        String projectId = postBody?.projectId
                        Boolean isAdmin = projectService.isUserAdminForProject(userId, projectId)
                        if (projectId && isAdmin) {
                            siteService.addSitesToSiteWhiteListInWorksProjects([siteId], [projectId], true);
                        } else {
                            siteService.addSitesToSiteWhiteListInWorksProjects([siteId], values.projects)
                        }

                        if (postBody?.pActivityId) {
                            def pActivity = projectActivityService.get(postBody.pActivityId);

                            if (result?.status != 'error') {
                                pActivity.sites.add(siteId)

                                projectActivityService.update(postBody.pActivityId, pActivity)
                            }
                        }
                    }
                } else {
                    result.status = 'error';
                    result.message = 'Could not save site';
                }
            }


            if (result.status == 'error') {
                render status: HttpStatus.SC_INTERNAL_SERVER_ERROR, text: "${result.message}"
            } else {
                render status: HttpStatus.SC_OK, text: result as JSON, contentType: "application/json"
            }
        }
    }

    def checkSiteName(String id) {
        log.debug "Name: ${params.name}"
        def result = siteService.isSiteNameUnique(id, params.entityType, params.name)

        response.sendError(result.value ? SC_NO_CONTENT : SC_CONFLICT)
    }

    def locationLookup(String id) {
        def md = [:]
        def site = siteService.get(id)
        if (!site || site.error) {
            md = [error: 'no such site']
        } else {
            md = siteService.getLocati onMetadata(site)
            if (!md) {
                md = [error: 'no metadata found']
            }
        }
        render md as JSON
    }

    /**
     * Looks up the site metadata (used for facetting) based on the supplied
     * point and returns it as JSON.
     * @param lat the latitude of the point (or centre of a shape)
     * @param lon the longitude of the point (or centre of a shape)
     */
    def locationMetadataForPoint() {
        def lat = params.lat
        def lon = params.lon


        if (!lat || !lon) {
            response.status = 400
            def result = [error:'lat and lon parameters are required']
            render result as JSON
        }
        if (!lat.isDouble() || !lon.isDouble()) {
            response.status = 400
            def result = [error:'invalid lat and lon supplied']
            render result as JSON
        }

        render metadataService.getLocationMetadataForPoint(lat, lon) as JSON
    }

    /**
     * Re-marshalls a map of arrays to an array of maps.
     *
     * Grails marshalling of repeating fields with names in dot notation: eg
     * <pre>
     *     <bs:textField name="shape.pid" label="Shape PID"/>
     *     <bs:textField name="shape.name" label="Shape name"/>
     *     <bs:textField name="shape.pid" label="Shape PID"/>
     *     <bs:textField name="shape.name" label="Shape name"/>
     * </pre>
     * produces a map like:
     *  [name:['shape1','shape2'],pid:['23','24']]
     * while we want:
     *  [[name:'shape1',pid:'23'],[name:'shape2',pid:'24']]
     *
     * We indicate that we want this style of marshalling (the other is also valid) by adding a hidden
     * field data-marshalling='list'.
     *
     * @param value the map to re-marshall
     * @return re-marshalled map
     */
    def reMarshallRepeatingObjects(value) {
        if (!(value instanceof HashMap)) {
            return value
        }
        if (value.handling != 'repeating') {
            return value
        }
        value.remove('handling')
        def list = []
        def len = value.collect({ it.value.size() }).max()
        (0..len-1).each { idx ->
            def newMap = [:]
            value.keySet().each { key ->
                newMap[key] = reMarshallRepeatingObjects(value[key][idx])
            }
            list << newMap
        }
        list
    }

    def removeKeysWithDotNotation(value) {
        if (value instanceof String) {
            return value
        }
        if (value instanceof Object[]) {
            return stripBlankElements(value)
        }
        // assume map for now
        def iter = value.entrySet().iterator()
        while (iter.hasNext()) {
            def entry = iter.next()
            if (entry.key.indexOf('.') >= 0) {
                iter.remove()
            }
            entry.value = removeKeysWithDotNotation(entry.value)
        }
        value
    }

    def stripBlankElements(list) {
        list.findAll {it}
    }

    // debug only
    def features(String id) {
        def site = siteService.get(id)
        if (site) {
            render siteService.getMapFeatures(site)
        } else {
            render 'no such site'
        }
    }

    /**
     * this function will get a list of siteId and return photo points for them
     * @param id - required - eg. 123,345
     * @return
     */
    def getImages(){
        List results
        if(params.id){
            GrailsParameterMap mParams = new GrailsParameterMap(commonService.parseParams(params), request);
            mParams.userId = authService.getUserId()
            try{
                results = siteService.getImages(mParams)
                render(text: results as JSON, contentType: 'application/json')
            } catch (SocketTimeoutException sTimeout){
                render(text: sTimeout.message, status: HttpStatus.SC_REQUEST_TIMEOUT);
            } catch (Exception e){
                render(text: e.message, status: HttpStatus.SC_INTERNAL_SERVER_ERROR);
            }
        } else {
            render( status: HttpStatus.SC_BAD_REQUEST, text: 'Parameter id not found')
        }
    }

    /**
     * this function will get all documents / images for a point of interest. Max and offset are supported.
     * @param siteId - required
     * @param poiId - required
     * @return
     */
    def getPoiImages(){
        Map results
        if(params.siteId && params.poiId){
            GrailsParameterMap mParams = new GrailsParameterMap(commonService.parseParams(params), request);
            mParams.userId = authService.getUserId()
            try {
                results = siteService.getPoiImages(mParams)
                render(text: results as JSON, contentType: 'application/json')
            } catch (SocketTimeoutException sTimeout){
                render(text: sTimeout.message, status: HttpStatus.SC_REQUEST_TIMEOUT);
            } catch (Exception e){
                render(text: e.message, status: HttpStatus.SC_INTERNAL_SERVER_ERROR);
            }
        } else {
            render( status: HttpStatus.SC_BAD_REQUEST, text: 'Parameters siteId or poiId not found')
        }
    }

    def list(){
    }

    def myFavourites() {
        def user = userService.getCurrentUserId()
        if(user){
            def model = [myFavourites:true]
            render view:"list", model:model
        } else {
            redirect action: 'list'
        }
    }

    /**
     * This function does an elastic search for sites. All elastic search parameters are supported like fq, max etc.
     * @return
     */
    def elasticsearch(){
        try{
            List query = ['className:au.org.ala.ecodata.Site', '-type:projectArea']
            String userId = userService.getCurrentUserId()
            Boolean isAlaAdmin = userService.userIsAlaAdmin()


            GrailsParameterMap queryParams = commonService.constructDefaultSearchParams(params, request, userId)

            def favouriteSiteIds
            if(userId) {
                favouriteSiteIds = userService.getStarredSiteIdsForUserId(userId)
                if(params.remove('myFavourites')){
                    def terms = [field: "siteId", values: favouriteSiteIds]
                    queryParams.terms = terms
                }
            }

            if(!queryParams.facets){
                queryParams.facets="typeFacet,className,organisationFacet,stateFacet,lgaFacet,nrmFacet,siteSurveyNameFacet,siteProjectNameFacet,photoType"
            }
            if(queryParams.query){
                query.push(queryParams.query);
            }

            queryParams.query = query.join(' AND ')
            queryParams.remove('hub')
            queryParams.remove('hubFq')
            Map searchResult = searchService.searchForSites(queryParams)
            List sites = searchResult?.hits?.hits
            List facets = []
            List projectIds = []
            sites?.each{
                if(it._source?.projects?.size()){
                    projectIds.push(StringUtils.join(it._source?.projects,','))
                }
            }
            // JSON Array join is inserting quotes around each array element. Hence using StringUtil.join method.
            String pIds = StringUtils.join(projectIds, ',')
            Map permissions = [:]
            // when sites are not associated with a project canUserEditProjects will throw exception.
            if(projectIds.size()>0 && userId){
                permissions = projectService.canUserEditProjects(userId, pIds)
            }
            sites = sites?.collect {
                Map doc = it._source
                Boolean canEdit = isAlaAdmin || userId && doc.projects.inject(false){flag, id ->
                    flag || !!permissions[id]
                }

                Boolean addToFavourites = false
                Boolean removeFromFavourites = false

                if (userId) {
                    if (favouriteSiteIds.contains(doc.siteId)) {
                        removeFromFavourites = true
                    } else {
                        addToFavourites = true
                    }
                }

                [
                        siteId           : doc.siteId,
                        name             : doc.name,
                        description      : doc.description,
                        numberOfPoi      : doc.poi?.size(),
                        numberOfProjects : doc.projects?.size(),
                        lastUpdated      : doc.lastUpdated,
                        type             : doc.type,
                        extent           : doc.extent,
                        // does a logical OR reduce operation on permissions for each projects
                        canEdit          : canEdit,
                        // only sites with no projects can be deleted
                        canDelete        : isAlaAdmin && (doc.projects?.size() == 0),
                        addToFavourites  : addToFavourites,
                        removeFromFavourites : removeFromFavourites
                ]
            }

            searchResult?.facets?.each { k, v ->
                Map facet = [:]
                facet.name = k
                facet.total = v.total
                facet.terms = v.terms
                facets << facet
            }

            render([sites: sites, facets: facets, total: searchResult.hits?.total ?: 0] as JSON)
        } catch (SocketTimeoutException sTimeout){
            render(text: sTimeout.message, status: HttpStatus.SC_REQUEST_TIMEOUT);
        } catch (Exception e){
            render(text: e.message, status: HttpStatus.SC_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Check each of the site's projects if logged in user is a member
     *
     * @param site
     * @return
     */
    private Boolean isUserMemberOfSiteProjects(site) {
        Boolean userCanEdit = false

        site.projects.each { p ->
            // handle both 'raw' and normal (project is a Map) output from siteService.get()
            def pId = (p instanceof Map && p.containsKey('projectId')) ? p.projectId : p
            if (pId && projectService.canUserEditSitesForProject(userService.getCurrentUserId(), pId)) {
                userCanEdit = true
            }
        }

        userCanEdit
    }
}