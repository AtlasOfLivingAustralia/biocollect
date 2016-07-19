package au.org.ala.biocollect.merit

import au.org.ala.biocollect.DateUtils
import au.org.ala.biocollect.ProjectActivityService
import org.codehaus.groovy.grails.commons.GrailsApplication
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

    def get(id, version = null) {
        def params = version ? '?version=' + version : ''
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

}
