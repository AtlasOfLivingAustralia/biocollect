package au.org.ala.biocollect.merit

import au.org.ala.biocollect.*
import au.org.ala.biocollect.merit.hub.HubSettings
import au.org.ala.biocollect.projectresult.Builder
import au.org.ala.biocollect.projectresult.Initiator
import au.org.ala.ecodata.forms.UserInfoService
import au.org.ala.web.AuthService
import grails.converters.JSON
import grails.web.servlet.mvc.GrailsParameterMap
import org.apache.http.HttpStatus
import org.joda.time.DateTime
import org.springframework.context.MessageSource

import static org.apache.http.HttpStatus.*

class ProjectController {

    ProjectService projectService
    MetadataService metadataService
    OrganisationService organisationService
    CommonService commonService
    ActivityService activityService
    UserService userService
    WebService webService
    RoleService roleService
    ProjectActivityService projectActivityService
    SiteService siteService
    DocumentService documentService
    SettingService settingService
    SearchService searchService
    AuditService auditService
    AuthService authService
    BlogService blogService
    MessageSource messageSource
    VocabService vocabService
    FormSpeciesFieldParserService formSpeciesFieldParserService
    CollectoryService collectoryService
    PdfGenerationService pdfGenerationService
    UtilService utilService
    UserInfoService userInfoService

    //def grailsApplication

    static defaultAction = "index"
    static ignore = ['action','controller','id']
    static allowedMethods = [listRecordImages: "POST", "sendEmailToMembers": "POST"]
    static int MAX_FACET_TERMS = 500

    def index(String id) {
        def project = projectService.get(id, ProjectService.PRIVATE_SITES_REMOVED, false, params?.version)
        def roles = roleService.getRoles()

        if (!project || project.error) {
            flash.message = message(code: 'project.warn.idNotFound') + ": ${id}"
            if (project?.error) {
                flash.message += "<br/>${project.error}"
                log.warn project.error.toString()
            }
            redirect(controller: 'home', model: [error: flash.message])
        }
        else if (project.isMERIT) {
            // MERIT projects have different security / access rules to BioCollect so it's best to simply
            // redirect to MERIT to view the project.
            redirect(uri:grailsApplication.config.merit.project.url+'/'+id)
        }

        else {
            project.sites?.sort {it.name}


            if(project.sites?.find{it.siteId == project.projectSiteId}) {
                project.projectSite = project.sites?.find{it.siteId == project.projectSiteId}
            } else if(project.projectSiteId) {
                // Project site is missing, update site and sync project site info
                project.projectSite = siteService.get(project.projectSiteId, [view:'brief'])
                List projectIds = project.projectSite?.projects
                projectIds = projectIds?.findAll{it != '' && it != null} ?: []
                projectIds << project.projectId
                siteService.update(project.projectSiteId, [projects: projectIds])
            }

            if(project.origin){
                project.origin = messageSource.getMessage("facets.origin." + project.origin, [].toArray(), project.origin, Locale.default)
            }

            String view = 'project'
            def user = userService.getUser()
            def members = projectService.getMembersForProjectId(id)
            def admins = members.findAll{ it.role == "admin" }.collect{ it.userName }.join(",") // comma separated list of user email addresses

            if (user) {
                user = user.properties
                user.isAdmin = projectService.isUserAdminForProject(user.userId, id)?:false
                user.isCaseManager = projectService.isUserCaseManagerForProject(user.userId, id)?:false
                user.isEditor = projectService.canUserEditProject(user.userId, id)?:false
                user.hasViewAccess = projectService.canUserViewProject(user.userId, id)?:false
            }
            def programs = projectService.programsModel()
            def content = projectContent(project, user, programs, params)
            projectService.buildFieldsForTags (project)
            String occurrenceUrl = projectService.getOccurrenceUrl(project, view)
            String spatialUrl = projectService.getSpatialUrl(project, view, params.spotterId)
            Boolean isProjectContributingDataToALA = projectService.isProjectContributingDataToALA(project)
            def licences = collectoryService.licence()

            def model = [project: project,
                mapFeatures: commonService.getMapFeatures(project),
                isProjectStarredByUser: userService.isProjectStarredByUser(user?.userId?:"0", project.projectId)?.isProjectStarredByUser,
                user: user,
                roles: roles,
                admins: admins,
                activityTypes: projectService.activityTypesList(),
                metrics: project.projectType == projectService.PROJECT_TYPE_WORKS ? projectService.summary(id): [],
                outputTargetMetadata:  metadataService.getOutputTargetScores(),
                programs: programs,
                today:DateUtils.format(new DateTime()),
                themes:metadataService.getThemesForProject(project),
                projectContent:content.model,
                hideBackButton: true,
                projectSite: project.projectSite,
                occurrenceUrl: occurrenceUrl,
                spatialUrl: spatialUrl,
                isProjectContributingDataToALA: isProjectContributingDataToALA,
                licences: licences
            ]


            if(project.projectType in [ProjectService.PROJECT_TYPE_ECOSCIENCE, ProjectService.PROJECT_TYPE_CITIZEN_SCIENCE]){
                model.projectActivities = projectActivityService?.getAllByProject(project.projectId, "docs", params?.version, true)
                model.pActivityForms = projectService.supportedActivityTypes(project).collect{[name: it.name, images: it.images]}
                model.vocabList = vocabService.getVocabValues ()
                println model.pActivityForms
            }
            model.mobile = params.getBoolean('mobile', false)
            model.showBackButton = request.getHeader('referer') ? true:false
            if(projectService.isWorks(project)){
                model.activityTypes = projectService.addSpeciesFieldsToActivityTypesList(metadataService.activityTypesList(project.associatedProgram))
            }

            render view:content.view, model:model
        }
    }

