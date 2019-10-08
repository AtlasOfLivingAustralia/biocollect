package au.org.ala.biocollect.merit

import au.org.ala.biocollect.DateUtils
import au.org.ala.biocollect.ProjectActivityService
import au.org.ala.biocollect.UtilService
import grails.core.GrailsApplication
import org.joda.time.DateTime
import org.joda.time.Period
import org.joda.time.format.DateTimeFormat

class ActivityService {

    GrailsApplication grailsApplication
    WebService webService
    MetadataService metadataService
    SpeciesService speciesService
    ProjectActivityService projectActivityService
    UserService userService
    CacheService cacheService
    OutputService outputService
    UtilService utilService

    public static final String PROGRESS_PLANNED = 'planned'
    public static final String PROGRESS_FINISHED = 'finished'
    public static final String PROGRESS_STARTED = 'started'
    public static final String PROGRESS_DEFERRED = 'deferred'
    public static final String PROGRESS_CANCELLED = 'cancelled'

    private static def PROGRESS = ['planned', 'started', 'finished', 'cancelled', 'deferred']

    public static Comparator<String> PROGRESS_COMPARATOR = {a,b -> PROGRESS.indexOf(a) <=> PROGRESS.indexOf(b)}

    static dateFormat = "yyyy-MM-dd'T'hh:mm:ssZ"

    def getCommonService() {
        grailsApplication.mainContext.commonService
    }

    def constructName = { act ->
        def date = commonService.simpleDateLocalTime(act.startDate) ?:
            commonService.simpleDateLocalTime(act.endDate)
        def dates = []
        if (act.startDate) {
            dates << commonService.simpleDateLocalTime(act.startDate)
        }
        if (act.endDate) {
            dates << commonService.simpleDateLocalTime(act.endDate)
        }
        def dateRange = dates.join('-')

        act.name = act.type + (dateRange ? ' ' + dateRange : '')
        act
    }

    def list() {
        def resp = webService.getJson(grailsApplication.config.ecodata.service.url + '/activity/')
        // inject constructed name
        resp.list.collect(constructName)
    }

    def assessments() {
        def resp = webService.getJson(grailsApplication.config.ecodata.service.url + '/assessment/')
        // inject constructed name
        resp.list.collect(constructName)
    }

    def getProjectActivityCount(id){
        webService.getJson(grailsApplication.config.ecodata.service.url + '/activity/countByProjectActivity/'+ id)
    }

    def getSitesWithDataForProjectActivity(id){
        webService.getJson(grailsApplication.config.ecodata.service.url + '/activity/getDistinctSitesForProjectActivity/'+ id)
    }

    def get(id, version = null, userId = null, hideMemberOnlyFlds = false) {
        def params = '?hideMemberOnlyFlds=' + hideMemberOnlyFlds
        if (version) {
            params += '&version=' + version
        }
        if (userId) {
            params += '&userId=' + userId
        }

        def activity = webService.getJson(grailsApplication.config.ecodata.service.url + '/activity/' + id + params)
        activity
    }

    def activitiesForUser(userId, query){
        def params = '?'+ query.collect { k,v -> "$k=$v" }.join('&')
        webService.getJson(grailsApplication.config.ecodata.service.url + '/activity/listForUser/' + userId + params)
    }

    def activitiesForProject(id, query){
        def params = '?'+ query.collect { k,v -> "$k=$v" }.join('&')
        webService.getJson(grailsApplication.config.ecodata.service.url + '/activity/listByProject/' + id + params)
    }

    def create(activity) {
        update('', activity)
    }

    def update(id, body) {
        webService.doPost(grailsApplication.config.ecodata.service.url + '/activity/' + id, body)
    }

    def deleteByProjectActivity(id){
        webService.doDelete(grailsApplication.config.ecodata.service.url + '/activity/deleteByProjectActivity/' + id)
    }

    def delete(id) {
        webService.doDelete(grailsApplication.config.ecodata.service.url + '/activity/' + id)
    }

    def bulkDelete(List ids) {
        webService.doPost(grailsApplication.config.ecodata.service.url + '/activityBulkDelete', [ids: ids])
    }

    def bulkEmbargo(List ids) {
        if (ids) {
            String params = "id=" + ids.join('&id=')
            webService.doPost(grailsApplication.config.ecodata.service.url + "/activities/?${params}", [embargoed: true])
        }
    }

