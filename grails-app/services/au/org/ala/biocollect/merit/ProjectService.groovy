package au.org.ala.biocollect.merit

import au.org.ala.biocollect.EmailService
import au.org.ala.biocollect.OrganisationService
import au.org.ala.biocollect.merit.hub.HubSettings
import grails.converters.JSON
import org.springframework.context.MessageSource

class ProjectService {

    //TODO refactor project type
    public static final PRIVATE_SITES_REMOVED  = 'privatesitesremoved'
    public static final String PROJECT_TYPE_CITIZEN_SCIENCE = 'survey'
    public static final String PROJECT_TYPE_CITIZEN_SCIENCE_TYPE_2 = 'citizenScience'
    public static final String PROJECT_TYPE_ECOSCIENCE = 'ecoScience'
    public static final String PROJECT_TYPE_WORKS = 'works'
        static  final MOBILE_APP_ROLE = [ "android",
                                          "blackberry",
                                          "iTunes",
                                          "windowsPhone"]

    public static final SPECIAL_FACETS = [
            [
                    name:'status',
                    total: 0,
                    terms: [ [ term: 'active', count: 0, title: 'Active'], [ term: 'completed', count: 0, title: 'Completed' ]],
                    type: 'terms'
            ],
            [
                    name:'plannedStartDate',
                    type: 'date',
                    total: 0,
                    terms: [ [ fromDate: '', toDate: ''] ],
                    type: 'date'
            ]
    ]
    public static final String PROJECT_FINDER_PAGE= 'projectFinder'


    WebService webService
    def grailsApplication
    SiteService siteService
    ActivityService activityService
    DocumentService documentService
    UserService userService
    MetadataService metadataService
    SettingService settingService
    EmailService emailService
    OrganisationService organisationService
    CacheService cacheService
    MessageSource messageSource
    SpeciesService speciesService
    FormSpeciesFieldParserService formSpeciesFieldParserService
    SearchService searchService

    def list(brief = false, citizenScienceOnly = false) {
        def params = brief ? '?brief=true' : ''
        if (citizenScienceOnly) params += (brief ? '&' : '?') + 'citizenScienceOnly=true'
        def resp = webService.getJson(grailsApplication.config.ecodata.service.url + '/project/' + params, 30000)
        resp.list
    }

    def listMyProjects(userId) {
        def resp = webService.getJson(grailsApplication.config.ecodata.service.url + '/permissions/getAllProjectsForUserId?id=' + userId, 30000)
        resp
    }

    def get(id, levelOfDetail = "", includeDeleted = false, version = null ) {

        def params = '?'
        params += "view=${levelOfDetail?:PRIVATE_SITES_REMOVED}&"
        params += "includeDeleted=${includeDeleted}&"
        params += version ? "version=${version}" : ''
        def project  = webService.getJson(grailsApplication.config.ecodata.service.url + '/project/' + id + params);
        return project;

    }

    def getRich(id) {
        get(id, 'rich')
    }

    def getActivities(project) {
        def list = []
        project.sites.each { site ->
            siteService.get(site.siteId)?.activities?.each { act ->
                list << activityService.constructName(act)
            }
        }
        list
    }