    /*
     * Get list of surveys/project activities for a given project
     *
     * @param id projectId
     *
     * @return surveys/projectActivities
     *
     */
    def listSurveys(String id) {
        def projectActivities = []
        def project = projectService.get(id, ProjectService.PRIVATE_SITES_REMOVED, false, params?.version)
        if (project && project.projectType in [ProjectService.PROJECT_TYPE_ECOSCIENCE, ProjectService.PROJECT_TYPE_CITIZEN_SCIENCE]) {
            projectActivities = projectActivityService?.getAllByProject(project.projectId, "docs", params?.version)
        }

        render projectActivities as JSON
    }

    protected Map projectContent(project, user, programs, params) {
        def model, view
        if(projectService.isCitizenScience(project)){
            model = surveyProjectContent(project, user, params)
            view = 'csProjectTemplate'
        } else if(projectService.isEcoScience(project)) {
            model = ecoSurveyProjectContent(project, user)
            view = 'csProjectTemplate'
        } else {
            model = worksProjectContent(project, user)
            view = 'worksProjectTemplate'
        }
        blogService.getProjectBlog(project)

        [view:view, model:model]
    }

    protected Map surveyProjectContent(project, user, params) {
        List blog = blogService.getProjectBlog(project)
        Boolean hasNewsAndEvents = blog.find{it.type == 'News and Events'}
        Boolean hasProjectStories = blog.find{it.type == 'Project Stories'}

        Boolean hasLegacyNewsAndEvents = project.newsAndEvents as Boolean
        Boolean hasLegacyProjectStories = project.projectStories as Boolean

        def config = [about:[label:message(code: 'project.tab.about'), template:'aboutCitizenScienceProject', visible: true, type:'tab', projectSite:project.projectSite],
         news:[label:message(code: 'project.tab.blog'), template:'projectBlog', visible: true, type:'tab', blog:blog, hasNewsAndEvents: hasNewsAndEvents, hasProjectStories:hasProjectStories, hasLegacyNewsAndEvents: hasLegacyNewsAndEvents, hasLegacyProjectStories:hasLegacyProjectStories],
         documents:[label:message(code: 'project.tab.resources'), template:'/shared/listDocuments', useExistingModel: true, editable:false, filterBy: 'all', visible: true, containerId:'overviewDocumentList', type:'tab'],
         activities:[label:message(code: 'project.tab.surveys'), visible:!project.isExternal, template:'/projectActivity/list', showSites:true, site:project.sites, wordForActivity:'Survey', type:'tab'],
         data:[label:message(code: 'project.tab.data'), visible:true, template:'/bioActivity/activities', showSites:true, site:project.sites, wordForActivity:'Data', type:'tab'],
         admin:[label:message(code: 'project.tab.admin'), template:'CSAdmin', visible:(user?.isAdmin || user?.isCaseManager) && !params.version, type:'tab', hasLegacyNewsAndEvents: hasLegacyNewsAndEvents, hasLegacyProjectStories:hasLegacyProjectStories]]

        if(project.isExternal) {
            config.remove('data')
            config.remove('activites')
        }

        HubSettings hubConfig = SettingService.hubConfig
        if (hubConfig?.content?.hideProjectBlogTab == true) {
            config.remove('news')
        }

        config
    }