    def bulkRelease(List ids) {
        if (ids) {
            String params = "id=" + ids.join('&id=')
            webService.doPost(grailsApplication.config.ecodata.service.url + "/activities/?${params}", [embargoed: false])
        }
    }

    def isUserOwnerForActivity(userId, id) {
        webService.doGet(grailsApplication.config.ecodata.service.url + '/activity/isUserOwnerForActivity/'+id, [userId: userId])?.resp?.userIsOwner
    }

    /**
     * Returns a detailed list of all activities associated with a project.
     *
     * Activities can be directly linked to a project, or more commonly, linked
     * via a site that is associated with the project.
     *
     * Main output scores are also included. As is the meta-model for the activity.
     *
     * @param id of the project
     */
    def activitiesForProject(String id) {
        def list = webService.getJson(grailsApplication.config.ecodata.service.url + '/activitiesForProject/' + id)?.list
        // inject the metadata model for each activity
        list.each {
            it.model = metadataService.getActivityModel(it.type)
        }
        list
    }

    def submitActivitiesForPublication(activityIds) {
        updatePublicationStatus(activityIds, 'pendingApproval')
    }

    def approveActivitiesForPublication(activityIds) {
        updatePublicationStatus(activityIds, 'published')
    }

    def rejectActivitiesForPublication(activityIds) {
        updatePublicationStatus(activityIds, 'unpublished')
    }

    /**
     * Updates the publicationStatus field of a set of Activities.
     * @param activityIds a List of the activity ids.  Identifies which activities to update.
     * @param status the new value for the publicationStatus field.
     */
    def updatePublicationStatus(activityIds, status) {

        def ids = activityIds.collect{"id=${it}"}.join('&')
        def body = ['publicationStatus':status]
        webService.doPost(grailsApplication.config.ecodata.service.url + "/activities/?$ids", body)

    }

    def bulkUpdateActivities(activityIds, props) {
        def ids = activityIds.collect{"id=${it}"}.join('&')
        webService.doPost(grailsApplication.config.ecodata.service.url + "/activities/?$ids", props)
    }

    /** @see au.org.ala.ecodata.ActivityController for a description of the criteria required. */
    def search(criteria) {
        def modifiedCriteria = new HashMap(criteria?:[:])
        // Convert dates to UTC format.
        criteria.each { key, value ->
            if (value instanceof Date) {
                modifiedCriteria[key] = value.format(dateFormat, TimeZone.getTimeZone("UTC"))
            }

        }
        webService.doPost(grailsApplication.config.ecodata.service.url+'/activity/search/', modifiedCriteria)
    }

    def isReport(activity) {
        def model = metadataService.getActivityModel(activity.type)
        return model.type == 'Report'
    }

    /**
     * Creates a description for the supplied activity based on the activity type and dates.
     */
    String defaultDescription(activity) {
        def start = activity.plannedStartDate
        def end = activity.plannedEndDate

        DateTime startDate = DateUtils.parse(start)
        DateTime endDate = DateUtils.parse(end).minusDays(1)

        Period period = new Period(startDate.toLocalDate(), endDate.toLocalDate())

        def description = DateTimeFormat.forPattern("MMM yyyy").print(endDate)
        if (period.months > 1) {
            description = DateTimeFormat.forPattern("MMM").print(startDate) + ' - ' + description
        }
        "${activity.type} (${description})"

    }

    /**
     * Identifies species typed data in an output model and converts String values into species data via
     * a species lookup operation.  The values are changed inline in the supplied outputData Map.
     *
     * @param outputName the output for which the data has been recorded.
     * @param listName (optional), if present identifies a list within the output model for which the data has been recorded
     * @param outputData the output data to look for species data types.
     * @return
     */
    void lookupSpeciesInOutputData(String projectActivityId, String outputName, String listName, List outputData) {

        Map singleSpecies = projectActivityService.getSingleSpecies(projectActivityId)
        def model = metadataService.annotatedOutputDataModel(outputName)
        if (listName) {
            model = model.find { it.name == listName }?.columns
        }

        // Do species lookup
        def speciesField = model.find { it.dataType == 'species' }
        if (speciesField) {
            outputData.each { row ->
                String name = row[speciesField.name]

                if (singleSpecies.isSingle && (speciesField.validate == 'required' || row[speciesField.name])) {
                    row[speciesField.name] = [name: singleSpecies.name, listId: "not applicable", guid: singleSpecies.guid]
                } else if (!singleSpecies.isSingle) {
                    Map speciesSearchResults = projectActivityService.searchSpecies(projectActivityId, name, 10)
                    Map species = speciesService.findMatch(speciesSearchResults, name)
                    if (species) {
                        row[speciesField.name] = [name: species.name, listId: species.listId, guid: species.guid]
                    } else {
                        row[speciesField.name] = [name: name, listId: 'unmatched', guid: null]
                    }
                }
            }
        }
    }

