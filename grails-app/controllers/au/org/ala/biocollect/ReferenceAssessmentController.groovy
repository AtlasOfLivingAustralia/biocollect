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

        // Create the new assessment activity record
        activityService.update("", assessActivity)

        // Update the numTimesReferenced field on the reference record
        referenceActivity.outputs[0].data.numTimesReferenced =
                referenceActivity.outputs[0].data.numTimesReferenced as Integer + 1
        activityService.update(referenceActivity.activityId, referenceActivity)

        // Return the assessment activity
        assessActivity
    }

    def requestRecords() {
        def config = grailsApplication.config.refAssess
        def body = request.JSON
        def result

        // Ensure BioCollect is configured for reference assessment projects
        if (!config) {
            response.status = 500
            result = [message: 'The application is not configured for reference assessment projects']
            render result as JSON
            return
        }

        // Ensure the body of the request contains the required fields
        if (!body['vegetationStructureGroups'] || !body['climateGroups'] || !body.keySet().contains('deIdentify')) {
            response.status = 400
            result = [message: 'Please ensure the assessment record request contains all relevant fields']
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

        // Get the activity records for the reference survey
        def refActivities = activityService.activitiesForProjectActivity(config.reference.projectActivityId)

        // Ensure the reference records exist
        def numRefActivities = refActivities?.size()
        if (numRefActivities == 0 || numRefActivities < config.assessment.maxRecordsToCreate) {
            response.status = 404
            result = [message: 'Insufficient number of reference records found in reference survey']
            render result as JSON
            return
        }

        // Filter out reference activities by the supplied vegetation structure groups & climate groups
        refActivities = refActivities.findAll {
            body["vegetationStructureGroups"].contains(it.outputs[0].data["vegetationStructureGroup"]) &&
            body["climateGroups"].contains(it.outputs[0].data["huchinsonGroup"])
        }

        // Split & sort the reference activities into:
        // Priority records (assessed <= 3 times), prioritising records assessed the MOST
        // Other records (assessed > 3 times), prioritising records assessed the LEAST

        def priorityRecords = refActivities
                .findAll { it.outputs[0].data.numTimesReferenced as Integer <= 3 }
                .sort{ -(it.outputs[0].data.numTimesReferenced as Integer) }
        def otherRecords = refActivities
                .findAll { it.outputs[0].data.numTimesReferenced as Integer > 3 }
                .sort{ it.outputs[0].data.numTimesReferenced as Integer }

        // Combine the two lists
        refActivities = priorityRecords + otherRecords

//        if (true) {
//            response.status = 200
//            result = [message: 'Test!']
//            render result as JSON
//            return
//        }

        // Ensure there are reference records after filtering
        if (refActivities.size() == 0) {
            response.status = 400
            result = [message: "No reference images matching your criteria could be found."]
            render result as JSON
            return
        }

        def assessProjectActivity = projectActivityService.get(config.assessment.projectActivityId)
        def assessActivities = []
        for (int projectIndex = 0; projectIndex < min(config.assessment.maxRecordsToCreate, refActivities.size()); projectIndex++) {
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
