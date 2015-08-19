/*
 * Copyright (C) 2015 Atlas of Living Australia
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
import grails.converters.JSON

class TaxonOverflowService {
    static transactional = false

    def grailsApplication, webserviceService

    def createQuestion(Question question) {
        def url =  "${grailsApplication.config.taxonoverflow?.baseURL}/ws/question"
        def postBody = [
                source: "ecodata",
                occurrenceId: question.occurrenceId,
                questionType: question.questionType,
                userId: question.userId,
                tags: question.tags?:[],
                comment:question.comment
        ]

        Map response = webserviceService.doJsonPost(url.toString(), (postBody as JSON).toString())
        log.debug "question response = ${response}"
        response
    }

    def bulkLookup(List uuids) {
        def url =  "${grailsApplication.config.taxonoverflow?.baseURL}/ws/question/bulkLookup"
        def response = webserviceService.doJsonPost(url.toString(), (uuids as JSON).toString())
        log.debug "bulkLookup response = ${response}"
        response
    }
}