    /**
     * Check whether sensitive species coordinates needs to be applied for the given projectId + userId
     * Supports only point based coordinates.
     *
     * @param userId user identifier
     * @param projectId project identifier.
     * @param model model with activity and site object
     */
    boolean applySensitiveSpeciesCoordinates(String userId, String projectId){

        List projectIds = userId ? userService.getProjectsForUserId(userId)?.collect{it.project?.projectId} : []
        boolean projectMember = projectIds && projectIds.find{it == projectId}

        return !(userService.userIsAlaOrFcAdmin() || projectMember)
    }

    Map getDynamicFacets(){
        webService.getJson(grailsApplication.config.ecodata.service.url+'/metadata/getIndicesForDataModels')
    }

    List getDefaultFacets(){
        cacheService.get('default-facets-for-data', {
            webService.getJson(grailsApplication.config.ecodata.service.url + '/activity/getDefaultFacets')
        })
    }

    List getFacets(){
        Map dynamicFacets = getDynamicFacets()?:[:]
        List facets = dynamicFacets.collect{ [name: it.key] }
        facets + getDefaultFacets()
    }

    /**
     * Add dynamic facets to list of possible columns to choose when configuring data page columns.
     * @return
     */
    List getDynamicIndexNamesAsColumnConfig () {
        cacheService.get("dynamic-index-names-as-column-config", {
            Map facets = getDynamicFacets()
            List result = []

            facets?.each { name, value ->
                Map config = [
                        type: "property",
                        propertyName: name,
                        displayName : "",
                        dataType: value[0]?.dataType
                ]

                result.add(config)
            }

            result

        })
    }

    /**
     * Update output site when activity site changes. This is done to synchronize site used in activity and output.
     * Works projects can choose a site for an activity on work schedule tab. In such a situation, this function is
     * used to update output with the new site.
     * @param newActivity
     * @param oldActivity
     */
    def updateOutputSite (Map newActivity, Map oldActivity, String mapDataType = 'geoMap') {
        // Execute this logic only when activity siteId is updated on work schedule tab.
        // Do not do this when activity is created or updated.
        String activityId = oldActivity?.activityId
        String type = oldActivity?.type
        if( !newActivity.outputs && activityId && type && oldActivity?.outputs) {
            if ( newActivity?.siteId && (newActivity?.siteId != oldActivity?.siteId) ) {
                // get data model describing map data
                Map outputModels = metadataService.getOutputNameAndDataModelForAnActivityName(type)
                Map dataModel
                String outputName
                outputModels?.each { key, outputModel ->
                    if ( !dataModel ) {
                        outputName = key
                        dataModel = outputModel.dataModel?.find { it.dataType == mapDataType }
                    }
                }

                // update output with new site
                if ( dataModel?.name ) {
                    String name = dataModel.name
                    Map output = oldActivity?.outputs?.find { it.name == outputName }
                    if (output) {
                        output.data[name] = newActivity.siteId
                        outputService.update(output.outputId, output)
                    }
                }
            }
        }
    }

    def addAdditionalProperties (List additionalPropertyConfig, Map doc, Map result) {
        additionalPropertyConfig?.each { Map config ->
            def value = doc
            List path = grailsApplication.config.activitypropertypath[config.propertyName] ?: [config.propertyName]
            path?.each { String prop ->
                if (value instanceof Map) {
                    value = value[prop]
                } else if (value instanceof List) {
                    value = value?.collect {
                        it[prop]
                    }?.join(', ')
                }
            }

            if (value != doc) {
                result[config.propertyName] = utilService.getDisplayNameForValue(config.propertyName, value)
            }
        }

        result
    }
}