    protected Map ecoSurveyProjectContent(project, user) {
        List blog = blogService.getProjectBlog(project)
        Boolean hasNewsAndEvents = blog.find{it.type == 'News and Events'}
        Boolean hasProjectStories = blog.find{it.type == 'Project Stories'}

        Boolean hasLegacyNewsAndEvents = project.newsAndEvents as Boolean
        Boolean hasLegacyProjectStories = project.projectStories as Boolean

        def config = [about:[label:message(code: 'project.tab.about'), template:'aboutCitizenScienceProject', visible: true, type:'tab', projectSite:project.projectSite],
         news:[label:message(code: 'project.tab.blog'), template:'projectBlog', visible: true, type:'tab', blog:blog, hasNewsAndEvents: hasNewsAndEvents, hasProjectStories:hasProjectStories, hasLegacyNewsAndEvents: hasLegacyNewsAndEvents, hasLegacyProjectStories:hasLegacyProjectStories],
         documents:[label:message(code: 'project.tab.resources'), template:'/shared/listDocuments', useExistingModel: true, editable:false, filterBy: 'all', visible: true, containerId:'overviewDocumentList', type:'tab'],
         activities:[label:message(code: 'project.tab.surveys'), visible:!project.isExternal, template:'/projectActivity/list', showSites:true, site:project.sites, wordForActivity:'Survey', type:'tab'],
         data:[label:message(code: 'project.tab.data'), visible:true, template:'/bioActivity/activities', showSites:true, site:project.sites, wordForActivity:'Data', type:'tab'],
         admin:[label:message(code: 'project.tab.admin'), template:'CSAdmin', visible:(user?.isAdmin || user?.isCaseManager) && !params.version, type:'tab', hasLegacyNewsAndEvents: hasLegacyNewsAndEvents, hasLegacyProjectStories:hasLegacyProjectStories]]

        if(project.isExternal) {
            config.remove('data')
            config.remove('activites')
        }

        HubSettings hubConfig = SettingService.hubConfig
        if (hubConfig?.content?.hideProjectBlogTab == true) {
            config.remove('news')
        }

        config
    }

    protected Map worksProjectContent(project, user) {
        def activities = activityService.activitiesForProject(project.projectId)
        activities.each { activity ->
            activity.typeCategory = metadataService.getActivityModel(activity.type)?.type
        }
        def risksAndThreatsVisible = metadataService.isOptionalContent('Risks and Threats', project.associatedProgram, project.associatedSubProgram)
        def canViewRisks = risksAndThreatsVisible && (user?.hasViewAccess || user?.isEditor)

        List blog = blogService.getProjectBlog(project)
        Boolean hasNewsAndEvents = blog.find{it.type == 'News and Events'}
        Boolean hasProjectStories = blog.find{it.type == 'Project Stories'}

        Boolean hasLegacyNewsAndEvents = project.newsAndEvents as Boolean
        Boolean hasLegacyProjectStories = project.projectStories as Boolean

        Boolean canEditSites = projectService.canUserEditSitesForProject(user?.userId, project.projectId)

        // Add a human readable name of the last user to update the project plan.
        if (project.custom?.details?.lastUpdatedBy) {
            project.custom.details.lastUpdatedDisplayName = authService.getUserForUserId(project.custom?.details?.lastUpdatedBy, false)?.displayName ?: 'Unknown user'
        }


        Map content = [overview:[label:message(code: 'project.tab.about'), template:'aboutCitizenScienceProject', visible: true, default: true, type:'tab', projectSite:project.projectSite],
                       news:[label:message(code: 'project.tab.blog'), template:'projectBlog', visible: true, type:'tab', blog:blog, hasNewsAndEvents: hasNewsAndEvents, hasProjectStories:hasProjectStories, hasLegacyNewsAndEvents: hasLegacyNewsAndEvents, hasLegacyProjectStories:hasLegacyProjectStories],
                       documents:[label:message(code: 'project.tab.resources'), template:'/shared/listDocuments', useExistingModel: true, editable:false, filterBy: 'all', visible: true, containerId:'overviewDocumentList', type:'tab', project:project],
                       activities:[label:message(code: 'project.tab.surveys'), template:'/shared/activitiesWorks', visible:!project.isExternal, disabled:!user?.hasViewAccess, wordForActivity:"Activity",type:'tab', activities:activities ?: [], sites:project.sites ?: [], showSites:false],
                       site:[label:message(code: 'project.tab.sites'), template:'/site/worksSites', visible: !project.isExternal, disabled:!user?.hasViewAccess, wordForSite:'Site', canEditSites: canEditSites, type:'tab'],
                       meriPlan:[label:'Project Plan', disable:false, visible:user?.isEditor, meriPlanVisibleToUser: user?.isEditor, canViewRisks: canViewRisks, type:'tab', template:'viewMeriPlan'],
                       outcomes:[label:'Outcomes', disable:false, visible:user?.isEditor, type:'tab', template:'outcomes'],
                       dashboard:[label:'Dashboard', visible: !project.isExternal, disabled:!user?.hasViewAccess, type:'tab', activities:activities],
                       admin:[label:'Admin', template:'worksAdmin', visible:(user?.isAdmin || user?.isCaseManager) && !params.version, type:'tab', hasLegacyNewsAndEvents: hasLegacyNewsAndEvents, hasLegacyProjectStories:hasLegacyProjectStories],
                       ]

        HubSettings hubConfig = SettingService.hubConfig
        if (hubConfig?.content?.hideProjectBlogTab == true) {
            content.remove('news')
        }

        if(!params.userIsProjectAdmin){
            content.remove('admin')
        }

        if(!params.userCanEditProject){
            content.remove('activities')
            content.remove('site')
            content.remove('meriPlan')
            content.remove('dashboard')
        }

        content
    }

