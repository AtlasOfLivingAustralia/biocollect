package au.org.ala.biocollect

import au.org.ala.biocollect.merit.*
import grails.converters.JSON
import grails.web.servlet.mvc.GrailsParameterMap

class ReferenceAssessmentController {
    UserService userService
    ProjectService projectService
    RecordService recordService
    ProjectActivityService projectActivityService
    ActivityService activityService
    SearchService searchService
    OutputService outputService


    // Get details about the supplied project

    def requestRecords(String projectId) {
        def result

        // Get details about the supplied project
        def projectResult = projectService.get(projectId)

        // Ensure the project is a reference assessment project
        if (!projectResult || !projectResult.refAssessEnabled) {
            response.status = 400
            result = [message: 'The supplied project is not configured for reference assessments']
            render result as JSON
            return
        }

        // Get the activity records for the reference survey
        def referenceActivities = activityService.activitiesForProjectActivity(projectResult.refAssessReferenceProjectActivityId)

        // Ensure records exist
        if (referenceActivities?.size() == 0) {
            response.status = 404
            result = [message: 'No records found in assessment image reference survey']
        } else {
            result = referenceActivities
        }

        render result as JSON
    }
}
