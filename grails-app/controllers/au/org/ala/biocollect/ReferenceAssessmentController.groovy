package au.org.ala.biocollect

import au.org.ala.biocollect.merit.*
import grails.converters.JSON
import grails.web.servlet.mvc.GrailsParameterMap

import java.time.Instant

class ReferenceAssessmentController {
    UserService userService
    ProjectService projectService
    ProjectActivityService projectActivityService
    ActivityService activityService


    private def mapReferenceToAssessment(Object referenceActivity, Object assessProjectActivity) {
        def assessActivity = referenceActivity

        // Remove irrelevant fields
        ["assessment", "complete", "dateCreated", "id", "lastUpdated", "progress", "status"]
                .each {
                    assessActivity.remove(it)
                }

        // Overwrite activity record IDs
        assessActivity.activityId = ""
        assessActivity.projectActivityId = assessProjectActivity["projectActivityId"]
        assessActivity.type = assessProjectActivity["pActivityFormName"]
        assessActivity.userId = userService.getCurrentUserId()

        // Overwrite activity outputs
        assessActivity.outputs.each {
            output -> {
                output.remove("id")
                output.remove("activityId")
                output.remove("lastUpdated")
                output.remove("dateCreated")
                output.remove("status")

                // Overwrite properties
                output.outputId = ""
                output.outputNotCompleted = true
                output.name = assessProjectActivity["pActivityFormName"]

                ["lastUpdated", "dateCreated", "id"].each({ output.remove(it) })

                // Output data
                output.data.recordedBy = userService.getCurrentUserDisplayName()
            }
        }

        assessActivity
    }


    // Get details about the supplied project

    def requestRecords(String projectId) {
        def config = grailsApplication.config.refAssess
        def result

        // GrailsParameterMap queryParams = params

        // Ensure BioCollect is configured for reference assessment projects
        if (!config) {
            response.status = 500
            result = [message: 'The application is not configured for reference assessment projects']
            render result as JSON
            return
        }

        // Ensure the user is authenticated
        if (!userService.getCurrentUserId()) {
            response.status = 403
            result = [message: 'User is not authenticated']
            render result as JSON
            return
        }

        // Get details about the supplied project
        def projectResult = projectService.get(projectId)

        // Ensure the project is a reference assessment project
        if (!projectResult) {
            response.status = 400
            result = [message: 'The supplied project is not configured for reference assessments']
            render result as JSON
            return
        }

        // Get the activity records for the reference survey
        def refActivities = activityService.activitiesForProjectActivity(config.reference.projectActivityId)

        // Ensure the reference records exist
        def numRefActivities = refActivities?.size()
        if (numRefActivities == 0 || numRefActivities < config.assessment.recordsToCreate) {
            response.status = 404
            result = [message: 'Insufficient number of reference records found in reference survey']
            render result as JSON
            return
        }

        // Sort the reference activities by
        // referenceActivities.sort { it.outputs[0].data.numTimesReferenced }
        // referenceActivities.findAll { it.outputs[0].data.recordedBy == "Bruno Ferronato" }


        def assessProjectActivity = projectActivityService.get(config.assessment.projectActivityId)
        def assessActivities = []
        for (int projectIndex = 0; projectIndex < config.assessment.recordsToCreate; projectIndex++) {
            assessActivities.push(
                    mapReferenceToAssessment(
                            refActivities[projectIndex],
                            assessProjectActivity
                    )
            )
        }

        render assessActivities as JSON
    }
}