    @PreAuthorise(accessLevel = 'admin')
    def edit(String id) {

        def project = projectService.get(id, ProjectService.PRIVATE_SITES_REMOVED)
        // This will happen if we are returning from the organisation create page during an edit workflow.
        if (params.organisationId) {
            project.organisationId = params.organisationId
        }

        def scienceTypes = projectService.getScienceTypes();
        def ecoScienceTypes = projectService.getEcoScienceTypes();

        if (project) {
            def siteInfo = siteService.getRaw(project.projectSiteId)
            [project: project,
             siteDocuments: siteInfo.documents?:'[]',
             site: siteInfo.site,
             programs: metadataService.programsModel(),
             scienceTypes: scienceTypes,
             ecoScienceTypes: ecoScienceTypes
            ]

        } else {
            forward(action: 'list', model: [error: 'no such id'])
        }
    }

    @PreAuthorise
    def newProjectIntro(String id) {
        Map project = projectService.get(id, ProjectService.PRIVATE_SITES_REMOVED)

        if (project) {
            [project: project, text: settingService.getSettingText(SettingPageType.NEW_CITIZEN_SCIENCE_PROJECT_INTRO)]
        } else {
            forward(action: 'list', model: [error: 'no such id'])
        }
    }

    def create() {
        def user = userService.getUser()
        if (!user) {
            flash.message = message(code:'project.permission')
            redirect controller: 'home', action: 'index'
            return
        }
        def scienceTypes = projectService.getScienceTypes();
        def ecoScienceTypes = projectService.getEcoScienceTypes();
        // Prepopulate the project as appropriate.
        def project = [:]
        if (params.organisationId) {
            project.organisationId = params.organisationId
        }
        if (params.citizenScience) {
            project.isCitizenScience = true
            project.projectType = ProjectService.PROJECT_TYPE_CITIZEN_SCIENCE
        }
        if (params.works) {
            project.isWorks = true
            project.projectType = ProjectService.PROJECT_TYPE_WORKS
        }
        if (params.ecoScience) {
            project.isEcoScience = true
            project.projectType = ProjectService.PROJECT_TYPE_ECOSCIENCE
        }

        HubSettings hub = SettingService.getHubConfig()
        if (hub && hub.defaultProgram) {
            project.associatedProgram = hub.defaultProgram
        }

        def userOrgIds = userService.getOrganisationIdsForUserId(user.userId)

        // If organisation id is passed as parameter, then select it.
        // Otherwise, select an organisation this user is a member.
        if( userOrgIds || params.organisationId){
            String orgId = params.organisationId
            orgId = orgId?: userOrgIds ? userOrgIds[0] : null

            if(orgId){
                def userOrganisation = organisationService.get(orgId)
                project.organisationId = userOrganisation.organisationId
                project.organisationName = userOrganisation.name
            }
        }

        [
                organisationId: params.organisationId,
                siteDocuments: '[]',
                programs: projectService.programsModel(),
                project:project,
                scienceTypes: scienceTypes,
                ecoScienceTypes: ecoScienceTypes
        ]
    }


    def myProjects() {
        Map result = projectFinder()
        result.isUserPage = true
        HubSettings hubConfig = SettingService.hubConfig
        result.showProjectDownloadButton = hubConfig.showProjectFinderDownloadButton() && userService.doesUserHaveHubRole(RoleService.PROJECT_ADMIN_ROLE)
        render view: 'projectFinder',  model:  result
    }

    def projectFinder() {
        Map result =
        [
                user                    : userService.getUser(),
                showTag                 : params.tag,
                downloadLink            : createLink(controller: 'project', action: 'search', params: [initiator:Initiator.biocollect.name(),'download': true])
        ]

        HubSettings hubConfig = SettingService.hubConfig
        if(hubConfig.defaultFacetQuery.contains('isWorks:true')) {
            result.isWorks = true
            result.associatedPrograms = projectService.programsModel().programs.findAll{!it?.readOnly}
        }

        if(hubConfig.defaultFacetQuery.contains('isEcoScience:true')) {
            result.isEcoScience = true
            result.associatedPrograms = projectService.programsModel().programs.findAll{!it?.readOnly}
        }

        if(hubConfig.defaultFacetQuery.contains('isCitizenScience:true')) {
            result.isCitizenScience = true
        }

        result
    }

