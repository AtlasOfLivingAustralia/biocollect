package au.org.ala.biocollect.merit

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONArray

import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream


/**
 * Handles requests from the mobile application.  Uses the mobile auth key services for authentication rather than
 * the usual CAS tickets.
 */
class MobileController {

    private static String USER_NAME_HEADER_FIELD = "userName"
    private static String AUTH_KEY_HEADER_FIELD = "authKey"


    static String MOBILE_AUTH_BASE_URL = "https://m.ala.org.au"
    static String MOBILE_AUTH_GET_KEY_URL = MOBILE_AUTH_BASE_URL+"/mobileauth/mobileKey/generateKey"
    static String MOBILE_AUTH_CHECK_KEY_URL = MOBILE_AUTH_BASE_URL+"/mobileauth/mobileKey/checkKey"

    def metadataService, webService, grailsApplication, userService, projectService, activityService, siteService

    def jsRegexp = /(?m)script src="\/(.*)" type="text\/javascript"/
    def cssRegexp = /(?m)link href="\/(.*)" type="text\/css"/
    def cssImgRegexp = /(?m)url\(["'](.*)["']/
    def imgRegexp = /(?m)img src="\/(.*\.gif|png|jpg)"/

    /**
     * Bundles activity forms into a zip file for use offline by the mobile applications.
     * @return an application/zip stream contain the activity forms and supporting script/css files.
     */
    def bundle() {

        def activities = metadataService.activitiesModel().activities

        response.setContentType('application/zip')

        ZipOutputStream zip = new ZipOutputStream(response.outputStream)
        def added = []
        activities.each {

            def type = it.name
            def enterActivityDataHtml = activityHtml(type)

            added = addExternalFiles(zip, jsRegexp, enterActivityDataHtml, added)
            added = addExternalFiles(zip, cssRegexp, enterActivityDataHtml, added)
            added = addExternalFiles(zip, imgRegexp, enterActivityDataHtml, added)
            // replace absolute references with relative ones to enable loading from file.
            enterActivityDataHtml = enterActivityDataHtml.replaceAll(jsRegexp, /script src="$1" type="text\/javascript"/)
            enterActivityDataHtml = enterActivityDataHtml.replaceAll(cssRegexp, /link href="$1" type="text\/css"/)
            enterActivityDataHtml = enterActivityDataHtml.replaceAll(imgRegexp, /img src="$1"/)
            if (params.targetServer) {
                enterActivityDataHtml = enterActivityDataHtml.replaceAll(grailsApplication.config.grails.serverURL, params.targetServer)
            }

            zip.putNextEntry(new ZipEntry(type.replaceAll(' ', '_')+'.html'))

            byte[] page = enterActivityDataHtml.getBytes('UTF-8')
            zip.write(page, 0, page.length)
            zip.closeEntry()
        }

        zip.finish()

        return null
    }

    /**
     * Follows links identified by the supplied regular expression and adds them to the supplied zip file.
     * @param zip the file being produced.
     * @param regexp used to match URLs to follow and add.
     * @param html the html to search.
     */
    private def addExternalFiles(ZipOutputStream zip, regexp, String html, alreadyAdded, path = "") {
        def urls = []

        def results = html =~ regexp
        while (results.find()) {
            urls << results.group(1)
        }

        urls.each { String url ->
            if (!alreadyAdded.contains(url)) {
                try {
                    def page = ""
                    def fullUrl = grailsApplication.config.serverName +'/'+ path + url
                    byte[] pageBytes
                    if (isImageUrl(url)) {
                        pageBytes = readBinaryUrl(fullUrl)
                    }
                    else {
                        page = webService.get(fullUrl)
                        pageBytes = page.getBytes('UTF-8')
                    }
                    zip.putNextEntry(new ZipEntry(path+url))
                    zip.write(pageBytes, 0, pageBytes.length)
                    zip.closeEntry()

                    alreadyAdded << url
                    if (url.endsWith("css")) {
                        def relativePath = url.substring(0, url.lastIndexOf('/'))+'/'

                        alreadyAdded = addExternalFiles(zip, cssImgRegexp, page, alreadyAdded, relativePath)

                    }
                }
                catch (Exception e) {
                    println e
                }
            }
        }

        return alreadyAdded

    }

    private boolean isImageUrl(String url) {
        url.endsWith("png") || url.endsWith("jpg") || url.endsWith("gif")
    }

    byte[] readBinaryUrl(String url) {
        ByteArrayOutputStream bytesout = new ByteArrayOutputStream(2048)
        bytesout << new URL(url).openStream()

        return bytesout.toByteArray()
    }


    String activityHtml(type) {
        def url = g.createLink(controller:'mobile', action:'activityForm', id:type, absolute: true, params: params)

        def result = webService.get(url)
        return result
    }

    def activityForm(String id) {

        def model = [:]
        model.speciesLists = new JSONArray()
        model.metaModel = metadataService.getActivityModel(id)
        // the array of output models
        model.outputModels = model.metaModel?.outputs?.collectEntries {
            [it, metadataService.getDataModelFromOutputName(it)]
        }

        if (params.activityId) {
            model.activity = activityService.get(params.activityId)
            model.sites = projectService.get(model.activity.projectId).sites
        }

        render view:'/activity/mobile', model:model
    }

    /**
     * Performs a login operation using m.ala.org.au and returns auth key.
     * @return JSON containing the auth key produced by m.ala.org.au
     */
    def login() {
        def username = params.userName.encodeAsURL()
        def password = params.password.encodeAsURL()
        def loginUrl = MOBILE_AUTH_GET_KEY_URL+"?userName=${username}&password=${password}"
        def result = webService.getJson(loginUrl)
        if (result.statusCode) {
            response.setStatus(result.statusCode)
        }
        render result as JSON
    }

    /**
     * @return the projects for the supplied user.
     */
    def userProjects() {
        // validate with mobile auth.
        UserDetails user = authorize()

        if (user) {
            def projects = userService.getProjectsForUserId(user.userId)

            if (params.program) {
                projects = projects.findAll{it?.project.associatedProgram == params.program}
            }

            projects?.each {
                trimProject(it?.project)
            }
            render projects as JSON
        }
        else  {
            response.status = 401
            def message = [error:'Invalid credentials supplied']
            render message as JSON

        }
    }

    private def trimProject(project) {
        // Removed unused fields to reduce the size of the payload.
        project.remove('documents')
        project.remove('outputTargets')
        project.remove('timeline')
    }

    def projectDetails(String id) {

        // validate with mobile auth.
        UserDetails user = authorize()

        if (user) {

            if (!projectService.canUserEditProject(user.userId, id)) {
                def error = [error: "Access denied: User does not have <b>editor</b> permission for project:'${id}'}"]
                response.status = 401
                render error as JSON
            }
            def includeDeleted = params.boolean('includeDeleted', false)
            def project = projectService.get(id, 'all', includeDeleted)
            project.sites?.each { site ->
                def centre = site.extent?.geometry?.centre
                if (centre) {
                    site.centroidLat = centre[1]
                    site.centroidLon = centre[0]
                }
                site.remove('projects')

                site.photoPoints = site.poi?.findAll { it.type == 'photopoint' || it.type == 'point' }
                site.remove('poi')
            }
            project.themes = metadataService.getThemesForProject(project)?.collect {it.name}


            if (params.updatedAfter) {
                project.activities = project.activities.findAll{it && it.lastUpdated > params.lastUpdated}
            }

            project.activities?.each {activity ->
                if (activity) {
                    activity.themes = project.themes
                }
            }

            trimProject(project)

            render project as JSON
        }
        else  {
            response.status = 401
            def message = [error:'Invalid credentials supplied']
            render message as JSON

        }
    }

    def updateActivity(String id) {

        UserDetails user = authorize()

        if (user) {
            def postBody = request.JSON
            if (!id || !postBody) {
                response.status = 400
                def result = [status: 400, error: "No activity id or details supplied"]
                render result as JSON
                return
            }

            def result = [:]

            def projectId
            if (id) {
                def activity = activityService.get(id)
                projectId = activity.projectId

                // There is a potential timing issue on the mobile - if an activity is re-edited after the sync is
                // triggered but before it is complete (and new outputIds assigned on the mobile device), the
                // output ids can be absent on the second update, resulting in duplicate outputs for an activity.
                postBody.outputs?.each { output ->
                    def matchingOutput = activity.outputs?.find{it.name == output.name}
                    if (matchingOutput) {
                        output.outputId = matchingOutput.outputId
                    }
                }
            } else {
                projectId = values.projectId
            }
            if (!projectId) {
                response.status = 400
                flash.message = "No project id supplied for activity: ${id}"
                result = [status: 400, error: flash.message]
            }

            // check user has permissions to edit/update site - user must have 'editor' access to
            // ALL linked projects to proceed.
            if (!projectService.canUserEditProject(user.userId, projectId)) {
                flash.message = "Error: access denied: User does not have <b>editor</b> permission for projectId ${projectId}"
                response.status = 401
                result = [status: 401, error: flash.message]
            }

            if (!result) {
                result = activityService.update(id, postBody)
            }
            //log.debug "result is " + result

            if (result.error) {
                render result as JSON
            } else {
                //log.debug "json result is " + (result as JSON)
                render result.resp as JSON
            }
        }
        else {
            response.status = 401
            def message = [error:'Invalid credentials supplied']
            render message as JSON
        }
    }

    def createSite() {
        UserDetails user = authorize()

        def mandatoryFields = ['name', 'centroidLat', 'centroidLon', 'projectId']
        if (user) {

            def result = [:]

            def siteDetails = request.JSON
            def missingFields = []
            mandatoryFields.each {
                if (!siteDetails[it]) {
                    missingFields << it
                }
            }

            def message = ""
            if (missingFields) {
                response.status = 400
                message += "Missing mandatory fields: ${missingFields}."
                result = [status: 400, error:message]

            }
            def projectId = siteDetails.projectId

            // check user has permissions to edit/update site - user must have 'editor' access to
            // ALL linked projects to proceed.
            if (projectId && !projectService.canUserEditProject(user.userId, projectId)) {
                message += "Access denied: User does not have <b>editor</b> permission for projectId ${projectId}"
                response.status = 401
                result = [status: 401, error: message]
                //render result as JSON
            }

            if (!result) {
                result = siteService.createSiteFromPoint(projectId, siteDetails.name, siteDetails.description, siteDetails.centroidLat, siteDetails.centroidLon)
                if (result.error) {
                    response.status = result.statusCode
                    render result as JSON
                }
                else {
                    render result.resp as JSON
                }
            }
            else {
                render result as JSON
            }

        }
        else  {
            response.status = 401
            def message = [error:'Invalid credentials supplied']
            render message as JSON


        }
    }

    /**
     * Extracts the username and authorization key from the HTTP header then validates the key with the mobile
     * auth service.
     * @return a UserDetails object if the key was valid, null otherwise.
     */
    UserDetails authorize() {

        def username = request.getHeader(USER_NAME_HEADER_FIELD)
        def key = request.getHeader(AUTH_KEY_HEADER_FIELD)

        // validate auth key.
        def url = MOBILE_AUTH_CHECK_KEY_URL
        def params = [userName:username, authKey:key]
        def result = webService.doPostWithParams(url,params)
        if (!result.statusCode && result.resp?.status == 'success') {
            // success!
            params = [userName:username]
            url = grailsApplication.config.userDetails.url+"getUserDetails"
            result = webService.doPostWithParams(url, params)
            if (!result.statusCode && result.resp) {
                return new UserDetails(result.resp.firstName+result.resp.lastName, result.resp.userName, result.resp.userId)
            }
        }
        return null

    }
}