    def validate(props, projectId = null) {
        def error = null
        def updating = projectId != null
        def project = projectId ? get(projectId) : null
        def projectType = ((updating && !props?.projectType) ? project?.projectType : props?.projectType)
        def isWorks = projectType == PROJECT_TYPE_WORKS
        def isEcoScience = projectType == PROJECT_TYPE_ECOSCIENCE
        def termsNeeded = !(props.containsKey("isExternal") && props.isExternal)

        if (!updating && !props.containsKey("isExternal") && !isWorks) {
            //error, not null
            return "isExternal is missing"
        }

        if (updating) {
            if (project?.error) {
                return "invalid projectId"
            }
        }

        if (props.containsKey("organisationId")) {
            def org = organisationService.get(props.organisationId)
            if (org?.error) {
                //error, not valid org
                return "organisationId is not a valid organisationId"
            } else if (!props.containsKey("organisationName") || !org.name.equals(props.organisationName)) {
                //fix the organisation name
                props["organisationName"] = org.name
            }
        } else if (!updating) {
            //error, no org
            return "organisationId is missing"
        }

        if (!updating && !props.containsKey("plannedStartDate")) {
            //error, no start date
            return "plannedStartDate is missing"
        }

        if (props.containsKey("name")) {
            if (!props.name) {
                return "name cannot be emtpy"
            }
        } else if (!updating) {
            //error, no project name
            return "name is missing"
        }

        if (!updating && !props.containsKey("aim") && !isWorks) {
            //error, no project aim
            return "aim is missing"
        }

        if (!updating && !props.containsKey("description")) {
            //error, no project description
            return "description is missing"
        }

        if (!updating && !props.containsKey("scienceType") && !isEcoScience) {
            //error, no science type
            return "scienceType is missing"
        }

        if (!isEcoScience && !isWorks) {
            if (!updating && !props.containsKey("task")) {
                //error, no task
                return "task is missing"
            }
        }

        if (!isEcoScience) {
            if (props.containsKey("projectSiteId")) {
                def site = siteService.get(props.projectSiteId)
                if (site?.error) {
                    //error, invalid site
                    return "projectSiteId is not a valid projectSiteId"
                }
            } else if (!updating) {
                //error, no site id
                return "projectSiteId is missing"
            }
        }

        if (termsNeeded && props.containsKey("termsOfUseAccepted")) {
            if (!props.termsOfUseAccepted) {
                //error, terms of use not accepted
                return "termsOfUseAccepted is not true"
            }
        } else if (termsNeeded && !updating) {
            //error, no terms of use accepted
            return "termsOfUseAccepted is missing"
        }

        //funding must be Double
        if (props?.funding && !(props?.funding instanceof Double)) {
            try {
                props.funding = props?.funding.toDouble()
            } catch (err) {
                return 'funding is not a number'
            }
        }

        error
    }

    /**
     * Creates a new project and adds the user as a project admin.
     */
    def create(props) {
        Map result

        // set default map configuration for works project at the time of creation.
        if (isWorks(props)) {
            props.mapConfiguration = siteService.defaultMapConfiguration(props.projectSiteId)
        }

        //validate
        def error = validate(props)
        if (error) {
            result = [:]
            result.error = error
            result.detail = ''
        }

        def activities = props.remove('selectedActivities')

        // create a project in ecodata
        if (!result) result = webService.doPost(grailsApplication.config.ecodata.service.url + '/project/', props)

        String subject
        String body
        if (result?.resp?.projectId) {
            String projectId = result.resp.projectId
            // Add the user who created the project as an admin of the project
            userService.addUserAsRoleToProject(userService.getUser().userId, projectId, RoleService.PROJECT_ADMIN_ROLE)
            if (activities) {
                settingService.updateProjectSettings(projectId, [allowedActivities: activities])
            }

            subject = "New project ${props.name} was created by ${userService.currentUserDisplayName}"
            body = "User ${userService.currentUserId} (${userService.currentUserDisplayName}) has successfully created a new project ${props.name} with id ${projectId}"
        } else {
            subject = "An error occurred while creating a new project"
            body = "User ${userService.currentUserId} (${userService.currentUserDisplayName}) attempted to create a new project ${props.name}, but an error occurred during creation: ${result.detail} : ${result.error}."
        }

        searchService.clearCachedProjectsInHubs()
        emailService.sendEmail(subject, body, ["${grailsApplication.config.biocollect.support.email.address}"])

        result
    }

    def update(id, body, boolean skipEmailNotification = true) {
        def result

        //validate
        def error = validate(body, id)
        if (error) {
            result = [:]
            result.error = error
            result.detail = ''
        }

        if (!result) result = webService.doPost(grailsApplication.config.ecodata.service.url + '/project/' + id, body)

        if (!skipEmailNotification) {
            String projectName = get(id, "brief")?.name
            String subject = "Project ${projectName ?: id} was updated by ${userService.currentUserDisplayName}"
            String emailBody = "User ${userService.currentUserId} (${userService.currentUserDisplayName}) has updated project ${projectName ?: id}"
            emailService.sendEmail(subject, emailBody, ["${grailsApplication.config.biocollect.support.email.address}"])
        }

        result
    }