    def homePage () {
        HubSettings hubSettings = SettingService.hubConfig
        if (hubSettings.overridesHomePage()) {
            if(hubSettings.isHomePagePathSimple()){
                Map result = hubSettings.getHomePageControllerAndAction()
                // avoid infinite loop
                if(result.controller != 'project' && result.action != 'homePage'){
                    forward(result)
                    return
                }
            } else {
                redirect([uri: hubSettings['homePagePath'] ])
                return
            }
        }

        forward(action: 'projectFinder')
    }

    /**
     * Updates existing project metadata. Only project admin can edit this information.
     *
     * @param id projectId
     * @return
     */
    @PreAuthorise(accessLevel='admin')
    def ajaxUpdate(String id) {
        createOrUpdate(id)
    }

    /**
     * Create a new project. Any logged in user can create a new project.
     * @return
     */
    @PreAuthorise(accessLevel="loggedInUser")
    def ajaxCreate(){
        createOrUpdate();
    }

    private void createOrUpdate(String id) {
        def postBody = request.JSON
        log.debug "Body: ${postBody}"
        log.debug "Params: ${params}"

        def values = [:]
        // filter params to remove keys in the ignore list
        postBody.each { k, v ->
            if (!(k in ignore)) {
                values[k] = v
            }
        }

        projectService.buildTags(values)


        log.debug "json=" + (values as JSON).toString()
        log.debug "id=${id} class=${id?.getClass()}"
        def projectSite = values.remove("projectSite")
        def documents = values.remove('documents')
        def links = values.remove('links')
        final Map project = id ? projectService.get(id) : null
        def projectType = id ? project.projectType : values?.projectType

        String mainImageAttribution = values.remove("mainImageAttribution")
        String logoAttribution = values.remove("logoAttribution")

        def siteResult
        if (projectSite) {
            siteResult = siteService.updateRaw(values.projectSiteId, projectSite)
            if (siteResult.status == 'error'){
                render status: HttpStatus.SC_INTERNAL_SERVER_ERROR, text: "${siteResult.message}"
                return
            }
            else if (siteResult.status != 'updated') values["projectSiteId"] = siteResult.id
        } else if (project?.sites?.isEmpty()) {
            render status: HttpStatus.SC_BAD_REQUEST, text: "No project site is defined."
            return
        }

        if (!values?.associatedOrgs) values.put('associatedOrgs', [])

        def result = id ? projectService.update(id, values) : projectService.create(values)
        log.info "Project creation result: " + result
        if (documents && !result.error) {
            if (!id) id = result.resp.projectId
            documents.each { doc ->
                doc.projectId = id
                if (doc.role == "mainImage") {
                    doc.isPrimaryProjectImage = true
                    doc.attribution = mainImageAttribution
                    doc.public = true
                } else if (doc.role == documentService.ROLE_LOGO) {
                    doc.public = true
                    doc.attribution = logoAttribution
                }
                documentService.saveStagedImageDocument(doc)
            }
        }
        if (links && !result.error) {
            if (!id) id = result.resp.projectId
            links.each { link ->
                link.projectId = id
                documentService.saveLink(link)
            }
        }

        if (siteResult && !result.error) {
            if (!id) id = result.resp.projectId
            if (!projectSite.projects || (projectSite.projects.size() == 1 && projectSite.projects.get(0).isEmpty()))
                projectSite.projects = [id]
            else if (!projectSite.projects.contains(id))
                projectSite.projects += id

            def siteUpdate = siteService.update(values.projectSiteId, projectSite)
            log.info(siteUpdate.toString())
        }
        if (result.error) {
            log.error(result.error.toString());
            render result as JSON
        } else {
            render result.resp as JSON
        }
    }

    @PreAuthorise
    def update(String id) {
        projectService.update(id, params)
        chain action: 'index', id: id
    }

    @PreAuthorise(accessLevel = 'admin')
    def updateProjectPlan(String id) {
        Map result
        if (!id) {
            result.status = 400
            result.error = message(code: 'project.warn.supplyId')
        }
        else {
            Map plan = request.JSON
            result = projectService.updateProjectPlan(id, plan)

        }
        render result as JSON
    }

    @PreAuthorise(accessLevel = 'admin')
    def delete(String id) {
        def resp = projectService.delete(id)
        if(resp == HttpStatus.SC_OK){
            flash.message = message(code:'g.deleteSuccess')
            render status:resp, text: flash.message
        } else {
            response.status = resp
            flash.errorMessage = message(code: 'project.warn.cannotDelete')
            render status:resp, error: flash.errorMessage
        }
    }

    def list() {
        // will show a list of projects
        // but for now just go home
        forward(controller: 'home')
    }

