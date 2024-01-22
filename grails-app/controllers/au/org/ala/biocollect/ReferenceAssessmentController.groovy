package au.org.ala.biocollect

import au.org.ala.biocollect.merit.*
import grails.converters.JSON
import grails.web.servlet.mvc.GrailsParameterMap

class ReferenceAssessmentController {
    UserService userService
    ProjectService projectService
    RecordService recordService
    SearchService searchService

    def requestRecords(String projectId) {
        def result

        // Retrieve reference image records from reference project
        GrailsParameterMap params = new GrailsParameterMap([:], request)
        params["hub"] = "acsa"
        // params["max"] = "30"
        params["fq"] = "projectActivityNameFacet:The Dead Tree Detective"



        Map searchResult = searchService.searchProjectActivity(params)
        List activities = searchResult?.hits?.hits

        // Ensure records exist
        if (activities?.size() == 0) {
            response.status = 404
            result = [message: 'No records found in assessment image reference survey']
        } else {
            result = searchResult
        }

        render result as JSON
    }
}