    /**
     * Adds the current user id as a field in the project plan then saves it to ecodata.
     * @param projectId the project to update
     * @param projectPlan the plan details, including the [custom:[details:[]] prefix.
     * @return the response from ecodata
     */
    Map updateProjectPlan(String projectId, Map projectPlan) {
        projectPlan.custom.details.lastUpdatedBy = userService.user.userId
        Map result = webService.doPost(grailsApplication.config.ecodata.service.url + '/project/' + projectId, projectPlan)
        if (result.statusCode == 200 && result.resp) {
            result.resp.lastUpdatedByDisplayName = userService.currentUserDisplayName
        }
        result
    }

    /**
     * This does a 'soft' delete. The record is marked as inactive but not removed from the DB.
     * @param id the record to delete
     * @return the returned status
     */
    def delete(id) {
        def response = webService.doDelete(grailsApplication.config.ecodata.service.url + '/project/' + id)

        String projectName = get(id, "brief")?.name
        String subject = "Project ${projectName ?: id} was deleted by ${userService.currentUserDisplayName}"
        String emailBody = "User ${userService.currentUserId} (${userService.currentUserDisplayName}) has deleted project ${projectName ?: id}"
        emailService.sendEmail(subject, emailBody, ["${grailsApplication.config.biocollect.support.email.address}"])

        response
    }

    /**
     * This does a 'hard' delete. The record is removed from the DB.
     * @param id the record to destroy
     * @return the returned status
     */
    def destroy(id) {
        String subject = "Project ${id} was hard-deleted by ${userService.currentUserDisplayName}"
        String emailBody = "User ${userService.currentUserId} (${userService.currentUserDisplayName}) has hard-deleted project ${id}"
        emailService.sendEmail(subject, emailBody, ["${grailsApplication.config.biocollect.support.email.address}"])

        webService.doDelete(grailsApplication.config.ecodata.service.url + '/project/' + id + '?destroy=true')
    }

    /**
     * Retrieves a summary of project metrics (including planned output targets)
     * and groups them by output type.
     * @param id the id of the project to get summary information for.
     * @return TODO document this structure.
     */
    def summary(String id) {
        def scores = webService.getJson(grailsApplication.config.ecodata.service.url + '/project/projectMetrics/' + id)

        def scoresWithTargetsByOutput = [:]
        def scoresWithoutTargetsByOutputs = [:]
        if (scores && scores instanceof List) {  // If there was an error, it would be returning a map containing the error.
            // There are some targets that have been saved as Strings instead of numbers.
            scoresWithTargetsByOutput = scores.grep{ it.target && it.target != "0" }.groupBy { it.outputType }
            scoresWithoutTargetsByOutputs = scores.grep{ it.result && it.result.count && (it.result.result || it.result.groups) && (!it.target || it.target == "0") }.groupBy { it.outputType }
        }
        [targets: scoresWithTargetsByOutput, other: scoresWithoutTargetsByOutputs]
    }

    def search(params) {
        webService.doPost(grailsApplication.config.ecodata.service.url + '/project/search', params)
    }

    /**
     * Get the list of users (members) who have any level of permission for the requested projectId
     *
     * @param projectId
     * @return
     */
    def getMembersForProjectId(projectId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/getMembersForProject/${projectId}"
        webService.getJson(url)
    }