    /**
     * Search project data and customize the result set based on initiator (ala, scistarter and biocollect).
     */
    def search() {

        GrailsParameterMap queryParams = projectService.buildProjectSearch(params, request)
        boolean skipDefaultFilters = params.getBoolean('skipDefaultFilters', false)
        Map searchResult = searchService.findProjects(queryParams, skipDefaultFilters);
        List projects = Builder.build(params, searchResult.hits?.hits, grailsApplication, messageSource)
        List facets

        // format facets to a way acceptable for JS view model
        if(searchResult.facets){
            HubSettings hub = SettingService.hubConfig
            List allFacetConfig = hub.getFacetConfigForPage('projectFinder') ?: projectService.getDefaultFacets()
            List facetConfig = HubSettings.getFacetConfigForElasticSearch(allFacetConfig)
            List facetList = params.facets ? params.facets?.split(',') : facetConfig?.collect { it.name }
            facets = searchService.standardiseFacets (searchResult.facets, facetList)

            List presenceAbsenceFacetConfig = HubSettings.getFacetConfigWithPresenceAbsenceSetting(allFacetConfig)
            if(presenceAbsenceFacetConfig){
                facets = searchService.standardisePresenceAbsenceFacets(facets, presenceAbsenceFacetConfig)
            }

            List histogramFacetConfig = HubSettings.getFacetConfigWithHistogramSetting(allFacetConfig)
            if(histogramFacetConfig){
                facets = searchService.standardiseHistogramFacets(facets, histogramFacetConfig)
            }


            // if facet is provided by client do not add special facets
            if(!params.facets){
                facets = projectService.addSpecialFacets(facets)
            }

            facets = projectService.addFacetExpandCollapseState(facets)
            utilService.getDisplayNamesForFacets(facets, allFacetConfig)
        }

        projects?.each{ Map project ->
            projectService.buildFieldsForTags (project)
        }

        if (params.download as boolean) {
            response.setHeader("Content-Disposition","attachment; filename=\"projects.json\"");
            // This is returned to the browswer as a text response due to workaround the warning
            // displayed by IE8/9 when JSON is returned from an iframe submit.
            response.setContentType('text/plain;charset=UTF8')
        } else {
            response.setContentType('application/json')
        }
        response.setCharacterEncoding('UTF-8')
        render( text: [ projects:  projects, total: searchResult.hits?.total?:0, facets: facets ] as JSON );
    }

    /**
     * Despite the name, this method will return all projects matched by the query, but the contents of the
     * download are tailored to works type projects.  Specificially Outcomes and Budget information which
     * is only available in works projects is included.
    */
    def downloadWorksProjects() {
        if (userService.doesUserHaveHubRole(RoleService.PROJECT_ADMIN_ROLE)) {

            String downloadUrl = "${grailsApplication.config.ecodata.service.url}/search/downloadAllData.xlsx"
            params.fq = params.getList('fq[]')
            GrailsParameterMap downloadParams = projectService.buildProjectSearch(params, request)

            downloadParams.reportType="works"
            downloadParams.max=1000
            downloadParams.offset=0
            downloadParams.downloadUrl = g.createLink(controller:'download', action:'downloadProjectDataFile', absolute: true)+'/'
            searchService.addDefaultFacetQuery(downloadParams)
            downloadUrl += "?"+commonService.buildUrlParamsFromMap(downloadParams)
            Map resp = webService.doPostWithParams(downloadUrl, [:])
            render resp as JSON
        }
        else {
            render status:401, text: "Unauthorized"
        }

    }

    /**
     *
     * Uses same criteria as search to retreive the projects with site information suitable to render a shared/_sites.gsp map
     */
    def mapSearch() {
        GrailsParameterMap queryParams = projectService.buildProjectSearch(params, request)
        render searchService.allProjectsWithSites(queryParams) as JSON
    }

    def species(String id) {
        def project = projectService.get(id, ProjectService.PRIVATE_SITES_REMOVED)
        def activityTypes = metadataService.activityTypesList();
        render view:'/species/select', model: [project:project, activityTypes:activityTypes]
    }

    /**
     * Star or unstar a project for a user
     * Action is determined by the URI endpoint, either: /add | /remove
     *
     * @return
     */
    def starProject() {
        String act = params.id?.toLowerCase() // rest path starProject/add or starProject/remove
        String userId = params.userId
        String projectId = params.projectId

        if (act && userId && projectId) {
            if (act == "add") {
                render userService.addStarProjectForUser(userId, projectId) as JSON
            } else if (act == "remove") {
                render userService.removeStarProjectForUser(userId, projectId) as JSON
            } else {
                render status:400, text: 'Required endpoint (path) must be one of: add | remove'
            }
        } else {
            render status:400, text: 'Required params not provided: userId, projectId'
        }
    }

    def getMembersForProjectId() {
        String projectId = params.id
        def adminUserId = userService.getCurrentUserId()

        if (projectId && adminUserId) {
            if (projectService.isUserAdminForProject(adminUserId, projectId) || projectService.isUserCaseManagerForProject(adminUserId, projectId)) {
                render projectService.getMembersForProjectId(projectId) as JSON
            } else {
                render status:403, text: message(code: 'g.noPermission')
            }
        } else if (adminUserId) {
            render status:400, text: message(code: 'project.warn.missingParamsId')
        } else if (projectId) {
            render status:403, text:  message(code:'project.warn.notLoggedIn')
        } else {
            render status:500, text: message(code:'g.unexpectedError')
        }
    }

