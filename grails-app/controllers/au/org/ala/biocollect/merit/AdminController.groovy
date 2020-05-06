package au.org.ala.biocollect.merit

import au.org.ala.biocollect.merit.hub.HubSettings
import grails.converters.JSON
//import grails.plugin.cache.CacheEvict
import org.springframework.cache.annotation.CacheEvict
import grails.util.Environment
import grails.util.GrailsNameUtils
import org.springframework.core.io.support.PathMatchingResourcePatternResolver
import org.springframework.web.multipart.MultipartHttpServletRequest

@PreAuthorise(accessLevel = 'officer', redirectController = "home")
class AdminController {

    def cacheService
    def metadataService
    def authService
    def projectService
    def importService
    def adminService
    def auditService
    def searchService
    def settingService
    def siteService
    def outputService
    def documentService
    def projectActivityService
    def webService
    grails.core.GrailsApplication grailsApplication
    def roleService

    def index() {}

    @PreAuthorise(accessLevel = 'alaAdmin', redirectController = "admin")
    def tools() {}

    /**
     * Admin page for checking or modifying user/project roles, requires CAS admin role
     * for access (see Config.groovy "security.cas.officerRole" for actual role)
     *
     * @return
     */
    def users() {
        def user = authService.userDetails()
        def projects = projectService.list(true)
        def roles = metadataService.getAccessLevels().collect {
            it.name
        }

        if (user && projects) {
            [ projects: projects, user: user, roles: roles]
        } else {
            flash.message = "Error: ${!user?'Logged-in user could not be determined ':' '}${!projects?'List of all projects not found ':''}"
            redirect(action: "index")
        }
    }

    @PreAuthorise(accessLevel = 'alaAdmin', redirectController = "admin")
    def bulkLoadUserPermissions() {
        def user = authService.userDetails()
        [user:user]
    }

    @PreAuthorise(accessLevel = 'alaAdmin')
    def syncCollectoryOrgs() {
        def result = adminService.syncCollectoryOrgs()
        if (result.statusCode == 200)
            render (status: 200)
        else
            render (status: result.statusCode, error: result.error)
    }

    @PreAuthorise(accessLevel = 'alaAdmin', redirectController = "admin")
    def uploadUserPermissionsCSV() {

        def user = authService.userDetails()

        def results

        if (request instanceof MultipartHttpServletRequest) {
            def file = request.getFile('projectData')
            if (file) {
                results = importService.importUserPermissionsCsv(file.inputStream)
                flash.message = results?.message
            }
        }

        render(view:'bulkLoadUserPermissions', model:[user: user, results: results])
    }

    @PreAuthorise(accessLevel = 'alaAdmin', redirectController = "admin")
    def syncSciStarter(){
        Map imported = projectService.importSciStarterProjects()
        render text: imported as JSON, contentType: 'application/json'
    }

    @PreAuthorise(accessLevel = 'siteAdmin', redirectController = "admin")
    def staticPages() {
        def settings = []

        for (setting in SettingPageType.values()) {
            log.debug "setting = $setting"
            settings << [key:setting.key, value:"&lt;Click edit to view...&gt;", editLink: createLink(controller:'admin', action:"editSettingText"), name:setting.name]
        }

        [settings: settings]
    }

    @PreAuthorise(accessLevel = 'alaAdmin', redirectController = "admin")
    def settings() {
        def settings = []

        def grailsStuff = []
        def config = grailsApplication.config.flatten()
        for ( e in config ) {
            if(e.key.startsWith("grails.")){
                grailsStuff << [key: e.key, value: e.value, comment: '']
            } else {
                settings << [key: e.key, value: e.value, comment: '']
            }
        }

        [settings: settings, grailsStuff: grailsStuff]
    }

    @PreAuthorise(accessLevel = 'siteAdmin', redirectController = "admin")
    def editSettingText(String id) {
        def content
        def layout = params.layout?:"adminLayout"
        def returnUrl = params.returnUrl?:g.createLink(controller:'admin', action:'staticPages', absolute: true )
        def returnAction = returnUrl.tokenize("/")[-1]
        def returnLabel = GrailsNameUtils.getScriptName(returnAction).replaceAll('-',' ').capitalize()
        SettingPageType type = SettingPageType.getForName(id)

        if (type) {
            content = settingService.getSettingText(type)
        } else {
            render(status: 404, text: "No settings type found for: ${id}")
            return
        }

        render(view:'editTextAreaSetting', model:[
                textValue: content,
                layout: layout,
                ajax: (layout =~ /ajax/) ? true : false,
                returnUrl: returnUrl,
                returnLabel: returnLabel,
                settingTitle: type.title,
                settingKey: type.key] )
    }