    def getMembersForProjectPerPage(projectId, pageStart, pageSize) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/getMembersForProjectPerPage?projectId=${projectId}&offset=${pageStart}&max=${pageSize}"
        webService.getJson(url, null, true)
    }

    /**
     * Does the current user have permission to administer the requested projectId?
     * Checks for the ADMIN role in CAS and then checks the UserPermission
     * lookup in ecodata.
     *
     * @param userId
     * @param projectId
     * @return boolean
     */
    def isUserAdminForProject(userId, projectId) {
        def userIsAdmin

        if (userService.userIsSiteAdmin()) {
            userIsAdmin = true
        } else {
            def url = grailsApplication.config.ecodata.service.url + "/permissions/isUserAdminForProject?projectId=${projectId}&userId=${userId}"
            userIsAdmin = webService.getJson(url)?.userIsAdmin  // either will be true or false
        }

        userIsAdmin
    }

    /**
     * Does the current user have caseManager permission for the requested projectId?
     *
     * @param userId
     * @param projectId
     * @return
     */
    def isUserCaseManagerForProject(userId, projectId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/isUserCaseManagerForProject?projectId=${projectId}&userId=${userId}"
        webService.getJson(url)?.userIsCaseManager // either will be true or false
    }

    /**
     * Does the current user have moderator permission for the requested projectId?
     *
     * @param userId
     * @param projectId
     * @return
     */
    def isUserModeratorForProject(userId, projectId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/isUserModeratorForProject?projectId=${projectId}&userId=${userId}"
        webService.getJson(url)?.userIsModerator // either will be true or false
    }

    /**
     * Does the current user have permission to edit the requested projectId?
     * Checks for the ADMIN role in CAS and then checks the UserPermission
     * lookup in ecodata.
     *
     * @param userId
     * @param projectId
     * @return boolean
     */
    def canUserModerateProjects(userId, projectIds) {
        def userCanModerate

        if (userService.userIsSiteAdmin()) {
            userCanModerate = true
        } else {
            userCanModerate = userService.canUserModerateForProjects(userId, projectIds)
        }

        userCanModerate
    }

    /**
     * Does the current user have permission to edit the requested projectId?
     * Checks for the ADMIN role in CAS and then checks the UserPermission
     * lookup in ecodata.
     *
     * @param userId
     * @param projectId
     * @return boolean
     */
    def canUserEditProject(userId, projectId, merit = true) {
        def userCanEdit

        if (userService.userIsSiteAdmin()) {
            userCanEdit = true
        } else {
            userCanEdit = userService.canUserEditProject(userId, projectId)
        }

        // Merit projects are not allowed to be edited.
        if (userCanEdit && merit) {
            def project = get(projectId, 'brief')
            def program = metadataService.programModel(project.associatedProgram)
            userCanEdit = !program?.isMeritProgramme
        }

        userCanEdit
    }

    /**
     * Check whether a works project has the allowAdditionalSurveySites and the user has permission to edit the project
     * If the project is not Works the default behaviour is to just call canUserEditProject.
     * @param userId The user calling the controller
     * @param projectId The project to check
     * @param merit Is this a merit project?
     */
    def canUserEditSitesForProject(String userId, String projectId, boolean merit = true) {
        boolean canManageSites = true

        Map project = get(projectId)

        if(isWorks(project)) {
            canManageSites = userService.userIsSiteAdmin() || userService.isUserAdminForProject(userId, projectId)  ||
                    project?.mapConfiguration?.allowAdditionalSurveySites && userService.isUserEditorForProject(userId, projectId)
        }

        // Not sure if merit check is still relevant but just in case we rely on canUserEditProject behaviour
        canManageSites && canUserEditProject(userId, projectId, merit)
    }

    def isUserEditorForProjects (String userId, String projectIds) {
        boolean userIsEditor = false
        if (userService.userIsSiteAdmin()) {
            userIsEditor = true
        } else {
            userIsEditor = userService.isUserEditorForProjects(userId, projectIds)
        }
        userIsEditor
    }

    /**
     * Does the current user have permission to edit the requested projectId?
     * Checks for the ADMIN role in CAS and then checks the UserPermission
     * lookup in ecodata.
     *
     * @param userId
     * @param projectId
     * @return boolean
     */
    Map canUserEditProjects(String userId, String projectId) throws SocketTimeoutException, Exception {
        def isAdmin
        Map permissions = [:], response

        if (userService.userIsAlaAdmin()) {
            isAdmin = true
        }

        def url = grailsApplication.config.ecodata.service.url + "/permissions/canUserEditProjects"
        Map params = [projectIds:projectId,userId:userId]
        response = webService.postMultipart(url, params, null, null, null)

        if(response.error){
            if(response.error.contains('Timed out')){
                throw new SocketTimeoutException(response.error)
            } else {
                throw new Exception(response.error)
            }
        }

        if(isAdmin){
            response?.content?.each{ key, value ->
                if(value != null){
                    permissions[key] = true
                } else {
                    permissions[key] = null;
                }
            }
        } else {
            permissions = response.content;
        }

        permissions
    }

    /**
     * Can user edit bio collect activity
     * @param userId the user to test.
     * @param the activity to test.
     */
    def canUserEditActivity(String userId, Map activity) {
        boolean userCanEdit = false
        if (userService.userIsSiteAdmin()) {
            userCanEdit = true
        } else {
            String url = grailsApplication.config.ecodata.service.url + "/permissions/canUserEditProject?projectId=${activity?.projectId}&userId=${userId}"
            boolean userIsProjectEditor = webService.getJson(url)?.userIsEditor ?: false
            if (userIsProjectEditor || (activity?.userId == userId)) {
                userCanEdit = true
            }
        }
        userCanEdit
    }

    /**
     * Does the current user have permission to view details of the requested projectId?
     * @param userId the user to test.
     * @param the project to test.
     */
    def canUserViewProject(userId, projectId) {

        def userCanView
        if (userService.userIsSiteAdmin() || userService.userHasReadOnlyAccess()) {
            userCanView = true
        } else {
            userCanView = canUserEditProject(userId, projectId)
        }
        userCanView
    }

    /**
      * Does the current user have editor permission for the requested projectId?
      *
      * @param userId
      * @param projectId
      * @return
      */
    def isUserEditorForProject(userId, projectId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/isUserEditorForProject?projectId=${projectId}&userId=${userId}"
        webService.getJson(url)?.userIsEditor // either will be true or false
    }

