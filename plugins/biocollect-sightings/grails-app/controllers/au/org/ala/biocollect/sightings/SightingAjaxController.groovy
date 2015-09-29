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

import au.org.ala.biocollect.sightings.command.Question
import au.org.ala.web.AuthService
import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONObject

/**
 * Server side code for the jQuery fileupload plugin, which performs an AJAX
 * file upload in the background
 */
class SightingAjaxController {
    ImageService imageService
    EcodataService ecodataService
    AuthService authService
    TaxonOverflowService taxonOverflowService
    WebserviceService webserviceService

    static allowedMethods = [upload:'POST', saveBookmarkLocation:'POST', createQuestion:'POST', bulkLookupQuestions:'POST', flagInappropriateImage:'POST']

    def upload = {
        try {
            File uploaded = imageService.createTemporaryFile(request.getFile("files[]"))
            InputStream inputStream = imageService.selectInputStream(request)
            imageService.uploadFile(inputStream, uploaded)
            File thumbFile = imageService.generateThumbnail(uploaded)

            def output = [
                    success:true,
                    mimeType: uploaded.mimeType, // metaClass attr
                    filename: uploaded.fileName, // metaClass attr
                    url: "${g.createLink(uri:"/uploads/${uploaded.name}", absolute:true)}",
                    thumbnailUrl: "${g.createLink(uri:"/uploads/${thumbFile.name}", absolute:true)}",
                    exif: imageService.getExifForFile(uploaded)
            ]

            return render (status: 200, text: output as JSON)
        } catch (Exception e) {
            log.error("Failed to upload file.", e)
            return render(status: 302, text: [success:false, error: e.message] as JSON)
        }
    }

    def getBookmarkLocations() {
        def userId = authService.userId
        def result = ecodataService.getBookmarkLocationsForUser(userId)

        if (result.hasProperty("error")) {
            render(status: result.status?:500, text: result.message)
        } else {
            render(result as JSON)
        }
    }

    def saveBookmarkLocation() {
        JSONObject bookmark = request.JSON
        log.debug "post json = ${request.JSON}"
        if (bookmark) {
            def result = ecodataService.addBookmarkLocation(bookmark)
            //render(status: result.status, text: result as JSON, contentType: "application/json")
            if (result.status != 200) {
                response.status = result.status?:500
            }
            return render(result as JSON)
        } else {
            return render(status: 400, text: "No bookmark provided")
        }
    }

    /**
     * Create a taxon overflow question
     *
     * @return
     */
    def createQuestion() {
        JSONObject jsonBody = request.JSON
        log.debug "post json = ${request.JSON}"
        Question question = new Question(jsonBody) // JsonSlurper slurper = new JsonSlurper().setType( JsonParserType.INDEX_OVERLAY ); slurper.parseText(jsonData)
        question.userId = authService.userId
        log.debug "question = ${(question as JSON).toString(true)}"
        def result = taxonOverflowService.createQuestion(question)
        render(status: 200, text: "${result as JSON}")
    }

    /**
     * Bulk lookup against taxon overflow, sending a list of record UUIDs and
     * getting back a list of questions IDs.
     */
    def bulkLookupQuestions() {
        def jsonBody = request.JSON
        log.debug "post json = ${request.JSON}"
        def result = taxonOverflowService.bulkLookup(jsonBody)
        if (result.hasProperty('error')) {
            render(status: result.status?:400, text: "${result as JSON}")
        } else {
            render(status: 200, text: "${result as JSON}")
        }
    }

    def flagInappropriateImage(String id) {
        def url = grailsApplication.config.ecodata.service.url + "//record/"
        def comment = params.comment
        def jsonBody = [ offensiveFlag: true, offensiveReason: comment?:'' ]
        def userId = authService.userId
        log.debug "flagInappropriateImage: id = ${id} || userId: ${userId} || comment =- ${comment}"

        if (id) {
            def result = webserviceService.doJsonPost(url + id, (jsonBody as JSON).toString())
            if (result.error) {
                render(status: 400, text: result.text?:'Unexpected error')
            } else {
                webserviceService.sendImageFlaggedEmail(id, userId, comment)
                def json = [message: "Record ${id} was flagged"]
                render(status: 200, text: "${json as JSON}")
            }
        } else {
            render(status: 400, text: "Record ID not provided")
        }
    }

    def unflagRecord(String id) {
        if (id && authService.userInRole("${grailsApplication.config.security.cas.adminRole}")) {
            def url = grailsApplication.config.ecodata.service.url + "//record"
            def jsonBody = [
                    offensiveFlag: 'false', // NOTE: ecodata won't accept a Boolean value of false or zero, etc
                    offensiveReason: "Unflagged by ${grailsApplication.config.security.cas.adminRole}"
            ]
            def result = webserviceService.doJsonPost("${url}/${id}", (jsonBody as JSON).toString())
            log.debug "unflagRecord: result = ${result} || json = ${jsonBody as JSON}"
            if (result.error) {
                render(status: 400, text: result.text?:'Unexpected error')
            } else {
                def json = [message: "Record (${id}) was UN-flagged by admin"]
                render(status: 200, text: "${json as JSON}")
            }
        } else if (id) {
            render(status: 401, text: "User not authorised to access this resource - requires role: ${grailsApplication.config.security.cas.adminRole}")
        } else {
            render(status: 400, text: "Record ID not provided")
        }
    }
}