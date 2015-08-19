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
package au.org.ala.biocollect.sightings

import au.org.ala.biocollect.sightings.command.Bookmark
import au.org.ala.biocollect.sightings.command.Sighting
import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONArray
import org.codehaus.groovy.grails.web.json.JSONElement
import org.codehaus.groovy.grails.web.json.JSONObject
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import org.joda.time.DateTime
import org.joda.time.format.DateTimeFormat
import org.joda.time.format.DateTimeFormatter

/**
 * A grails service for interacting with ecodata webservices.
 */
class EcodataService {

    def grailsApplication, httpWebService, webserviceService

    /**
     * Retrieve the details of this sighting.
     *
     * @param id
     * @return
     */
    Sighting getSighting(String id) {
        Sighting sc = new Sighting()

        def json = httpWebService.getJson("${grailsApplication.config.ecodata.service.url}/record/${id}")

        if (json instanceof JSONObject && json.has("error")) {
            // WS failed
            sc.error = json.error
        } else if (json instanceof JSONObject) {
            json = fixJsonValues(json)
            try {
                sc = new Sighting(json)
            } catch (Exception e) {
                log.error "Couldn't un-marshall JSON - " + e.message, e
                sc.error = "Error: sighting could not be loaded - ${e.message}"
            }
        } else {
            log.error "Unexpected error: ${json}"
            sc.error = "Unexpected error: ${json}"
        }

        sc
    }

    /**
     * Retrieve a list of data resources supplying data.
     * @return
     */
    def getDataResourceUids(){
        def json = httpWebService.getJson("${grailsApplication.config.ecodata.service.url}/project/")
        def dataResourceUids = ['dr364'] // bug with prod where dataResourceId is not set
        log.debug "json = $json"
        json.list.each { project ->
            if (project?.dataResourceId && !project?.isExternal?.toBoolean()){
                dataResourceUids << project.dataResourceId
            }
        }
        log.debug "dataResourceUids = ${dataResourceUids}"
        dataResourceUids.toSet()
    }

    /**
     * Non JSON marshalling method for getting userId for a record id
     * Needed for older records which can't be marshalled into the Sighting Obj
     *
     * @param id
     * @return
     */
    String getUserIdForSightingId(String id) {
        def json = httpWebService.getJson("${grailsApplication.config.ecodata.service.url}/record/${id}")
        String userId = ""

        if (json instanceof JSONObject && json.has("userId")) {
            userId = json.userId
        }

        userId
    }

    /**
     * Submit the sighting object
     *
     * @param sightingCommand
     * @return
     */
    Map submitSighting(Sighting sightingCommand) {

        def url = grailsApplication.config.ecodata.service.url + "//record"

        if (sightingCommand.occurrenceID) {
            // must be an edit if occurrenceID is present
            url += "/${sightingCommand.occurrenceID}"
        }

        if (sightingCommand.multimedia) {
            // remove null elements (i.e. image removed in UI)
            sightingCommand.multimedia.removeAll([null])
        }

        def json = sightingCommand as JSON
        def result = webserviceService.doJsonPost(url, json.toString(), [
                "Authorization": grailsApplication.config.ecodata.apiKey
        ])
        log.debug "ecodata result = ${result}"
        // if error return Map below
        // else return Map key/values as JSON
        def returnMap = [status: result.status?:200]

        if (result.error) {
            returnMap.error = result.error
        } else {
            returnMap.text = result
        }

        returnMap
    }

    private String getQueryStringForParams(GrailsParameterMap params, Boolean convertKeys) {
        params.remove("controller")
        params.remove("action")
        params.remove("format")
        String queryString = params.toQueryString()

        if (convertKeys) {
            // convert Grails pagination params to SOLR params
            queryString = queryString.replaceAll("max", "pageSize")
            queryString = queryString.replaceAll("offset", "start")
        }

        log.debug "params string = ${queryString}"

        if(queryString == "?"){
            ""
        } else {
            queryString
        }
    }

    def deleteSighting(String id) {
        webserviceService.doDelete("${grailsApplication.config.ecodata.service.url}/record/${id}", [
                "Authorization": grailsApplication.config.ecodata.apiKey
        ]) // returns statusCode 200|500
    }

    def getSightingsForUserId(String userId, GrailsParameterMap params) {
        httpWebService.getJson("${grailsApplication.config.ecodata.service.url}/record/user/${userId}" + getQueryStringForParams(params, true))
    }

    def getRecentSightings(GrailsParameterMap params) {
        //log.debug "records = " + httpWebService.getJson("${grailsApplication.config.ecodata.service.url}/record")
        JSONObject sightings = new JSONObject()
        def result = httpWebService.getJson("${grailsApplication.config.ecodata.service.url}/record" + getQueryStringForParams(params, true))

        if (result instanceof JSONArray) {
            sightings.put("list", result)
        } else if (result instanceof JSONObject) {
            sightings = result
        }

        sightings
    }

    def getBookmarkLocationsForUser(String userId) {
        def bookmarks = []
        JSONElement results = httpWebService.getJson("${grailsApplication.config.ecodata.service.url}/location/user/$userId?pageSize=20")

        if (results.hasProperty('error')) {
            return [error: results.error]
        } else {
            results.each {
                bookmarks.add(new Bookmark(it))
            }
        }

        bookmarks
    }

    def addBookmarkLocation(JSONObject bookmarkLocation) {
        def url = grailsApplication.config.ecodata.service.url + "//location/"
        def result = webserviceService.doJsonPost(url, bookmarkLocation.toString())
        log.debug "ecodata post bookmark result = ${result}"
        // if error return Map below
        // else return Map key/values as JSON
        [status:result.status?:200, message: (result.error?:result)]
    }

    /**
     * Remove pesky JSONObject.NULL values from JSON, which cause GroovyCastException errors
     * during Object binding.
     *
     * @param json
     * @return
     */
    private fixJsonValues(JSONObject json) {
        JSONObject jsonCopy = new JSONObject(json)
        json.each {
            if (it.value == JSONObject.NULL) {
                jsonCopy.remove(it.key)
            } else if (it.key == 'eventDateZ') {
                try {
                    DateTimeFormatter format = DateTimeFormat.forPattern("yyyy-MM-dd'T'HH:mm:ssZ");
                    DateTime dateTime = format.withOffsetParsed().parseDateTime(it.value)
                    Date date = dateTime.toDate();
                    jsonCopy.eventDate = date
                } catch (Exception e) {
                    log.warn "Error parsing iso date: ${e.message}", e
                }
            } else if (it.key == 'imageLicence') {
                jsonCopy.remove(it.key)
            }
        }

        log.debug "jsonCopy = ${jsonCopy.toString(2)}"

        jsonCopy
    }
}
