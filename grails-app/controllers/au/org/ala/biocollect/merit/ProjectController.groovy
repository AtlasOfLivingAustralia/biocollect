package au.org.ala.biocollect.merit

import au.org.ala.biocollect.DateUtils
import au.org.ala.biocollect.ProjectActivityService
import au.org.ala.biocollect.projectresult.Builder
import au.org.ala.biocollect.projectresult.Initiator
import au.org.ala.web.AuthService
import grails.converters.JSON
import org.apache.http.HttpStatus
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import org.joda.time.DateTime

import java.text.SimpleDateFormat

import static org.apache.http.HttpStatus.*

class ProjectController {

    ProjectService projectService
    MetadataService metadataService
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

    def grailsApplication

    static defaultAction = "index"
    static ignore = ['action','controller','id']
    static allowedMethods = [listRecordImages: "POST"]

    def index(String id) {
        def project = projectService.get(id, 'brief', false, params?.version)
        def roles = roleService.getRoles()

        if (!project || project.error) {
            flash.message = "Project not found with id: ${id}"
            if (project?.error) {
                flash.message += "<br/>${project.error}"
                log.warn project.error
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
            project.projectSite = project.sites?.find{it.siteId == project.projectSiteId}

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
            def messages = auditService.getAuditMessagesForProject(id)

            def model = [project: project,
                mapFeatures: commonService.getMapFeatures(project),
                isProjectStarredByUser: userService.isProjectStarredByUser(user?.userId?:"0", project.projectId)?.isProjectStarredByUser,
                user: user,
                roles: roles,
                admins: admins,
                activityTypes: projectService.activityTypesList(),
                metrics: projectService.summary(id),
                outputTargetMetadata: metadataService.getOutputTargetsByOutputByActivity(),
                organisations: metadataService.organisationList().list.collect { [organisationId: it.organisationId, name: it.name] },
                programs: programs,
                today:DateUtils.format(new DateTime()),
                themes:metadataService.getThemesForProject(project),
                projectContent:content.model,
                messages: messages?.messages,
                userMap: messages?.userMap,
                hideBackButton: true,
                projectSite: project.projectSite
            ]

            if(project.projectType == 'survey'){
                def activityModel = metadataService.activitiesModel().activities.findAll { it.category == "Assessment & monitoring" }
                model.projectActivities = projectActivityService?.getAllByProject(project.projectId, "docs", params?.version)
                model.pActivityForms = activityModel.collect{[name: it.name, images: it.images]}
            } else if(project.projectType == 'ecoscience'){
                def activityModel = metadataService.activitiesModel().activities.findAll { it.category == "Assessment & monitoring" }
                model.projectActivities = projectActivityService?.getAllByProject(project.projectId, "docs", params?.version)
                model.pActivityForms = activityModel.collect{[name: it.name, images: it.images]}
            }else if(project.projectType == 'works'){
                model.activities = activityService.activitiesForProject(project.projectId)
            }

            render view:content.view, model:model
        }
    }

    protected Map projectContent(project, user, programs, params) {

        boolean isSurveyProject = (project.projectType == 'survey')
        boolean isEcoScienceProject = (project.projectType == 'ecoscience')
        def model = isSurveyProject?surveyProjectContent(project, user, params):(isEcoScienceProject?ecoSurveyProjectContent(project, user):worksProjectContent(project, user))

        blogService.getProjectBlog(project)

        [view:projectView(project), model:model]
    }

    protected String projectView(project) {
        if (project.isExternal) {
            return 'externalCSProjectTemplate'
        }

        return project.projectType == 'survey' || project.projectType == 'ecoscience' ? 'csProjectTemplate' : 'index'
    }

    protected Map surveyProjectContent(project, user, params) {
        [about:[label:'About', template:'aboutCitizenScienceProject', visible: true, type:'tab', projectSite:project.projectSite],
         news:[label:'News', visible: true, type:'tab'],
         documents:[label:'Resources', template:'/shared/listDocuments', useExistingModel: true, editable:false, filterBy: 'all', visible: !project.isExternal, imageUrl:resource(dir:'/images/filetypes'), containerId:'overviewDocumentList', type:'tab'],
         activities:[label:'Surveys', visible:!project.isExternal, template:'/projectActivity/list', showSites:true, site:project.sites, wordForActivity:'Survey', type:'tab'],
         data:[label:'Data', visible:true, template:'/bioActivity/activities', showSites:true, site:project.sites, wordForActivity:'Data', type:'tab'],
         admin:[label:'Admin', template:'internalCSAdmin', visible:(user?.isAdmin || user?.isCaseManager) && !params.version, type:'tab']]
    }

    protected Map ecoSurveyProjectContent(project, user) {
        [about:[label:'About', template:'aboutCitizenScienceProject', visible: true, type:'tab', projectSite:project.projectSite],
         news:[label:'News', visible: true, type:'tab'],
         documents:[label:'Resources', template:'/shared/listDocuments', useExistingModel: true, editable:false, filterBy: 'all', visible: !project.isExternal, imageUrl:resource(dir:'/images/filetypes'), containerId:'overviewDocumentList', type:'tab'],
         activities:[label:'Surveys', visible:!project.isExternal, template:'/projectActivity/list', showSites:true, site:project.sites, wordForActivity:'Survey', type:'tab'],
         data:[label:'Data', visible:true, template:'/bioActivity/activities', showSites:true, site:project.sites, wordForActivity:'Data', type:'tab'],
         admin:[label:'Admin', template:'internalCSAdmin', visible:(user?.isAdmin || user?.isCaseManager) && !params.version, type:'tab']]
    }

    protected Map worksProjectContent(project, user) {
        [overview:[label:'Overview', visible: true, default: true, type:'tab', projectSite:project.projectSite],
         documents:[label:'Documents', visible: !project.isExternal, type:'tab'],
         activities:[label:'Activities', visible:!project.isExternal, disabled:!user?.hasViewAccess, wordForActivity:"Activity",type:'tab'],
         site:[label:'Sites', visible: !project.isExternal, disabled:!user?.hasViewAccess, wordForSite:'Site', editable:user?.isEditor == true, type:'tab'],
         dashboard:[label:'Dashboard', visible: !project.isExternal, disabled:!user?.hasViewAccess, type:'tab'],
         admin:[label:'Admin', visible:(user?.isAdmin || user?.isCaseManager), type:'tab']]
    }

    @PreAuthorise
    def edit(String id) {

        def project = projectService.get(id, 'all')
        // This will happen if we are returning from the organisation create page during an edit workflow.
        if (params.organisationId) {
            project.organisationId = params.organisationId
        }
        def user = userService.getUser()
        def groupedOrganisations = groupOrganisationsForUser(user.userId)
        def scienceTypes = projectService.getScienceTypes();
        def ecoScienceTypes = projectService.getEcoScienceTypes();

        if (project) {
            def siteInfo = siteService.getRaw(project.projectSiteId)
            [project: project,
             siteDocuments: siteInfo.documents?:'[]',
             site: siteInfo.site,
             userOrganisations: groupedOrganisations.user ?: [],
             organisations: groupedOrganisations.other ?: [],
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
        Map project = projectService.get(id, 'brief')

        if (project) {
            [project: project, text: settingService.getSettingText(SettingPageType.NEW_CITIZEN_SCIENCE_PROJECT_INTRO)]
        } else {
            forward(action: 'list', model: [error: 'no such id'])
        }
    }

    def create() {
        def user = userService.getUser()
        if (!user) {
            flash.message = "You do not have permission to perform that operation"
            redirect controller: 'home', action: 'index'
            return
        }
        def groupedOrganisations = groupOrganisationsForUser(user.userId)
        def scienceTypes = projectService.getScienceTypes();
        def ecoScienceTypes = projectService.getEcoScienceTypes();
        // Prepopulate the project as appropriate.
        def project = [:]
        if (params.organisationId) {
            project.organisationId = params.organisationId
        }
        if (params.citizenScience) {
            project.isCitizenScience = true
            project.projectType = 'survey'
        }
        if (params.works) {
            project.isWorks = true
            project.projectType = 'works'
        }
        if (params.ecoScience) {
            project.isEcoScience = true
            project.projectType = 'ecoscience'
        }
        // Default the project organisation if the user is a member of a single organisation.
        if (groupedOrganisations.user?.size() == 1) {
            project.organisationId = groupedOrganisations.user[0].organisationId
        }
        [
                organisationId: params.organisationId,
                siteDocuments: '[]',
                userOrganisations: groupedOrganisations.user ?: [],
                organisations: groupedOrganisations.other ?: [],
                programs: projectService.programsModel(),
                project:project,
                scienceTypes: scienceTypes,
                ecoScienceTypes: ecoScienceTypes
        ]
    }

    /**
     * Splits the list of organisations into two - one containing organisations that the user is a member of,
     * the other containing the rest.
     * @param the user id to use for the grouping.
     * @return [user:[], other:[]]
     */
    private Map groupOrganisationsForUser(userId) {

        def organisations = metadataService.organisationList().list ?: []
        def userOrgIds = userService.getOrganisationIdsForUserId(userId)

        organisations.groupBy{organisation -> organisation.organisationId in userOrgIds ? "user" : "other"}
    }

    def citizenScience() {
        [
                user                    : userService.getUser(),
                showTag                 : params.tag,
                downloadLink            : createLink(controller: 'project', action: 'search', params: [initiator:Initiator.biocollect.name(),'download': true]),
                showCitizenScienceBanner: true
        ]
    }

    def works() {
        [
                user                    : userService.getUser(),
                showTag                 : params.tag,
                downloadLink            : createLink(controller: 'project', action: 'search', params: [initiator:Initiator.biocollect.name(),'download': true]),
                showWorksBanner: true
        ]
    }

    def ecoScience() {
        [
                user                    : userService.getUser(),
                showTag                 : params.tag,
                downloadLink            : createLink(controller: 'project', action: 'search', params: [initiator:Initiator.biocollect.name(),'download': true]),
                showEcoScienceBanner: true
        ]
    }

    def myProjects() {
        [user: userService.getUser()]
    }

    /**
     * Updates existing or creates new output.
     *
     * If id is blank, a new project will be created
     *
     * @param id projectId
     * @return
     */
    def ajaxUpdate(String id) {
        def postBody = request.JSON
        log.debug "Body: ${postBody}"
        log.debug "Params: ${params}"

        Map project
        String name = postBody.name
        if (id && !name) {
            project = projectService.get(id, 'brief')
            name = project?.name
        }

        boolean validName = projectService.checkProjectName(name, id)
        if (!validName) {
            render status: 400, text: "Another project already exists with the name ${params.projectName}"
        } else {
            def values = [:]
            // filter params to remove keys in the ignore list
            postBody.each { k, v ->
                if (!(k in ignore)) {
                    values[k] = v
                }
            }

            // The rule currently is that anyone is allowed to create a project so we only do these checks for
            // existing projects.
            def userId = userService.getUser()?.userId
            if (id) {
                if (!projectService.canUserEditProject(userId, id)) {
                    render status:401, text: "User ${userId} does not have edit permissions for project ${id}"
                    log.debug "user not caseManager"
                    return
                }

                if (values.containsKey("planStatus") && values.planStatus =~ /approved/) {
                    // check to see if user has caseManager permissions
                    if (!projectService.isUserCaseManagerForProject(userId, id)) {
                        render status:401, text: "User does not have caseManager permissions for project"
                        log.warn "User ${userId} who is not a caseManager attempting to change planStatus for project ${id}"
                        return
                    }
                }
            } else if (!userId) {
                render status: 401, text: 'You do not have permission to create a project'
            }


            log.debug "json=" + (values as JSON).toString()
            log.debug "id=${id} class=${id?.getClass()}"
            def projectSite = values.remove("projectSite")
            def documents = values.remove('documents')
            def links = values.remove('links')
            def projectType = id ? projectService.get(id).projectType : values?.projectType

            String mainImageAttribution = values.remove("mainImageAttribution")
            String logoAttribution = values.remove("logoAttribution")

            def siteResult
            if (projectSite) {
                siteResult = siteService.updateRaw(values.projectSiteId, projectSite)
                if (siteResult.status == 'error') render status: 400, text: "SiteService failed."
                else if (siteResult.status != 'updated') values["projectSiteId"] = siteResult.id
            } else if (projectService.get(id)?.sites?.isEmpty()) {
                render status: 400, text: "No project site is defined."
            }

            if (!values?.associatedOrgs) values.put('associatedOrgs', [])

            def result = id? projectService.update(id, values): projectService.create(values)
            log.debug "result is " + result
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

                siteService.update(siteResult.id, projectSite)
            }
            if (result.error) {
                render result as JSON
            } else {
                render result.resp as JSON
            }
        }
    }

    @PreAuthorise
    def update(String id) {
        boolean validName = projectService.checkProjectName(params.projectName, params.id)
        if (!validName) {
            render status: 400, text: "Another project already exists with the name ${params.projectName}"
        } else {
            projectService.update(id, params)
            chain action: 'index', id: id
        }
    }

    @PreAuthorise(accessLevel = 'admin')
    def delete(String id) {
        def resp = projectService.delete(id)
        if(resp == HttpStatus.SC_OK){
            flash.message = 'Successfully deleted'
            render status:resp, text: flash.message
        } else {
            response.status = resp
            flash.errorMessage = 'Error deleting the project, please try again later.'
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

        GrailsParameterMap queryParams = buildProjectSearch(params)
        boolean skipDefaultFilters = params.getBoolean('skipDefaultFilters', false)
        Map searchResult = searchService.findProjects(queryParams, skipDefaultFilters);
        List projects = Builder.build(params, searchResult.hits?.hits)

        if (params.download as boolean) {
            response.setHeader("Content-Disposition","attachment; filename=\"projects.json\"");
            // This is returned to the browswer as a text response due to workaround the warning
            // displayed by IE8/9 when JSON is returned from an iframe submit.
            response.setContentType('text/plain;charset=UTF8')
        } else {
            response.setContentType('application/json')
        }
        response.setCharacterEncoding('UTF-8')
        render( text: [ projects:  projects, total: searchResult.hits?.total?:0 ] as JSON );
    }


    private GrailsParameterMap buildProjectSearch(GrailsParameterMap params){
        Builder.override(params)

        List difficulty = [], status =[]
        Map trimmedParams = commonService.parseParams(params)
        trimmedParams.max = params.max && params.max.isNumber() ? params.max : 20
        trimmedParams.offset = params.offset && params.offset.isNumber() ? params.offset : 0
        trimmedParams.status = params.list('status');
        trimmedParams.isCitizenScience = params.boolean('isCitizenScience');
        trimmedParams.isWorks = params.boolean('isWorks');
        trimmedParams.isBiologicalScience = params.boolean('isBiologicalScience')
        trimmedParams.isMERIT = params.boolean('isMERIT')
        trimmedParams.isMetadataSharing = params.boolean("isMetadataSharing")
        trimmedParams.query = "docType:project"
        trimmedParams.isUserPage = params.boolean('isUserPage');
        trimmedParams.isUserWorksPage = params.boolean('isUserWorksPage');
        trimmedParams.isUserEcoSciencePage = params.boolean('isUserEcoSciencePage');
        trimmedParams.hasParticipantCost = params.boolean('hasParticipantCost')
        trimmedParams.isSuitableForChildren = params.boolean('isSuitableForChildren')
        trimmedParams.isDIY = params.boolean('isDIY')
        trimmedParams.hasTeachingMaterials = params.boolean('hasTeachingMaterials')
        trimmedParams.isMobile = params.boolean('isMobile')
        trimmedParams.isContributingDataToAla = params.boolean('isContributingDataToAla')
        trimmedParams.difficulty = params.list('difficulty')
        trimmedParams.mobile = params.boolean('mobile')

        List fq = [], projectType = []
        List immutableFq = params.list('fq')
        immutableFq.each {
            it? fq.push(it):null;
        }
        trimmedParams.fq = fq;

        if (params?.hub == 'ecoscience') {
            trimmedParams.query += " AND projectType:ecoscience";
        }

        switch (trimmedParams.sort){
            case 'organisationSort':
            case 'nameSort':
                trimmedParams.order = 'ASC';
                break;
            case '_score':
                trimmedParams.order = 'DESC';
                break;
        }

        if(trimmedParams.isCitizenScience){
            projectType.push('isCitizenScience:true')
            trimmedParams.isCitizenScience = null
        }

        if(trimmedParams.isBiologicalScience){
            projectType.push('(projectType:survey AND isCitizenScience:false)')
            trimmedParams.isSurvey = null
        }

        if(trimmedParams.isWorks){
            projectType.push('(projectType:works AND isMERIT:false)')
            trimmedParams.isWorks = null
        }

        if(trimmedParams.isEcoScience){
            projectType.push('(projectType:ecoscience)')
        }

        if (trimmedParams.isMERIT) {
            projectType.push('isMERIT:true')
            trimmedParams.isMERIT = null
        }

        if(trimmedParams.difficulty){
            trimmedParams.difficulty.each{
                difficulty.push("difficulty:${it}")
            }
            trimmedParams.query += " AND (${difficulty.join(' OR ')})"
            trimmedParams.difficulty = null
        }

        if (projectType) {
            // append projectType to query. this is used by organisation page.
            trimmedParams.query += ' AND (' + projectType.join(' OR ') + ')'
        }

        if(trimmedParams.isMetadataSharing){
            trimmedParams.query += " AND (isMetadataSharing:true)"
            trimmedParams.isMetadataSharing = null
        }

        // query construction
        if(trimmedParams.q){
            trimmedParams.query += " AND " + trimmedParams.q;
            trimmedParams.q = null
        }

        if(trimmedParams.status){
            SimpleDateFormat sdf = new SimpleDateFormat('yyyy-MM-dd');
            // do not run if both active and completed is pressed
            if(trimmedParams.status.size()<2){
                trimmedParams.status.each{
                    switch (it){
                        case 'active':
                            status.push("-(plannedEndDate:[* TO *] AND -plannedEndDate:>=${sdf.format( new Date())})");
                            break;
                        case 'completed':
                            status.push("(plannedEndDate:<${sdf.format( new Date())})");
                            break;
                    }
                }
                trimmedParams.query += " AND (${status.join(' OR ')})";
            }
            trimmedParams.status = null
        }
        if (trimmedParams.isUserPage) {
            if (trimmedParams.mobile) {
                String username = request.getHeader(UserService.USER_NAME_HEADER_FIELD)
                String key = request.getHeader(UserService.AUTH_KEY_HEADER_FIELD)
                fq.push('admins:' + (username && key ? userService.getUserFromAuthKey(username, key)?.userId : ''))
            } else {
                fq.push('admins:' + userService.getUser()?.userId);
            }
            trimmedParams.isUserPage = null
        }

        if(trimmedParams.hasParticipantCost){
            fq.push('hasParticipantCost:false');
            trimmedParams.hasParticipantCost = null
        }

        if(trimmedParams.isSuitableForChildren){
            fq.push('isSuitableForChildren:true');
            trimmedParams.isSuitableForChildren = null
        }

        if(trimmedParams.isDIY){
            fq.push('isDIY:true');
            trimmedParams.isDIY = null
        }

        if(trimmedParams.hasTeachingMaterials){
            fq.push('hasTeachingMaterials:true');
            trimmedParams.hasTeachingMaterials = null
        }

        if(trimmedParams.isMobile){
            fq.push('isMobileApp:true');
            trimmedParams.isMobile = null
        }

        if(trimmedParams.isContributingDataToAla){
            fq.push('isContributingDataToAla:true');
            trimmedParams.isContributingDataToAla = null
        }

        if(trimmedParams.organisationName){
            fq.push('organisationFacet:'+trimmedParams.organisationName);
            trimmedParams.organisationName = null
        }


        GrailsParameterMap queryParams = new GrailsParameterMap([:], request)
        trimmedParams.each { key, value ->
            if (value != null && value) {
                queryParams.put(key, value)
            }
        }

        queryParams.put("geoSearchJSON", params.geoSearchJSON)

        params.url = grailsApplication.config.grails.serverURL
        queryParams
    }



    def species(String id) {
        def project = projectService.get(id, 'brief')
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
                render status:403, text: 'Permission denied'
            }
        } else if (adminUserId) {
            render status:400, text: 'Required params not provided: id'
        } else if (projectId) {
            render status:403, text: 'User not logged-in or does not have permission'
        } else {
            render status:500, text: 'Unexpected error'
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
            response.sendError(SC_FORBIDDEN, 'You are not authorized to view this page')
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
            response.sendError(SC_FORBIDDEN, 'You are not authorized to view this page')
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
            if (params?.hub == 'ecoscience') {
                payload.fq.push("projectType:ecoscience");
            }
            Map result = projectService.listImages(payload, params?.version) ?: [:];
            render contentType: 'application/json', text: result as JSON
        } catch (SocketTimeoutException sTimeout){
            render(status: SC_REQUEST_TIMEOUT, text: sTimeout.message)
        } catch( Exception e){
            render(status: SC_INTERNAL_SERVER_ERROR, text: e.message)
        }
    }

    def checkProjectName() {
        if (!params.projectName) {
            render status: SC_BAD_REQUEST, text: 'projectName is a required parameter'
        } else {
            boolean validName = projectService.checkProjectName(params.projectName, params.id)

            render ([validName: validName] as JSON)
        }
    }
}
