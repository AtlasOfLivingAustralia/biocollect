package au.org.ala.biocollect.merit

import au.org.ala.biocollect.DateUtils
import grails.converters.JSON
import org.apache.http.HttpStatus
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import org.joda.time.DateTime

import java.text.SimpleDateFormat

class ProjectController {

    def projectService, metadataService, organisationService, commonService, activityService, userService, webService, roleService, grailsApplication, projectActivityService
    def siteService, documentService
    SearchService searchService

    static defaultAction = "index"
    static ignore = ['action','controller','id']

    def index(String id) {
        def project = projectService.get(id, 'brief')
        def roles = roleService.getRoles()

        if (!project || project.error) {
            flash.message = "Project not found with id: ${id}"
            if (project?.error) {
                flash.message += "<br/>${project.error}"
                log.warn project.error
            }
            redirect(controller: 'home', model: [error: flash.message])
        } else {
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
            def content = projectContent(project, user, programs)

            def model = [project: project,
                mapFeatures: commonService.getMapFeatures(project),
                isProjectStarredByUser: userService.isProjectStarredByUser(user?.userId?:"0", project.projectId)?.isProjectStarredByUser,
                user: user,
                roles: roles,
                admins: admins,
                activityTypes: projectService.activityTypesList(),
                metrics: projectService.summary(id),
                outputTargetMetadata: metadataService.getOutputTargetsByOutputByActivity(),
                organisations: metadataService.organisationList().list,
                programs: programs,
                today:DateUtils.format(new DateTime()),
                themes:metadataService.getThemesForProject(project),
                projectContent:content.model
            ]

            if(project.projectType == 'survey'){
                def activityModel = metadataService.activitiesModel().activities.findAll { it.category == "Assessment & monitoring" }
                model.projectActivities = projectActivityService?.getAllByProject(project.projectId, "docs")
                model.pActivityForms = activityModel.collect{[name: it.name, images: it.images]}
            }

            render view:content.view, model:model
        }
    }

    protected Map projectContent(project, user, programs) {

        boolean isSurveyProject = (project.projectType == 'survey')
        def model = isSurveyProject?surveyProjectContent(project, user):worksProjectContent(project, user)
        [view:projectView(project), model:model]
    }

    protected String projectView(project) {
        if (project.isExternal) {
            return 'externalCSProjectTemplate'
        }
        return project.projectType == 'survey' ? 'csProjectTemplate' : 'index'
    }

