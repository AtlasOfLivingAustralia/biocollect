package au.org.ala.biocollect.sightings

import grails.converters.JSON

class SightingsController {

    def ecodataService, authService
    def sightingValidationService

    def index() {
        [
                user: authService.userDetails()?:[:],
                sightings: ecodataService.getRecentSightings(params),
                pageHeading: "Recent sightings",
                dataResourceUids: ecodataService.getDataResourceUids()
        ]
    }

    /**
     * Validate the supplied scientificName and coordinates.
     *
     * @return
     */
    def validate(){
        def requestJson = request.JSON
        log.debug("Checking: ${requestJson.scientificName} with ${requestJson.decimalLatitude}, ${requestJson.decimalLongitude}")
        if(requestJson.scientificName && requestJson.decimalLatitude && requestJson.decimalLongitude){
            def result = sightingValidationService.validate(
                    requestJson.scientificName,
                    requestJson.decimalLatitude,
                    requestJson.decimalLongitude)
            render (result as JSON)
        } else {
            response.sendError(400, "Service requires a JSON payload with scientificName, decimalLatitude and decimalLongitude properties.")
        }
    }

    /**
     * Retrieve a users sightings.
     *
     * @param id
     * @return
     */
    def user(String id) {
        def user = authService.userDetails()
        String heading =  "My sightings"

        if (id) {
            user = authService.getUserForUserId(id)

            if (user) {
                def name = user.displayName
                heading =  "${name}'${(name.endsWith('s')) ? '' : 's'} sightings"
            } else {
                heading =  "User sightings"
                flash.errorMessage = "Error: User details lookup failed for user with ID ${id}. Check authorised systems listings."
            }
        }

        render(view:"index", model:[
                user: user,
                sightings: ecodataService.getSightingsForUserId(user?.userId?:id, params),
                pageHeading: heading,
                dataResourceUids: ecodataService.getDataResourceUids()
        ])
    }

    /**
     * Delete a sighting.
     *
     * @param id
     * @return
     */
    def delete(String id) {
        log.debug "DEL id = ${id}"
        def user = authService.userDetails()
        String recordUserId = ecodataService.getUserIdForSightingId(id)

        if (authService.userInRole("${grailsApplication.config.security.cas.adminRole}") || user?.userId == recordUserId) {
            def result = ecodataService.deleteSighting(id)
            log.debug "result = ${result}"

            if (result.success) {
                flash.message = "Record was successfully deleted"
            } else {
                flash.message = "An error occurred. Record was not deleted"
            }
        } else {
            flash.message = "You do not have permission to delete record ${id}"
        }
        
        redirect(uri: request.getHeader('referer') )
    }
}