/**
  * Does the current user have project participant permission for the requested projectId?
  *
  * @param userId
  * @param projectId
  * @return
  */
    def isUserParticipantForProject(userId, projectId) {
        def url = grailsApplication.config.ecodata.service.url + "/permissions/isUserParticipantForProject?projectId=${projectId}&userId=${userId}"
        webService.getJson(url)?.userIsParticipant // either will be true or false
    }


    /**
     * Returns the programs model for use by a particular project.  At the moment, this method just delegates to the metadataservice,
     * however a per organisation programs model is something being discussed.
     */
    def programsModel() {
        metadataService.programsModel()
    }

    /**
     * Returns a filtered list of activities for use by a project
     */
    public List activityTypesList(String projectId) {
        def projectSettings = settingService.getProjectSettings(projectId)
        def activityTypes = metadataService.activityTypesList()

        def allowedActivities = activityTypes
        if (projectSettings?.allowedActivities) {

            allowedActivities = []
            activityTypes.each { category ->
                def matchingActivities = []
                category.list.each { nameAndDescription ->
                    if (nameAndDescription.name in projectSettings.allowedActivities) {
                        matchingActivities << nameAndDescription
                    }
                }
                if (matchingActivities) {
                    allowedActivities << [name: category.name, list: matchingActivities]
                }
            }

        }

        allowedActivities
    }

    /**
     * Find and add all species fields in an activity type. The resulting list is returned.
     * @param activityTypes
     * @return
     */
    List addSpeciesFieldsToActivityTypesList(List activityTypes){
        activityTypes.each { category ->
            category?.list?.each { type ->
                type.speciesFields = formSpeciesFieldParserService.getSpeciesFieldsForSurvey(type.name)?.result
            }
        }
    }

    /**
     * Returns a list of the activity types that can be used by the supplied project.
     * The types are filtered based on what program the project is run under.
     * @param project the project.
     * @return a flat List of activity types that can be used by the project.
     */
    protected List supportedActivityTypes(Map project, List projectActivities = []) {
        List activityTypes
        if (project.associatedProgram) {
            List activityTypesByCategory = metadataService.activityTypesList(project.associatedProgram)
            activityTypes = activityTypesByCategory.collect{it.list}.flatten()
        }
        // Even if the program exists, it may not have configured a set of supported activities.  If so, we
        // will fallback on the assessment & monitoring activities for backwards compatibility
        if (!activityTypes) {
            activityTypes = metadataService.activitiesModel().activities.findAll { it.category == "Assessment & monitoring" }
        }

        activityTypes += projectActivities.findAll{it.pActivityForm && !activityTypes.find{type->type.name == it.pActivityForm}}.collect{[name:it.pActivityForm]}
        activityTypes
    }


    public JSON userProjects(UserDetails user) {
        if (user) {
            def projects = userService.getProjectsForUserId(8443)
            def starredProjects = userService.getStarredProjectsForUserId(8443)
            ['active': projects, 'starred': starredProjects] as JSON;
        } else {
            [:] as JSON
        }
    }

    /**
     * get image documents from ecodata
     * @param projectId
     * @param payload
     * @return
     */
    Map listImages(Map payload, version = null) throws SocketTimeoutException, Exception{
        Map response
        payload.type = 'image';
        payload.role = ['surveyImage']
        def params = version ? "?version=${version}" : ''
        String url = grailsApplication.config.ecodata.service.url + '/document/listImages' + params
        response = webService.doPost(url, payload)
        if(response.resp){
            return response.resp;
        } else  if(response.error){
            if(response.error.contains('Timed out')){
                throw new SocketTimeoutException(response.error)
            } else {
                throw  new Exception(response.error);
            }
        }
    }

    /**
     * calls ecodata webservice to import scistarter projects
     * @return Interger - number of imported projects.
     * @throws SocketTimeoutException
     * @throws Exception
     */
    Map importSciStarterProjects() throws SocketTimeoutException, Exception{
        String url = "${grailsApplication.config.ecodata.service.url}/project/importProjectsFromSciStarter";
        Map response = webService.doPostWithParams(url, [:]);
        if(response.resp && response.resp.count != null){
            return response.resp
        } else {
            if(response.error.contains('Timed out')){
                throw new SocketTimeoutException(response.error)
            } else {
                throw  new Exception(response.error);
            }
        }
    }

    /**
     * get science type from ecodata and cache it since it is not likely to change.
     * @return
     */
    List getScienceTypes(){
        cacheService.get("project-sciencetypes", {
            def url = grailsApplication.config.ecodata.service.url + '/project/getScienceTypes'
            webService.getJson(url)
        })
    }

    /**
     * get eco science type from ecodata and cache it since it is not likely to change.
     * @return
     */
    List getEcoScienceTypes(){
        cacheService.get("project-ecosciencetypes", {
            def url = grailsApplication.config.ecodata.service.url + '/project/getEcoScienceTypes'
            webService.getJson(url)
        })
    }

    /**
     * Get UN regions from ecoddata
     */
    List getUNRegions(){
        cacheService.get("UNRegions", {
            String url =  grailsApplication.config.ecodata.service.url + '/project/getUNRegions'
            webService.getJson(url)
        })
    }

    /**
     * Get list of all countries from ecoddata
     */
    List getCountries(){
        cacheService.get("AllCountries", {
            String url =  grailsApplication.config.ecodata.service.url + '/project/getCountries'
            webService.getJson(url)
        })
    }

    /**
     * Get science type list for which data collection is supported.
     */
    List getDataCollectionWhiteList(){
        cacheService.get("data-collection-whitelist", {
            String url =  grailsApplication.config.ecodata.service.url + '/project/getDataCollectionWhiteList'
            webService.getJson(url)
        })
    }

    /**
     * Convert project values to a list of tags.
     * @param project
     * @return
     */
    Map buildTags(Map project){
        project.tags = project.tags?:[]

        if (project.hasParticipantCost) {
            project.tags.push('hasParticipantCost')
        } else {
            project.tags.push('noCost')
        }

        project.remove('hasParticipantCost')

        if (project.isSuitableForChildren) {
            project.tags.push('isSuitableForChildren')
        }

        if (project.isDIY) {
            project.tags.push('isDIY')
        }

        project.remove('isDIY')

        if (project.isHome) {
            project.tags.push('isHome')
        }

        project.remove('isHome')

        if (project.hasTeachingMaterials) {
            project.tags.push('hasTeachingMaterials')
        }

        project.remove('hasTeachingMaterials')


        Boolean isMobile = isMobileAppForProject(project)
        if(isMobile){
            project.tags.push('mobileApp')
        }

        project
    }

    /**
     * convert tags to field so that it can be stored as KO observable.
     * @param project
     * @return
     */
    Map buildFieldsForTags(Map project){
        List fields = ['hasParticipantCost', 'isSuitableForChildren', 'isDIY', 'isHome', 'isExternal','hasTeachingMaterials', 'noCost', 'mobileApp']
        project?.tags?.eachWithIndex { String tag, int i ->
            if(tag in fields){
                project[tag] = true
            }
        }

        project
    }

    /**
     * Check if project has mobile application attached.
     * @param project
     * @return
     */
    Boolean isMobileAppForProject(Map project){
        List links = project.links
        Boolean isMobileApp = false;
        isMobileApp = links?.any {
            it.role in MOBILE_APP_ROLE;
        }
        isMobileApp;
    }

    public boolean isCitizenScience(project) {
        project.projectType == PROJECT_TYPE_CITIZEN_SCIENCE || project.projectType == PROJECT_TYPE_CITIZEN_SCIENCE_TYPE_2
    }

    public boolean isEcoScience(project) {
        project.projectType == PROJECT_TYPE_ECOSCIENCE
    }

    public boolean isWorks(project){
        project.projectType == PROJECT_TYPE_WORKS
    }

    /**
     * Get list of all possible facets for citizen science project finder. Then process it to a form it can be used
     * on admin's hub page.
     * @return
     */
    List getFacets(){
        cacheService.get("facets.project.resolved", {
            List facetsMapList = getDefaultFacets()
            facetsMapList.sort{ it.title }
        })
    }

    /**
     * Adds a property called state to all facets. State decides whether to expand or collapse a facet section.
     * It is configured on the admin's hub panel.
     * @param facets
     * @return
     */
    List addFacetExpandCollapseState (List facets){
        HubSettings hub = SettingService.getHubConfig()
        List configurableFacets = []
        if(hub.isFacetListConfigured(PROJECT_FINDER_PAGE)){
            configurableFacets = hub.getFacetsForProjectFinderPage()
        }

        addFacetState(facets, configurableFacets)
    }

    List addFacetState(List facets, List configurableFacets) {
        facets?.each { facet ->
            String state = 'Expanded'
            if (configurableFacets) {
                Map cFacet = configurableFacets.find {
                    it.name == facet.name
                }

                if (cFacet) {
                    state = cFacet.state
                }
            }

            facet.state = state
        }

        facets
    }

    /**
     * Add facets that has special function like project status - completed or active.
     * These two categories depends on today's date and hence dynamic.
     * @param facets
     * @return
     */
    List addSpecialFacets(List facets){
        HubSettings hub = SettingService.getHubConfig()
        if(hub.isFacetListConfigured(PROJECT_FINDER_PAGE)) {
            List hubFacets = hub.getFacetsForProjectFinderPage()
            SPECIAL_FACETS.each { specialFacet ->
                int index = hubFacets?.findIndexOf{ it.name == specialFacet.name }
                if(index >= 0){
                    if(index >= facets?.size()){
                        index = facets.size()
                        facets.add(index, specialFacet.clone())
                    } else {
                        facets.putAt(index, specialFacet.clone())
                    }
                }
            }
        } else {
            facets = SPECIAL_FACETS + facets
        }

        facets
    }


    private Map findSpeciesFieldConfig(String projectId, String surveyName, String dataFieldName, String output) {
        def project = get(projectId)

        def survey = project?.speciesFieldsSettings?.surveysConfig?.find {
            it.name == surveyName
        }

        def specificFieldDefinition = survey?.speciesFields?.find {
            it.dataFieldName == dataFieldName && it.output == output
        }


        Map speciesFieldConfig = (specificFieldDefinition?.config && specificFieldDefinition?.config?.type != "DEFAULT_SPECIES") ?
                //New species per field configuration
                specificFieldDefinition.config :
                // Legacy per survey species configuration
                project?.speciesFieldsSettings?.defaultSpeciesConfig

        // All species is the default setting when field is not configured.
        if(!speciesFieldConfig){
            speciesFieldConfig = grailsApplication.config.speciesConfiguration.default
        }

        return speciesFieldConfig
    }

    /**
     * Searches for a species name taking into account the species constraints setup for the survey.
     * @param id the id of the Project being completed
     * @param q query string to search for
     * @param limit the maximum number of results to return
     * @param output Identity of field for specific configuration.
     * @param dataFieldName Identity of field for specific configuration.
     * @param surveyName Identity of field for specific configuration
     * @return json structure containing search results suitable for use by the species autocomplete widget on a survey form.
     */
    def searchSpecies(String id, String q, Integer limit, String output, String dataFieldName, String surveyName){

        Map speciesFieldConfig = findSpeciesFieldConfig(id, surveyName, dataFieldName, output)

        def result = speciesService.searchSpeciesForConfig(speciesFieldConfig, q, limit)
        speciesService.formatSpeciesNameInAutocompleteList(speciesFieldConfig.speciesDisplayFormat , result)
    }


    /**
     * Check if project is contributing data to Atlas of Living Australia
     * @return boolean
     */
    boolean isProjectContributingDataToALA(Map project){
        project.dataResourceId && (project.alaHarvest == true)
    }

    /**
     * Get biocache query to get all records belonging to a project or a user's project records
     * @param project
     * @param view
     * @param spotterId
     * @return
     */
    String getOccurrenceUrl(Map project, String view, String spotterId = null){
        if(project.dataResourceId){
            String url = grailsApplication.config.biocache.baseURL + "/occurrences/search?q=*:*&"
            String query = getQueryStringForALASystems(view, project, spotterId)

            "${url}${query?:''}"
        }
    }

    /**
     * Get spatial portal query to get all records belonging to a project or a user's project records
     * @param project
     * @param view
     * @param spotterId
     * @return
     */
    String getSpatialUrl(Map project, String view, String spotterId = null){
        if(project.dataResourceId){
            String url = grailsApplication.config.spatial.baseURL
            String query = getQueryStringForALASystems(view, project, spotterId)

            "${url}?${query?:''}"
        }
    }

    /**
     * Add filter queries so that ALA systems like biocache, spatial portal etc. will be able to show
     * records belonging to a project or a user's project records.
     * @param view
     * @param project
     * @param spotterId
     * @return
     */
    String getQueryStringForALASystems(String view, Map project, String spotterId) {
        switch (view) {
            case 'project':
            case 'projectrecords':
                return  "fq=(data_resource_uid:${project.dataResourceId})";
                break;
            case 'myprojectrecords':
                return  "fq=(data_resource_uid:${project.dataResourceId})&fq=alau_user_id:${userService.getUser()?.userId}";
                break
            case 'userprojectactivityrecords':
                return  "fq=(data_resource_uid:${project.dataResourceId})&fq=alau_user_id:${spotterId}";
                break

            case 'myrecords':
            case 'allrecords':
            default:
                break
        }
    }

    List getDefaultFacets(){
        cacheService.get('default-facets-for-project-finder', {
            webService.getJson(grailsApplication.config.ecodata.service.url + '/project/getDefaultFacets')
        })
    }

    def sendTestEmail (String subjectLine, String body) {
        String replyTo = userService.getUser().userName
        Map result = [success: false, message : "You must be logged in to send emails."]
        if (replyTo) {
            result = emailService.sendEmail(subjectLine, body, [replyTo], null, replyTo, null, null)
        }

        result
    }

    def sendEmailNotificationToMembers (String subjectLine, String body, List userIDs, String projectId) {
        String replyTo = userService.getUser().userName
        Map result = [success: false, message : "You must be logged in to send emails."]
        if (replyTo) {
            List sanitisedUserIDs = getProjectMembersAndSanitiseRecipientList(userIDs, projectId)
            if (sanitisedUserIDs) {
                if (sanitisedUserIDs.size() != userIDs.size()) {
                    List blackListedUserIDs = userIDs.minus(sanitisedUserIDs)
                    log.info ("Email will not be sent to following userIDs - ${blackListedUserIDs.toString()}")
                }

                List bccList = userService.getUserNamesForUserIDs(sanitisedUserIDs)
                if (bccList) {
                    result = emailService.sendEmail(subjectLine, body, [replyTo], null, replyTo, null, bccList)
                } else {
                    result.message = "Could not resolve email address for given user ids."
                }
            } else {
                result.message = "Cannot send email either because no recipients were selected or they are not members of this project."
            }
        }

        result
    }

    List getProjectMembersAndSanitiseRecipientList (List userIDs, String projectId) {
        if (userIDs) {
            List projectMembers = getMembersForProjectId(projectId)
            List whiteList
            List blackList = []
            whiteList = projectMembers?.collect { it.userId }
            sanitiseRecipientList(userIDs, whiteList, blackList)
        }
    }

    List sanitiseRecipientList (List userIDs, List whiteList, List blackList) {
        userIDs?.findAll { whiteList?.contains(it) && !blackList?.contains(it) }
    }
}