    protected Map surveyProjectContent(project, user) {
        [about:[label:'About', template:'aboutCitizenScienceProject', visible: true, type:'tab', projectSite:project.projectSite, click: "initialiseProjectArea"],
         news:[label:'News', visible: true, type:'tab'],
         documents:[label:'Resources', template:'/shared/listDocuments', useExistingModel: true, editable:false, filterBy: 'all', visible: !project.isExternal, imageUrl:resource(dir:'/images/filetypes'), containerId:'overviewDocumentList', type:'tab'],
         activities:[label:'Surveys', visible:!project.isExternal, template:'/projectActivity/list', showSites:true, site:project.sites, wordForActivity:'Survey', type:'tab'],
         data:[label:'Data', visible:true, template:'/bioActivity/allData', showSites:true, site:project.sites, wordForActivity:'Data', type:'tab'],
         admin:[label:'Admin', template:'internalCSAdmin', visible:(user?.isAdmin || user?.isCaseManager), type:'tab']]
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

        if (project) {
            def siteInfo = siteService.getRaw(project.projectSiteId)
            [project: project,
             siteDocuments: siteInfo.documents?:'[]',
             site: siteInfo.site,
             userOrganisations: groupedOrganisations.user ?: [],
             organisations: groupedOrganisations.other ?: [],
             programs: metadataService.programsModel()]
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
        // Prepopulate the project as appropriate.
        def project = [:]
        if (params.organisationId) {
            project.organisationId = params.organisationId
        }
        if (params.citizenScience) {
            project.isCitizenScience = true
            project.projectType = 'survey'
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
                project:project
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
                user: userService.getUser(),
                showTag: params.tag,
                downloadLink: createLink(controller: 'project', action: 'getProjectList', params: ['download' : true] )
        ]
    }

    def myProjects() {

    }

    def fields (){
        params = [
                'isSuitableForChildren', // child friendly
                'difficulty', // difficulty level
                'isDIY', // DIY
                'status', 'endDate', // active check field status
                'hasParticipantCost', // no cost
                'hasTeachingMaterials', // teaching material
                '', // mobile uses links to find it out
                '', // page size
                'asc','desc', // sort order
                'name', 'aim','organisationName', // sort fields
                'endDate' //'daysStatus' sort field has to use end data

        ]
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
        def result = id? projectService.update(id, values): projectService.create(values)
        log.debug "result is " + result
        if (documents && !result.error) {
            if (!id) id = result.resp.projectId
            documents.each { doc ->
                doc.projectId = id
                doc.isPrimaryProjectImage = doc.role == 'mainImage'
                if (doc.isPrimaryProjectImage || doc.role == documentService.ROLE_LOGO) doc.public = true
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
        if (projectSite && !result.error) {
            if (!id) id = result.resp.projectId
            if (!projectSite.projects)
                projectSite.projects = [id]
            else if (!projectSite.projects.contains(id))
                projectSite.projects += id
            def siteResult = siteService.updateRaw(values.projectSiteId, projectSite)
            if (siteResult.status == 'error')
                result = [error:'SiteService failed']
            else if (siteResult.status == 'created') {
                def updateResult = projectService.update(id, [projectSiteId: siteResult.id])
                if (updateResult.error) result = updateResult
            }
        }
        if (result.error) {
            render result as JSON
        } else {
            render result.resp as JSON
        }
    }

    @PreAuthorise
    def update(String id) {
        //params.each { println it }
        projectService.update(id, params)
        chain action: 'index', id: id
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

    def getProjectList(){
        String activeQuery
        GrailsParameterMap queryParams = new GrailsParameterMap([:], request)
        Map trimmedParams = commonService.parseParams(params)
        trimmedParams.status = params.boolean('status');
        trimmedParams.isCitizenScience = params.boolean('isCitizenScience');
        trimmedParams.isWorks = params.boolean('isWorks');
        trimmedParams.isSurvey = params.boolean('isSurvey')
        trimmedParams.query = "docType:project"
        trimmedParams.isUserPage = params.boolean('isUserPage');
        trimmedParams.hasParticipantCost = params.boolean('hasParticipantCost')
        trimmedParams.isSuitableForChildren = params.boolean('isSuitableForChildren')
        trimmedParams.isDIY = params.boolean('isDIY')
        trimmedParams.hasTeachingMaterials = params.boolean('hasTeachingMaterials')
        trimmedParams.isMobile = params.boolean('isMobile')

        List fq = [], projectType = []
        List immutableFq = params.list('fq')
        immutableFq.each {
            it? fq.push(it):null;
        }
        trimmedParams.fq = fq;

        if(trimmedParams.isCitizenScience){
            projectType.push('isCitizenScience:true')
            trimmedParams.isCitizenScience = null
        }

        if(trimmedParams.isSurvey){
            projectType.push('(projectType:survey AND isExternal:true)')
            trimmedParams.isSurvey = null
        }

        if(trimmedParams.isWorks){
            projectType.push('projectType:works')
            trimmedParams.isWorks = null
        }
        // append projectType to query. this is used by organisation page.
        trimmedParams.query += ' AND (' + projectType.join(' OR ') + ')'

        // query construction
        if(trimmedParams.q){
            trimmedParams.query += " AND " + trimmedParams.q;
            trimmedParams.q = null
        }

        if(trimmedParams.status){
            SimpleDateFormat sdf = new SimpleDateFormat('yyyy-MM-dd');
            activeQuery = "-(plannedEndDate:[* TO *] AND -plannedEndDate:>=${sdf.format( new Date())})";
            trimmedParams.query += ' AND ' + activeQuery;
            trimmedParams.status = null
        }

        if(trimmedParams.isUserPage){
            fq.push('admins:' + userService.getUser()?.userId);
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

        if(trimmedParams.difficulty){
            fq.push('difficulty:'+trimmedParams.difficulty);
            trimmedParams.difficulty = null
        }

        if(trimmedParams.organisationName){
            fq.push('organisationFacet:'+trimmedParams.organisationName);
            trimmedParams.organisationName = null
        }

        trimmedParams.each{ key, value ->
            if(value != null && value){
                queryParams.put(key, value)
            }
        }

        Map searchResult = searchService.getCitizenScienceProjects(queryParams);
        List projects = searchResult.hits?.hits;
        projects = projects.collect {
            Map doc = it._source;

            // no need to ship the whole link object down to browser
            def trimmedLinks = doc.links.collect {
                [
                        role: it.role,
                        url: it.url
                ]
            }

            Map siteGeom;
            doc?.sites?.each{ site ->
                if(doc?.projectSiteId == site.siteId){
                    siteGeom = site.extent?.geometry;
                }
            }

            [
                    projectId  : doc.projectId,
                    aim        : doc.aim,
                    coverage   : siteGeom,
                    description: doc.description,
                    difficulty : doc.difficulty,
                    endDate    : doc.plannedEndDate,
                    hasParticipantCost: doc.hasParticipantCost && true, // force it to boolean
                    hasTeachingMaterials: doc.hasTeachingMaterials && true, // force it to boolean
                    isDIY      : doc.isDIY && true, // force it to boolean
                    isExternal : doc.isExternal && true, // force it to boolean
                    isSuitableForChildren: doc.isSuitableForChildren && true, // force it to boolean
                    keywords   : doc.keywords,
                    links      : trimmedLinks,
                    name       : doc.name,
                    organisationId  : doc.organisationId,
                    organisationName: doc.organisationName ?: organisationService.getNameFromId(doc.organisationId),
                    scienceType: doc.scienceType,
                    startDate  : doc.plannedStartDate,
                    urlImage   : doc.imageUrl,
                    urlWeb     : doc.urlWeb,
                    plannedStartDate: doc.plannedStartDate,
                    plannedEndDate: doc.plannedEndDate
            ]
        }

        if (params.download as boolean) {
            response.setHeader("Content-Disposition","attachment; filename=\"projects.json\"");
            // This is returned to the browswer as a text response due to workaround the warning
            // displayed by IE8/9 when JSON is returned from an iframe submit.
            response.setContentType('text/plain;charset=UTF8')
        } else {
            response.setContentType('application/json')
        }

        render( text: [ projects:  projects, total: searchResult.hits?.total?:0 ] as JSON );
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

    @PreAuthorise(accessLevel = 'siteAdmin', redirectController ='home', redirectAction = 'index')
    def downloadProjectData() {
        String projectId = params.id

        if (!projectId) {
            render status:400, text: 'Required params not provided: id'
        }
        else{
            def path = "project/downloadProjectData/${projectId}"

            if (params.view == 'xlsx' || params.view == 'json') {
                path += ".${params.view}"
            }else{
                path += ".json"
            }
            def url = grailsApplication.config.ecodata.service.url + path
            webService.proxyGetRequest(response, url, true, true,120000)
        }
    }

    def getUserProjects(){
        UserDetails user = userService.user;
        JSON projects = projectService.userProjects(user);
        render(text: projects);
    }
}