    @PreAuthorise(accessLevel = 'siteAdmin', redirectController = "admin")
    def saveTextAreaSetting() {
        def text = params.textValue
        def settingKey = params.settingKey
        def returnUrl = params.returnUrl?:g.createLink(controller:'admin', action:'settings', absolute: true )

        if (settingKey) {
            SettingPageType type = SettingPageType.getForKey(settingKey)

            if (type) {
                settingService.setSettingText(type, text)
                cacheService.clear(type.key) // clear cached copy
                flash.message = "${settingKey} content saved."
            } else {
                throw new RuntimeException("Undefined setting key!")
                flash.message = "Error: Undefined setting key - ${settingKey}"
            }
        }

        redirect(uri: returnUrl)
    }

    def reloadConfig = {
        // reload system config
        def resolver = new PathMatchingResourcePatternResolver()
        def resource = resolver.getResource(grailsApplication.config.reloadable.cfgs[0])
        if (!resource) {
            def warning = "No external config to reload. grailsApplication.config.grails.config.locations is empty."
            println warning
            flash.message = warning
            render warning
        } else {
            def stream = null

            try {
                stream = resource.getInputStream()
                ConfigSlurper configSlurper = new ConfigSlurper(Environment.current.name)
                if(resource.filename.endsWith('.groovy')) {
                    def newConfig = configSlurper.parse(stream.text as String)
                    grailsApplication.getConfig().merge(newConfig)
                }
                else if(resource.filename.endsWith('.properties')) {
                    def props = new Properties()
                    props.load(stream)
                    def newConfig = configSlurper.parse(props)
                    grailsApplication.getConfig().merge(newConfig)
                }
                flash.message = "Configuration reloaded."
                String res = "<ul>"
                grailsApplication.config.each { key, value ->
                    if (value instanceof Map) {
                        res += "<p>" + key + "</p>"
                        res += "<ul>"
                        value.each { k1, v1 ->
                            res += "<li>" + k1 + " = " + v1 + "</li>"
                        }
                        res += "</ul>"
                    }
                    else if (key != 'api_key') { // never reveal the api key
                        res += "<li>${key} = ${value}</li>"
                    }
                }
                render res + "</ul>"
            }
            catch (FileNotFoundException fnf) {
                def error = "No external config to reload configuration. Looking for ${grailsApplication.config.grails.config.locations[0]}"
                log.error error
                flash.message = error
                render error
            }
            catch (Exception gre) {
                def error = "Unable to reload configuration. Please correct problem and try again: " + gre.getMessage()
                log.error error
                flash.message = error
                render error
            }
            finally {
                stream?.close()
            }
        }
    }

    def clearMetadataCache() {
        if (params.clearEcodataCache) {
            metadataService.clearEcodataCache()
        }
        cacheService.clear()
        flash.message = "Metadata cache cleared."
        render 'done'
    }

    /**
     * Accepts a CSV file (as a multipart file upload) and validates and loads project, site & institution data from it.
     * @return an error message if the CSV file is invalid, otherwise writes a CSV file describing any validation
     * errors that were encountered.
     */
    def importProjectData() {

        if (request instanceof MultipartHttpServletRequest) {
            def file = request.getFile('projectData')

            if (file) {

                def results = importService.importProjectsByCsv(file.inputStream, params.importWithErrors)

                if (results.error) {
                    render contentType: 'text/json', status:400, text:"""{"error":"${results.error}"}"""
                }
                else {
                    // Make sure the new projects are re-indexed.
                    adminService.reIndexAll()
                }

                // The validation results are current returned as a CSV file so that it can easily be sent back to
                // be corrected at the source.  It's not great usability at the moment.
                response.setContentType("text/csv")
                PrintWriter pw = new PrintWriter(response.outputStream)
                results.validationErrors.each {
                    pw.println('"'+it.join('","')+'"')
                }
                pw.flush()
                return null
            }

        }

        render contentType: 'text/json', status:400, text:'{"error":"No file supplied"}'
    }

    /**
     * Accepts a CSV file (as a multipart file upload) and validates and bulk loads activity plan data for multiple projects.
     * @return an error message if the CSV file is invalid, otherwise writes a CSV file describing any validation
     * errors that were encountered.
     */
    def importPlanData() {
        if (request instanceof MultipartHttpServletRequest) {
            def file = request.getFile('planData')

            if (file) {

                def results = importService.importPlansByCsv(file.inputStream, params.overwriteActivities)

                render results as JSON
            }

        }

        render contentType: 'text/json', status:400, text:'{"error":"No file supplied"}'
    }

    /**
     * Re-index all docs with ElasticSearch
     */
    def reIndexAll() {
        render adminService.reIndexAll()
    }

    def audit() {
    }

    def auditProjectSearch() {

        def results = []
        def searchTerm = params.searchTerm as String
        if (searchTerm) {
            if (!searchTerm.endsWith("*")) {
                searchTerm += "*"
            }
            results = searchService.allProjects(params, searchTerm)
        }

        render(view: 'audit', model:[results: results, searchTerm: params.searchTerm])
    }

    def auditProject() {
        def id = params.id
        if (id) {
            def project = projectService.get(id)
            if (project) {
                render view:'/admin/auditProject', model: [project: project]

            } else {
                flash.message = "Specified project id does not exist!"
                redirect(action:'audit')
            }
        } else {
            flash.message = "No project specified!"
            redirect(action:'audit')
        }
    }