    def getMembersForProjectIdPaginated() {
        String projectId = params.id
        def adminUserId = userService.getCurrentUserId()

        if (projectId && adminUserId) {
            if (projectService.isUserAdminForProject(adminUserId, projectId) || projectService.isUserCaseManagerForProject(adminUserId, projectId)) {
                def results = projectService.getMembersForProjectPerPage(projectId, params.int('start'), params.int('length'))
                asJson results

            } else {
                response.sendError(SC_FORBIDDEN, message(code: 'g.noPermission'))
            }
        } else if (adminUserId) {
            response.sendError(SC_BAD_REQUEST, message(code: 'project.warn.missingParamsId'))
        } else if (projectId) {
            response.sendError(SC_FORBIDDEN, message(code:'project.warn.notLoggedIn'))
        } else {
            response.sendError(SC_INTERNAL_SERVER_ERROR, message(code:'g.unexpectedError'))
        }
    }

    def getUserProjects(){
        UserDetails user = userService.user;
        JSON projects = projectService.userProjects(user);
        render(text: projects);
    }

    def auditMessageDetails() {
        String userId = authService.getUserId()
        String projectId = params.projectId
        String compareId= params.compareId
        String skin

        Boolean isAdmin = projectService.isUserAdminForProject(userId, projectId)
        if(isAdmin) {
            def results = auditService.getAuditMessage(params.id as String)
            def userDetails = [:]
            Map compare
            if (results?.message) {
                userDetails = auditService.getUserDetails(results?.message?.userId)
            }

            if(compareId){
                compare = auditService.getAuditMessage(params.compareId as String)
            } else {
                compare = auditService.getAutoCompareAuditMessage(params.id)
            }

            skin = SettingService.getHubConfig().skin
            render view: '/admin/auditMessageDetails', model: [message: results?.message, compare: compare?.message, userDetails: userDetails.user, layoutContent: skin, backToProject: true]
        } else {
            response.sendError(SC_FORBIDDEN, message(code: 'project.warn.notAuthorized'))
        }
    }

    def getAuditMessagesForProject(){
        String userId = authService.getUserId()
        String projectId = params.id
        Boolean isAdmin = projectService.isUserAdminForProject(userId, projectId)
        if(isAdmin) {
            String sort = params.sort?:''
            String orderBy = params.orderBy?:''
            Integer start = params.int('start')
            Integer size = params.int('length')
            String q = params.q
            Long version = params.long('version')

            def results = auditService.getAuditMessagesForProjectPerPage(projectId,start,size,sort,orderBy,q)
            def data = []
            results.data.each{ msg ->
                if (!version || DateUtils.parse(msg.date).millis < version) {
                    msg['date'] = DateUtils.displayFormatWithTime(msg['date']);
                    data << msg
                }

            }
            results.data = data
            asJson results;
        } else {
            response.sendError(SC_FORBIDDEN, message(code: 'project.warn.notAuthorized'))
        }
    }

    def asJson(json) {
        render(contentType: 'application/json', text: json as JSON)
    }

    /**
     * list images in the context of a project, all records or my records
     * payload.view parameter is used to differentiate these context
     */
    def listRecordImages() {
        try{
            Map payload = request.JSON
            payload.max = payload.max ?: 10;
            payload.offset = payload.offset ?: 0;
            payload.userId = authService.getUserId()
            payload.order = payload.order ?: 'DESC';
            payload.sort = payload.sort ?: 'lastUpdated';
            payload.fq = payload.fq ?: []
            payload.fq.push('surveyImage:true');
            payload.hub = params.hub

            Map result = projectService.listImages(payload, params?.version) ?: [:];
            documentService.addLicenceDescription(result.documents);
            render contentType: 'application/json', text: result as JSON
        } catch (SocketTimeoutException sTimeout){
            render(status: SC_REQUEST_TIMEOUT, text: sTimeout.message)
        } catch( Exception e){
            render(status: SC_INTERNAL_SERVER_ERROR, text: e.message)
        }
    }

    /**
     * Get list of all countries
     * @return
     */
    def getCountries(){
        def countries = projectService.getCountries()
        render text: countries as JSON, contentType: 'application/json'
    }

    /**
     * Get list of all UN regions
     * @return
     */
    def getUNRegions(){
        def uNRegions = projectService.getUNRegions()
        render text: uNRegions as JSON, contentType: 'application/json'
    }

    /**
     * Get science type list for which data collection is supported.
     */
    def getDataCollectionWhiteList(){
        def whiteList = projectService.getDataCollectionWhiteList()
        render text: whiteList as JSON, contentType: 'application/json'
    }


