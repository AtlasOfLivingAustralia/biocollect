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

        GrailsParameterMap queryParams = params

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

        // Ensure the reference records exist
        if (referenceActivities?.size() == 0) {
            response.status = 404
            result = [message: 'No records found in assessment image reference survey']
            render result as JSON
            return
        }

        // Sort the reference activities by
        // referenceActivities.sort { it.outputs[0].data.taxaRichness }
        // referenceActivities.findAll { it.outputs[0].data.recordedBy == "Bruno Ferronato" }

        render referenceActivities as JSON
    }
}
