package au.org.ala.biocollect.merit

import grails.converters.JSON
import org.grails.web.json.JSONObject

class AjaxController {

    def authService
    def locationService

    /**
     * Simple action that can be called by long running pages periodically to keep the container session alive.
     * If this action is configured to hit CAS, then it should keep the CAS session alive also.
     * @return
     */
    def keepSessionAlive() {
        render(['status':'ok'] as JSON)
    }

    def getBookmarkLocations() {
        def userId = authService.userId
        def result = locationService.getBookmarkLocationsForUser(userId)

        if (result.hasProperty("error")) {
            render(status: result.status?:500, text: result.message)
        } else {
            render(result as JSON)
        }
    }

    def saveBookmarkLocation() {
        def userId = authService.userId
        JSONObject bookmark = request.JSON
        bookmark.put("userId", userId)
        log.debug "post json = ${request.JSON}"
        if (bookmark) {
            def result = locationService.addBookmarkLocation(bookmark)

            if (result.status != 200) {
                response.status = result.status?:500
            }
            return render(result as JSON)
        } else {
            return render(status: 400, text: "No bookmark provided")
        }
    }
}
