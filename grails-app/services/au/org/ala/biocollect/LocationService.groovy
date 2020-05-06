/*
 * Copyright (C) 2014 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 */
package au.org.ala.biocollect

import org.grails.web.json.JSONElement
import org.grails.web.json.JSONObject

/**
 * A grails service for interacting with ecodata webservices.
 */
class LocationService {

    def grailsApplication
    def webService

    def getBookmarkLocationsForUser(String userId) {
        def bookmarks = []
        JSONElement results = webService.getJson("${grailsApplication.config.ecodata.service.url}/location/user/$userId?pageSize=20")

        if (results.hasProperty('error')) {
            return [error: results.error]
        } else {
            results.each {
                bookmarks.add(it)
            }
        }

        bookmarks
    }

    def addBookmarkLocation(JSONObject bookmarkLocation) {
        def url = grailsApplication.config.ecodata.service.url + "/location/"
        def result = webService.doPost(url, bookmarkLocation)
        log.debug "ecodata post bookmark result = ${result}"
        // if error return Map below
        // else return Map key/values as JSON
        [status:result.status?:200, message: (result.error?:result)]
    }

}