    /**
     * Get list of facets for Elasticsearch's homepage index i.e. index used to search projects
     */
    def getFacets(){
        List facets = projectService.getFacets()
        render text: [facets: facets] as JSON, contentType: 'application/json'
    }

    //Search species by project activity species constraint.
    def searchSpecies(String id, String q, Integer limit, String output, String dataFieldName, String surveyName){

        def result = projectService.searchSpecies(id, q, limit, output, dataFieldName, surveyName)
        render result as JSON
    }

    @PreAuthorise(accessLevel = 'admin', redirectController ='home', redirectAction = 'index')
    def downloadShapefile(String id) {

        def url = grailsApplication.config.ecodata.baseURL + "/ws/project/${id}.shp"
        def resp = webService.proxyGetRequest(response, url, true, true,960000)
        if (resp.status != 200) {
            render view:'/error', model:[error:resp.error]
        }
    }

    @PreAuthorise(accessLevel = 'admin')
    def projectSitePhotos(String id) {

        Map project = projectService.get(id)
        List activities = activityService.activitiesForProject(id)
        siteService.addPhotoPointPhotosForSites(project.sites?:[], activities, [project])

        render template: 'sitessPhotoPoints', model:[project:project]

    }

    @PreAuthorise(accessLevel = 'admin')
    def projectSummaryReport(String id) {
        projectSummaryReportModel(id)
    }

    @PreAuthorise(accessLevel = 'admin')
    def projectSummaryReportPDF(String id) {

        Map reportUrlConfig = [controller: 'project', action: 'projectSummaryReportCallback', id: id]

        Map pdfGenParams = [:]
        if (params.orientation) {
            pdfGenParams.orientation = params.orientation
        }
        boolean result = pdfGenerationService.generatePDF(reportUrlConfig, pdfGenParams, response)
        if (!result) {
            render view: '/error', model: [error: "An error occurred generating the project report."]
        }

    }

    @PreAuthorise(accessLevel = 'admin')
    def sendEmailToMembers(String id) {
        if(grailsApplication.config.notification.enabled?.toBoolean()){
            Map payload = request.JSON
            List recipients = payload?.recipients
            String subject = payload?.subject
            String body = payload?.body

            if(id){
                if (recipients && subject && body) {
                    def result = projectService.sendEmailNotificationToMembers(subject, body, recipients, id)
                    if (result.success) {
                        render ( status: HttpStatus.SC_OK, text: result.message )
                    } else {
                        render ( status: HttpStatus.SC_INTERNAL_SERVER_ERROR, text: result.message )
                    }
                } else {
                    render ( status: HttpStatus.SC_BAD_REQUEST, text: "Missing parameters in payload - subject, recipients,  body" )
                }
            } else {
                render ( status: HttpStatus.SC_BAD_REQUEST, text: "Missing parameter - id" )
            }
        }
    }

    @PreAuthorise(accessLevel = 'admin')
    def sendTestEmail(String id) {
        if(grailsApplication.config.notification.enabled?.toBoolean()){
            Map payload = request.JSON
            String subject = payload?.subject
            String body = payload?.body

            if(id){
                if (subject && body) {
                    def result = projectService.sendTestEmail(subject, body)
                    if (result.success) {
                        render ( status: HttpStatus.SC_OK, text: result.message )
                    } else {
                        render ( status: HttpStatus.SC_INTERNAL_SERVER_ERROR, text: result.message )
                    }
                } else {
                    render ( status: HttpStatus.SC_BAD_REQUEST, text: "Missing parameters in payload - subject, recipients,  body" )
                }
            } else {
                render ( status: HttpStatus.SC_BAD_REQUEST, text: "Missing parameter - id" )
            }
        }
    }

    /**
     * This is designed as a callback from the PDF generation service.  It produces a HTML report that will
     * be converted into PDF.
     * @param id the project id
     */
    def projectSummaryReportCallback(String id) {

        if (pdfGenerationService.authorizePDF(request)) {
            Map model = projectSummaryReportModel(id)
            render view:'projectSummaryReport', model:model
        }
        else {
            render status:HttpStatus.SC_UNAUTHORIZED
        }
    }

    private Map projectSummaryReportModel(String id) {
        Map project = projectService.get(id, 'all')
        project.activities?.each { activity ->
            if (activity.siteId) {
                Map site = project.sites?.find{it.siteId == activity.siteId}
                activity.siteName = site?.name?:''
            }
            activity.typeCategory = metadataService.getActivityModel(activity.type)?.type
        }

        project.activities?.sort{ a,b -> a.plannedStartDate <=> b.plannedStartDate ?: a.dateCreated <=> b.dateCreated ?: a.description <=> b.description }

        Map metrics = projectService.summary(id)
        [project:project, metrics:metrics, activities:project.activities?:[]]
    }



}