    def auditMessageDetails() {
        def results = auditService.getAuditMessage(params.id as String)
        String compareId = params.compareId
        def userDetails = [:]
        def compare
        if (results?.message) {
            userDetails = auditService.getUserDetails(results?.message?.userId)
        }

        if(compareId){
            compare = auditService.getAuditMessage(params.compareId as String)
        } else {
            compare = auditService.getAutoCompareAuditMessage(params.id)
        }

        [message: results?.message, compare: compare?.message, userDetails: userDetails.user, layoutContent: 'adminLayout']
    }

    def reloadSiteMetadata() {
        def sites = []
        if (params.siteId) {
            sites << siteService.get(params.siteId)
        }
        else {
            sites = siteService.list()
        }

        for (site in sites) {
             def siteId = site["siteId"]
             def geometry = site["extent"]["geometry"]
             if (geometry)
             if (geometry.containsKey("centre")) {
                 def updatedSite = [:]
                 updatedSite["extent"] = site["extent"]
                 siteService.update(siteId, updatedSite)
             }

        }
        def result = [result: "success"]
        render result as JSON
    }

    @PreAuthorise(accessLevel = 'alaAdmin', redirectController = "admin")
    def assignPOIIds() {
        def errors = []
        def count = 0
        def sites = siteService.list()
        for (site in sites) {
            try {
                siteService.update(site.siteId, [poi:site.poi])
                count++
            }
            catch (Exception e) {
                errors << e.message
            }
        }
        def result = [count:count, errors:errors]
        render result as JSON
    }

    @PreAuthorise(accessLevel = 'alaAdmin', redirectController = "admin")
    def migratePhotoPoints() {
        if (params.outputId) {
            def output = outputService.get(params.outputId)
            adminService.migratePhotoPoints([output])
        }
        else {
            adminService.migratePhotoPoints()
        }
        render text:'ok'
    }

    @PreAuthorise(accessLevel = 'alaAdmin', redirectController = "admin")
    def manageHubs() {
        render view:'editHub', model:[programsModel: metadataService.programsModel(), roles:roleService.getHubRoles()]
    }

    @PreAuthorise(accessLevel = 'alaAdmin', redirectController = "admin")
    def listHubs() {
        List hubs = settingService.listHubs()?.collect{it.urlPath}
        render hubs as JSON
    }

    @PreAuthorise(accessLevel = 'alaAdmin', redirectController = "admin")
    def loadHubSettings(String id) {
        HubSettings hubSettings = settingService.getHubSettings(id)
        if (!hubSettings) {
            hubSettings = new HubSettings()
        }
        render hubSettings as JSON
    }

    @PreAuthorise(accessLevel = 'alaAdmin', redirectController = "admin")
    @CacheEvict(value=['styleSheetCache'], allEntries = true)
    def saveHubSettings() {
        def json = request.JSON
        def documents = json.remove('documents')
        List bannerImages = json.templateConfiguration?.banner?.images

        documents.each { document ->
            def staged = bannerImages?.find {
                it.url == document.url
            }

            def logo = json.templateConfiguration?.footer?.logos?.find {
                it.url == document.url
            }

            def response = documentService.saveStagedImageDocument(document)
            if (response?.content.documentId) {
                def savedDoc = documentService.get(response.content.documentId)
                if (savedDoc.role == 'banner') {
                    staged.url = savedDoc.url
                }
                else if (savedDoc.role == 'logo') {
                    json.logoUrl = savedDoc.url
                }
                else if (savedDoc.role == 'footerlogo') {
                    logo.url = savedDoc.url
                }
            }

        }

        if(bannerImages.size()){
            json.bannerUrl = bannerImages[0].url;
        }

        HubSettings settings = new HubSettings(json)
        settingService.updateHubSettings(settings)
        if ( settings.hubId ) {
            searchService.clearCachedProjectsInHub(settings.hubId)
        }

        def message = [status:'ok']
        render message as JSON

    }


    def importSightingsData() {
        if (request instanceof MultipartHttpServletRequest) {
            def file = request.getFile('sightingsData')

            if (file) {
                def pActivity = projectActivityService.get(params.pActivityId)
                if (pActivity?.projectId) {
                    def model = metadataService.getActivityModel(pActivity.pActivityFormName)
                    def results = importService.importSightingsData(file.inputStream, pActivity.projectId, pActivity.pActivityFormName, model.outputs[0], params.pActivityId)

                    render results as JSON
                    return
                } else {
                    render contentType: 'text/json', status:400, text:'{"error":"Invalid project activity id"}'
                    return
                }
            }

        }

        render contentType: 'text/json', status:400, text:'{"error":"No file supplied"}'
    }

    @PreAuthorise(accessLevel = 'alaAdmin', redirectController = "admin")
    def syncSpeciesWithBie(){
        //It's a async task..
        webService.get("${grailsApplication.config.ecodata.service.url}/admin/initiateSpeciesRematch")
        render text: [message:'Species rematch initiated.'] as JSON, contentType: 'application/json'
    }

}
