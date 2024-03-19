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


    private def createAssessmentRecordFromReference(Object referenceActivity, Object assessProjectActivity) {
        def assessActivity = [
                outputs: [
                        [
                                outputId: "",
                                outputNotCompleted: false,
                                data: [
                                        recordedBy: userService.getCurrentUserDisplayName(),
                                        upperConditionBound: "0",
                                        lowerConditionBound: "0",
                                        overallConditionBestEstimate: "0",
                                        mvgGroup: referenceActivity.outputs[0].data.vegetationStructureGroup,
                                        huchinsonGroup: referenceActivity.outputs[0].data.huchinsonGroup
                                ],
                                name: assessProjectActivity["pActivityFormName"]
                        ]
                ],
                projectActivityId: assessProjectActivity["projectActivityId"],
                userId: userService.getCurrentUserId(),
                projectStage: "",
                embargoed: false,
                type: assessProjectActivity["pActivityFormName"],
                projectId: assessProjectActivity["projectId"],
                mainTheme: ""
        ]

        activityService.update("", assessActivity)

        assessActivity
    }


    // Get details about the supplied project

    def requestRecords(String projectId) {
        def config = grailsApplication.config.refAssess
        def result

        // Ensure we're provided with a filter query item
        GrailsParameterMap queryParams = params
        if (!queryParams[config.reference.filterKey]) {
            response.status = 500
            result = [message: "Missing '${config.reference.filterKey}' parameter!"]
            render result as JSON
            return
        }

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
        refActivities = refActivities.sort { it.outputs[0].data.numTimesReferenced }
        refActivities = refActivities.findAll { it.outputs[0].data[config.reference.filterKey] == queryParams[config.reference.filterKey]}

        // Ensure there are reference records after filtering
        if (refActivities.size() < config.assessment.recordsToCreate) {
            response.status = 400
            result = [message: "Insufficient number of reference records for '${config.reference.filterKey}' filter (${queryParams[config.reference.filterKey]})"]
            render result as JSON
            return
        }

        def assessProjectActivity = projectActivityService.get(config.assessment.projectActivityId)
        def assessActivities = []
        for (int projectIndex = 0; projectIndex < config.assessment.recordsToCreate; projectIndex++) {
            assessActivities.push(
                    createAssessmentRecordFromReference(
                            refActivities[projectIndex],
                            assessProjectActivity
                    )
            )
        }

        render assessActivities as JSON
    }
}
