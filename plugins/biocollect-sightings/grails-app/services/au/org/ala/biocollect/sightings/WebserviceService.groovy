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

import grails.converters.JSON
import groovyx.net.http.ContentType
import groovyx.net.http.HTTPBuilder

class WebserviceService {

    static transactional = false

    def grailsApplication, mailService

    /**
     * HTTP Post with JSON body.
     *
     * @param url
     * @param postBody
     * @param requestHeaders
     * @return
     */
    def doJsonPost(String url, String postBody, Map requestHeaders = [:]) {
        log.debug "url = ${url} "
        log.debug "postBody = ${postBody} "
        def http = new HTTPBuilder(url)
        http.request( groovyx.net.http.Method.POST, groovyx.net.http.ContentType.JSON ) {
            body = postBody
            requestContentType = ContentType.JSON

            // add possible headers
            requestHeaders.each { key, value ->
                headers."${key}" = "${value}"
            }

            response.success = { resp, json ->
                log.debug "json = " + json
                log.debug "resp = ${resp}"
                log.debug "json is a ${json.getClass().name}"
                return json
            }

            response.failure = { resp ->
                def error = [error: "Unexpected error: ${resp.statusLine.statusCode} : ${resp.statusLine.reasonPhrase}", status: resp.statusLine.statusCode]
                log.error "Oops: ${error.error} for ${url}"
                return error
            }
        }
    }

    def doDelete(String url, Map requestHeaders = [:]) {
        log.debug "url = ${url} "
        def http = new HTTPBuilder(url)
        http.request( groovyx.net.http.Method.DELETE ) {
            // add possible headers
            requestHeaders.each { key, value ->
                headers."${key}" = "${value}"
            }
            response.success = { resp, json ->
                log.debug "json = " + json
                log.debug "resp = ${resp}"
                log.debug "json is a ${json.getClass().name}"
                return json
            }
            response.failure = { resp ->
                def error = [error: "Unexpected error: ${resp.statusLine.statusCode} : ${resp.statusLine.reasonPhrase}", status: resp.statusLine.statusCode]
                log.error "Oops: " + error.error
                return error
            }
        }
    }

    /**
     * Send an "image flagged as inappropriate" email
     * @param recordId
     * @param userId
     * @param comment
     * @return
     */
    def sendImageFlaggedEmail(String recordId, String userId, String comment) {
        if (grailsApplication.config.grails.mail?.host && !grailsApplication.config.grails.mail?.disabled) {

            mailService.sendMail {
                // to and from defaults set in config.groovy
                subject "Sighting image flagged as INAPPROPRIATE"
                text "Sighting (${recordId}) was flagged as inappropriate by userId: ${userId}\n\nURL: ${grailsApplication.config.ecodata.service.url}/record/${recordId}\n\nReason: ${comment}"
            }
        }
    }

    /**
     * HTTP form POST
     *
     * @param url
     * @param postBody
     * @return
     */
    def doPost(String url, Map postBody) {
        def conn = null
        def charEncoding = 'utf-8'
        try {
            conn = new URL(url).openConnection()
            conn.setDoOutput(true)
            conn.setRequestProperty("Content-Type", "application/json;charset=${charEncoding}");
            OutputStreamWriter wr = new OutputStreamWriter(conn.getOutputStream(), charEncoding)
            wr.write((postBody as JSON).toString())
            wr.flush()
            def resp = conn.inputStream.text
            wr.close()
            return [resp: JSON.parse(resp?:"{}")] // fail over to empty json object if empty response string otherwise JSON.parse fails
        } catch (SocketTimeoutException e) {
            def error = [error: "Timed out calling web service. URL= ${url}."]
            log.error(error, e)
            return error
        } catch (Exception e) {
            def error = [error: "Failed calling web service. ${e.getMessage()} URL= ${url}.",
                         statusCode: conn?.responseCode?:"",
                         detail: conn?.errorStream?.text]
            log.error(error, e)
            return error
        }
    }

    def doPostWithParams(String url, Map params) {
        def conn = null
        def charEncoding = 'utf-8'
        try {
            String query = ""
            boolean first = true
            for (String name:params.keySet()) {
                query += first?"?":"&"
                first = false
                query += name.encodeAsURL()+"="+params.get(name).encodeAsURL()
            }
            conn = new URL(url+query).openConnection()
            conn.setRequestMethod("POST")
            conn.setDoOutput(true)
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

            OutputStreamWriter wr = new OutputStreamWriter(conn.getOutputStream(), charEncoding)

            wr.flush()
            def resp = conn.inputStream.text
            wr.close()
            return [resp: JSON.parse(resp?:"{}")] // fail over to empty json object if empty response string otherwise JSON.parse fails
        } catch (SocketTimeoutException e) {
            def error = [error: "Timed out calling web service. URL= ${url}."]
            log.error(error, e)
            return error
        } catch (Exception e) {
            def error = [error: "Failed calling web service. ${e.getMessage()} URL= ${url}.",
                         statusCode: conn?.responseCode?:"",
                         detail: conn?.errorStream?.text]
            log.error(error, e)
            return error
        }
    }

    def getJson(String url, Integer timeout = null) {
        def conn = null
        try {
            conn = new URL(url).openConnection()
            def json = conn.content.getText('UTF-8')
            return JSON.parse(json)
        } catch (SocketTimeoutException e) {
            def error = [error: "Timed out getting json. URL= ${url}."]
            println error
            return error
        } catch (ConnectException ce) {
            log.info "Exception class = ${ce.getClass().name} - ${ce.getMessage()}"
            def error = [error: "ecodata service not available. URL= ${url}."]
            println error
            return error
        } catch (Exception e) {
            log.info "Exception class = ${e.getClass().name} - ${e.getMessage()}"
            def error = [error: "Failed to get json from web service. ${e.getClass()} ${e.getMessage()} URL= ${url}.",
                         statusCode: conn?.responseCode?:"",
                         detail: conn?.errorStream?.text]
            log.error error
            return error
        }
    }
}
