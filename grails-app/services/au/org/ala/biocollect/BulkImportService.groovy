package au.org.ala.biocollect

import au.org.ala.biocollect.merit.ActivityService
import au.org.ala.biocollect.merit.UserService
import au.org.ala.biocollect.merit.WebService
import grails.core.GrailsApplication

class BulkImportService {
    static final int MAX_OFFSET = 20
    WebService webService
    GrailsApplication grailsApplication
    ActivityService activityService
    UserService userService
    ProjectActivityService projectActivityService

    Map get(String id) {
        String url = grailsApplication.config.getProperty('ecodata.service.url') + "/bulkImport/" + id
        webService.getJson(url, null, true)
    }

    Map create (Map props) {
        props.userId = userService.getCurrentUserId()
        addProjectId(props)
        String url = grailsApplication.config.getProperty('ecodata.service.url') + "/bulkImport"
        webService.doPost(url, props)
    }

    Map update(Map props, String bulkImportId) {
        addProjectId(props)
        String url = grailsApplication.config.getProperty('ecodata.service.url') + "/bulkImport/" + bulkImportId
        webService.doPut(url, props)
    }

    Map deleteActivitiesImported(String bulkImportId) {
        Boolean success
        List activityIds = getBulkImportActivities( bulkImportId )

        success = activityService.batchedBulkDelete(activityIds)
        [success: success]
    }


    Map publishActivitiesImported(String bulkImportId) {
        Boolean success
        List activityIds = getBulkImportActivities( bulkImportId )

        // delete activities
        success = activityService.batchedBulkRelease(activityIds)
        [success: success]
    }

    Map embargoActivitiesImported(String bulkImportId) {
        Boolean success
        List activityIds = getBulkImportActivities( bulkImportId )

        // delete activities
        success = activityService.batchedBulkEmbargo(activityIds)
        [success: success]
    }


    List getBulkImportActivities (String bulkImportId) {
        def offset = 0
        String url = grailsApplication.config.getProperty('ecodata.service.url') + "/activity/search"
        Map criteria = [bulkImportId: bulkImportId, options: [offset: offset, max: MAX_OFFSET]]
        def result = webService.doPost(url, criteria)?.resp?.activities
        List activityIds = []

        // list activities
        while (result) {
            activityIds.addAll(result?.collect { it.activityId })
            offset += MAX_OFFSET
            criteria = [bulkImportId: bulkImportId, options: [offset: offset, max: MAX_OFFSET]]
            result = webService.doPost(url, criteria)?.resp?.activities
        }

        activityIds
    }

    private Map addProjectId (Map props) {
        if (props.projectActivityId) {
            Map pa = projectActivityService.get(props.projectActivityId)
            if (!pa.error)
                props.projectId = pa.projectId
            else
                props.projectId = null
        }
        else {
            props.projectId = null
        }

        props
    }
}
